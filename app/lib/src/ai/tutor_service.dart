// Tutor service: builds the two MVP prompts ("explain deeper" + "why was I
// wrong?") and runs them through whatever [LlmClient] is currently
// configured.

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/db/app_database.dart';
import 'ai_settings.dart';
import 'llm_client.dart';

class TutorService {
  TutorService(this._client);
  final LlmClient _client;

  static const String _systemPrompt =
      'You are a friendly SOC analyst study tutor. Explain in clear, '
      'concrete terms with concrete examples from real Security Operations '
      'Centre workflows. Keep answers focused and under 200 words unless '
      'the user asks for more. Never invent CVEs, RFC numbers, or '
      'product features you are not 100% sure about — say "I do not know" '
      'instead. Markdown is OK (bold/lists), no headings.';

  Future<String> explainDeeper({
    required Flashcard card,
    String? subject,
    String? topic,
  }) {
    final buf = StringBuffer()
      ..writeln('Explain this flashcard in more depth.')
      ..writeln()
      ..writeln('Front: ${card.front}')
      ..writeln('Back: ${card.back}');
    if (subject != null && subject.isNotEmpty) {
      buf.writeln('Subject: $subject');
    }
    if (topic != null && topic.isNotEmpty) {
      buf.writeln('Topic: $topic');
    }
    buf.writeln();
    buf.writeln('Give a 4-step breakdown:');
    buf.writeln('1) Why this matters in a SOC.');
    buf.writeln('2) One concrete real-world example.');
    buf.writeln('3) A common misconception or pitfall.');
    buf.writeln('4) A 1-sentence memorable summary.');
    return _client.complete(
      TutorPrompt(system: _systemPrompt, user: buf.toString()),
    );
  }

  Future<String> whyWrong({
    required Question question,
    required List<QuestionOption> options,
    required Iterable<int> chosenIds,
  }) {
    final correctLabels = options
        .where((o) => o.isCorrect)
        .map((o) => '${o.label}) ${o.content}')
        .join(' | ');
    final chosenLabels = options
        .where((o) => chosenIds.contains(o.id))
        .map((o) => '${o.label}) ${o.content}')
        .join(' | ');
    final allLabels = options
        .map((o) => '${o.label}) ${o.content}')
        .join('\n');
    final buf = StringBuffer()
      ..writeln('Explain why my answer was wrong.')
      ..writeln()
      ..writeln('Question: ${question.stem}')
      ..writeln('Options:')
      ..writeln(allLabels)
      ..writeln()
      ..writeln('Correct answer(s): $correctLabels')
      ..writeln('My answer(s): $chosenLabels')
      ..writeln()
      ..writeln('Tell me:')
      ..writeln(
          '1) What my choice gets wrong (be specific about the misconception).')
      ..writeln('2) Why the correct answer is correct.')
      ..writeln('3) A short heuristic to spot this trap next time.');
    if (question.explanation != null && question.explanation!.isNotEmpty) {
      buf
        ..writeln()
        ..writeln('Existing explanation for context: ${question.explanation}');
    }
    return _client.complete(
      TutorPrompt(system: _systemPrompt, user: buf.toString()),
    );
  }
}

final tutorServiceProvider = Provider<TutorService>((ref) {
  return TutorService(ref.watch(llmClientProvider));
});
