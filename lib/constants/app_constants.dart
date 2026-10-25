import 'package:flutter/material.dart';

/// App-wide constants for consistent configuration

/// Navigation routes
class AppRoutes {
  static const String home = '/home';
  static const String mesh = '/mesh';
  static const String settings = '/settings';
  static const String talker = '/talker';
}

/// SharedPreferences keys
class PrefKeys {
  static const String isDarkMode = 'is_dark_mode';
  static const String animationEnabled = 'animation_enabled';
}

/// Animation durations
class AppDurations {
  static const veryShort = Duration(milliseconds: 100);
  static const short = Duration(milliseconds: 200);
  static const medium = Duration(milliseconds: 400);
  static const long = Duration(milliseconds: 600);
  static const exitWarning = Duration(seconds: 2);
}

/// Spacing
class Spacing {
  static const xs = 4.0;
  static const sm = 8.0;
  static const md = 16.0;
  static const lg = 24.0;
  static const xl = 32.0;
}

/// Border radius
class BorderRadiusRadius {
  static const small = 4.0;
  static const medium = 8.0;
  static const large = 12.0;
  static const xl = 16.0;
}

/// Icon sizes
class IconSizes {
  static const small = 16.0;
  static const medium = 24.0;
  static const large = 32.0;
}

/// Toast configuration
class ToastConfig {
  static const autoCloseDuration = Duration(seconds: 2);
  static const margin = EdgeInsets.all(Spacing.md);
}

/// NavigationRail configuration
class NavRailConfig {
  static const railWidth = 72.0;
  static const expandedWidth = 200.0;
  static const iconSize = 24.0;
}

/// App info
class AppInfo {
  static const String name = 'Teapot';
  static const String version = '1.0.0';
}

/// Layout constraints
class LayoutConstraints {
  static const double minHomeHeightRatio = 0.6;
}

/// Connectivity check configuration
class ConnectivityConfig {
  /// URL to ping for real internet validation (returns 204 No Content).
  /// Uses Google's official connectivity-check endpoint.
  static const String pingUrl =
      'https://connectivitycheck.gstatic.com/generate_204';

  /// Timeout for each ping request
  static const Duration pingTimeout = Duration(seconds: 5);

  /// Interval between periodic connectivity checks
  static const Duration checkInterval = Duration(seconds: 15);

  /// Delay before re-validation when network reports back online
  static const Duration revalidationDelay = Duration(seconds: 2);
}
