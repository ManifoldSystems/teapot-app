import 'package:shared_preferences/shared_preferences.dart';

/// User-editable agent settings. Read by the foreground service on start,
/// written by the settings screen (which then restarts the service).
class TeapotSettings {
  TeapotSettings({
    required this.controlUrl,
    required this.deviceName,
    required this.allowLan,
  });

  static const defaultControl = 'https://teapot.example.com';
  static const _kControl = 'teapot.control_url';
  static const _kName = 'teapot.device_name';
  static const _kLan = 'teapot.allow_lan';

  final String controlUrl;

  /// Empty means "derive from the node id" (android-xxxxxx).
  final String deviceName;
  final bool allowLan;

  static Future<TeapotSettings> load() async {
    final p = await SharedPreferences.getInstance();
    return TeapotSettings(
      controlUrl: p.getString(_kControl) ?? defaultControl,
      deviceName: p.getString(_kName) ?? '',
      allowLan: p.getBool(_kLan) ?? false,
    );
  }

  Future<void> save() async {
    final p = await SharedPreferences.getInstance();
    await p.setString(_kControl, controlUrl);
    await p.setString(_kName, deviceName);
    await p.setBool(_kLan, allowLan);
  }
}
