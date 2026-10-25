import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:gap/gap.dart';
import 'package:provider/provider.dart';

import 'package:teapot_app/l10n/gen/app_localizations.dart';

import '../../constants/app_constants.dart';
import '../../providers/theme_manager.dart';
import '../../utils/toast_helper.dart';
import '../../widgets/teapot_settings_card.dart';

/// Settings tab content
class SettingsTab extends StatelessWidget {
  const SettingsTab({super.key});

  @override
  Widget build(BuildContext context) {
    final themeManager = context.watch<ThemeManager>();
    final animate = themeManager.animationEnabled;
    final l10n = AppLocalizations.of(context)!;

    return ListView(
      shrinkWrap: true,
      physics: const ClampingScrollPhysics(),
      padding: const EdgeInsets.all(Spacing.md),
      children: [
        Text(
          l10n.teapotSettingsTitle,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.grey,
          ),
        ),
        const Gap(Spacing.sm),
        const TeapotSettingsCard(),
        const Gap(Spacing.lg),
        Text(
          l10n.settingsLabel,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.grey,
          ),
        ).animate(target: 1).fadeIn(duration: animate ? 300.ms : 0.ms),
        const Gap(Spacing.sm),
        Card(
              child: Column(
                children: [
                  SwitchListTile(
                    title: Text(l10n.darkModeTitle),
                    subtitle: Text(l10n.darkModeSubtitle),
                    value: themeManager.isDarkMode,
                    onChanged: (_) {
                      themeManager.toggleTheme();
                      ToastHelper.show(
                        context,
                        title: themeManager.isDarkMode
                            ? l10n.darkModeEnabled
                            : l10n.lightModeEnabled,
                      );
                    },
                  ),
                  const Divider(height: 1),
                  SwitchListTile(
                    title: Text(l10n.animationsTitle),
                    subtitle: Text(l10n.animationsSubtitle),
                    value: themeManager.animationEnabled,
                    onChanged: (_) {
                      themeManager.toggleAnimation();
                      ToastHelper.show(
                        context,
                        title: themeManager.animationEnabled
                            ? l10n.animationsEnabled
                            : l10n.animationsDisabled,
                      );
                    },
                  ),
                  const Divider(height: 1),
                  ListTile(
                    title: Text(l10n.languageTitle),
                    subtitle: Text(l10n.languageSubtitle),
                    trailing: Text(
                      themeManager.locale.languageCode == 'id'
                          ? l10n.languageIndonesian
                          : l10n.languageEnglish,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: Text(l10n.languageTitle),
                          content: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              ListTile(
                                leading: const Text(
                                  '🇬🇧',
                                  style: TextStyle(fontSize: 24),
                                ),
                                title: Text(l10n.languageEnglish),
                                onTap: () {
                                  themeManager.setLocale(const Locale('en'));
                                  Navigator.pop(context);
                                },
                                selected:
                                    themeManager.locale.languageCode == 'en',
                              ),
                              ListTile(
                                leading: const Text(
                                  '🇮🇩',
                                  style: TextStyle(fontSize: 24),
                                ),
                                title: Text(l10n.languageIndonesian),
                                onTap: () {
                                  themeManager.setLocale(const Locale('id'));
                                  Navigator.pop(context);
                                },
                                selected:
                                    themeManager.locale.languageCode == 'id',
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            )
            .animate(target: 1)
            .fadeIn(
              delay: animate ? 50.ms : 0.ms,
              duration: animate ? 400.ms : 0.ms,
            ),
        const Gap(Spacing.lg),
        Text(
              l10n.aboutTitle,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            )
            .animate(target: 1)
            .fadeIn(
              delay: animate ? 100.ms : 0.ms,
              duration: animate ? 300.ms : 0.ms,
            ),
        const Gap(Spacing.sm),
        Card(
              child: ListTile(
                title: Text(l10n.versionTitle),
                subtitle: const Text('1.0.0'),
              ),
            )
            .animate(target: 1)
            .fadeIn(
              delay: animate ? 150.ms : 0.ms,
              duration: animate ? 400.ms : 0.ms,
            ),
      ],
    );
  }
}
