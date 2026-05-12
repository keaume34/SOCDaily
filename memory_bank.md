# SOCDaily — Memory Bank

This document tracks the multi-phase implementation of the SOCDaily learning
app + admin web. Updated after every meaningful change so the next session can
pick up exactly where the previous one stopped.

Conventions:
- "P0", "P1", … = phase number from the plan.
- `[x]` = done & on `main` (or merged).
- `[~]` = in progress on a feature branch.
- `[ ]` = not started.

---

## High-level architecture

```
[Admin Web (Next.js)] ──CRUD──▶ [Supabase Postgres] ◀──pull content──[App (Flutter)]
                                       ▲                                    │
                                       │                          user_state local SQLite
                                 sync user_state ─── 2-way pairing-code ────┘
                                                                            │
[VPS 40 GB] ── HTTP fetch PDF (source_page) ◀────────────────────────────────
```

- **Content** (subjects / chapters / topics / flashcards / questions): source of
  truth is Supabase Postgres. The app caches it in a local SQLite (drift); the
  initial APK ships with a bundled JSON seed so the first launch is fully
  usable offline.
- **User state** (SM-2 schedule, bookmarks, notes, streaks, AI history) is
  written to the local SQLite first and (optionally) synced to Supabase via a
  6-digit pairing code that two devices exchange — no Google login required.
- **PDFs** are large + copyright-sensitive, so they live on the user's VPS
  (40 GB free) and are fetched only when the user opens the "view source"
  action on a card.

## Tech stack

| Layer | Choice | Why |
|---|---|---|
| Mobile / desktop app | **Flutter 3.24** (Dart) | Single codebase → Android, iOS, Windows, macOS, Linux, Web. Native compiled (not webview). |
| Local DB | **drift** on SQLite | Type-safe, reactive queries, mirrors `db/schema.sql`. |
| State | **Riverpod 2** + codegen | Compile-time safety, devtools, testable. |
| Routing | **go_router** | Declarative, deep-link friendly, web-compatible. |
| i18n | `flutter_localizations` + `intl` | Default `en`, also `vi`. Strings live in `assets/i18n/` + ARB later. |
| Charts | `fl_chart` | Heatmap, streak, accuracy graphs. |
| AI | OpenAI-compat + Anthropic via Dio | Mirrors the Python pipeline's provider-agnostic design. User supplies their own API key in Settings. |
| Admin web | Next.js 14 + Tailwind + shadcn/ui | Fast, modern, talks directly to Supabase via service-role key. |
| Backend sync | Supabase free tier (Postgres 500 MB + Storage 1 GB) | Content + user-state delta sync. |
| PDF host | VPS 40 GB | Storage cost free, only fetched on demand. |

## Languages

- **Default UI**: English. Also Vietnamese (vi).
- **Generated content language** stays as configured by the Python pipeline
  (`SOCDAILY_CONTENT_LANG=vi` by default), but the app shell + menus + buttons
  follow the device locale falling back to `en`.

## Design system

- **Primary motif**: monochrome gradients (black ↔ near-black in dark mode;
  white ↔ near-white in light mode) for surfaces — gives the "professional"
  vibe the user asked for.
- **Accent**: user-selectable per profile (blue, purple, red, green, …). The
  accent always pairs with white or black in a soft gradient so the look stays
  clean.
- **Material 3** with a custom `ColorScheme.fromSeed`-style generator that
  wraps both the accent and the monochrome surface palette.
- **Motion**: brief, purposeful — flashcard flip, MCQ option pop-in, streak
  ring tween.

---

## Phase progress

