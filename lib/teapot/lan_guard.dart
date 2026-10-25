import 'dart:io';

/// Addresses on the exit node's own network rather than the internet:
/// loopback, RFC 1918, link-local, CGNAT, ULA, multicast. Mirrors
/// `teapot-core/src/net.rs` so every exit node refuses the same targets.
bool isLocal(InternetAddress address) {
  final b = address.rawAddress;
  if (address.type == InternetAddressType.IPv4) {
    final a0 = b[0], a1 = b[1];
    return a0 == 127 ||
        a0 == 10 ||
        (a0 == 172 && a1 >= 16 && a1 <= 31) ||
        (a0 == 192 && a1 == 168) ||
        (a0 == 169 && a1 == 254) ||
        a0 == 0 ||
        (a0 == 255 && a1 == 255 && b[2] == 255 && b[3] == 255) ||
        (a0 >= 224 && a0 <= 239) ||
        (a0 == 100 && (a1 & 0xc0) == 64);
  }
  // IPv4-mapped ::ffff:a.b.c.d
  final mapped =
      b.sublist(0, 10).every((x) => x == 0) && b[10] == 0xff && b[11] == 0xff;
  if (mapped) return isLocal(InternetAddress.fromRawAddress(b.sublist(12)));
  final loopback = b.sublist(0, 15).every((x) => x == 0) && b[15] == 1;
  final unspecified = b.every((x) => x == 0);
  return loopback ||
      unspecified ||
      b[0] == 0xff || // multicast
      (b[0] & 0xfe) == 0xfc || // fc00::/7
      (b[0] == 0xfe && (b[1] & 0xc0) == 0x80); // fe80::/10
}

/// Resolves [host] on this phone and connects to the first address the
/// policy allows. Checks resolved IPs, not the name: any public name can
/// point at 192.168.x.x.
Future<Socket> dialGuarded(
  String host,
  int port, {
  required bool allowLan,
}) async {
  final addresses = await InternetAddress.lookup(host);
  if (addresses.isEmpty) throw SocketException('$host did not resolve');
  final allowed = addresses.where((a) => allowLan || !isLocal(a)).toList();
  if (allowed.isEmpty) {
    throw SocketException(
      '$host:$port is a local address and allow_lan is off',
    );
  }
  Object? lastError;
  for (final address in allowed) {
    try {
      return await Socket.connect(
        address,
        port,
        timeout: const Duration(seconds: 10),
      );
    } catch (e) {
      lastError = e;
    }
  }
  throw lastError ?? SocketException('could not connect to $host:$port');
}
