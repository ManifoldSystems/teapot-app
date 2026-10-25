import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:iroh_flutter/iroh_flutter.dart';

/// The device identity: a 32-byte secret key kept in the Android Keystore
/// (via flutter_secure_storage). The endpoint id is its public half, so
/// losing it turns the phone into a new device that needs approval again.
class KeyStore {
  KeyStore([FlutterSecureStorage? storage])
    : _storage = storage ?? const FlutterSecureStorage();

  final FlutterSecureStorage _storage;
  static const _key = 'teapot.secret_key';

  Future<SecretKey> loadOrCreate() async {
    final stored = await _storage.read(key: _key);
    if (stored != null) return SecretKey.fromBytes(base64Decode(stored));
    final secret = SecretKey.generate();
    await _storage.write(key: _key, value: base64Encode(secret.toBytes()));
    return secret;
  }
}
