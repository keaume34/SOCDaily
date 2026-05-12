// Bookmarks, notes, and search repository tests.

import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:socdaily_app/src/data/db/app_database.dart';
import 'package:socdaily_app/src/data/db/user_state_repository.dart';

void main() {
  late AppDatabase db;
  late UserStateRepository repo;
  late int flashcardId;
  late int questionId;

  setUp(() async {
    db = AppDatabase.forExecutor(NativeDatabase.memory());
    repo = UserStateRepository(db);
    final s = await db.into(db.subjects).insert(
        SubjectsCompanion.insert(code: 's', title: 'SIEM Fundamentals'));
    final c = await db.into(db.chapters).insert(
        ChaptersCompanion.insert(subjectId: s, code: 'c', title: 'Alerts'));
    final t = await db.into(db.topics).insert(TopicsCompanion.insert(
        chapterId: c, code: 't', title: 'Triage workflow'));
    flashcardId = await db.into(db.flashcards).insert(
          FlashcardsCompanion.insert(
            topicId: t,
            front: 'What is alert triage?',
            back: 'Prioritising alerts by impact and confidence.',
          ),
        );
    questionId = await db.into(db.questions).insert(
          QuestionsCompanion.insert(
            topicId: t,
            stem: 'Which step comes first in alert triage?',
            explanation: const Value(
                'Containment cannot start before classification is done.'),
          ),
        );
  });

  tearDown(() async {
    await db.close();
  });

  test('toggleBookmark adds then removes', () async {
    expect(await repo.isBookmarked('flashcard', flashcardId), isFalse);
    final added =
        await repo.toggleBookmark('flashcard', flashcardId);
    expect(added, isTrue);
    expect(await repo.isBookmarked('flashcard', flashcardId), isTrue);
    final removed =
        await repo.toggleBookmark('flashcard', flashcardId);
    expect(removed, isFalse);
    expect(await repo.isBookmarked('flashcard', flashcardId), isFalse);
  });

  test('listBookmarks returns mixed kinds ordered by createdAt desc', () async {
    await repo.toggleBookmark('flashcard', flashcardId,
        now: DateTime.utc(2025, 1, 1, 10));
    await repo.toggleBookmark('question', questionId,
        now: DateTime.utc(2025, 1, 1, 11));
    final all = await repo.listBookmarks();
    expect(all.length, 2);
    expect(all.first.itemKind, 'question'); // most recent first
    final onlyFlash = await repo.listBookmarks(kind: 'flashcard');
    expect(onlyFlash.length, 1);
    expect(onlyFlash.first.itemId, flashcardId);
  });

  test('addNote + listNotesForItem returns saved note', () async {
    final id = await repo.addNote(
        'flashcard', flashcardId, 'Cross-reference with NIST 800-61.');
    final notes = await repo.listNotesForItem('flashcard', flashcardId);
    expect(notes.length, 1);
    expect(notes.first.id, id);
    expect(notes.first.body, contains('NIST'));
    await repo.deleteNote(id);
    final after = await repo.listNotesForItem('flashcard', flashcardId);
    expect(after, isEmpty);
  });

  test('searchFlashcards matches on front or back', () async {
    final byFront = await repo.searchFlashcards('triage');
    expect(byFront.length, 1);
    final byBack = await repo.searchFlashcards('confidence');
    expect(byBack.length, 1);
    final none = await repo.searchFlashcards('zzz');
    expect(none, isEmpty);
  });

  test('searchQuestions matches on stem and explanation', () async {
    final byStem = await repo.searchQuestions('triage');
    expect(byStem.length, 1);
    final byExpl = await repo.searchQuestions('classification');
    expect(byExpl.length, 1);
  });
}
