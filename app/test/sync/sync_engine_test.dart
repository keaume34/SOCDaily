// Phase 11 — SyncEngine + InMemorySyncRemote round-trip:
// simulates two devices, ensures user state propagates and conflicts
// resolve via last-write-wins.

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:socdaily_app/src/data/db/app_database.dart';
import 'package:socdaily_app/src/data/db/user_state_repository.dart';
import 'package:socdaily_app/src/features/study/study_session_controller.dart';
import 'package:socdaily_app/src/sync/in_memory_sync_remote.dart';
import 'package:socdaily_app/src/sync/sync_engine.dart';

class _Device {
  _Device(this.id)
      : db = AppDatabase.forExecutor(NativeDatabase.memory()) {
    repo = UserStateRepository(db);
  }
  final String id;
  final AppDatabase db;
  late final UserStateRepository repo;

  Future<int> seedFlashcard() async {
    final s = await db.into(db.subjects).insert(
        SubjectsCompanion.insert(code: 's', title: 'S'));
    final c = await db.into(db.chapters).insert(
        ChaptersCompanion.insert(subjectId: s, code: 'c', title: 'C'));
    final t = await db.into(db.topics).insert(
        TopicsCompanion.insert(chapterId: c, code: 't', title: 'T'));
    return db.into(db.flashcards).insert(
          FlashcardsCompanion.insert(topicId: t, front: 'f', back: 'b'),
        );
  }

  Future<void> close() => db.close();
}

void main() {
  late _Device a;
  late _Device b;
  late InMemorySyncRemote remote;

  setUp(() async {
    a = _Device('A');
    b = _Device('B');
    remote = InMemorySyncRemote();
  });

  tearDown(() async {
    await a.close();
    await b.close();
  });

  test('two devices share user_card_state via pairing code', () async {
    final flashcardA = await a.seedFlashcard();
    final flashcardB = await b.seedFlashcard();
    expect(flashcardA, flashcardB,
        reason: 'in-memory dbs should give the same row id');

    final pair = await remote.createPair(deviceId: a.id);
    await remote.redeemPair(code: pair.code, deviceId: b.id);

    // Device A reviews the card.
    await a.repo.recordFlashcardRating(
      flashcardA,
      CardRating.good,
      now: DateTime.utc(2025, 1, 1),
    );

    // Device A pushes; device B pulls.
    final engineA = SyncEngine(a.db, remote);
    final engineB = SyncEngine(b.db, remote);
    await engineA.sync(code: pair.code, myDeviceId: a.id);
    final pullResult = await engineB.sync(code: pair.code, myDeviceId: b.id);

    expect(pullResult.applied, greaterThanOrEqualTo(1));
    final stateOnB = await (b.db.select(b.db.userCardState)
          ..where((s) => s.flashcardId.equals(flashcardB)))
        .getSingle();
    expect(stateOnB.lastResult, 'good');
    expect(stateOnB.intervalDays, 1);
  });

  test('last-write-wins resolves a conflict on the same item', () async {
    final fid = await a.seedFlashcard();
    await b.seedFlashcard();
    final pair = await remote.createPair(deviceId: a.id);
    await remote.redeemPair(code: pair.code, deviceId: b.id);

    // A rated 'again' at 10:00, B rated 'easy' at 10:05.
    await a.repo.recordFlashcardRating(
      fid,
      CardRating.again,
      now: DateTime.utc(2025, 1, 1, 10, 0),
    );
    await b.repo.recordFlashcardRating(
      fid,
      CardRating.easy,
      now: DateTime.utc(2025, 1, 1, 10, 5),
    );

    final engineA = SyncEngine(a.db, remote);
    final engineB = SyncEngine(b.db, remote);

    // A pushes first, then B pushes (newer). A then pulls B's row.
    await engineA.sync(code: pair.code, myDeviceId: a.id);
    await engineB.sync(code: pair.code, myDeviceId: b.id);
    await engineA.sync(code: pair.code, myDeviceId: a.id);

    final stateOnA = await (a.db.select(a.db.userCardState)
          ..where((s) => s.flashcardId.equals(fid)))
        .getSingle();
    expect(stateOnA.lastResult, 'easy');
  });

  test('bookmarks sync across devices', () async {
    final fid = await a.seedFlashcard();
    await b.seedFlashcard();
    final pair = await remote.createPair(deviceId: a.id);
    await remote.redeemPair(code: pair.code, deviceId: b.id);

    await a.repo.toggleBookmark('flashcard', fid);
    await SyncEngine(a.db, remote)
        .sync(code: pair.code, myDeviceId: a.id);
    await SyncEngine(b.db, remote)
        .sync(code: pair.code, myDeviceId: b.id);

    expect(await b.repo.isBookmarked('flashcard', fid), isTrue);
  });
}
