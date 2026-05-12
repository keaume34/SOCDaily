import Link from "next/link";
import { redirect } from "next/navigation";

import { isAuthEnabled, isAuthed } from "@/lib/auth";
import { loadLibrary, topicKey } from "@/lib/content";

export const dynamic = "force-dynamic";

export default async function LibraryPage() {
  if (isAuthEnabled() && !isAuthed()) redirect("/login");

  const lib = await loadLibrary();

  return (
    <div className="max-w-5xl mx-auto px-6 py-10">
      <header className="mb-8">
        <p className="text-xs uppercase tracking-widest text-ink-300">
          Subjects → chapters → topics
        </p>
        <h1 className="text-4xl font-bold mt-1">Library</h1>
      </header>

      <ol className="space-y-8">
        {lib.manifest.subjects
          .slice()
          .sort((a, b) => a.order_index - b.order_index)
          .map((subject) => (
            <li
              key={subject.code}
              className="rounded-xl border border-white/10 bg-white/[0.03] overflow-hidden"
            >
              <div className="px-5 py-4 border-b border-white/5 flex items-baseline justify-between">
                <div>
                  <h2 className="text-xl font-semibold">{subject.title}</h2>
                  {subject.description && (
                    <p className="text-sm text-ink-300 mt-0.5">
                      {subject.description}
                    </p>
                  )}
                </div>
                <span className="text-xs uppercase tracking-widest text-ink-400">
                  {subject.code}
                </span>
              </div>
              <div className="divide-y divide-white/5">
                {subject.chapters
                  .slice()
                  .sort((a, b) => a.order_index - b.order_index)
                  .map((chapter) => (
                    <div key={chapter.code} className="px-5 py-4">
                      <h3 className="text-sm font-medium text-ink-100">
                        {chapter.title}
                      </h3>
                      <ul className="mt-3 grid gap-2">
                        {chapter.topics
                          .slice()
                          .sort((a, b) => a.order_index - b.order_index)
                          .map((t) => {
                            const ref = {
                              subject_code: subject.code,
                              chapter_code: chapter.code,
                              topic_code: t.code,
                              file: "", // unused in URL
                            };
                            const k = topicKey(ref);
                            const summary = lib.topics.get(k);
                            const target = `/library/${subject.code}/${chapter.code}/${t.code}`;
                            return (
                              <li key={t.code}>
                                <Link
                                  href={target}
                                  className="flex items-baseline justify-between rounded-md px-3 py-2 hover:bg-white/5"
                                >
                                  <span className="text-sm">
                                    {summary?.title ?? t.code}
                                  </span>
                                  <span className="text-xs text-ink-400 tabular-nums">
                                    {summary
                                      ? `${summary.flashcards}fc · ${summary.questions}q`
                                      : "—"}
                                  </span>
                                </Link>
                              </li>
                            );
                          })}
                      </ul>
                    </div>
                  ))}
              </div>
            </li>
          ))}
      </ol>
    </div>
  );
}
