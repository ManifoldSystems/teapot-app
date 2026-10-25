// Wire format shared with the Rust agent. Source of truth:
// ManifoldSystems/teapot docs/protocol.md — change it there first.

import 'dart:convert';
import 'dart:typed_data';

import 'package:iroh_flutter/iroh_flutter.dart';

/// ALPN for device-to-device proxy traffic.
final List<int> alpnProxy = utf8.encode('teapot/proxy/0');

/// Upper bound for a header line, so a peer cannot make us buffer forever.
const int maxLine = 1024;

class ProtoException implements Exception {
  ProtoException(this.message);
  final String message;
  @override
  String toString() => message;
}

/// `CONNECT host:port\n` sent by the client on a new stream.
class ConnectRequest {
  ConnectRequest(this.host, this.port);
  final String host;
  final int port;

  String get target => '$host:$port';

  static ConnectRequest parse(String line) {
    if (!line.startsWith('CONNECT ')) {
      throw ProtoException('malformed header line');
    }
    final target = line.substring(8).trim();
    final colon = target.lastIndexOf(':');
    if (colon <= 0) throw ProtoException('malformed header line');
    var host = target.substring(0, colon);
    final port = int.tryParse(target.substring(colon + 1));
    if (port == null || port < 1 || port > 65535) {
      throw ProtoException('malformed header line');
    }
    if (host.startsWith('[') && host.endsWith(']')) {
      host = host.substring(1, host.length - 1);
    }
    return ConnectRequest(host, port);
  }
}

List<int> encodeOk() => utf8.encode('OK\n');

List<int> encodeErr(String reason) =>
    utf8.encode('ERR ${reason.replaceAll('\n', ' ')}\n');

/// Reads one `\n`-terminated header line from a [RecvStream] and keeps
/// whatever arrived after it, which is payload and must be forwarded.
class LineReader {
  LineReader(this._recv);
  final RecvStream _recv;
  Uint8List leftover = Uint8List(0);

  Future<String> readLine() async {
    final buf = BytesBuilder(copy: false);
    while (true) {
      final chunk = await _recv.read(4096);
      if (chunk == null) {
        throw ProtoException('stream closed before header line');
      }
      final nl = chunk.indexOf(0x0a);
      if (nl >= 0) {
        buf.add(chunk.sublist(0, nl));
        leftover = chunk.sublist(nl + 1);
        final bytes = buf.takeBytes();
        if (bytes.length > maxLine) {
          throw ProtoException('header line too long');
        }
        return utf8.decode(bytes, allowMalformed: false);
      }
      buf.add(chunk);
      if (buf.length > maxLine) throw ProtoException('header line too long');
    }
  }
}
