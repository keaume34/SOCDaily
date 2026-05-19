// Phase 14.B — generated-seed sync test.
//
// Device A generates a TopicSeed (simulated by uploading directly to the
// in-memory remote with kind='generated_seed') and syncNow on device B
// imports it via SeedImporter — the new flashcards + MCQs land in B's DB
// without a fresh asset bundle.

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:socdaily_app/src/data/db/app_database.dart';
import 'package:socdaily_app/src/sync/in_memory_sync_remote.dart';
import 'package:socdaily_app/src/sync/sync_engine.dart';
import 'package:socdaily_app/src/sync/sync_types.dart';

Map<String, dynamic> _seed() => {
      'subject_code': 'soc-fundamentals',
      'subject_title': 'SOC Fundamentals',
      'chapter_code': 'detection',
      'chapter_title': 'Detection',
      'topic_code': 'detection-rules',
      'topic_title': 'Detection Rules',
      'topic_summary': 'Sigma + YARA basics',
      'source_pdf': 'detection.pdf',
      'flashcards': [
        {'front': 'Q1', 'back': 'A1', 'difficulty': 'medium'},
        {'front': 'Q2', 'back': 'A2', 'difficulty': 'easy'},
      ],
      'questions': [
        {
          'stem': 'Q?',
          'qtype': 'single',
          'difficulty': 'medium',
          'options': [
            {'label': 'A', 'content': 'a', 'is_correct': true},
            {'label': 'B', 'content': 'b', 'is_correct': false},
          ],
        }
      ],
    };

void main() {
  test('generated_seed envelope is applied on the partner device', () async {
    final dbB = AppDatabase.forExecutor(NativeDatabase.memory());
    final remote = InMemorySyncRemote();

    final pair = await remote.createPair(deviceId: 'A');
    await remote.redeemPair(code: pair.code, deviceId: 'B');

    // Device A pushes a generated_seed envelope directly (mimics what
    // SyncController.pushGeneratedSeed does after a successful generate).
    await remote.upsertPayload(SyncEnvelope(
      code: pair.code,
      deviceId: 'A',
      kind: SyncKinds.generatedSeed,
      itemKey: 'detection-rules',
      payload: _seed(),
      updatedAt: DateTime.utc(2026, 5, 14, 12),
    ));

    // Device B has an empty content DB. Sync should pull + import.
    final engineB = SyncEngine(dbB, remote);
    final result = await engineB.sync(code: pair.code, myDeviceId: 'B');
    expect(result.applied, greaterThanOrEqualTo(1));

    final subjects = await dbB.select(dbB.subjects).get();
    expect(subjects.single.code, 'soc-fundamentals');
    final cards = await dbB.select(dbB.flashcards).get();
    expect(cards.length, 2);
    final questions = await dbB.select(dbB.questions).get();
    expect(questions.length, 1);

    await dbB.close();
  });

  test('re-applying the same envelope is idempotent (no duplicate rows)',
      () async {
    final dbB = AppDatabase.forExecutor(NativeDatabase.memory());
    final remote = InMemorySyncRemote();
    final pair = await remote.createPair(deviceId: 'A');
    await remote.redeemPair(code: pair.code, deviceId: 'B');

    await remote.upsertPayload(SyncEnvelope(
      code: pair.code,
      deviceId: 'A',
      kind: SyncKinds.generatedSeed,
      itemKey: 'detection-rules',
      payload: _seed(),
      updatedAt: DateTime.utc(2026, 5, 14, 12),
    ));

    final engineB = SyncEngine(dbB, remote);
    await engineB.sync(code: pair.code, myDeviceId: 'B');
    // Same envelope, same updated_at → second sync still imports (idempotent
    // because importTopicSeed replaces flashcards/questions in-place).
    await engineB.sync(code: pair.code, myDeviceId: 'B');

    final cards = await dbB.select(dbB.flashcards).get();
    expect(cards.length, 2);
    final topics = await dbB.select(dbB.topics).get();
    expect(topics.length, 1);

    await dbB.close();
  });
}
