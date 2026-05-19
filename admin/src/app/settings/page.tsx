import { redirect } from "next/navigation";

import { isAuthEnabled, isAuthed } from "@/lib/auth";
import { seedRoot } from "@/lib/content";

export const dynamic = "force-dynamic";

export default function SettingsPage() {
  if (isAuthEnabled() && !isAuthed()) redirect("/login");

  const entries: { label: string; value: string }[] = [
    { label: "Seed directory", value: seedRoot() },
    {
      label: "Auth mode",
      value: isAuthEnabled() ? "Password (ADMIN_PASSWORD set)" : "Open",
    },
    { label: "Node version", value: process.version },
  ];

  return (
    <div className="max-w-3xl mx-auto px-6 py-10">
      <header className="mb-8">
        <p className="text-xs uppercase tracking-widest text-ink-300">
          Admin runtime
        </p>
        <h1 className="text-4xl font-bold mt-1">Settings</h1>
      </header>

      <dl className="grid sm:grid-cols-2 gap-3">
        {entries.map((e) => (
          <div
            key={e.label}
            className="rounded-lg border border-white/10 bg-white/[0.04] p-4"
          >
            <dt className="text-xs uppercase tracking-widest text-ink-300">
              {e.label}
            </dt>
            <dd className="mt-1 font-mono text-sm break-all">{e.value}</dd>
          </div>
        ))}
      </dl>

      <section className="mt-10">
        <h2 className="text-lg font-semibold mb-3">How to configure</h2>
        <p className="text-sm text-ink-200">
          The admin is configured via environment variables. See{" "}
          <code className="px-1.5 py-0.5 rounded bg-white/10">.env.example</code>{" "}
          at the admin root.
        </p>
      </section>
    </div>
  );
}
