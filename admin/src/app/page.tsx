import { redirect } from "next/navigation";

import { isAuthEnabled, isAuthed } from "@/lib/auth";
import { loadLibrary, seedRoot } from "@/lib/content";
import { formatNumber } from "@/lib/util";

export const dynamic = "force-dynamic";

export default async function DashboardPage() {
  if (isAuthEnabled() && !isAuthed()) redirect("/login");

  const lib = await loadLibrary();

  const stats: { label: string; value: string; sub: string }[] = [
    {
      label: "Subjects",
      value: formatNumber(lib.totals.subjects),
      sub: "top-level taxonomy",
    },
    {
      label: "Chapters",
      value: formatNumber(lib.totals.chapters),
      sub: "across all subjects",
    },
    {
      label: "Topics",
      value: formatNumber(lib.totals.topics),
      sub: "leaf nodes",
    },
    {
      label: "Flashcards",
      value: formatNumber(lib.totals.flashcards),
      sub: "front / back cards",
    },
    {
      label: "Questions",
      value: formatNumber(lib.totals.questions),
      sub: "MCQ / scenario",
    },
  ];

  return (
    <div className="max-w-5xl mx-auto px-6 py-10">
      <header className="mb-10">
        <p className="text-xs uppercase tracking-widest text-ink-300">
          Content bank
        </p>
        <h1 className="text-4xl font-bold mt-1">Dashboard</h1>
        <p className="mt-3 text-ink-200">
          You are editing JSON files in{" "}
          <code className="px-1.5 py-0.5 rounded bg-white/10 text-ink-50">
            {seedRoot()}
          </code>
          . Saved changes are picked up by the next build of the Flutter
          app.
        </p>
      </header>

      <section className="grid grid-cols-2 md:grid-cols-5 gap-4">
        {stats.map((s) => (
          <div
            key={s.label}
            className="rounded-xl bg-white/5 border border-white/10 px-4 py-5"
          >
            <div className="text-3xl font-semibold tracking-tight">
              {s.value}
            </div>
            <div className="mt-1 text-sm text-ink-100">{s.label}</div>
            <div className="text-xs text-ink-300 mt-0.5">{s.sub}</div>
          </div>
        ))}
      </section>

      <section className="mt-10">
        <h2 className="text-xl font-semibold mb-4">Quick links</h2>
        <ul className="grid sm:grid-cols-2 gap-3">
          <li>
            <a
              href="/library"
              className="block rounded-xl border border-white/10 px-5 py-4 hover:bg-white/5"
            >
              <p className="font-medium">Browse library →</p>
              <p className="text-sm text-ink-300 mt-1">
                Drill into subjects → chapters → topics, edit content.
              </p>
            </a>
          </li>
          <li>
            <a
              href="/pipeline"
              className="block rounded-xl border border-white/10 px-5 py-4 hover:bg-white/5"
            >
              <p className="font-medium">Pipeline status →</p>
              <p className="text-sm text-ink-300 mt-1">
                Inspect the Python ETL pipeline that produced this bank.
              </p>
            </a>
          </li>
        </ul>
      </section>
    </div>
  );
}
