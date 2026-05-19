import Link from "next/link";
import { redirect } from "next/navigation";

import { isAuthEnabled, isAuthed } from "@/lib/auth";
import { seedRoot } from "@/lib/content";

export const dynamic = "force-dynamic";

export default function PipelinePage() {
  if (isAuthEnabled() && !isAuthed()) redirect("/login");

  const steps: { title: string; cmd: string; note: string }[] = [
    {
      title: "1 — Ingest a PDF",
      cmd: "socdaily ingest path/to/source.pdf",
      note: "Extracts page-tagged markdown to raw/markdown/<name>.md.",
    },
    {
      title: "2 — Build an outline",
      cmd: "socdaily outline raw/markdown/<name>.md",
      note: "LLM produces a Subject → Chapter → Topic outline YAML.",
    },
    {
      title: "3 — Generate flashcards + MCQs",
      cmd: "socdaily generate outline/<name>.yaml",
      note: "LLM emits seed JSON per topic with source-page citations.",
    },
    {
      title: "4 — Import into SQLite",
      cmd: "socdaily db-import seed/",
      note: "Idempotent upsert into db/socdaily.db.",
    },
  ];

  return (
    <div className="max-w-3xl mx-auto px-6 py-10">
      <header className="mb-8">
        <p className="text-xs uppercase tracking-widest text-ink-300">
          Python pipeline
        </p>
        <h1 className="text-4xl font-bold mt-1">Pipeline</h1>
        <p className="mt-3 text-ink-200">
          The admin web edits JSON files in{" "}
          <code className="px-1.5 py-0.5 rounded bg-white/10">
            {seedRoot()}
          </code>{" "}
          directly. To produce <em>new</em> topics from PDFs, run the Python
          pipeline. These commands are documented here for convenience — they
          run on the host (not inside the admin web).
        </p>
      </header>
      <ol className="space-y-4">
        {steps.map((s) => (
          <li
            key={s.title}
            className="rounded-lg border border-white/10 bg-white/[0.04] p-4"
          >
            <p className="font-medium">{s.title}</p>
            <pre className="mt-2 rounded bg-black/40 px-3 py-2 text-xs font-mono whitespace-pre-wrap">
              {s.cmd}
            </pre>
            <p className="text-sm text-ink-300 mt-2">{s.note}</p>
          </li>
        ))}
      </ol>
      <p className="text-sm text-ink-300 mt-8">
        Full reference:{" "}
        <Link
          href="https://github.com/keaume34/SOCDaily/blob/main/README.md"
          className="underline"
        >
          README
        </Link>
        .
      </p>
    </div>
  );
}
