import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:provider/provider.dart';

import 'package:teapot_app/l10n/gen/app_localizations.dart';

import '../../constants/app_constants.dart';
import '../../teapot/service.dart';

/// Every approved device in the mesh, as control reports it.
class MeshTab extends StatelessWidget {
  const MeshTab({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final peers =
        ((context.watch<TeapotController>().snapshot['peers'] as List?) ??
                const [])
            .cast<Map>();
    final sorted = [...peers]
      ..sort((a, b) {
        final online =
            (b['online'] == true ? 1 : 0) - (a['online'] == true ? 1 : 0);
        return online != 0 ? online : '${a['name']}'.compareTo('${b['name']}');
      });

    return ListView(
      // MainLayout already scrolls (SingleChildScrollView); an unbounded
      // ListView there renders nothing in release builds.
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.all(Spacing.md),
      children: [
        Text(
          l10n.meshTitle,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.grey,
          ),
        ),
        const Gap(Spacing.sm),
        if (sorted.isEmpty)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(Spacing.md),
              child: Text(l10n.meshEmpty),
            ),
          )
        else
          Card(
            child: Column(
              children: [
                for (final (i, p) in sorted.indexed) ...[
                  if (i > 0) const Divider(height: 1),
                  ListTile(
                    leading: Icon(
                      _icon('${p['platform']}'),
                      color: p['online'] == true ? Colors.green : Colors.grey,
                    ),
                    title: Text('${p['name']}'),
                    subtitle: Text(
                      [
                        p['online'] == true
                            ? l10n.peerOnline
                            : l10n.peerOffline,
                        if (p['exit'] == true) l10n.peerExit,
                        if (p['ipv4'] != null) '${p['ipv4']}',
                      ].join(' · '),
                    ),
                    trailing: p['using_me'] == true
                        ? Chip(
                            label: Text(l10n.peerUsingMe),
                            visualDensity: VisualDensity.compact,
                          )
                        : null,
                  ),
                ],
              ],
            ),
          ),
      ],
    );
  }

  static IconData _icon(String platform) => switch (platform) {
    'macos' => Icons.laptop_mac,
    'linux' => Icons.dns,
    'android' => Icons.phone_android,
    'windows' => Icons.desktop_windows,
    _ => Icons.devices_other,
  };
}
