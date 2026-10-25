import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:teapot_app/l10n/gen/app_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:talker_flutter/talker_flutter.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:toastification/toastification.dart';

import 'providers/connectivity_provider.dart';
import 'providers/theme_manager.dart';
import 'router/app_router.dart';
import 'teapot/service.dart';

/// Talker instance for logging (only active in debug mode)
/// In release mode, all logs are disabled for security
final talker = kDebugMode ? Talker() : null;

void main() {
  // Only log in debug mode - production builds have no logs for security
  talker?.info('🚀 App started');
  WidgetsFlutterBinding.ensureInitialized();
  // Data channel between the UI and the agent in the foreground service.
  FlutterForegroundTask.initCommunicationPort();

  runApp(
    ToastificationWrapper(
      child: MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => ThemeManager()),
          ChangeNotifierProvider(create: (_) => ConnectivityProvider()),
          ChangeNotifierProvider(create: (_) => TeapotController()..init()),
        ],
        child: const MyApp(),
      ),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeManager = context.watch<ThemeManager>();

    return WithForegroundTask(
      child: MaterialApp.router(
        title: 'Teapot',
        theme: themeManager.isDarkMode ? ThemeData.dark() : ThemeData.light(),
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [
          Locale('en'), // English
          Locale('id'), // Indonesian
        ],
        locale: themeManager.locale,
        routerConfig: appRouter,
        // Remove debug banner for cleaner look
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}

/// Floating button to open Talker logs panel
/// Only visible in debug mode
class TalkerFab extends StatelessWidget {
  const TalkerFab({super.key});

  @override
  Widget build(BuildContext context) {
    // Only show in debug mode
    if (!kDebugMode) return const SizedBox.shrink();

    return FloatingActionButton.small(
      heroTag: 'talker_fab',
      onPressed: () {
        // Open Talker logs panel
        context.push('/talker');
      },
      child: const Icon(Icons.bug_report),
    );
  }
}
