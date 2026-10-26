// The agent that runs inside the foreground service: joins control, keeps
// presence up, syncs the exit allowlist, and serves as an exit node.
// The UI only ever sees [snapshot]s.

import 'dart:async';
import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:iroh_flutter/iroh_flutter.dart';

import 'control_client.dart';
import 'exit_node.dart';
import 'key_store.dart';
import 'lan_guard.dart';
import 'protocol.dart';
import 'settings.dart';

class TeapotAgent {
  TeapotAgent(this.settings, this._emit);

  final TeapotSettings settings;
  final void Function(Map<String, Object?> snapshot) _emit;

  final _stop = Completer<void>();
  Endpoint? _endpoint;
  ControlClient? _control;
  ExitNode? _exit;

  String phase = 'starting'; // starting | pending | approved | error
  String? error;
  bool presence = false;
  DateTime? presenceSince;
  bool exitEnabled = false;
  int allowed = 0;
  Map<String, String> _names = {};
  List<Peer> _peers = [];

  /// From the phone: the "Device name" in Android settings, and brand + model.
  String? _deviceName;
  String? _model;
  final List<String> _log = [];

  /// Settings override, else the phone's own device name, else `android-<id>`.
  /// The owner can still give it an alias in the dashboard.
  String get name {
    if (settings.deviceName.isNotEmpty) return settings.deviceName;
    if (_deviceName != null && _deviceName!.isNotEmpty) return _deviceName!;
    return 'android-${_control?.nodeId.substring(0, 6) ?? ''}';
  }

  Future<void> start() async {
    try {
      final info = await DeviceInfoPlugin().androidInfo;
      _model = '${info.manufacturer} ${info.model}'.trim();
      _deviceName = info.name.trim().isNotEmpty ? info.name.trim() : _model;
    } catch (e) {
      log('device info: $e');
    }
    try {
      await Iroh.init();
      final key = await KeyStore().loadOrCreate();
      _endpoint = await Endpoint.bind(secretKey: key, alpns: [alpnProxy]);
      _control = ControlClient(settings.controlUrl, key);
      _exit = ExitNode(_endpoint!, allowLan: settings.allowLan, log: log);
      unawaited(_exit!.run());
      log('endpoint up: ${_control!.nodeId.substring(0, 8)}');
    } catch (e) {
      _fail('start: $e');
      return;
    }
    unawaited(_joinAndSync());
    unawaited(
      _control!.runPresence(
        _report,
        _stop.future,
        onState: (on) {
          if (on && !presence) {
            presenceSince = DateTime.now();
            log('presence connected');
          } else if (!on && presence) {
            log('presence lost');
          }
          presence = on;
          push();
        },
        log: log,
      ),
    );
  }

  Future<void> stop() async {
    if (!_stop.isCompleted) _stop.complete();
    await _endpoint?.close();
  }

  /// Logs in (retrying while offline), registers as an exit-capable device,
  /// then keeps the allowlist and peer names current.
  Future<void> _joinAndSync() async {
    final control = _control!;
    while (!_stop.isCompleted) {
      try {
        final status = await control.login();
        await control.updateMe(
          name: name,
          platform: 'android',
          model: _model,
          canExit: true,
        );
        phase = status == 'approved' ? 'approved' : 'pending';
        error = null;
        log('logged in to control ($phase)');
        push();
        break;
      } catch (e) {
        _fail('login: $e');
        await Future.any([
          Future.delayed(const Duration(seconds: 10)),
          _stop.future,
        ]);
      }
    }
    final changes = control.changed.listen((_) => _sync());
    final timer = Timer.periodic(const Duration(seconds: 30), (_) => _sync());
    await _sync();
    await _stop.future;
    timer.cancel();
    await changes.cancel();
  }

  Future<void> _sync() async {
    final control = _control!;
    try {
      final list = await control.allowlist();
      if (exitEnabled != list.exitEnabled) {
        log(
          list.exitEnabled
              ? 'exit is enabled in the dashboard'
              : 'exit is off in the dashboard',
        );
      }
      exitEnabled = list.exitEnabled;
      allowed = list.allow.length;
      _exit!.setAllowed(list.allow);
      _peers = await control.peers();
      _names = {for (final p in _peers) p.nodeId: p.label};
      phase = 'approved';
      error = null;
    } on ApiException catch (e) {
      if (e.isPending) {
        phase = 'pending';
      } else {
        error = e.toString();
      }
    } catch (e) {
      error = 'sync: $e';
    }
    push();
  }

  (String?, String?) _publicIps() {
    String? v4, v6;
    for (final hostPort in _endpoint?.addr.ipAddrs ?? const <String>[]) {
      final host = hostPort.startsWith('[')
          ? hostPort.substring(1, hostPort.indexOf(']'))
          : hostPort.substring(0, hostPort.lastIndexOf(':'));
      final ip = InternetAddress.tryParse(host);
      if (ip == null || isLocal(ip)) continue;
      if (ip.type == InternetAddressType.IPv4) {
        v4 ??= ip.address;
      } else {
        v6 ??= ip.address;
      }
    }
    return (v4, v6);
  }

  StatusReport _report() {
    final (v4, v6) = _publicIps();
    final links = _exit?.links ?? const <String, PeerLink>{};
    return StatusReport(
      paths: [
        for (final e in links.entries)
          if (e.value.connected)
            {'peer': e.key, 'kind': e.value.kind, 'rtt_ms': -1},
      ],
      traffic: [
        for (final e in links.entries)
          if (e.value.tx > 0 || e.value.rx > 0)
            {'peer': e.key, 'tx': e.value.tx, 'rx': e.value.rx},
      ],
      ipv4: v4,
      ipv6: v6,
    );
  }

  void push() => _emit(snapshot());

  Map<String, Object?> snapshot() {
    final (v4, v6) = _publicIps();
    return {
      'phase': phase,
      'error': error,
      'node_id': _control?.nodeId,
      'name': name,
      'model': _model,
      'control': settings.controlUrl,
      'approve_url': _control?.approveUrl,
      'presence': presence,
      'presence_since': presenceSince?.toIso8601String().substring(11, 19),
      'exit_enabled': exitEnabled,
      'allowed': allowed,
      'allow_lan': settings.allowLan,
      'ipv4': v4,
      'ipv6': v6,
      'clients': [
        for (final e in (_exit?.links ?? const <String, PeerLink>{}).entries)
          {
            'peer': e.key,
            'name': _names[e.key] ?? e.key.substring(0, 8),
            'connected': e.value.connected,
            'kind': e.value.kind,
            'streams': e.value.openStreams,
            'tx': e.value.tx,
            'rx': e.value.rx,
            'targets': [
              for (final t in e.value.targets) Map<String, Object>.of(t),
            ],
          },
      ],
      'peers': [
        for (final p in _peers)
          {
            'node_id': p.nodeId,
            'name': p.label,
            'platform': p.platform,
            'online': p.online,
            'exit': p.exit,
            'ipv4': p.publicIpv4,
            'using_me': _exit?.links[p.nodeId]?.connected ?? false,
          },
      ],
      'log': List<String>.of(_log),
    };
  }

  void log(String line) {
    final t = DateTime.now().toIso8601String().substring(11, 19);
    _log.add('$t $line');
    if (_log.length > 80) _log.removeAt(0);
  }

  void _fail(String message) {
    phase = phase == 'starting' ? 'error' : phase;
    error = message;
    log(message);
    push();
  }
}
