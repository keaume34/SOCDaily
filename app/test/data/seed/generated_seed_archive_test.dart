// Phase 14.C — GeneratedSeedArchive tests.

import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;

import 'package:socdaily_app/src/data/seed/generated_seed_archive.dart';

void main() {
  late Directory tmp;

  setUp(() async {
    tmp = await Directory.systemTemp.createTemp('socdaily_archive_');
  });

  tearDown(() async {
    if (await tmp.exists()) await tmp.delete(recursive: true);
  });

  test('archive writes <root>/socdaily/generated/<day>/<topic>.json', () async {
    final archive = GeneratedSeedArchive(rootOverride: tmp);
    final seed = {
      'topic_code': 'siem-core',
      'flashcards': [
        {'front': 'q', 'back': 'a'},
      ],
    };
    final path = await archive.archive(
      seed,
      now: DateTime.utc(2026, 5, 15, 12),
    );
    expect(path, isNotNull);
    final f = File(path!);
    expect(await f.exists(), isTrue);
    expect(p.basename(f.path), 'siem-core.json');
    expect(p.basename(f.parent.path), '2026-05-15');

    final raw = await f.readAsString();
    expect(jsonDecode(raw), equals(seed));
  });

  test('archive sanitises topic_code into a safe filename', () async {
    final archive = GeneratedSeedArchive(rootOverride: tmp);
    final path = await archive.archive(
      {'topic_code': '../etc/passwd', 'flashcards': []},
      now: DateTime.utc(2026, 5, 15),
    );
    expect(path, isNotNull);
    expect(p.basename(path!), 'etc-passwd.json');
  });

  test('list returns archived entries sorted newest-first', () async {
    final archive = GeneratedSeedArchive(rootOverride: tmp);
    await archive.archive({'topic_code': 't1'},
        now: DateTime.utc(2026, 5, 14));
    await archive.archive({'topic_code': 't2'},
        now: DateTime.utc(2026, 5, 15));
    final list = await archive.list();
    expect(list.length, 2);
    expect(list.first.day, '2026-05-15');
    expect(list.last.day, '2026-05-14');
  });

  test('list returns empty when no archive directory exists yet', () async {
    final archive = GeneratedSeedArchive(rootOverride: tmp);
    expect(await archive.list(), isEmpty);
  });
}
