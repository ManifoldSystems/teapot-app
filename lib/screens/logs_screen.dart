import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:iroh_flutter/iroh_flutter.dart';
import 'package:teapot_app/l10n/gen/app_localizations.dart';

import '../teapot/control_client.dart';
import '../teapot/key_store.dart';
import '../teapot/log_store.dart';
import '../teapot/settings.dart';

/// Viewing is UI-owned: closing this screen closes only its log subscription.
class LogsScreen extends StatefulWidget {
  const LogsScreen({super.key, this.device = 'local'});
  final String device;

  @override
  State<LogsScreen> createState() => _LogsScreenState();
}

class _LogsScreenState extends State<LogsScreen> {
  late String _device = widget.device;
  String _level = 'info';
  String _query = '';
  String _state = 'connecting';
  bool _paused = false;
  int _generation = 0;
  final List<Map<String, dynamic>> _entries = [];
  List<Peer> _peers = [];
  ControlClient? _client;
  Completer<void>? _stop;
  Timer? _localTimer;

  @override
  void initState() {
    super.initState();
    unawaited(_init());
  }

  Future<void> _init() async {
    _connect(reset: true);
    try {
      final settings = await TeapotSettings.load();
      await Iroh.init();
      final key = await KeyStore().loadOrCreate();
      if (!mounted) return;
      _client = ControlClient(settings.controlUrl, key);
      try {
        _peers = await _client!.peers();
      } catch (_) {
        /* local logs remain usable offline */
      }
      if (!mounted) return;
      setState(() {});
      if (_device != 'local') _connect(reset: true);
    } catch (_) {
      if (mounted && _device != 'local') setState(() => _state = 'error');
    }
  }

  void _connect({bool reset = false}) {
    final generation = ++_generation;
    _stop?.complete();
    _stop = null;
    _localTimer?.cancel();
    if (reset) _entries.clear();
    if (_paused) {
      setState(() => _state = 'paused');
      return;
    }
    setState(() => _state = 'connecting');
    if (_device == 'local') {
      Future<void> read() async {
        try {
          final entries = await LogStore.read();
          if (!mounted || generation != _generation) return;
          setState(() {
            _entries
              ..clear()
              ..addAll(entries);
            _state = 'local';
          });
        } catch (_) {
          if (mounted && generation == _generation) {
            setState(() => _state = 'error');
          }
        }
      }

      unawaited(read());
      _localTimer = Timer.periodic(const Duration(seconds: 3), (_) => read());
      return;
    }
    final client = _client;
    if (client == null) return;
    final stop = _stop = Completer<void>();
    unawaited(
      client.watchLogs(
        device: _device.isEmpty ? null : _device,
        level: _level,
        after: reset || _entries.isEmpty
            ? 0
            : (_entries.last['cursor'] as int? ?? 0),
        stop: stop.future,
        onEntries: (entries) {
          if (!mounted || generation != _generation) return;
          setState(() {
            final ids = _entries.map((e) => e['cursor']).toSet();
            _entries.addAll(entries.where((e) => !ids.contains(e['cursor'])));
            if (_entries.length > 1000) {
              _entries.removeRange(0, _entries.length - 1000);
            }
          });
        },
        onState: (state) {
          if (mounted && generation == _generation) {
            setState(() => _state = state);
          }
        },
      ),
    );
  }

  @override
  void dispose() {
    _generation++;
    _stop?.complete();
    _localTimer?.cancel();
    _client?.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final choices = <String, String>{
      'local': l.logsLocal,
      '': l.logsAll,
      'control': 'Control',
      if (_client != null) _client!.nodeId: l.logsThisDevice,
      for (final p in _peers) p.nodeId: p.label,
    };
    choices.putIfAbsent(_device, () => _device.substring(0, 8));
    const levels = ['debug', 'info', 'warn', 'error'];
    final visible = _entries
        .where((e) => levels.indexOf('${e['level']}') >= levels.indexOf(_level))
        .map((e) {
          final time = DateTime.fromMillisecondsSinceEpoch(
            e['timestamp'] as int,
          ).toLocal().toIso8601String();
          final node = e['node_id'] as String?;
          return '$time ${'${e['level']}'.toUpperCase()} [${choices[node] ?? node ?? l.logsLocal}] ${e['source']}: ${e['message']}';
        })
        .where((s) => s.toLowerCase().contains(_query.toLowerCase()))
        .toList();
    final state = switch (_state) {
      'live' => l.logsLive,
      'local' => l.logsLocal,
      'paused' => l.logsPaused,
      'reconnecting' => l.logsReconnecting,
      'error' => l.logsError,
      _ => l.logsConnecting,
    };
    return Scaffold(
      appBar: AppBar(
        title: Text(l.logsTitle),
        actions: [
          IconButton(
            tooltip: _paused ? l.logsResume : l.logsPause,
            icon: Icon(_paused ? Icons.play_arrow : Icons.pause),
            onPressed: () {
              _paused = !_paused;
              _connect();
            },
          ),
          IconButton(
            tooltip: l.logsCopy,
            icon: const Icon(Icons.copy),
            onPressed: () async {
              await Clipboard.setData(ClipboardData(text: visible.join('\n')));
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: DropdownButton<String>(
                        isExpanded: true,
                        value: _device,
                        items: choices.entries
                            .map(
                              (e) => DropdownMenuItem(
                                value: e.key,
                                child: Text(
                                  e.value,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            )
                            .toList(),
                        onChanged: (v) {
                          if (v != null) {
                            _device = v;
                            _connect(reset: true);
                          }
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    DropdownButton<String>(
                      value: _level,
                      items: levels
                          .map(
                            (l) => DropdownMenuItem(value: l, child: Text(l)),
                          )
                          .toList(),
                      onChanged: (v) {
                        if (v != null) {
                          _level = v;
                          _connect(reset: true);
                        }
                      },
                    ),
                  ],
                ),
                TextField(
                  decoration: InputDecoration(
                    hintText: l.logsSearch,
                    prefixIcon: const Icon(Icons.search),
                  ),
                  onChanged: (v) => setState(() => _query = v),
                ),
                const SizedBox(height: 8),
                Text(
                  '$state · ${visible.length}/1000',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
          Expanded(
            child: visible.isEmpty
                ? Center(child: Text(l.logsEmpty))
                : ListView.builder(
                    reverse: true,
                    itemCount: visible.length,
                    padding: const EdgeInsets.all(12),
                    itemBuilder: (_, i) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: SelectableText(
                        visible[visible.length - 1 - i],
                        style: const TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
