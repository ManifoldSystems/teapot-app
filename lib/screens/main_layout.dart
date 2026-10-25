import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:responsive_builder/responsive_builder.dart';

import '../constants/app_constants.dart';
import '../main.dart';
import '../models/nav_item.dart';
import '../providers/theme_manager.dart';
import '../utils/toast_helper.dart';
import '../widgets/connection_indicator.dart';
import 'package:teapot_app/l10n/gen/app_localizations.dart';
import 'package:flutter/services.dart';

/// Build navigation destinations for NavigationBar/NavigationRail
List<NavigationDestination> _buildNavDestinations(List<NavItem> navItems) {
  return navItems.map((item) {
    return NavigationDestination(icon: Icon(item.icon), label: item.label);
  }).toList();
}

/// Main layout with responsive navigation
class MainLayout extends StatefulWidget {
  const MainLayout({required this.child, super.key});

  final Widget child;

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> with WidgetsBindingObserver {
  List<NavItem> get _navItems {
    final l10n = AppLocalizations.of(context)!;
    return [
      NavItem(label: l10n.homeLabel, icon: Icons.home, route: AppRoutes.home),
      NavItem(
        label: l10n.settingsLabel,
        icon: Icons.settings,
        route: AppRoutes.settings,
      ),
    ];
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Future<bool> didPopRoute() async {
    talker?.debug('MainLayout: didPopRoute called. Index: $_currentIndex');

    // Handle navigation to Home from other tabs
    if (_currentIndex != 0) {
      talker?.debug('MainLayout: Navigating to Home');
      _onNavTap(0);
      return true; // We handled the pop
    }

    // Handle Double Back to Exit on Home
    if (_isExiting) {
      talker?.debug('MainLayout: Showing exit dialog');
      _showExitDialog();
      return true; // We handled the pop
    }

    talker?.debug('MainLayout: Showing exit warning');
    setState(() => _isExiting = true);

    // Show snackbar using ScaffoldMessenger
    ScaffoldMessenger.of(context)
        .showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.pressBackAgain),
            duration: AppDurations.exitWarning,
          ),
        )
        .closed
        .then((_) {
          if (mounted) {
            setState(() => _isExiting = false);
          }
        });

    return true; // We handled the pop (prevented exit)
  }

  int get _currentIndex {
    final path = GoRouterState.of(context).uri.path;
    final index = _navItems.indexWhere((item) => path.startsWith(item.route));
    return index >= 0 ? index : 0;
  }

  void _onNavTap(int index) {
    if (index != _currentIndex) {
      context.go(_navItems[index].route);
    }
  }

  bool _isExiting = false;

  void _showExitDialog() {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => AlertDialog(
        title: Text(l10n.exitAppTitle),
        content: Text(l10n.exitAppMessage),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() => _isExiting = false);
            },
            child: Text(l10n.cancelButton),
          ),
          TextButton(
            onPressed: () => SystemNavigator.pop(),
            child: Text(l10n.exitButton),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ResponsiveBuilder(
      builder: (context, sizingInfo) {
        final isTablet = sizingInfo.deviceScreenType == DeviceScreenType.tablet;
        final isLandscape =
            MediaQuery.orientationOf(context) == Orientation.landscape;
        final useRail = isTablet && isLandscape;

        if (useRail) {
          return _TabletLayout(
            navItems: _navItems,
            currentIndex: _currentIndex,
            onNavTap: _onNavTap,
            child: widget.child,
          );
        }

        return _MobileLayout(
          navItems: _navItems,
          currentIndex: _currentIndex,
          onNavTap: _onNavTap,
          child: widget.child,
        );
      },
    );
  }
}

class _MobileLayout extends StatelessWidget {
  const _MobileLayout({
    required this.navItems,
    required this.currentIndex,
    required this.onNavTap,
    required this.child,
  });

  final List<NavItem> navItems;
  final int currentIndex;
  final void Function(int) onNavTap;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.appTitle),
        actions: [
          const ConnectionIndicator(),
          IconButton(
            icon: const Icon(
              Icons.brightness_6,
            ).animate(delay: 200.ms).scale(curve: Curves.easeOutBack),
            onPressed: () {
              final themeManager = context.read<ThemeManager>();
              themeManager.toggleTheme();
              ToastHelper.show(
                context,
                title: themeManager.isDarkMode
                    ? l10n.darkModeEnabled
                    : l10n.lightModeEnabled,
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: child,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: currentIndex,
        onDestinationSelected: onNavTap,
        destinations: _buildNavDestinations(navItems),
      ),
      floatingActionButton: kDebugMode ? const TalkerFab() : null,
    );
  }
}

/// Tablet layout with Side NavigationRail (always expanded)
class _TabletLayout extends StatelessWidget {
  const _TabletLayout({
    required this.navItems,
    required this.currentIndex,
    required this.onNavTap,
    required this.child,
  });

  final List<NavItem> navItems;
  final int currentIndex;
  final void Function(int) onNavTap;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      body: SafeArea(
        child: Row(
          children: [
            // NavigationRail - always expanded with labels
            NavigationRail(
              selectedIndex: currentIndex,
              onDestinationSelected: onNavTap,
              labelType: NavigationRailLabelType.all,
              groupAlignment: -1.0,
              // Destinations only
              destinations: navItems.map((item) {
                return NavigationRailDestination(
                  icon: Icon(item.icon),
                  selectedIcon: Icon(item.icon, color: colorScheme.primary),
                  label: Text(item.label),
                );
              }).toList(),
            ),
            const VerticalDivider(thickness: 1),
            // Main content
            Expanded(
              child: Column(
                children: [
                  // Connection indicator pinned at top-right
                  const Align(
                    alignment: Alignment.centerRight,
                    child: Padding(
                      padding: EdgeInsets.only(right: 16, top: 8, bottom: 4),
                      child: ConnectionIndicator(),
                    ),
                  ),
                  Expanded(child: child),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
