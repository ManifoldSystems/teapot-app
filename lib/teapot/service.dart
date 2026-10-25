// Foreground-service glue. The agent lives in the service's isolate so it
// keeps running with the UI closed and after reboot; the UI talks to it via
// flutter_foreground_task's data channel.

import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';

import 'agent.dart';
import 'settings.dart';

@pragma('vm:entry-point')
void startTeapotTask() =>
    FlutterForegroundTask.setTaskHandler(TeapotTaskHandler());

class TeapotTaskHandler extends TaskHandler {
  TeapotAgent? _agent;
  String _lastNotification = '';

  @override
  Future<void> onStart(DateTime timestamp, TaskStarter starter) async {
    final settings = await TeapotSettings.load();
    _agent = TeapotAgent(settings, _onSnapshot);
    await _agent!.start();
  }

  void _onSnapshot(Map<String, Object?> snap) {
    FlutterForegroundTask.sendDataToMain(snap);
    final clients = (snap['clients'] as List)
        .where((c) => (c as Map)['connected'] == true)
        .length;
    final text = switch (snap['phase']) {
      'pending' => 'Waiting for approval',
      'error' => 'Error: ${snap['error']}',
      _ when snap['exit_enabled'] != true => 'Online · exit off in dashboard',
      _ =>
        'Exit node · $clients client${clients == 1 ? '' : 's'} · ${snap['ipv4'] ?? '…'}',
    };
    if (text != _lastNotification) {
      _lastNotification = text;
      FlutterForegroundTask.updateService(
        notificationTitle: 'Teapot',
        notificationText: text,
      );
    }
  }

  @override
  void onRepeatEvent(DateTime timestamp) => _agent?.push();

  @override
  Future<void> onDestroy(DateTime timestamp, bool isTimeout) async =>
      _agent?.stop();

  @override
  void onReceiveData(Object data) {
    if (data == 'refresh') _agent?.push();
  }
}

/// UI-side handle: starts/stops the service and exposes the latest snapshot.
class TeapotController extends ChangeNotifier {
  Map<String, Object?> snapshot = const {};
  bool running = false;

  Future<void> init() async {
    FlutterForegroundTask.init(
      androidNotificationOptions: AndroidNotificationOptions(
        channelId: 'teapot',
        channelName: 'Teapot agent',
        channelDescription: 'Shown while Teapot keeps this phone in your mesh.',
        onlyAlertOnce: true,
      ),
      iosNotificationOptions: const IOSNotificationOptions(
        showNotification: false,
        playSound: false,
      ),
      foregroundTaskOptions: ForegroundTaskOptions(
        eventAction: ForegroundTaskEventAction.repeat(2000),
        autoRunOnBoot: true,
        autoRunOnMyPackageReplaced: true,
        allowWakeLock: true,
        allowWifiLock: true,
      ),
    );
    FlutterForegroundTask.addTaskDataCallback(_onData);
    running = await FlutterForegroundTask.isRunningService;
    if (running) FlutterForegroundTask.sendDataToTask('refresh');
    notifyListeners();
  }

  void _onData(Object data) {
    if (data is Map) {
      snapshot = data.cast<String, Object?>();
      notifyListeners();
    }
  }

  Future<void> start() async {
    if (await FlutterForegroundTask.checkNotificationPermission() !=
        NotificationPermission.granted) {
      await FlutterForegroundTask.requestNotificationPermission();
    }
    if (Platform.isAndroid &&
        !await FlutterForegroundTask.isIgnoringBatteryOptimizations) {
      await FlutterForegroundTask.requestIgnoreBatteryOptimization();
    }
    final result = await FlutterForegroundTask.startService(
      serviceTypes: [ForegroundServiceTypes.specialUse],
      serviceId: 7,
      notificationTitle: 'Teapot',
      notificationText: 'Starting…',
      callback: startTeapotTask,
    );
    running = result is ServiceRequestSuccess;
    notifyListeners();
  }

  Future<void> stop() async {
    await FlutterForegroundTask.stopService();
    running = false;
    snapshot = const {};
    notifyListeners();
  }

  /// Settings changed: the service reads them on start.
  Future<void> restart() async {
    if (!running) return;
    await stop();
    await start();
  }

  @override
  void dispose() {
    FlutterForegroundTask.removeTaskDataCallback(_onData);
    super.dispose();
  }
}
