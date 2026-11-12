import 'package:flutter/material.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:gap/gap.dart';
import 'package:provider/provider.dart';

import 'package:teapot_app/l10n/gen/app_localizations.dart';

import '../constants/app_constants.dart';
import '../teapot/service.dart';
import '../teapot/settings.dart';
import '../utils/toast_helper.dart';

/// Agent settings. The service reads them on start, so saving restarts it.
class TeapotSettingsCard extends StatefulWidget {
  const TeapotSettingsCard({super.key});

  @override
  State<TeapotSettingsCard> createState() => _TeapotSettingsCardState();
}

class _TeapotSettingsCardState extends State<TeapotSettingsCard> {
  final _control = TextEditingController();
  final _name = TextEditingController();
  bool _allowLan = false;
  bool _batteryExempt = true;
  bool _loaded = false;
  bool _invalidControl = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final s = await TeapotSettings.load();
    final exempt = await FlutterForegroundTask.isIgnoringBatteryOptimizations;
    if (!mounted) return;
    setState(() {
      _control.text = s.controlUrl;
      _name.text = s.deviceName;
      _allowLan = s.allowLan;
      _batteryExempt = exempt;
      _loaded = true;
    });
  }

  Future<void> _save() async {
    final l10n = AppLocalizations.of(context)!;
    final ctrl = context.read<TeapotController>();
    final control = _control.text.trim().isEmpty
        ? TeapotSettings.defaultControl
        : _control.text.trim();
    if (!TeapotSettings.isValidControlUrl(control)) {
      setState(() => _invalidControl = true);
      return;
    }
    setState(() => _invalidControl = false);
    await TeapotSettings(
      controlUrl: control,
      deviceName: _name.text.trim(),
      allowLan: _allowLan,
    ).save();
    await ctrl.restart();
    if (mounted) ToastHelper.show(context, title: l10n.settingsSaved);
  }

  @override
  void dispose() {
    _control.dispose();
    _name.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    if (!_loaded) return const SizedBox.shrink();
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(Spacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _control,
              keyboardType: TextInputType.url,
              decoration: InputDecoration(
                labelText: l10n.controlUrlTitle,
                hintText: 'https://teapot.example.com',
                errorText: _invalidControl ? l10n.controlUrlInvalid : null,
              ),
            ),
            const Gap(Spacing.sm),
            TextField(
              controller: _name,
              decoration: InputDecoration(
                labelText: l10n.deviceNameTitle,
                hintText: l10n.deviceNameHint,
              ),
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(l10n.allowLanTitle),
              subtitle: Text(l10n.allowLanSubtitle),
              value: _allowLan,
              onChanged: (v) => setState(() => _allowLan = v),
            ),
            if (!_batteryExempt)
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.battery_alert),
                title: Text(l10n.batteryTitle),
                subtitle: Text(l10n.batterySubtitle),
                onTap: () async {
                  await FlutterForegroundTask.requestIgnoreBatteryOptimization();
                  _load();
                },
              ),
            const Gap(Spacing.sm),
            FilledButton(onPressed: _save, child: Text(l10n.saveButton)),
          ],
        ),
      ),
    );
  }
}
