import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:teapot_app/teapot/settings.dart';

void main() {
  test('new installs have no server unless supplied at build time', () async {
    SharedPreferences.setMockInitialValues({});
    final settings = await TeapotSettings.load();
    expect(settings.controlUrl, TeapotSettings.defaultControl);
    expect(
      TeapotSettings.defaultControl,
      const String.fromEnvironment('TEAPOT_CONTROL'),
    );
  });

  test('saved deployment survives a settings reload', () async {
    SharedPreferences.setMockInitialValues({});
    await TeapotSettings(
      controlUrl: 'https://mesh.example.com',
      deviceName: 'phone-exit',
      allowLan: false,
    ).save();
    expect(
      (await TeapotSettings.load()).controlUrl,
      'https://mesh.example.com',
    );
  });

  test(
    'control URL must identify an HTTP server without embedded credentials',
    () {
      for (final url in [
        '',
        'mesh.example.com',
        'file:///tmp/control',
        'https://user:pass@mesh.example.com',
        'https://mesh.example.com?token=x',
        'https://mesh.example.com#fragment',
      ]) {
        expect(TeapotSettings.isValidControlUrl(url), isFalse, reason: url);
      }
      for (final url in ['https://mesh.example.com', 'http://127.0.0.1:8787']) {
        expect(TeapotSettings.isValidControlUrl(url), isTrue, reason: url);
      }
    },
  );
}
