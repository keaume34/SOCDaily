import type { Metadata } from "next";
import type { ReactNode } from "react";
import Link from "next/link";

import "./globals.css";

import { cn } from "@/lib/util";

export const metadata: Metadata = {
  title: "SOCDaily Admin",
  description: "Edit the SOCDaily content bank used by the Flutter app.",
};

const NAV: { href: string; label: string }[] = [
  { href: "/", label: "Dashboard" },
  { href: "/library", label: "Library" },
  { href: "/pipeline", label: "Pipeline" },
  { href: "/settings", label: "Settings" },
];

export default function RootLayout({ children }: { children: ReactNode }) {
  return (
    <html lang="en">
      <body className="min-h-screen bg-gradient-deck text-ink-50 font-sans antialiased">
        <div className="min-h-screen flex">
          <aside className="hidden md:flex flex-col w-60 bg-black/30 border-r border-white/5 px-4 py-6">
            <Link
              href="/"
              className="flex items-center gap-2 px-2 mb-8"
            >
              <span className="inline-flex h-9 w-9 items-center justify-center rounded-md bg-white text-black font-black tracking-tight">
                SD
              </span>
              <span className="font-semibold text-lg tracking-tight">
                SOCDaily
                <span className="ml-1 text-xs uppercase tracking-widest text-ink-300">
                  admin
                </span>
              </span>
            </Link>
            <nav className="flex flex-col gap-1">
              {NAV.map((item) => (
                <Link
                  key={item.href}
                  href={item.href}
                  className={cn(
                    "rounded-md px-3 py-2 text-sm text-ink-200 hover:bg-white/5 hover:text-white",
                  )}
                >
                  {item.label}
                </Link>
              ))}
            </nav>
            <div className="mt-auto text-xs text-ink-400 px-2 leading-relaxed">
              <p>SOCDaily admin — edits the JSON bank consumed by the
                Flutter app.</p>
            </div>
          </aside>
          <main className="flex-1 min-w-0">{children}</main>
        </div>
      </body>
    </html>
  );
}
