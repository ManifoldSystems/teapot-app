import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gap/gap.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:teapot_app/l10n/gen/app_localizations.dart';

import '../../constants/app_constants.dart';
import '../../teapot/service.dart';
import '../../utils/toast_helper.dart';

/// Status of the Teapot agent running in the foreground service.
class HomeTab extends StatelessWidget {
  const HomeTab({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = context.watch<TeapotController>();
    final l10n = AppLocalizations.of(context)!;
    final s = ctrl.snapshot;

    if (!ctrl.running) {
      return _Stopped(onStart: ctrl.start, l10n: l10n);
    }

    final phase = s['phase'] as String? ?? 'starting';
    final nodeId = s['node_id'] as String?;
    final clients = ((s['clients'] as List?) ?? const []).cast<Map>();
    final log = ((s['log'] as List?) ?? const []).cast<String>();

    return ListView(
      // MainLayout already scrolls (SingleChildScrollView); an unbounded
      // ListView there renders nothing in release builds.
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.all(Spacing.md),
      children: [
        _PhaseCard(snapshot: s, phase: phase, l10n: l10n, onStop: ctrl.stop),
        if (phase == 'pending' && s['approve_url'] != null) ...[
          const Gap(Spacing.sm),
          _ApproveCard(
            url: s['approve_url'] as String,
            code: nodeId!.substring(0, 8),
            l10n: l10n,
          ),
        ],
        if (phase == 'approved') ...[
          const Gap(Spacing.sm),
          _ExitCard(snapshot: s, l10n: l10n),
          const Gap(Spacing.sm),
          _ClientsCard(clients: clients, l10n: l10n),
        ],
        const Gap(Spacing.sm),
        _LogCard(lines: log, l10n: l10n),
      ],
    );
  }
}

class _Stopped extends StatelessWidget {
  const _Stopped({required this.onStart, required this.l10n});
  final VoidCallback onStart;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(Spacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('🫖', style: TextStyle(fontSize: 64)),
            const Gap(Spacing.md),
            Text(
              l10n.statusStopped,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const Gap(Spacing.sm),
            Text(l10n.statusStoppedHint, textAlign: TextAlign.center),
            const Gap(Spacing.lg),
            FilledButton.icon(
              onPressed: onStart,
              icon: const Icon(Icons.power_settings_new),
              label: Text(l10n.startButton),
            ),
          ],
        ),
      ),
    );
  }
}

class _PhaseCard extends StatelessWidget {
  const _PhaseCard({
    required this.snapshot,
    required this.phase,
    required this.l10n,
    required this.onStop,
  });
  final Map<String, Object?> snapshot;
  final String phase;
  final AppLocalizations l10n;
  final VoidCallback onStop;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final (label, color) = switch (phase) {
      'approved' => (l10n.phaseApproved, Colors.green),
      'pending' => (l10n.phasePending, Colors.orange),
      'error' => (l10n.phaseError, scheme.error),
      _ => (l10n.phaseStarting, scheme.outline),
    };
    final online = snapshot['presence'] == true;
    final nodeId = snapshot['node_id'] as String?;
    final error = snapshot['error'] as String?;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(Spacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.circle, size: 12, color: color),
                const Gap(Spacing.sm),
                Expanded(
                  child: Text(
                    label,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                TextButton(onPressed: onStop, child: Text(l10n.stopButton)),
              ],
            ),
            const Gap(Spacing.xs),
            Text(
              '${snapshot['name'] ?? ''}${nodeId == null ? '' : ' · ${l10n.deviceCode} ${nodeId.substring(0, 8)}'}',
            ),
            Text(
              online
                  ? (snapshot['presence_since'] != null
                        ? l10n.presenceSince('${snapshot['presence_since']}')
                        : l10n.presenceOnline)
                  : l10n.presenceOffline,
              style: TextStyle(color: online ? Colors.green : scheme.outline),
            ),
            if (error != null) ...[
              const Gap(Spacing.xs),
              Text(error, style: TextStyle(color: scheme.error, fontSize: 12)),
            ],
          ],
        ),
      ),
    );
  }
}

