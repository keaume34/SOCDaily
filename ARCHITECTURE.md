# SOCDaily Architecture

This document is the steady-state reference for how the SOCDaily project is
laid out. For *what is in progress right now*, see `memory_bank.md`.

## Repo layout (target)

```
SOCDaily/
├── app/                       Flutter learning app (this PR scaffolds it)
│   ├── lib/
│   │   ├── main.dart
│   │   └── src/
│   │       ├── app/           MaterialApp + router
│   │       ├── core/          shared utilities (logger, result types)
│   │       ├── data/
│   │       │   ├── db/        drift SQLite schema + DAOs
│   │       │   └── seed/      JSON seed loader
│   │       ├── features/
│   │       │   ├── home/
│   │       │   ├── browse/    Subject → Chapter → Topic navigation
│   │       │   ├── study/     Flashcards + MCQ player
│   │       │   ├── quiz/      Timed mock exam
│   │       │   ├── daily/     Daily challenge
│   │       │   ├── cheatsheet/
│   │       │   ├── timer/     Pomodoro
│   │       │   ├── stats/     Streak, heatmap, accuracy
│   │       │   └── settings/
│   │       ├── l10n/          generated strings (en + vi)
│   │       └── theme/         gradient + accent system
│   ├── assets/
│   │   ├── seed/              JSON shipped with the APK for offline-first
│   │   └── i18n/              ARB / JSON translations
│   ├── test/
│   └── pubspec.yaml
├── admin/                     Next.js admin web (P10)
├── db/                        original SQLite schema (Python pipeline source)
├── outline/                   YAML outlines (Python pipeline output)
├── raw/                       PDF + markdown (gitignored)
├── seed/                      JSON cards/questions (Python pipeline output)
├── src/socdaily/              Python ingest + LLM pipeline (existing)
├── tests/                     Python tests
├── memory_bank.md             multi-phase progress log
├── ARCHITECTURE.md            this file
├── README.md
└── pyproject.toml
```

## Data flow

```
PDFs   ──python pipeline──▶  seed/*.json  ──┬──▶ app/assets/seed/  (bundled)
                                            │
                                            └──▶ Supabase Postgres   (admin web edits here)
                                                       │
                                                       └──▶ app pulls deltas (P11)
```

User state:

```
app local SQLite ───┐
                    ├── sync (P11) ──▶ Supabase user_state rows
device A ↔ device B ┘   keyed by pairing code (6 digits, TTL 10 min)
```

PDF viewing:

```
app  ──HTTPS──▶  https://<user-vps>/pdfs/<category>/<filename>.pdf#page=<n>
```

## Database schema mirroring

The local SQLite uses **the same logical schema as `db/schema.sql`** plus
client-only tables for user state:

- `subjects`, `chapters`, `topics`               — taxonomy (mirror)
- `flashcards`, `questions`, `question_options`  — content (mirror)
- `sources`                                      — PDF metadata (mirror)
- `user_card_state`                              — SM-2 schedule (already in schema)
- `user_question_state`                          — answer history + accuracy
- `user_notes`                                   — per-item free-form note
- `user_bookmarks`                               — bookmark flag
- `user_sessions`                                — Pomodoro / study session log
- `user_streak`                                  — daily streak counter
- `sync_meta`                                    — last-pulled timestamps & pairing token

## Theming

The default theme is a custom Material 3 `ColorScheme` built from two inputs:

- `surfaceTone` ∈ {`monochrome`} — gradient endpoints for surfaces.
- `accent` ∈ {`graphite`, `azure`, `violet`, `crimson`, `forest`, `amber`} —
  drives buttons, focus rings, selected states.

Surfaces apply linear gradients (top-left → bottom-right) at a low opacity to
avoid washing out content. Cards have a subtle border that picks up the accent
in dark mode and goes neutral grey in light mode.

## AI subsystem

Same provider-agnostic design as the Python side:

- `LlmClient` interface with `complete(messages, jsonMode)` and `listModels()`.
- Two implementations: `OpenAiCompatClient`, `AnthropicClient`.
- User provides base URL + API key + (optional) model in Settings; the
  selection is stored in `shared_preferences` (lightweight, encrypted on iOS /
  Android keychain via `flutter_secure_storage` when introduced in P7).
- Two product features wrap the client:
  - **Explain deeper** — given a flashcard, request a 3-bullet expansion that
    cites the source page.
  - **Why was I wrong?** — given a question + the user's wrong answer + the
    correct answer + explanation, request a focused critique.

## Sync (P11) protocol sketch

1. Device A → tap **Pair another device** → generate 6-digit code, POST to
   Supabase `pair_sessions` with TTL 10 min and a server-generated `pair_id`.
2. Device B → enter code → look up `pair_id` → exchange `device_id`s.
3. Both devices push their `user_*` rows where `updated_at > last_pushed_at`
   into Supabase `user_state_pushes`.
4. Both devices pull the other's rows since their `last_pulled_at`, merging
   per Last-Writer-Wins on `updated_at` with a per-row CRDT-ish tiebreaker
   (`device_id` ASC).
5. No login required; the pair token is the only identifier.

## CI / quality gates

- `flutter analyze` and `flutter test` for the app (GitHub Actions, P0 sets it
  up).
- `pnpm lint`, `pnpm typecheck`, `pnpm build` for the admin web (P10).
- Python pipeline keeps its `ruff` + `pytest` checks.