- **P0 — Scaffold & memory bank** [x]
  - [x] Repo audit + plan
  - [x] Memory bank doc (this file)
  - [x] Flutter app scaffold under `app/`
  - [x] Architecture doc `ARCHITECTURE.md`
  - [x] Phase-0 PR pushed to GitHub (#2)

- **P1 — Theme + navigation shell + i18n + Settings** [x]
  - [x] Custom Material 3 theme + monochrome gradient surfaces
  - [x] `AppAccent` enum with 6 presets (graphite/azure/violet/crimson/forest/amber)
  - [x] `GradientBackground` + `AccentChip` shared widgets
  - [x] Bottom-nav shell via `StatefulShellRoute` (Home, Browse, Study, Stats, Settings)
  - [x] Riverpod-backed `SettingsController` persisting `themeMode`, `accent`, `locale` via `shared_preferences`
  - [x] Settings screen with theme picker + accent swatches + language picker
  - [x] i18n via Flutter ARB (en default + vi); l10n.yaml config
  - [x] Smoke widget test (`flutter test` + `flutter analyze` clean)
  - [x] PR #3 pushed

- **P2 — Local SQLite (drift) + seed import + Browse** [x]
  - [x] Drift schema mirroring `db/schema.sql` + user-state tables (`user_bookmarks`, `user_notes`, `user_sessions`, `user_streak`)
  - [x] Generated `app_database.g.dart` via build_runner
  - [x] `ContentRepository` + Riverpod providers (`subjectsProvider`, `chaptersProvider`, `topicsProvider`)
  - [x] Bundled sample seed JSONs (4 topics covering SOC Fundamentals + Blue Team) at `app/assets/seed/`
  - [x] `SeedImporter` (idempotent) + `seedBootstrapProvider`
  - [x] Browse screen: Subject → Chapter → Topic list with counts; tapping topic opens placeholder study screen
  - [x] 4 drift schema tests + smoke widget test still passing
  - [x] PR #4 pushed

- **P3 — Flashcard flip + MCQ + explanation** [x]
  - [x] `FlashcardView` widget: 3D Y-axis flip + tap-to-flip + swipe-to-next, optional hint surface, tag chips
  - [x] `McqView` widget: single/multiple/T-F, pre-submit selection state, post-submit correctness coloring + explanation card
  - [x] `StudySessionController` (AsyncNotifier family): loads all flashcards + MCQs for topic, walks index, tracks ratings + correctness, accuracy stat
  - [x] `TopicStudyScreen` full Phase-3 player: progress bar, exit button, flashcard rating row (Again/Hard/Good/Easy), MCQ submit/next, "Session complete" summary
  - [x] 4 session-controller tests against in-memory drift DB
  - [x] PR #5 pushed

- **P4 — SM-2 spaced repetition + Today queue** [~]
  - [x] Pure SM-2 algorithm in `lib/src/features/study/sm2.dart` (Anki-style Again/Hard/Good/Easy → q0/q2/q4/q5)
  - [x] `UserStateRepository` persists per-card `UserCardState` (ease/interval/nextReview/reviewCount/lastResult) + per-question `UserQuestionState` (attempts/correct/lastAttempt/lastChoice)
  - [x] `dueFlashcards()` query: includes never-reviewed cards + cards with `nextReview <= now`
  - [x] `dueCountsProvider`: total / new / due rollups for Home dashboard
  - [x] `TodayReviewScreen` at `/study/today` — full-screen flashcard-only review queue
  - [x] Home dashboard chips show real `Due / New` counts; "Start session" CTA routes to Today queue
  - [x] `StudySessionController` writes SM-2 + MCQ state to DB on each grade/submit
  - [x] 6 SM-2 progression tests + 6 user-state-repo tests + existing 9 still pass (total 21)
- **P5 — Bookmarks + per-card notes + FTS search** [ ]
- **P6 — Stats / streak / heatmap** [ ]
- **P7 — AI Settings + "Explain deeper" + "Why was I wrong?"** [ ]
- **P8 — Daily Challenge + Quiz mock exam + Cheatsheet** [ ]
- **P9 — Pomodoro + export certificate** [ ]
- **P10 — Admin web (Next.js)** [ ]
- **P11 — Sync 2-way via Supabase + pairing code** [ ]
- **P12 — PDF source viewer (VPS-hosted)** [ ]

---

## Open questions / blockers

1. Supabase project credentials needed before P11 — will request when the
   phase starts.
2. VPS SSH / domain needed before P12 — will request when the phase starts.
3. AI key strategy: the app expects each user to supply their own OpenAI /
   Anthropic key in Settings. No shared key ships with the app.

---

## Conventions

- One PR per phase. Branch name: `devin/<unix-ts>-phaseN-<slug>`.
- Each PR updates the relevant `[x]` row above before merge.
- All Dart code must pass `flutter analyze` and `flutter test` before push.
- All TypeScript code (admin web) must pass `pnpm lint && pnpm typecheck` and
  `pnpm build` before push.
- The Python pipeline in `src/socdaily/` keeps its `ruff` + `pytest` checks.
