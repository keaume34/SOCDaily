// Study session state machine. Loads all flashcards + MCQs for a topic and
// walks the user through them one by one. Phase 3 only tracks per-session
// progress in memory; Phase 4 will write SM-2 + per-question state back to
// the DB via the user-state tables.

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/db/app_database.dart';
import '../../data/db/content_repository.dart';
import '../../data/db/user_state_repository.dart';

/// One step in a study session — either a flashcard or an MCQ.
sealed class StudyItem {
  const StudyItem();
}

class FlashcardItem extends StudyItem {
  const FlashcardItem(this.card);
  final Flashcard card;
}

class QuestionItem extends StudyItem {
  const QuestionItem(this.question, this.options);
  final Question question;
  final List<QuestionOption> options;
}

/// Difficulty rating the user reports on each flashcard. Phase 4 turns
/// these into SM-2 ease/interval updates.
enum CardRating { again, hard, good, easy }

@immutable
class StudySessionState {
  const StudySessionState({
    required this.items,
    required this.index,
    required this.selectedOptions,
    required this.submitted,
    required this.flashcardRatings,
    required this.questionResults,
  });

  factory StudySessionState.initial(List<StudyItem> items) {
    return StudySessionState(
      items: items,
      index: 0,
      selectedOptions: const {},
      submitted: false,
      flashcardRatings: const {},
      questionResults: const {},
    );
  }

  final List<StudyItem> items;
  final int index;

  /// Currently-selected option ids for the active question. Reset between
  /// items.
  final Set<int> selectedOptions;
  final bool submitted;

  /// `flashcardId → rating` for cards the user already graded.
  final Map<int, CardRating> flashcardRatings;

  /// `questionId → was answered fully correctly`.
  final Map<int, bool> questionResults;

  bool get isDone => index >= items.length;

  StudyItem? get current => isDone ? null : items[index];

  int get cardsTotal => items.whereType<FlashcardItem>().length;
  int get cardsSeen => flashcardRatings.length;
  int get questionsTotal => items.whereType<QuestionItem>().length;
  int get questionsAnswered => questionResults.length;
  int get questionsCorrect =>
      questionResults.values.where((v) => v).length;
  double get accuracy =>
      questionsAnswered == 0 ? 0 : questionsCorrect / questionsAnswered;

  StudySessionState copyWith({
    int? index,
    Set<int>? selectedOptions,
    bool? submitted,
    Map<int, CardRating>? flashcardRatings,
    Map<int, bool>? questionResults,
  }) {
    return StudySessionState(
      items: items,
      index: index ?? this.index,
      selectedOptions: selectedOptions ?? this.selectedOptions,
      submitted: submitted ?? this.submitted,
      flashcardRatings: flashcardRatings ?? this.flashcardRatings,
      questionResults: questionResults ?? this.questionResults,
    );
  }
}

class StudySessionController
    extends AutoDisposeFamilyAsyncNotifier<StudySessionState, int> {
  late ContentRepository _repo;
  late UserStateRepository _userRepo;

  @override
  Future<StudySessionState> build(int arg) async {
    final topicId = arg;
    _repo = ref.watch(contentRepositoryProvider);
    _userRepo = ref.watch(userStateRepositoryProvider);
    // Load cards and questions in parallel — they're independent.
    final results = await Future.wait([
      _repo.listFlashcardsForTopic(topicId),
      _repo.listQuestionsForTopic(topicId),
    ]);
    final cards = results[0] as List<Flashcard>;
    final questions = results[1] as List<Question>;
    final optionsMap = await _repo.listOptionsForQuestions(
        questions.map((q) => q.id).toList());
    final items = <StudyItem>[
      for (final c in cards) FlashcardItem(c),
      for (final q in questions)
        QuestionItem(q, optionsMap[q.id] ?? const []),
    ];
    return StudySessionState.initial(items);
  }

  void toggleOption(int optionId, {required bool multiple}) {
    final cur = state.valueOrNull;
    if (cur == null || cur.submitted) return;
    final next = Set<int>.from(cur.selectedOptions);
    if (multiple) {
      if (!next.add(optionId)) next.remove(optionId);
    } else {
      next
        ..clear()
        ..add(optionId);
    }
    state = AsyncData(cur.copyWith(selectedOptions: next));
  }

  Future<void> submitQuestion() async {
    final cur = state.valueOrNull;
    if (cur == null) return;
    final item = cur.current;
    if (item is! QuestionItem) return;
    final correctIds =
        item.options.where((o) => o.isCorrect).map((o) => o.id).toSet();
    final wasCorrect = correctIds.length == cur.selectedOptions.length &&
        correctIds.containsAll(cur.selectedOptions);
    final choice = cur.selectedOptions.toList()..sort();
    await _userRepo.recordQuestionAttempt(
      item.question.id,
      wasCorrect: wasCorrect,
      choice: choice.join(','),
    );
    state = AsyncData(cur.copyWith(
      submitted: true,
      questionResults: {
        ...cur.questionResults,
        item.question.id: wasCorrect,
      },
    ));
  }

  Future<void> rateFlashcard(CardRating rating) async {
    final cur = state.valueOrNull;
    if (cur == null) return;
    final item = cur.current;
    if (item is! FlashcardItem) return;
    await _userRepo.recordFlashcardRating(item.card.id, rating);
    state = AsyncData(cur.copyWith(
      flashcardRatings: {
        ...cur.flashcardRatings,
        item.card.id: rating,
      },
    ));
    next();
  }

  void next() {
    final cur = state.valueOrNull;
    if (cur == null) return;
    state = AsyncData(cur.copyWith(
      index: cur.index + 1,
      selectedOptions: const {},
      submitted: false,
    ));
  }

  void restart() {
    final cur = state.valueOrNull;
    if (cur == null) return;
    state = AsyncData(StudySessionState.initial(cur.items));
  }
}

final studySessionControllerProvider = AutoDisposeAsyncNotifierProvider
    .family<StudySessionController, StudySessionState, int>(
  StudySessionController.new,
);