class _ApproveCard extends StatelessWidget {
  const _ApproveCard({
    required this.url,
    required this.code,
    required this.l10n,
  });
  final String url;
  final String code;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(Spacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.approveHint),
            const Gap(Spacing.sm),
            SelectableText(
              '${l10n.deviceCode}: $code',
              style: const TextStyle(fontFamily: 'monospace', fontSize: 18),
            ),
            const Gap(Spacing.sm),
            Wrap(
              spacing: Spacing.sm,
              children: [
                FilledButton(
                  onPressed: () => launchUrl(
                    Uri.parse(url),
                    mode: LaunchMode.externalApplication,
                  ),
                  child: Text(l10n.approveOpen),
                ),
                OutlinedButton(
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: url));
                    ToastHelper.show(context, title: l10n.linkCopied);
                  },
                  child: Text(l10n.approveCopy),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ExitCard extends StatelessWidget {
  const _ExitCard({required this.snapshot, required this.l10n});
  final Map<String, Object?> snapshot;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final on = snapshot['exit_enabled'] == true;
    final v4 = snapshot['ipv4'] as String?;
    final v6 = snapshot['ipv6'] as String?;
    return Card(
      child: Column(
        children: [
          ListTile(
            leading: Icon(
              on ? Icons.public : Icons.public_off,
              color: on ? Colors.green : null,
            ),
            title: Text(on ? l10n.exitOn : l10n.exitOffDashboard),
            subtitle: Text(
              l10n.allowedCount((snapshot['allowed'] as int?) ?? 0),
            ),
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.sim_card),
            title: Text(l10n.publicIpTitle),
            subtitle: SelectableText(
              [if (v4 != null) v4, if (v6 != null) v6].join('\n').ifEmpty('…'),
            ),
          ),
        ],
      ),
    );
  }
}

class _ClientsCard extends StatelessWidget {
  const _ClientsCard({required this.clients, required this.l10n});
  final List<Map> clients;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              Spacing.md,
              Spacing.md,
              Spacing.md,
              0,
            ),
            child: Text(
              l10n.clientsTitle,
              style: Theme.of(context).textTheme.titleSmall,
            ),
          ),
          if (clients.isEmpty)
            Padding(
              padding: const EdgeInsets.all(Spacing.md),
              child: Text(l10n.clientsEmpty),
            )
          else
            for (final c in clients)
              ExpansionTile(
                dense: true,
                leading: Icon(
                  Icons.circle,
                  size: 10,
                  color: c['connected'] == true ? Colors.green : Colors.grey,
                ),
                title: Text('${c['name']}'),
                subtitle: Text(
                  '${c['kind']} · ↑${_bytes(c['tx'] as int)} ↓${_bytes(c['rx'] as int)}',
                ),
                childrenPadding: const EdgeInsets.fromLTRB(
                  Spacing.md,
                  0,
                  Spacing.md,
                  Spacing.sm,
                ),
                expandedCrossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.recentTargets,
                    style: Theme.of(context).textTheme.labelMedium,
                  ),
                  const Gap(Spacing.xs),
                  for (final t
                      in ((c['targets'] as List?) ?? const []).cast<Map>())
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 2),
                      child: Row(
                        children: [
                          Text(
                            '${t['at']}',
                            style: const TextStyle(
                              fontFamily: 'monospace',
                              fontSize: 11,
                              color: Colors.grey,
                            ),
                          ),
                          const Gap(Spacing.sm),
                          Expanded(
                            child: Text(
                              '${t['target']}${(t['count'] as int) > 1 ? ' ×${t['count']}' : ''}',
                              style: const TextStyle(
                                fontFamily: 'monospace',
                                fontSize: 12,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (t['ok'] != true)
                            Text(
                              l10n.targetRefused,
                              style: TextStyle(
                                fontSize: 11,
                                color: Theme.of(context).colorScheme.error,
                              ),
                            ),
                        ],
                      ),
                    ),
                ],
              ),
        ],
      ),
    );
  }
}

class _LogCard extends StatelessWidget {
  const _LogCard({required this.lines, required this.l10n});
  final List<String> lines;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ExpansionTile(
        title: Text(l10n.logTitle),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              Spacing.md,
              0,
              Spacing.md,
              Spacing.md,
            ),
            child: SelectableText(
              lines.reversed.join('\n'),
              style: const TextStyle(fontFamily: 'monospace', fontSize: 11),
            ),
          ),
        ],
      ),
    );
  }
}

String _bytes(int n) {
  if (n < 1024) return '$n B';
  const units = ['KB', 'MB', 'GB', 'TB'];
  var v = n / 1024;
  var i = 0;
  while (v >= 1024 && i < units.length - 1) {
    v /= 1024;
    i++;
  }
  return '${v < 10 ? v.toStringAsFixed(1) : v.round()} ${units[i]}';
}

extension on String {
  String ifEmpty(String fallback) => isEmpty ? fallback : this;
}
