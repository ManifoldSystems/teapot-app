// Client for teapot-control: signature login, device API, presence socket.
// Mirrors teapot-core/src/control.rs; wire format in teapot docs/protocol.md.

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:iroh_flutter/iroh_flutter.dart';
import 'package:web_socket_channel/io.dart';

/// Cloudflare rejects library-default user agents (error 1010).
const userAgent = 'teapot-android/1.0.0';

class ApiException implements Exception {
  ApiException(this.status, this.code, this.message);
  final int status;
  final String code;
  final String message;
  bool get isPending => code == 'PENDING';
  @override
  String toString() => 'control: $message ($status $code)';
}

class Peer {
  Peer.fromJson(Map<String, dynamic> j)
    : nodeId = j['node_id'] as String,
      name = j['name'] as String?,
      platform = j['platform'] as String?,
      online = j['online'] == true,
      exit = j['exit'] == true,
      publicIpv4 = j['public_ipv4'] as String?;
  final String nodeId;
  final String? name;
  final String? platform;
  final String? publicIpv4;
  final bool online;
  final bool exit;
  String get label => name ?? nodeId.substring(0, 8);
}

class Allowlist {
  Allowlist(this.exitEnabled, this.allow);
  final bool exitEnabled;
  final Set<String> allow;
}

/// Path (direct/relay) and tunnel bytes per peer, plus public addresses —
/// the presence status message.
class StatusReport {
  StatusReport({
    required this.paths,
    required this.traffic,
    this.ipv4,
    this.ipv6,
  });
  final List<Map<String, Object>> paths;
  final List<Map<String, Object>> traffic;
  final String? ipv4;
  final String? ipv6;

  String encode() => jsonEncode({
    'type': 'status',
    'paths': paths,
    'traffic': traffic,
    'ips': {if (ipv4 != null) 'v4': ipv4, if (ipv6 != null) 'v6': ipv6},
  });
}

class ControlClient {
  ControlClient(String base, this._key)
    : base = base.replaceAll(RegExp(r'/+$'), ''),
      _http = Dio(
        BaseOptions(
          headers: {'user-agent': userAgent},
          connectTimeout: const Duration(seconds: 15),
          receiveTimeout: const Duration(seconds: 20),
          validateStatus: (_) => true,
        ),
      );

  final String base;
  final SecretKey _key;
  final Dio _http;
  String? _token;

  /// Fires on `peers_changed` and on every presence (re)connect.
  final _changed = StreamController<void>.broadcast();
  Stream<void> get changed => _changed.stream;

  String get nodeId => _key.publicKey.toHex();
  String get approveUrl => '$base/approve/$nodeId';

  /// Proves we hold the key behind our node id; returns pending/approved.
  Future<String> login() async {
    final ch = await _call(
      'POST',
      '/v1/auth/challenge',
      body: {'node_id': nodeId},
      auth: false,
    );
    final challenge = ch['challenge'] as String;
    final sig = _key.sign(utf8.encode(challenge)).toBytes();
    final signature = sig
        .map((b) => b.toRadixString(16).padLeft(2, '0'))
        .join();
    final v = await _call(
      'POST',
      '/v1/auth/verify',
      body: {'node_id': nodeId, 'challenge': challenge, 'signature': signature},
      auth: false,
    );
    _token = v['token'] as String;
    return v['status'] as String;
  }

  Future<Map<String, dynamic>> me() async =>
      await _call('GET', '/v1/devices/me') as Map<String, dynamic>;

  Future<void> updateMe({String? name, String? platform, bool? canExit}) =>
      _call(
        'PUT',
        '/v1/devices/me',
        body: {
          if (name != null) 'name': name,
          if (platform != null) 'platform': platform,
          if (canExit != null) 'can_exit': canExit,
        },
      );

  Future<List<Peer>> peers() async {
    final data = await _call('GET', '/v1/peers') as List;
    return data.map((p) => Peer.fromJson(p as Map<String, dynamic>)).toList();
  }

