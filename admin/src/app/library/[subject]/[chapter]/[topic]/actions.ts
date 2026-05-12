"use server";

import { revalidatePath } from "next/cache";

import {
  findTopicRef,
  readManifest,
  readTopic,
  writeTopic,
  type Difficulty,
  type Flashcard,
  type Question,
  type QuestionOption,
  type QuestionType,
} from "@/lib/content";

const DIFFICULTIES: Difficulty[] = ["easy", "medium", "hard"];
const QTYPES: QuestionType[] = ["single", "multiple", "truefalse", "scenario"];

export interface SaveResult {
  ok: boolean;
  error?: string;
  saved?: { flashcards: number; questions: number };
}

function asString(v: FormDataEntryValue | null, fallback = ""): string {
  return typeof v === "string" ? v : fallback;
}

function asDifficulty(v: FormDataEntryValue | null): Difficulty {
  const s = asString(v, "medium").toLowerCase();
  return (DIFFICULTIES as readonly string[]).includes(s)
    ? (s as Difficulty)
    : "medium";
}

function asQtype(v: FormDataEntryValue | null): QuestionType {
  const s = asString(v, "single").toLowerCase();
  return (QTYPES as readonly string[]).includes(s)
    ? (s as QuestionType)
    : "single";
}

function asTags(v: FormDataEntryValue | null): string[] {
  return asString(v)
    .split(",")
    .map((t) => t.trim())
    .filter(Boolean);
}

function asPage(v: FormDataEntryValue | null): number | null {
  const s = asString(v).trim();
  if (!s) return null;
  const n = Number.parseInt(s, 10);
  return Number.isFinite(n) ? n : null;
}

export async function saveTopic(
  subjectCode: string,
  chapterCode: string,
  topicCode: string,
  form: FormData,
): Promise<SaveResult> {
  const manifest = await readManifest();
  const ref = findTopicRef(manifest, subjectCode, chapterCode, topicCode);
  if (!ref) return { ok: false, error: "Topic not found in manifest." };
  const current = await readTopic(ref);

  const flashCount = Number.parseInt(asString(form.get("flashcards_count"), "0"), 10) || 0;
  const questionCount = Number.parseInt(asString(form.get("questions_count"), "0"), 10) || 0;

  const flashcards: Flashcard[] = [];
  for (let i = 0; i < flashCount; i++) {
    if (asString(form.get(`fc_${i}_delete`)) === "1") continue;
    const front = asString(form.get(`fc_${i}_front`)).trim();
    const back = asString(form.get(`fc_${i}_back`)).trim();
    if (!front || !back) continue; // skip empty rows
    flashcards.push({
      front,
      back,
      hint: asString(form.get(`fc_${i}_hint`)).trim() || null,
      difficulty: asDifficulty(form.get(`fc_${i}_difficulty`)),
      tags: asTags(form.get(`fc_${i}_tags`)),
      source_page: asPage(form.get(`fc_${i}_page`)),
    });
  }

  // Optional new flashcard.
  const newFront = asString(form.get("fc_new_front")).trim();
  const newBack = asString(form.get("fc_new_back")).trim();
  if (newFront && newBack) {
    flashcards.push({
      front: newFront,
      back: newBack,
      hint: asString(form.get("fc_new_hint")).trim() || null,
      difficulty: asDifficulty(form.get("fc_new_difficulty")),
      tags: asTags(form.get("fc_new_tags")),
      source_page: asPage(form.get("fc_new_page")),
    });
  }

  const questions: Question[] = [];
  for (let i = 0; i < questionCount; i++) {
    if (asString(form.get(`q_${i}_delete`)) === "1") continue;
    const stem = asString(form.get(`q_${i}_stem`)).trim();
    if (!stem) continue;
    const optCount =
      Number.parseInt(asString(form.get(`q_${i}_opt_count`), "0"), 10) || 0;
    const options: QuestionOption[] = [];
    for (let j = 0; j < optCount; j++) {
      const label = asString(form.get(`q_${i}_opt_${j}_label`)).trim();
      const content = asString(form.get(`q_${i}_opt_${j}_content`)).trim();
      if (!content) continue;
      options.push({
        label: label || String.fromCharCode(65 + j),
        content,
        is_correct:
          asString(form.get(`q_${i}_opt_${j}_correct`)) === "1",
      });
    }
    if (options.length === 0) continue;
    questions.push({
      qtype: asQtype(form.get(`q_${i}_qtype`)),
      stem,
      options,
      explanation: asString(form.get(`q_${i}_explanation`)).trim(),
      difficulty: asDifficulty(form.get(`q_${i}_difficulty`)),
      tags: asTags(form.get(`q_${i}_tags`)),
      source_page: asPage(form.get(`q_${i}_page`)),
    });
  }

  const next = {
    ...current,
    topic_title:
      asString(form.get("topic_title")).trim() || current.topic_title,
    topic_summary:
      asString(form.get("topic_summary")).trim() ||
      current.topic_summary,
    flashcards,
    questions,
  };

  await writeTopic(ref, next);
  revalidatePath(`/library/${subjectCode}/${chapterCode}/${topicCode}`);
  revalidatePath("/library");
  revalidatePath("/");
  return {
    ok: true,
    saved: { flashcards: flashcards.length, questions: questions.length },
  };
}
