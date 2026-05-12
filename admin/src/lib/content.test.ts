import { promises as fs } from "node:fs";
import os from "node:os";
import path from "node:path";

import { afterEach, beforeEach, describe, expect, it } from "vitest";

const SAMPLE_MANIFEST = {
  version: 1,
  generated_at: "2025-01-01",
  subjects: [
    {
      code: "subj",
      title: "Subject",
      description: "d",
      order_index: 0,
      chapters: [
        {
          code: "chap",
          title: "Chapter",
          order_index: 0,
          topics: [{ code: "topic", order_index: 0 }],
        },
      ],
    },
  ],
  topics: [
    {
      subject_code: "subj",
      chapter_code: "chap",
      topic_code: "topic",
      file: "subj/chap/topic.json",
    },
  ],
};

const SAMPLE_TOPIC = {
  subject_code: "subj",
  subject_title: "Subject",
  chapter_code: "chap",
  chapter_title: "Chapter",
  topic_code: "topic",
  topic_title: "Topic",
  topic_summary: "summary",
  flashcards: [
    {
      front: "F1",
      back: "B1",
      difficulty: "easy" as const,
      tags: ["t"],
      source_page: 1,
    },
  ],
  questions: [
    {
      qtype: "single" as const,
      stem: "S?",
      options: [
        { label: "A", content: "A", is_correct: true },
        { label: "B", content: "B", is_correct: false },
      ],
      explanation: "E",
      difficulty: "easy" as const,
      tags: ["q"],
      source_page: 2,
    },
  ],
};

describe("content data layer", () => {
  let tmp: string;

  beforeEach(async () => {
    tmp = await fs.mkdtemp(path.join(os.tmpdir(), "socdaily-admin-"));
    process.env.SOCDAILY_SEED_DIR = tmp;
    await fs.writeFile(
      path.join(tmp, "manifest.json"),
      JSON.stringify(SAMPLE_MANIFEST, null, 2),
    );
    await fs.mkdir(path.join(tmp, "subj", "chap"), { recursive: true });
    await fs.writeFile(
      path.join(tmp, "subj", "chap", "topic.json"),
      JSON.stringify(SAMPLE_TOPIC, null, 2),
    );
  });

  afterEach(async () => {
    await fs.rm(tmp, { recursive: true, force: true });
  });

  it("loads library totals from manifest + topic files", async () => {
    const mod = await import("./content");
    const lib = await mod.loadLibrary();
    expect(lib.totals.subjects).toBe(1);
    expect(lib.totals.chapters).toBe(1);
    expect(lib.totals.topics).toBe(1);
    expect(lib.totals.flashcards).toBe(1);
    expect(lib.totals.questions).toBe(1);
  });

  it("readTopic round-trips with writeTopic", async () => {
    const mod = await import("./content");
    const manifest = await mod.readManifest();
    const ref = manifest.topics[0]!;
    const topic = await mod.readTopic(ref);
    topic.flashcards.push({
      front: "F2",
      back: "B2",
      difficulty: "medium",
      tags: [],
      source_page: null,
    });
    await mod.writeTopic(ref, topic);
    const again = await mod.readTopic(ref);
    expect(again.flashcards).toHaveLength(2);
    expect(again.flashcards[1]!.front).toBe("F2");
  });

  it("findTopicRef returns null for missing topics", async () => {
    const mod = await import("./content");
    const manifest = await mod.readManifest();
    expect(mod.findTopicRef(manifest, "subj", "chap", "topic")).not.toBeNull();
    expect(mod.findTopicRef(manifest, "x", "y", "z")).toBeNull();
  });
});