  Future<Allowlist> allowlist() async {
    final d = await _call('GET', '/v1/exit/allowlist') as Map<String, dynamic>;
    return Allowlist(
      d['exit_enabled'] == true,
      (d['allow'] as List).cast<String>().toSet(),
    );
  }

  /// Authenticated call; on 401 logs in again once (expired token, or the
  /// device was removed and has to re-register).
  Future<dynamic> _call(
    String method,
    String path, {
    Object? body,
    bool auth = true,
  }) async {
    for (var attempt = 0; attempt < 2; attempt++) {
      if (auth && _token == null) await login();
      final res = await _http.request<dynamic>(
        '$base$path',
        data: body,
        options: Options(
          method: method,
          headers: {if (auth) 'authorization': 'Bearer $_token'},
        ),
      );
      if (auth && res.statusCode == 401 && attempt == 0) {
        _token = null;
        continue;
      }
      final j = res.data is Map ? res.data as Map : const {};
      if (j['success'] == true) return j['data'];
      throw ApiException(
        res.statusCode ?? 0,
        (j['error'] ?? 'BAD_RESPONSE').toString(),
        (j['message'] ?? 'request failed').toString(),
      );
    }
    throw StateError('unreachable');
  }

  /// Keeps the presence socket up until [stop] completes; [report] builds the
  /// status sent every 5 s (only when it changed, or every 60 s).
  Future<void> runPresence(
    StatusReport Function() report,
    Future<void> stop, {
    void Function(bool online)? onState,
    void Function(String)? log,
  }) async {
    var backoff = const Duration(seconds: 1);
    var stopped = false;
    unawaited(stop.then((_) => stopped = true));
    while (!stopped) {
      final started = DateTime.now();
      try {
        await _presenceOnce(report, stop, onState);
      } catch (e) {
        log?.call('presence: $e');
      }
      onState?.call(false);
      if (stopped) break;
      if (DateTime.now().difference(started) > const Duration(seconds: 30)) {
        backoff = const Duration(seconds: 1);
      }
      await Future.any([Future.delayed(backoff), stop]);
      backoff = backoff * 2 > const Duration(seconds: 60)
          ? const Duration(seconds: 60)
          : backoff * 2;
    }
  }

  Future<void> _presenceOnce(
    StatusReport Function() report,
    Future<void> stop,
    void Function(bool)? onState,
  ) async {
    if (_token == null) await login();
    final uri = Uri.parse(
      '${base.replaceFirst('https://', 'wss://').replaceFirst('http://', 'ws://')}/v1/presence',
    );
    final IOWebSocketChannel ws;
    try {
      ws = IOWebSocketChannel.connect(
        uri,
        headers: {'authorization': 'Bearer $_token', 'user-agent': userAgent},
      );
      await ws.ready;
    } on WebSocketException catch (e) {
      if (e.message.contains('401')) _token = null;
      rethrow;
    }
    onState?.call(true);
    _changed.add(null);

    String? lastSent;
    var lastSentAt = DateTime.fromMillisecondsSinceEpoch(0);
    final ping = Timer.periodic(
      const Duration(seconds: 20),
      (_) => ws.sink.add('ping'),
    );
    final status = Timer.periodic(const Duration(seconds: 5), (_) {
      final msg = report().encode();
      if (msg != lastSent ||
          DateTime.now().difference(lastSentAt) > const Duration(seconds: 60)) {
        ws.sink.add(msg);
        lastSent = msg;
        lastSentAt = DateTime.now();
      }
    });
    final done = Completer<void>();
    final sub = ws.stream.listen(
      (m) {
        if (m is String && m.contains('"peers_changed"')) _changed.add(null);
      },
      onDone: () => done.isCompleted ? null : done.complete(),
      onError: (Object e) => done.isCompleted ? null : done.completeError(e),
    );
    try {
      await Future.any([done.future, stop]);
    } finally {
      ping.cancel();
      status.cancel();
      await sub.cancel();
      await ws.sink.close();
    }
  }
}
