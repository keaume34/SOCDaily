// Admin web — content data layer. Reads/writes the JSON seed bank that
// the Flutter app bundles. This is intentionally file-backed so the same
// pipeline (Python → JSON → app) keeps working: the admin web just edits
// the JSON in place. In P11 this same interface will be re-implemented
// against Supabase.

import { promises as fs } from "node:fs";
import path from "node:path";

function seedRootPath(): string {
  const env = process.env.SOCDAILY_SEED_DIR;
  if (env && path.isAbsolute(env)) return env;
  return path.resolve(process.cwd(), env ?? "../app/assets/seed");
}

export type Difficulty = "easy" | "medium" | "hard";

export type QuestionType = "single" | "multiple" | "truefalse" | "scenario";

export interface Flashcard {
  front: string;
  back: string;
  hint?: string | null;
  difficulty: Difficulty;
  tags: string[];
  source_page?: number | null;
}

export interface QuestionOption {
  label: string;
  content: string;
  is_correct: boolean;
}

export interface Question {
  qtype: QuestionType;
  stem: string;
  options: QuestionOption[];
  explanation: string;
  difficulty: Difficulty;
  tags: string[];
  source_page?: number | null;
}

export interface TopicFile {
  subject_code: string;
  subject_title: string;
  chapter_code: string;
  chapter_title: string;
  topic_code: string;
  topic_title: string;
  topic_summary?: string;
  source_pdf?: string;
  flashcards: Flashcard[];
  questions: Question[];
}

export interface ManifestTopicRef {
  subject_code: string;
  chapter_code: string;
  topic_code: string;
  file: string;
}

export interface ManifestChapter {
  code: string;
  title: string;
  order_index: number;
  topics: { code: string; order_index: number }[];
}

export interface ManifestSubject {
  code: string;
  title: string;
  description?: string;
  order_index: number;
  chapters: ManifestChapter[];
}

export interface Manifest {
  version: number;
  generated_at: string;
  subjects: ManifestSubject[];
  topics: ManifestTopicRef[];
}

export interface TopicSummary {
  ref: ManifestTopicRef;
  title: string;
  flashcards: number;
  questions: number;
}

export interface LibraryTree {
  manifest: Manifest;
  topics: Map<string, TopicSummary>;
  totals: {
    subjects: number;
    chapters: number;
    topics: number;
    flashcards: number;
    questions: number;
  };
}

function manifestPath(): string {
  return path.join(seedRootPath(), "manifest.json");
}

export function seedRoot(): string {
  return seedRootPath();
}

async function readJson<T>(p: string): Promise<T> {
  const raw = await fs.readFile(p, "utf8");
  return JSON.parse(raw) as T;
}

export async function readManifest(): Promise<Manifest> {
  return readJson<Manifest>(manifestPath());
}

export function topicKey(ref: ManifestTopicRef): string {
  return `${ref.subject_code}/${ref.chapter_code}/${ref.topic_code}`;
}

export async function readTopic(ref: ManifestTopicRef): Promise<TopicFile> {
  return readJson<TopicFile>(path.join(seedRootPath(), ref.file));
}

export async function writeTopic(
  ref: ManifestTopicRef,
  data: TopicFile,
): Promise<void> {
  const target = path.join(seedRootPath(), ref.file);
  const json = JSON.stringify(data, null, 2) + "\n";
  await fs.writeFile(target, json, "utf8");
}

export async function loadLibrary(): Promise<LibraryTree> {
  const manifest = await readManifest();
  const topics = new Map<string, TopicSummary>();
  let totalFlash = 0;
  let totalQ = 0;
  let topicCount = 0;
  let chapterCount = 0;

  for (const ref of manifest.topics) {
    const data = await readTopic(ref);
    topics.set(topicKey(ref), {
      ref,
      title: data.topic_title,
      flashcards: data.flashcards.length,
      questions: data.questions.length,
    });
    totalFlash += data.flashcards.length;
    totalQ += data.questions.length;
    topicCount += 1;
  }
  for (const subject of manifest.subjects) {
    chapterCount += subject.chapters.length;
  }

  return {
    manifest,
    topics,
    totals: {
      subjects: manifest.subjects.length,
      chapters: chapterCount,
      topics: topicCount,
      flashcards: totalFlash,
      questions: totalQ,
    },
  };
}

export function findTopicRef(
  manifest: Manifest,
  subjectCode: string,
  chapterCode: string,
  topicCode: string,
): ManifestTopicRef | null {
  return (
    manifest.topics.find(
      (t) =>
        t.subject_code === subjectCode &&
        t.chapter_code === chapterCode &&
        t.topic_code === topicCode,
    ) ?? null
  );
}
