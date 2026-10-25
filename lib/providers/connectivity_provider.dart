import 'dart:async';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';

import '../constants/app_constants.dart';
import '../main.dart';

/// Monitors real internet connectivity by combining [connectivity_plus]
/// network-change events with actual HTTP pings to [ConnectivityConfig.pingUrl].
///
/// States:
/// - [isOnline]  – true only after a successful ping.
/// - [isChecking] – true while a re-validation ping is in-flight (used by
///   the UI to show a "Reconnecting…" indicator).
class ConnectivityProvider extends ChangeNotifier {
  ConnectivityProvider() {
    _init();
  }

  final Connectivity _connectivity = Connectivity();

  bool _isOnline = true; // optimistic initial state
  bool _isChecking = false;

  StreamSubscription<List<ConnectivityResult>>? _networkSub;
  Timer? _periodicTimer;

  bool get isOnline => _isOnline;
  bool get isChecking => _isChecking;

  // ------------------------------------------------------------------
  // Lifecycle
  // ------------------------------------------------------------------

  void _init() {
    // 1. Run an immediate check on startup.
    _performPing();

    // 2. Listen for network-change events from the OS.
    _networkSub = _connectivity.onConnectivityChanged.listen(_onNetworkChange);

    // 3. Periodic background check as a safety net (handles captive portals,
    //    proxy drops, etc. that connectivity_plus can't detect).
    _periodicTimer = Timer.periodic(
      ConnectivityConfig.checkInterval,
      (_) => _performPing(),
    );
  }

  @override
  void dispose() {
    _networkSub?.cancel();
    _periodicTimer?.cancel();
    super.dispose();
  }

  // ------------------------------------------------------------------
  // Network-change handler
  // ------------------------------------------------------------------

  Future<void> _onNetworkChange(List<ConnectivityResult> results) async {
    final hasNetwork = results.any((r) => r != ConnectivityResult.none);

    talker?.debug(
      'ConnectivityProvider: network change → $results (hasNetwork=$hasNetwork)',
    );

    if (!hasNetwork) {
      // The OS says we have no interface – mark offline immediately.
      _setOnline(false);
      return;
    }

    // The OS says an interface is available, but that doesn't guarantee
    // real internet access. Run a ping to confirm.
    await _revalidate();
  }

  // ------------------------------------------------------------------
  // Ping logic
  // ------------------------------------------------------------------

  /// Single ping. Returns `true` if the device can reach the internet.
  ///
  /// Tries an HTTP GET to the configured ping URL first. If that fails,
  /// falls back to a raw DNS lookup as a last resort.
  Future<bool> _ping() async {
    // Attempt 1: HTTP ping (most reliable – detects captive portals).
    try {
      final client = HttpClient();
      client.connectionTimeout = ConnectivityConfig.pingTimeout;

      final request = await client.getUrl(
        Uri.parse(ConnectivityConfig.pingUrl),
      );
      final response = await request.close().timeout(
        ConnectivityConfig.pingTimeout,
      );

      await response.drain<void>();
      client.close();

      // Accept any successful response (some proxies/networks return 200
      // instead of 204).
      final code = response.statusCode;
      if (code >= 200 && code < 400) return true;
    } catch (e) {
      talker?.debug('ConnectivityProvider: HTTP ping failed → $e');
    }

    // Attempt 2: DNS lookup fallback.
    try {
      final result = await InternetAddress.lookup(
        'google.com',
      ).timeout(ConnectivityConfig.pingTimeout);
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } catch (e) {
      talker?.debug('ConnectivityProvider: DNS lookup failed → $e');
      return false;
    }
  }

  /// Fire a single ping and update state accordingly.
  Future<void> _performPing() async {
    final result = await _ping();
    _setOnline(result);
  }

  /// Re-validation: when the OS reports the network came back, wait a short
  /// moment, then ping **twice** to make sure the connection is truly stable
  /// before re-enabling the UI.
  Future<void> _revalidate() async {
    _setChecking(true);

    // Small grace period – newly-connected interfaces sometimes need a moment.
    await Future<void>.delayed(ConnectivityConfig.revalidationDelay);

    final firstPing = await _ping();
    if (!firstPing) {
      talker?.debug('ConnectivityProvider: re-validation ping 1 failed');
      _setOnline(false);
      _setChecking(false);
      return;
    }

    // Second ping after a short pause to confirm stability.
    await Future<void>.delayed(const Duration(seconds: 1));
    final secondPing = await _ping();

    talker?.debug(
      'ConnectivityProvider: re-validation result → ping1=$firstPing, ping2=$secondPing',
    );

    _setOnline(secondPing);
    _setChecking(false);
  }

  // ------------------------------------------------------------------
  // State helpers
  // ------------------------------------------------------------------

  void _setOnline(bool value) {
    if (_isOnline == value) return;
    _isOnline = value;
    talker?.info('ConnectivityProvider: ${_isOnline ? "ONLINE" : "OFFLINE"}');
    notifyListeners();
  }

  void _setChecking(bool value) {
    if (_isChecking == value) return;
    _isChecking = value;
    notifyListeners();
  }
}
