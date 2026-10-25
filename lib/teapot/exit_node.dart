// Exit node: accepts proxy streams from allowed peers and dials the internet
// from this phone, so targets see the phone's (SIM) IP. Same behaviour as
// teapot-core/src/exit.rs.

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:iroh_flutter/iroh_flutter.dart';

import 'lan_guard.dart';
import 'protocol.dart';

/// Per-peer view for the status report and the UI.
class PeerLink {
  String kind = 'relay'; // relay until a PathSelected says otherwise
  String? remoteAddr;
  int tx = 0; // bytes sent to the peer (target → peer)
  int rx = 0; // bytes received from the peer (peer → target)
  int openStreams = 0;
  bool connected = false;
}

class ExitNode {
  ExitNode(this.endpoint, {this.allowLan = false, void Function(String)? log})
    : _log = log ?? ((_) {});

  final Endpoint endpoint;
  final bool allowLan;
  final void Function(String) _log;

  /// Hex endpoint ids allowed to use this exit; replaced by [setAllowed].
  Set<String> _allowed = {};
  final Map<String, Connection> _conns = {};
  final Map<String, PeerLink> links = {};

  /// Applies a new allowlist and drops clients that are no longer on it.
  void setAllowed(Set<String> allowed) {
    _allowed = allowed;
    for (final entry in _conns.entries.toList()) {
      if (!_allowed.contains(entry.key)) {
        _log('${_short(entry.key)} removed from allowlist; disconnecting');
        entry.value.close(errorCode: 1, reason: utf8.encode('not allowed'));
      }
    }
  }

  Future<void> run() async {
    while (true) {
      final Connection? conn;
      try {
        conn = await endpoint.accept();
      } catch (e) {
        _log('accept: $e');
        continue;
      }
      if (conn == null) return; // endpoint closed
      unawaited(_serve(conn));
    }
  }

  Future<void> _serve(Connection conn) async {
    final peer = conn.remoteId.toHex();
    if (!_allowed.contains(peer)) {
      _log('rejected ${_short(peer)}: not in allowlist');
      conn.close(errorCode: 1, reason: utf8.encode('not allowed'));
      return;
    }
    final link = links.putIfAbsent(peer, PeerLink.new)..connected = true;
    _conns[peer] = conn;
    _log('client ${_short(peer)} connected');
    final paths = conn.pathEvents().listen((e) {
      if (e is PathSelected) {
        link.remoteAddr = e.remoteAddr;
        link.kind = e.remoteAddr.contains('Relay') ? 'relay' : 'direct';
      }
    });
    try {
      while (true) {
        final (send, recv) = await conn.acceptBi();
        unawaited(_stream(send, recv, link, peer));
      }
    } catch (e) {
      _log('client ${_short(peer)} disconnected');
    } finally {
      await paths.cancel();
      link.connected = false;
      if (identical(_conns[peer], conn)) _conns.remove(peer);
    }
  }

  Future<void> _stream(
    SendStream send,
    RecvStream recv,
    PeerLink link,
    String peer,
  ) async {
    link.openStreams++;
    Socket? socket;
    try {
      final reader = LineReader(recv);
      final req = ConnectRequest.parse(await reader.readLine());
      try {
        socket = await dialGuarded(req.host, req.port, allowLan: allowLan);
      } catch (e) {
        _log('dial refused ${req.target}: $e');
        await send.writeAll(encodeErr(e.toString()));
        await send.finish();
        return;
      }
      await send.writeAll(encodeOk());

      // target → peer
      final down = Completer<void>();
      final sub = socket.listen(
        null,
        onDone: () => down.isCompleted ? null : down.complete(),
        onError: (Object _) => down.isCompleted ? null : down.complete(),
        cancelOnError: true,
      );
      sub.onData((data) {
        sub.pause();
        link.tx += data.length;
        send
            .writeAll(data)
            .then(
              (_) => sub.resume(),
              onError: (Object _) {
                if (!down.isCompleted) down.complete();
              },
            );
      });

      // peer → target
      Future<void> up() async {
        final s = socket!;
        if (reader.leftover.isNotEmpty) {
          link.rx += reader.leftover.length;
          s.add(reader.leftover);
        }
        while (true) {
          final chunk = await recv.read(64 * 1024);
          if (chunk == null) break;
          link.rx += chunk.length;
          s.add(chunk);
          await s.flush();
        }
        await s.close(); // half-close: target sees EOF, can still answer
      }

      await Future.wait([up().catchError((Object _) {}), down.future]);
      await sub.cancel();
      await send.finish().catchError((Object _) {});
    } catch (e) {
      _log('stream ${_short(peer)}: $e');
    } finally {
      socket?.destroy();
      link.openStreams--;
    }
  }

  static String _short(String id) => id.length > 8 ? id.substring(0, 8) : id;
}
