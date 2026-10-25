import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:teapot_app/teapot/control_client.dart';
import 'package:teapot_app/teapot/lan_guard.dart';
import 'package:teapot_app/teapot/protocol.dart';

void main() {
  group('ConnectRequest', () {
    test('parses host and port', () {
      final r = ConnectRequest.parse('CONNECT example.com:443');
      expect(r.host, 'example.com');
      expect(r.port, 443);
    });
    test('strips IPv6 brackets', () {
      final r = ConnectRequest.parse('CONNECT [2001:db8::1]:8080');
      expect(r.host, '2001:db8::1');
      expect(r.port, 8080);
    });
    test('rejects malformed lines', () {
      for (final line in [
        'GET example.com:443',
        'CONNECT example.com',
        'CONNECT :443',
        'CONNECT a:99999',
      ]) {
        expect(
          () => ConnectRequest.parse(line),
          throwsA(isA<ProtoException>()),
          reason: line,
        );
      }
    });
  });

  test('replies match the Rust agent byte for byte', () {
    expect(utf8.decode(encodeOk()), 'OK\n');
    expect(utf8.decode(encodeErr('lan\nblocked')), 'ERR lan blocked\n');
    expect(utf8.decode(alpnProxy), 'teapot/proxy/0');
  });

  group('isLocal', () {
    test('local addresses', () {
      for (final s in [
        '127.0.0.1',
        '10.1.2.3',
        '172.16.0.1',
        '192.168.1.1',
        '169.254.1.1',
        '100.64.0.1',
        '0.0.0.0',
        '::1',
        'fd00::1',
        'fe80::1',
        '::ffff:192.168.1.1',
      ]) {
        expect(isLocal(InternetAddress(s)), isTrue, reason: s);
      }
    });
    test('public addresses', () {
      for (final s in [
        '1.1.1.1',
        '8.8.8.8',
        '100.128.0.1',
        '203.0.113.30',
        '2606:4700:4700::1111',
      ]) {
        expect(isLocal(InternetAddress(s)), isFalse, reason: s);
      }
    });
  });

  test('status report carries paths, traffic and ips', () {
    final msg =
        jsonDecode(
              StatusReport(
                paths: [
                  {'peer': 'ab', 'kind': 'direct', 'rtt_ms': -1},
                ],
                traffic: [
                  {'peer': 'ab', 'tx': 10, 'rx': 20},
                ],
                ipv4: '203.0.113.30',
              ).encode(),
            )
            as Map;
    expect(msg['type'], 'status');
    expect(msg['ips'], {'v4': '203.0.113.30'});
    expect((msg['traffic'] as List).single['rx'], 20);
  });
}
