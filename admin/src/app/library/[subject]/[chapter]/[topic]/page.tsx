import Link from "next/link";
import { notFound, redirect } from "next/navigation";

import { isAuthEnabled, isAuthed } from "@/lib/auth";
import { findTopicRef, readManifest, readTopic } from "@/lib/content";

import { TopicEditor } from "./TopicEditor";

export const dynamic = "force-dynamic";

export default async function TopicEditPage({
  params,
}: {
  params: { subject: string; chapter: string; topic: string };
}) {
  if (isAuthEnabled() && !isAuthed()) redirect("/login");
  const manifest = await readManifest();
  const ref = findTopicRef(
    manifest,
    params.subject,
    params.chapter,
    params.topic,
  );
  if (!ref) notFound();
  const topic = await readTopic(ref);

  return (
    <div className="max-w-5xl mx-auto px-6 py-10">
      <header className="mb-8">
        <Link href="/library" className="text-sm text-ink-300 hover:text-white">
          ← Library
        </Link>
        <p className="text-xs uppercase tracking-widest text-ink-300 mt-3">
          {topic.subject_title} · {topic.chapter_title}
        </p>
        <h1 className="text-3xl font-bold mt-1">{topic.topic_title}</h1>
        <p className="mt-1 text-sm text-ink-400 font-mono">{ref.file}</p>
      </header>

      <TopicEditor
        topic={topic}
        subjectCode={params.subject}
        chapterCode={params.chapter}
        topicCode={params.topic}
      />
    </div>
  );
}
