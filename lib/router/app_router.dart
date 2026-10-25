import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:talker_flutter/talker_flutter.dart';
import '../constants/app_constants.dart';
import '../main.dart';
import '../screens/main_layout.dart';
import '../screens/tabs/home_tab.dart';
import '../screens/tabs/mesh_tab.dart';
import '../screens/tabs/settings_tab.dart';

/// App router configuration using GoRouter
/// Supports deep linking, web URL routing, and type-safe navigation
final appRouter = GoRouter(
  debugLogDiagnostics: kDebugMode,
  initialLocation: AppRoutes.home,
  observers: kDebugMode && talker != null ? [TalkerRouteObserver(talker!)] : [],
  routes: [
    ShellRoute(
      builder: (context, state, child) => MainLayout(child: child),
      routes: [
        GoRoute(
          path: AppRoutes.home,
          name: 'home',
          pageBuilder: (context, state) =>
              const NoTransitionPage(child: HomeTab()),
        ),
        GoRoute(
          path: AppRoutes.mesh,
          name: 'mesh',
          pageBuilder: (context, state) =>
              const NoTransitionPage(child: MeshTab()),
        ),
        GoRoute(
          path: AppRoutes.settings,
          name: 'settings',
          pageBuilder: (context, state) =>
              const NoTransitionPage(child: SettingsTab()),
        ),
      ],
    ),
    GoRoute(path: '/', redirect: (_, state) => AppRoutes.home),
    // Talker logs screen (debug only)
    if (kDebugMode && talker != null)
      GoRoute(
        path: AppRoutes.talker,
        name: 'talker',
        builder: (context, state) => TalkerScreen(talker: talker!),
      ),
    // Add more routes here (e.g., sales, inventory, reports)
    // GoRoute(
    //   path: '/sales',
    //   name: 'sales',
    //   pageBuilder: (context, state) => const NoTransitionPage(child: SalesScreen()),
    // ),
  ],
  errorPageBuilder: (context, state) => MaterialPage(
    child: Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Page not found'),
            const Gap(16),
            ElevatedButton(
              onPressed: () => context.go(AppRoutes.home),
              child: const Text('Go Home'),
            ),
          ],
        ),
      ),
    ),
  ),
);
