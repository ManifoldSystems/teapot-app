import 'dart:convert';
import 'dart:developer' as developer;
import 'dart:io';
import 'dart:math';

import 'package:path_provider/path_provider.dart';

/// Service-isolate writer; the UI can read the same bounded JSONL history.
class LogStore {
  final List<Map<String, dynamic>> pending = [];
  final String _session =
      '${DateTime.now().microsecondsSinceEpoch}-${Random.secure().nextInt(1 << 32)}';
  int _seq = 0;
  File? _file;
  Future<void> _writes = Future.value();

  Future<void> init() async {
    final dir = await getApplicationSupportDirectory();
    _file = File('${dir.path}/teapot.log.jsonl');
  }

  void add(String message, {String level = 'info', String source = 'agent'}) {
    final entry = <String, dynamic>{
      'id': '$_session-${++_seq}',
      'timestamp': DateTime.now().millisecondsSinceEpoch,
      'level': level,
      'source': source,
      'message': String.fromCharCodes(message.runes.take(1024)),
    };
    pending.add(entry);
    if (pending.length > 1000) pending.removeAt(0);
    _disk.add(entry);
    if (_disk.length > 1000) _disk.removeAt(0);
    developer.log(
      entry['message'] as String,
      name: 'teapot.$source',
      level: switch (level) {
        'error' => 1000,
        'warn' => 900,
        'debug' => 500,
        _ => 800,
      },
    );
  }

  final List<Map<String, dynamic>> _disk = [];

  Future<void> flush() {
    final batch = List<Map<String, dynamic>>.of(_disk);
    _disk.clear();
    _writes = _writes
        .then((_) async {
          final file = _file;
          if (file == null || batch.isEmpty) return;
          if (await file.exists() && await file.length() > 2 * 1024 * 1024) {
            await file.rename('${file.path}.1');
          }
          await file.writeAsString(
            '${batch.map(jsonEncode).join('\n')}\n',
            mode: FileMode.append,
            flush: true,
          );
        })
        .catchError((Object _) {
          /* Service/console logging remains available. */
        });
    return _writes;
  }

  static Future<List<Map<String, dynamic>>> read() async {
    final dir = await getApplicationSupportDirectory();
    final entries = <Map<String, dynamic>>[];
    for (final suffix in ['.1', '']) {
      final file = File('${dir.path}/teapot.log.jsonl$suffix');
      try {
        for (final line in await file.readAsLines()) {
          try {
            entries.add(jsonDecode(line) as Map<String, dynamic>);
          } on FormatException {
            /* partial last line */
          }
        }
      } on FileSystemException {
        /* no history yet, or rotating */
      }
    }
    return entries.skip(max(0, entries.length - 1000)).toList();
  }
}
