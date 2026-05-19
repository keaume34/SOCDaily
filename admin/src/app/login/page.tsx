import { redirect } from "next/navigation";

import { isAuthEnabled, isAuthed } from "@/lib/auth";

import { login } from "./actions";

export const dynamic = "force-dynamic";

export default function LoginPage({
  searchParams,
}: {
  searchParams: { error?: string };
}) {
  if (!isAuthEnabled() || isAuthed()) redirect("/");

  return (
    <div className="min-h-screen flex items-center justify-center px-6">
      <form
        action={login}
        className="w-full max-w-sm rounded-2xl border border-white/10 bg-white/[0.04] p-8 space-y-5"
      >
        <header>
          <p className="text-xs uppercase tracking-widest text-ink-300">
            SOCDaily admin
          </p>
          <h1 className="text-2xl font-bold mt-1">Sign in</h1>
        </header>
        <label className="block">
          <span className="block text-xs uppercase tracking-widest text-ink-300 mb-1">
            Password
          </span>
          <input
            type="password"
            name="password"
            autoFocus
            className="w-full rounded-md bg-black/40 border border-white/10 px-3 py-2 text-sm focus:outline-none focus:border-white/40"
          />
        </label>
        {searchParams.error && (
          <p className="text-sm text-rose-300">
            {searchParams.error === "bad"
              ? "Incorrect password."
              : "Please enter a password."}
          </p>
        )}
        <button
          type="submit"
          className="w-full rounded-md bg-white text-black px-4 py-2 text-sm font-medium hover:bg-ink-100"
        >
          Continue
        </button>
      </form>
    </div>
  );
}
