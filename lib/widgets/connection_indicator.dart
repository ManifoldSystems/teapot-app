import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/connectivity_provider.dart';
import 'package:teapot_app/l10n/gen/app_localizations.dart';

/// A small colored-dot indicator that shows real-time connection status.
///
/// - **Green**  → Online
/// - **Orange** → Reconnecting (validating)
/// - **Red**    → Offline
///
/// Designed to sit inside an [AppBar.actions] list.
class ConnectionIndicator extends StatelessWidget {
  const ConnectionIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    final connectivity = context.watch<ConnectivityProvider>();
    final l10n = AppLocalizations.of(context);

    final (color, label) = switch ((
      connectivity.isOnline,
      connectivity.isChecking,
    )) {
      (_, true) => (
        Colors.orange,
        l10n?.connectionReconnecting ?? 'Reconnecting...',
      ),
      (true, false) => (Colors.green, 'Online'),
      _ => (Colors.red, 'Offline'),
    };

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Animated dot
          TweenAnimationBuilder<Color?>(
            tween: ColorTween(end: color),
            duration: const Duration(milliseconds: 400),
            builder: (context, animatedColor, _) => Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: animatedColor,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: (animatedColor ?? color).withValues(alpha: 0.5),
                    blurRadius: 4,
                    spreadRadius: 1,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 6),
          Text(label, style: Theme.of(context).textTheme.bodySmall),
        ],
      ),
    );
  }
}
