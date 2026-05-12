// AI tutor + settings tests with a fake LlmClient.

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:socdaily_app/src/ai/ai_settings.dart';
import 'package:socdaily_app/src/ai/llm_client.dart';
import 'package:socdaily_app/src/ai/tutor_service.dart';
import 'package:socdaily_app/src/data/db/app_database.dart';

class _RecordingClient implements LlmClient {
  TutorPrompt? lastPrompt;
  String response = 'ok';
  bool throwError = false;

  @override
  Future<String> complete(TutorPrompt prompt, {Duration? timeout}) async {
    lastPrompt = prompt;
    if (throwError) throw LlmException('boom');
    return response;
  }
}

void main() {
  test('AiSettings.isConfigured requires key + model', () {
    expect(AiSettings.initial.isConfigured, isFalse);
    final partial = AiSettings.initial.copyWith(apiKey: 'k', model: '');
    expect(partial.isConfigured, isFalse);
    final ok = AiSettings.initial.copyWith(apiKey: 'k', model: 'gpt-4');
    expect(ok.isConfigured, isTrue);
  });

  test('AiProvider.fromName falls back to openaiCompat', () {
    expect(AiProvider.fromName(null), AiProvider.openaiCompat);
    expect(AiProvider.fromName('garbage'), AiProvider.openaiCompat);
    expect(AiProvider.fromName('anthropic'), AiProvider.anthropic);
  });

  test('TutorService.explainDeeper sends card front+back and 4-step ask',
      () async {
    final client = _RecordingClient()..response = 'deeper';
    final svc = TutorService(client);
    final card = Flashcard(
      id: 1,
      topicId: 1,
      front: 'What is MITRE ATT&CK?',
      back: 'A knowledge base of adversary tactics and techniques.',
      difficulty: 'beginner',
      tagsJson: '[]',
      createdAt: DateTime.now(),
    );
    final out = await svc.explainDeeper(card: card, topic: 'TI fundamentals');
    expect(out, 'deeper');
    expect(client.lastPrompt!.user, contains('MITRE ATT&CK'));
    expect(client.lastPrompt!.user, contains('knowledge base'));
    expect(client.lastPrompt!.user, contains('1)'));
    expect(client.lastPrompt!.user, contains('Topic: TI fundamentals'));
  });

  test('TutorService.whyWrong sends correct + chosen + heuristic ask',
      () async {
    final client = _RecordingClient()..response = 'because';
    final svc = TutorService(client);
    final q = Question(
      id: 2,
      topicId: 1,
      stem: 'Which is a TTP?',
      explanation: 'Tactics, Techniques, Procedures.',
      qtype: 'single',
      difficulty: 'beginner',
      tagsJson: '[]',
      createdAt: DateTime.now(),
    );
    final opts = [
      const QuestionOption(
          id: 10,
          questionId: 2,
          label: 'A',
          content: 'PowerShell encoded command',
          isCorrect: true,
          orderIndex: 0),
      const QuestionOption(
          id: 11,
          questionId: 2,
          label: 'B',
          content: 'TCP/IP',
          isCorrect: false,
          orderIndex: 1),
    ];
    final out = await svc.whyWrong(
        question: q, options: opts, chosenIds: [11]);
    expect(out, 'because');
    expect(client.lastPrompt!.user, contains('PowerShell'));
    expect(client.lastPrompt!.user, contains('TCP/IP'));
    expect(client.lastPrompt!.user, contains('Correct answer(s)'));
    expect(client.lastPrompt!.user, contains('My answer(s)'));
    expect(client.lastPrompt!.user, contains('Existing explanation'));
  });

  test('LlmException surfaces messages', () async {
    final client = _RecordingClient()..throwError = true;
    final svc = TutorService(client);
    final card = Flashcard(
      id: 1,
      topicId: 1,
      front: 'f',
      back: 'b',
      difficulty: 'beginner',
      tagsJson: '[]',
      createdAt: DateTime.now(),
    );
    expect(svc.explainDeeper(card: card), throwsA(isA<LlmException>()));
  });

  test('Flashcard companion is constructible (sanity)', () async {
    // Just verifies the test schema is in sync.
    final db = AppDatabase.forExecutor(NativeDatabase.memory());
    final s = await db
        .into(db.subjects)
        .insert(SubjectsCompanion.insert(code: 's', title: 't'));
    final c = await db.into(db.chapters).insert(
        ChaptersCompanion.insert(subjectId: s, code: 'c', title: 'c'));
    final t = await db
        .into(db.topics)
        .insert(TopicsCompanion.insert(chapterId: c, code: 't', title: 't'));
    final id = await db.into(db.flashcards).insert(
        FlashcardsCompanion.insert(topicId: t, front: 'f', back: 'b'));
    expect(id, greaterThan(0));
    await db.close();
  });
}
