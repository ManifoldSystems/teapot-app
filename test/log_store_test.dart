import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:teapot_app/teapot/log_store.dart';

void main() {
  test('offline queue is bounded and new sessions do not reuse event ids', () {
    final store = LogStore();
    store.add('first');
    final first = store.pending.single['id'];
    for (var i = 0; i < 1100; i++) {
      store.add('event $i', level: 'warn');
    }
    expect(store.pending.length, 1000);
    expect(store.pending.first['message'], 'event 100');
    final second = LogStore()..add('first');
    expect(second.pending.single['id'], isNot(first));
  });

  test('unicode and escaped log messages fit a control upload batch', () {
    final store = LogStore();
    for (var i = 0; i < 20; i++) {
      store.add(i.isEven ? '🫖' * 3000 : '\u0000' * 3000);
    }
    expect(store.pending.first['message'].runes.length, 1024);
    expect((store.pending.first['message'] as String).length, 2048);
    expect(
      utf8.encode(jsonEncode({'entries': store.pending})).length,
      lessThan(128 * 1024),
    );
  });
}
