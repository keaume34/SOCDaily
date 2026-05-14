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

- **P4 — SM-2 spaced repetition + Today queue** [x]
  - [x] Pure SM-2 algorithm in `lib/src/features/study/sm2.dart` (Anki-style Again/Hard/Good/Easy → q0/q2/q4/q5)
  - [x] `UserStateRepository` persists per-card `UserCardState` (ease/interval/nextReview/reviewCount/lastResult) + per-question `UserQuestionState` (attempts/correct/lastAttempt/lastChoice)
  - [x] `dueFlashcards()` query: includes never-reviewed cards + cards with `nextReview <= now`
  - [x] `dueCountsProvider`: total / new / due rollups for Home dashboard
  - [x] `TodayReviewScreen` at `/study/today` — full-screen flashcard-only review queue
  - [x] Home dashboard chips show real `Due / New` counts; "Start session" CTA routes to Today queue
  - [x] `StudySessionController` writes SM-2 + MCQ state to DB on each grade/submit
  - [x] 6 SM-2 progression tests + 6 user-state-repo tests + existing 9 still pass (total 21)
  - [x] PR #6 pushed

- **P5 — Bookmarks + per-card notes + search** [x]
  - [x] `UserStateRepository`: `isBookmarked/toggleBookmark/listBookmarks` + `listNotesForItem/addNote/deleteNote` + `searchFlashcards/searchQuestions` (LIKE-based for MVP)
  - [x] `searchProvider`/`bookmarksProvider`/`isBookmarkedProvider`/`notesForItemProvider` (Riverpod families)
  - [x] `SearchScreen` at `/search` — debounced text field, "Flashcards" + "Questions" result sections with type + difficulty badges
  - [x] `BookmarksScreen` at `/bookmarks` — list of saved flashcards + questions with preview + delete
  - [x] Bookmark + notes icons next to FLASHCARD/QUESTION step badge in TopicStudyScreen; modal bottom sheet for note CRUD
  - [x] Browse top app bar: search + bookmarks icon buttons
  - [x] 5 new tests (bookmark toggle/list, note add/list/delete, flashcard + question search) — total 26 pass
  - [x] PR #7 pushed

- **P6 — Stats / streak / heatmap** [x]
  - [x] `UserStateRepository`: `recordActivity(cards, questions, now)` upserts the `user_streak` day bucket; auto-called from `recordFlashcardRating` + `recordQuestionAttempt`
  - [x] `streakStats({now})` computes current + longest consecutive-day streak; `activityHeatmap(days:90, now)` fills a complete grid with zero entries; `totals()` rollup of cards rated + total reviews + MCQ accuracy
  - [x] Providers: `streakStatsProvider`, `activityHeatmapProvider`, `totalsSnapshotProvider`
  - [x] `StatsScreen` rebuilt: gradient streak ring (uses current accent gradient), 3-chip totals row (Cards rated / Total reviews / MCQ accuracy), 13×7 heatmap with intensity-buckets + legend
  - [x] 6 new tests (per-day accumulate, streak counting, no-activity zero state, heatmap window/fills, totals aggregation, activity-on-rating) — total 32 pass
  - [x] PR #8 pushed

- **P7 — AI Settings + "Explain deeper" + "Why was I wrong?"** [x]
  - [x] `lib/src/ai/llm_client.dart`: provider-agnostic `LlmClient` interface + `OpenAICompatClient` (chat/completions) + `AnthropicClient` (messages API) — mirrors Python pipeline pattern
  - [x] `lib/src/ai/ai_settings.dart`: `AiSettings` (provider/baseUrl/apiKey/model) persisted via SharedPreferences; `aiSettingsControllerProvider` + `llmClientProvider`
  - [x] `lib/src/ai/tutor_service.dart`: `TutorService.explainDeeper(card, topic)` + `TutorService.whyWrong(question, options, chosenIds)` — both emit structured SOC-tutor prompts with no-hallucination guardrails
  - [x] `lib/src/ai/tutor_sheet.dart`: modal bottom sheet with loading / error / configure-CTA states; uses `flutter_markdown` to render the answer
  - [x] Settings screen: "AI tutor" section with provider segmented button, base URL (OpenAI-compat only), model, masked API key with show/clear; status row indicates "Configured" / "Not configured"
  - [x] Study screen: "Explain deeper" outlined button under every flashcard; "Why was I wrong?" appears after submitting an MCQ that scored 0
  - [x] 6 new tests (configured-check, provider name fallback, explainDeeper prompt assembly, whyWrong prompt + chosen vs correct, exception propagation, schema sanity) — total 38 pass
  - [x] PR #9 pushed

- **P8 — Daily Challenge + Quiz mock exam + Cheatsheet** [x]
  - [x] `ContentRepository.dailyChallenge({day, flashcardCount, questionCount})`: seeded Fisher-Yates (`yyyymmdd`) → same picks across devices, day-over-day rotation
  - [x] `ContentRepository.randomQuestions(count, {seed})` for the timed mock exam; `cheatsheetForSubject(subjectId)` rolls up flashcards by topic
  - [x] `DailyChallengeScreen` (`/daily`): mixed flashcards + MCQs, real Rating buttons (records SM-2 + activity), summary card on completion
  - [x] `QuizSetupScreen` + `QuizRunScreen` (`/quiz`, `/quiz/run?count=…&minutes=…`): choose 5/10/20/30 questions × 5/10/15/30 min, countdown chip turning red below 1 min, auto-submit on timeout, per-question recap + correct/wrong icons + explanation
  - [x] `CheatsheetSubjectPickerScreen` + `CheatsheetScreen` (`/cheatsheet`, `/cheatsheet/:id`): table-style Term / Definition rendering for fast scanning before an exam
  - [x] Home dashboard: Daily Challenge / Mock exam / Cheatsheet cards added next to Today queue and Browse
  - [x] 5 new tests (daily determinism, day-over-day rotation, count clamping, random seed reproducibility, cheatsheet grouping) — total 43 pass
  - [x] PR #10 pushed

- **P9 — Pomodoro + export certificate** [x]
  - [x] `lib/src/features/pomodoro/pomodoro_controller.dart`: Riverpod `Notifier` for global timer state (`PomodoroPhase` idle/focus/shortBreak/longBreak, remaining seconds, running, completedFocus, configurable durations). Timer survives navigation because the controller lives at app scope. `start/pause/reset/skip/updateDurations` with `SharedPreferences` persistence of focus/short/long/cycles
  - [x] `lib/src/features/pomodoro/pomodoro_screen.dart` (`/pomodoro`): gradient progress ring rendered via `CustomPainter` (sweep gradient using current accent's deep + soft), phase chip, tabular-numeral countdown, focus-done counter, big play/pause + reset + skip controls, inline duration pickers via ChoiceChips
  - [x] `lib/src/services/certificate_service.dart`: builds an A4-landscape PDF certificate via the `pdf` package; header + name + 4 stat blocks (cards mastered / questions answered / longest streak / subjects studied) + issue-date footer + "SELF-PACED" badge
  - [x] `lib/src/features/certificate/certificate_screen.dart` (`/certificate`): name input + `PdfPreview` from `printing` package — user can share / save / print directly
  - [x] Home dashboard: Pomodoro + Certificate cards added; routes wired in `router.dart`
  - [x] `pubspec.yaml`: added `pdf: ^3.11.1` + `printing: ^5.13.4`
  - [x] 9 new tests (7 pomodoro state machine: idle init, start, skip → break + completion count, long break every N cycles, reset, updateDurations persistence, progress bounds; 2 certificate: PDF magic-byte + zero-attempts handling) — total 52 pass
  - [x] PR #11 pushed

- **P10 — Admin web (Next.js)** [x]
  - [x] Next.js 14 App Router scaffold at `admin/` (TypeScript + Tailwind + Vitest, no shadcn CLI — hand-rolled components)
  - [x] `admin/src/lib/content.ts`: file-backed data layer that reads/writes the JSON content bank under `app/assets/seed/` (same files the Flutter app bundles). Lazy `seedRootPath()` so `SOCDAILY_SEED_DIR` env can override
  - [x] `admin/src/lib/auth.ts` + `/login`: optional cookie-based password gate. If `ADMIN_PASSWORD` unset → open mode (no auth, friction-free local dev)
  - [x] Dashboard `/`: totals tiles (subjects, chapters, topics, flashcards, questions) + quick-link cards
  - [x] Library `/library`: subject → chapter → topic tree with per-topic flashcard + question counts
  - [x] Topic editor `/library/[subject]/[chapter]/[topic]`: full CRUD against the JSON file — edit topic title/summary, edit/delete each flashcard (front/back/hint/tags/difficulty/page), add new flashcard inline, edit/delete each question (stem/qtype/difficulty/explanation + per-option label/content/correct toggle). Sticky save bar with status
  - [x] Pipeline `/pipeline`: documents the 4-step Python ETL pipeline (ingest → outline → generate → import) for users wanting new topics
  - [x] Settings `/settings`: shows runtime config (seed dir, auth mode, Node version) + how-to-configure pointer
  - [x] `admin/README.md`, `admin/.env.example`
  - [x] 3 Vitest tests for the data layer (load library + totals, round-trip read/write, findTopicRef miss); `pnpm typecheck` + `pnpm lint` + `pnpm build` all green
- **P11 — Sync 2-way via Supabase + pairing code** [x]
  - [x] `supabase/schema.sql`: content tables (`subjects/chapters/topics/flashcards/questions/question_options`) + sync tables (`device_sync_pair`, `user_sync_payload`) + RLS (content read-only via anon, sync rows scoped by `(code, device_id)`) + `purge_expired_pairs()` cleanup function
  - [x] `supabase/README.md`: setup + free-tier sizing + RLS recap
  - [x] `lib/src/sync/sync_config.dart`: reads `SUPABASE_URL` / `SUPABASE_ANON_KEY` from `--dart-define`, gates everything by `isConfigured`
  - [x] `lib/src/sync/device_id.dart`: random UUID v4 persisted to `SharedPreferences` (one device id per install)
  - [x] `lib/src/sync/sync_types.dart`: `SyncPair` (code, deviceA, deviceB, timestamps, isExpired) and `SyncEnvelope` (code, deviceId, kind, item_key, payload, updatedAt) + `SyncKinds` constants (`card_state`, `question_state`, `bookmark`, `note`, `streak`)
  - [x] `lib/src/sync/sync_remote.dart`: abstract `SyncRemote` interface (createPair / readPair / redeemPair / upsertPayload / upsertPayloadBatch / readRemotePayloads) so the engine is decoupled from Supabase
  - [x] `lib/src/sync/in_memory_sync_remote.dart`: testable fake. Used by every sync test in CI
  - [x] `lib/src/sync/supabase_sync_remote.dart`: production implementation against `supabase_flutter`. Retries on unique-violation when generating codes. Last-write-wins applied via `onConflict: 'code,device_id,kind,item_key'`
  - [x] `lib/src/sync/sync_engine.dart`: snapshots local rows (`user_card_state`, `user_question_state`, `user_bookmarks`) into envelopes, pushes the batch, then pulls *the partner device's* envelopes and applies them with last-write-wins on `updated_at`. Returns `SyncRoundResult{uploaded, downloaded, applied, lastSyncedAt}`
  - [x] `lib/src/sync/sync_controller.dart`: Riverpod `Notifier<SyncState>` with `SyncMode { unconfigured, idle, generating, redeeming, syncing, error }`. Persists active pair code + lastSyncedAt to `SharedPreferences`. Exposes `generatePairCode / redeemPairCode / syncNow / unpair`
  - [x] `lib/main.dart`: calls `Supabase.initialize(...)` at startup when `SyncConfig.isConfigured` (build-time embedded anon key + url)
  - [x] `lib/src/features/sync/sync_screen.dart` (`/sync`): paired status card, generate-code card with copy-to-clipboard, redeem-code card with 6-digit input, "Sync now" + "Unpair" actions, explainer card; gracefully degrades to an "unconfigured" placeholder when env-defines are missing
  - [x] `lib/src/features/settings/settings_screen.dart`: added a "Cloud sync" section with status summary + deep-link button to `/sync`
  - [x] `pubspec.yaml`: added `supabase_flutter: ^2.8.0`
  - [x] 15 new tests (8 `in_memory_sync_remote_test`: pairing happy path, redeem unknown code, redeem rejects 3rd device, redeem refuses expired pair, payload filter by device, last-write-wins, since filter; 3 `sync_engine_test`: card state propagates between two devices, conflict resolves via newer updated_at, bookmarks propagate; 6 `sync_controller_test`: initial idle, unconfigured fallback, generate, redeem unknown, unpair, two-container end-to-end sync) — total 67 pass
  - [x] `flutter analyze` clean
- **P12 — PDF source viewer (VPS-hosted)** [x]
  - **VPS side (DONE in the prior session)**
    - User authorized Devin's VM onto their Tailscale tailnet via login link (no auth-key needed). Devin VM hostname: `devin-socdaily` (`100.82.82.92`).
    - SSH passwordless via Tailscale SSH to `ubuntu@100.110.125.8` (a.k.a. `neam-vps`, Ubuntu 24.04, 37 GB free).
    - `nginx 1.24.0` installed on VPS. `/var/www/socdaily-pdfs/` created, owned by `ubuntu:ubuntu`.
    - `/etc/nginx/sites-available/socdaily-pdfs` server block: listens on `100.110.125.8:8080` (tailnet IP only — not exposed publicly). Serves `*.pdf` with `Content-Type: application/pdf`, `Accept-Ranges: bytes`, `Cache-Control: public, max-age=2592000, immutable`, `Access-Control-Allow-Origin: *`. Has `/healthz` returning `ok` and `autoindex on; autoindex_format json;` for directory listings.
    - 4 sample PDFs (3 pages each, generated via `reportlab`) uploaded under `<subject>/<chapter>/<topic-code>.pdf` (e.g. `soc-fundamentals/introduction/soc-mission.pdf`). `curl -sI` returns 200 + correct headers; byte-range request returns valid `%PDF-1.3` magic.
  - **Flutter side (DONE)**
    - [x] `lib/src/pdf/pdf_source_config.dart`: `PdfSourceConfig.fromEnvironment()` reads `--dart-define=PDF_BASE_URL=…`; `isConfigured` gates UI buttons + the viewer screen (mirrors `SyncConfig` from P11). Exposes `pdfSourceConfigProvider`.
    - [x] `lib/src/pdf/pdf_source_service.dart`:
      - `PdfSourceService.buildUrl(loc)` + static `buildRelativePath(loc)` (pure): bare filename → `<subject>/<chapter>/<slug>.pdf`; path with slashes → preserved-but-slugified; Windows-style backslashes normalized; empty string → deterministic `source.pdf` placeholder.
      - `slugifyPdfFilename` lowercases, strips `.pdf`, collapses non-alphanumerics to single dashes, trims dashes, re-appends `.pdf`.
      - `cacheKeyFor(url)` = sha1 hex (via `crypto: ^3.0.5` added as direct dep — already transitive; no `flutter_cache_manager`).
      - `fetchPdf(loc)` downloads via `Dio` into `<getApplicationDocumentsDirectory>/socdaily/pdf_cache/<sha1>.pdf` with a configurable 30-day TTL; throws `PdfSourceException` on dio failures.
      - `PdfSourceLookup`: joins `sources` → flashcards/questions → topics → chapters → subjects so a `sources.id` resolves to a rich `PdfSourceContext` (subject/chapter codes + topic title) for both URL building and the viewer's banner.
      - Providers: `pdfSourceServiceProvider`, `pdfSourceLookupProvider`, plus a private `_pdfDioProvider`.
    - [x] `lib/src/features/pdf/pdf_viewer_screen.dart` (`/source/:sourceId?topicId=T&page=N`): uses the existing `printing.PdfPreview` (already in pubspec from P9 — no extra deps). Defaults to rendering only the source page via `pages: [page-1]` so the user lands on the citation; an AppBar toggle switches to "Show all pages". Loading + error + retry + unconfigured states all implemented. Header strip shows source title + subject / chapter / topic breadcrumb + a "Source page N" pill.
    - [x] `lib/src/app/router.dart`: `/source/:sourceId` route with optional `?topicId=` + `?page=` query parameters.
    - [x] `lib/src/features/study/topic_study_screen.dart`: new `OpenSourceButton` consumer widget shows up under "Explain deeper" for flashcards, and after submitting an MCQ — only when `card.sourceId != null && PdfSourceConfig.isConfigured` (hidden silently otherwise). Wired via `context.push('/source/<id>?topicId=…&page=…')`.
    - [x] `pubspec.yaml`: added `crypto: ^3.0.5` (already transitive; promoted to direct dep so the cache-key sha1 doesn't depend on lockfile resolution accidents).
    - [x] 15 new tests (`test/pdf/pdf_source_service_test.dart`): 5× `slugifyPdfFilename` (basic, diacritics + punctuation, dash trimming, no-alphanumeric fallback, missing-extension), 4× `buildRelativePath` (bare filename, paths with slashes, Windows backslashes, empty fallback), 1× `buildUrl` (trailing-slash trim), 2× `cacheKeyFor` (sha1 shape + uniqueness), 3× `PdfSourceConfig.isConfigured` — total 84 pass.
    - [x] `flutter analyze` clean.
  - **Operational notes (carried forward)**
    - Tailscale MagicDNS is **off** on the user's tailnet — use the bare IP `100.110.125.8` (not `neam-vps`).
    - If Devin's VM is rebuilt fresh, re-auth Tailscale: `sudo tailscale up --hostname=devin-socdaily --accept-routes --accept-dns=false` (user clicks the printed login URL — no `TS_AUTHKEY`).
    - PDFs are kept *off* git per the existing `.gitignore`. To push more PDFs from the repo's `raw/pdf/` into the VPS:
      ```
      tar -C raw/pdf -czf /tmp/pdfs.tar.gz .
      scp /tmp/pdfs.tar.gz ubuntu@100.110.125.8:/tmp/
      ssh ubuntu@100.110.125.8 "tar xzf /tmp/pdfs.tar.gz -C /var/www/socdaily-pdfs"
      ```
    - The current sample PDFs on the VPS are named after the *topic_code* (`<subject>/<chapter>/<topic-code>.pdf`).
    - **Resolved**: the 4 bundled seed JSONs (`phishing-indicators`, `siem-core-concepts`, `soc-mission`, `soc-tier-roles`) now use `source_pdf: "<topic-code>.pdf"` so `buildRelativePath` resolves straight to the on-disk path. When the user adds new seeds later, keep `source_pdf` aligned with the actual VPS filename — the convention is `<topic-code>.pdf` namespaced by `<subject>/<chapter>/` (which the lookup adds automatically). To wire up a brand new human-named PDF instead, re-upload it to the VPS at the slugified path the app computes (`slugifyPdfFilename` lowercases + dashes the name).

- [x] **P13.A — Design audit & language doc** (branch: `devin/<ts>-phase13a-design-audit`)
  - [x] Install Flutter SDK 3.24.5 on the VM + the Linux desktop toolchain
    (`clang`, `cmake`, `ninja-build`, `pkg-config`, `libgtk-3-dev`,
    `liblzma-dev`, `wmctrl`). Web target *does not work* for this app
    because `sqlite3_flutter_libs` is FFI-only — use Linux desktop or
    Android for visual smoke tests.
  - [x] `flutter test` re-run on the VM after install — **84 / 84 pass**.
  - [x] Capture 20 screenshots covering Home (light + dark), Browse
    (subject / chapter / topic), Study (flashcard front + back + MCQ +
    answered), Stats, Settings (incl. dark), Pomodoro, Daily Challenge,
    Mock Exam, Cheatsheet (list + table), Certificate. Saved to
    `/home/ubuntu/screenshots/p13a_audit/` (kept local — not committed).
  - [x] Author `DESIGN.md` at repo root: "Cute Sentinel" design language,
    palette (3 new pastel accents on top of existing 6), typography
    (Quicksand + Plus Jakarta Sans), shape / elevation rules, motion
    spec, mascot proposal (A: Sentinel Owl / B: Sherlock Magnifier /
    C: Shield Bunny — em đề xuất B), and the P13.A → P13.E sub-phase
    plan with acceptance criteria each.
  - [x] User picks mascot direction + bundling preference + onboarding
    preference before P13.B starts.
    → **Otto the Sentinel Owl** chosen. Keep 9 accents. 3-step onboarding.
    Bundle fonts offline (no `google_fonts` runtime download).

- [x] **P13.B — Theme refinements** (branch: `devin/<ts>-phase13b-theme-refinements`)
  - [x] Bundled **Quicksand** (variable-weight TTF) + **Plus Jakarta Sans**
    (variable-weight TTF + italic) into `app/assets/fonts/`, with OFL
    license files. Declared in `pubspec.yaml` under `flutter.fonts`.
    No `google_fonts` package — fully offline.
  - [x] Added 3 pastel accents to `AppAccent` enum: `sakura` (`#DB2777` /
    `#FCE7F3`), `mint` (`#0F766E` / `#CCFBF1`), `mocha` (`#92400E` /
    `#FEF3C7`). Static lists `AppAccent.professional` (6) and
    `AppAccent.friendly` (3) for the settings picker.
  - [x] Settings accent picker split into two labelled groups:
    **Professional** (graphite, azure, violet, crimson, forest, amber) and
    **Friendly** (sakura, mint, mocha).
  - [x] Card radius bumped `20 → 22`. Button radius bumped `14 → 16`
    (filled, outlined, input decoration). Navigation bar indicator now
    uses `accent.soft × 70%` fill + 1px `accent.deep` border for a
    clearly visible active state.
  - [x] Typography split: headlines / displays / titles use **Quicksand**;
    body / labels use **Plus Jakarta Sans**. AppBar title also uses
    Quicksand.
  - [x] `flutter analyze` clean (only pre-existing `assets/i18n/` warning).
    `flutter test` — **84 / 84 pass** (no regressions).
  - **Operational note**: Flutter SDK lives at `/home/ubuntu/flutter/` on
    the VM. `~/.bashrc` exports `$HOME/flutter/bin` onto `PATH`. Blueprint
    updated — snapshot now pre-installs Flutter 3.24.5.

- [x] **P13.C — Vector mascot + onboarding** (branch: `devin/<ts>-phase13c-mascot-onboarding`)
  - [x] Created **Otto the Sentinel Owl** SVG mascot — 4 mood variants in
    `app/assets/mascot/`: `otto_neutral.svg`, `otto_correct.svg` (sparkles +
    thumbs-up), `otto_wrong.svg` (squint + ?), `otto_sleeping.svg`
    (nightcap + zzz). Round owl body, big eyes, black-framed glasses,
    grey hoodie, blue "SOC" badge.
  - [x] Added `flutter_svg ^2.0.10+1` dependency. Created `MascotWidget`
    (`lib/src/mascot/mascot_widget.dart`) with `OttoMood` enum exposing
    4 states. Accepts `size` parameter, renders via `SvgPicture.asset`.
  - [x] 3-step **OnboardingScreen** (`lib/src/features/onboarding/`):
    pages introduce Otto ("Meet Otto", "Learn by doing", "Study at your
    pace"). Page dots + Skip / Next / Get started buttons. Persists
    `onboarding.complete` in SharedPreferences; `onboardingCompleteProvider`
    controls initial route.
  - [x] Home greeting now shows Otto neutral (64px) beside the title.
    Stats screen shows `_EmptyStatsCard` with sleeping Otto when
    `current == 0 && longest == 0`.
  - [x] Existing `widget_test.dart` updated to seed `onboarding.complete:
    true` so the smoke test still finds `NavigationBar`.
  - [x] 3 new unit tests for the onboarding flag (absent → shows,
    present → skips, set → persists).
  - [x] `flutter analyze` clean (only pre-existing `assets/i18n/`).
    `flutter test` — **87 / 87 pass** (84 original + 3 new).

- [x] **P13.D — Micro-interactions** (commit `016ae5f` on `main`)
  - [x] Streak milestone signal: `streakStats()` returns
    `(current, longest, milestoneHit)`. `milestoneHit ∈ {3, 7, 30, 100}`
    only on the day the user freshly hits one of those streak lengths.
  - [x] Stats `_StreakCard` fires `ConfettiWidget` (2.5 s burst) +
    slide-up `MascotWidget(correct)` from the card bottom on milestone
    hits. Already-celebrated state persists in `SharedPreferences`
    keyed by `yyyy-mm-dd:milestone`.
  - [x] New dep: `confetti ^0.8.0`.
  - [x] `_ResultBanner` (MCQ): `FadeTransition` (300 ms) + `ScaleTransition`
    (`Curves.elasticOut`, 320 ms) on the icon. `Icons.celebration` →
    `Icons.check_circle` for the correct case.
  - [x] `_ShakeOnce` wraps a wrong-selected option for a 180 ms
    decaying-sine wiggle (±6 px, 3 oscillations).
  - [x] New `TapBounce` shared widget (`lib/src/widgets/tap_bounce.dart`):
    `AnimatedScale` 1.0 → 0.97 → 1.0 / 120 ms `Curves.easeOutBack`.
    Wrapped around home `_DashCard`. Skipped on MCQ option (InkWell
    ripple already conveys press).
  - [x] `_GlowingWhyWrongButton` wraps the existing OutlinedButton with
    an `AnimatedBuilder` driving `BoxShadow(accent.deep@40%, blur 12,
    spread 2)` through 3 ease-in-out pulses then settles to none.
  - [x] `_BreathingRing` wraps the Pomodoro `CustomPaint` with a 4 s
    repeating-reverse `AnimationController`. `Transform.scale`
    1.0 → 1.02 only when `phase == focus && running`; pauses + resets
    to 1.0 otherwise.
  - [x] 4 new tests in `user_state_repository_streak_test.dart`
    covering milestone hits at 3/7/30/100, non-milestone day,
    broken-streak day. `flutter test` — **91 / 91 pass**.

- [x] **P13.E — Screen polish** (commit `d9f826d` on `main`)
  - [x] Home `_DashCard` is now `ConsumerWidget`; icon tile background
    goes `accent.soft`, icon goes `accent.deep`. Replaces the flat
    `primary @ 12 %` wash so the user's accent choice actually surfaces
    on Home.
  - [x] `_DailyResult` (Daily Challenge completion) shows Otto (correct
    mood) above the trophy.
  - [x] `CertificateService` loads bundled `Quicksand` + `PlusJakartaSans`
    TTFs via `rootBundle` and applies them per `pw.TextStyle`. Display
    font on holder name / 'SOCDaily' / stat values / 'SELF-PACED'
    badge; body font everywhere else. Falls back to Helvetica when
    assets are missing (test envs).
  - [x] Stats heatmap already accent-driven (`Color.lerp(accent.soft,
    accent.deep, t)`) — no code change.
  - [x] Cheatsheet left as-is (data screen, intentional restraint).
  - [x] `flutter test` — **91 / 91 pass**.

- [~] **P14 — On-demand Content Generator**
  - **Why**: the user has a much larger pile of source PDFs than the 4
    bundled samples. Manually running the Python pipeline per document
    is fine for bootstrap; the app should also let users (a) request
    generated cards/MCQs on a topic from inside the app, and (b)
    auto-target weak areas based on their own SM-2 + MCQ accuracy.
  - **User decisions (2026-05-14)**:
    1. Backend host: **public** (HTTPS + bearer token), not Tailscale-only.
    2. Source PDFs: **both** — list pre-uploaded VPS PDFs *and* allow
       in-app upload (multipart/form-data → `POST /pdfs`).
    3. Generated seeds: **synced** via Supabase using the existing
       `user_sync_payload` table with new `kind = 'generated_seed'`
       (no schema change — see `supabase/README.md`).
  - [x] **P14.A — FastAPI generator service** (this session)
    - [x] `src/socdaily/api/auth.py` — Bearer-token dependency.
      Tokens loaded from `SOCDAILY_API_TOKENS` (comma-separated). 401
      for missing/invalid token; 503 when the env var is empty so the
      operator notices the misconfig.
    - [x] `src/socdaily/api/app.py` — FastAPI app factory + endpoints:
      - `GET  /healthz` — liveness, no auth, returns `{"status":"ok"}`.
      - `GET  /pdfs` — lists `*.pdf` under `SOCDAILY_PDF_DIR` (default
        `./raw/pdf`). Bearer required.
      - `POST /pdfs` — multipart upload; sanitises filenames (strips
        `..`, collapses unsafe chars to `-`); rejects non-`.pdf`.
      - `POST /generate` — extracts the PDF page slice via
        `pdf_extract.pdf_to_markdown` + `slice_pages`, then calls
        `pipeline.generate.generate_topic_seed` and returns the
        `TopicSeed` JSON. LLM/parse failures bubble up as 502.
    - [x] `tests/test_api.py` — 9 tests (auth required, 503 when
      tokens unset, list/upload/safe-filename/non-pdf-rejection,
      page-range validation, full happy path with a fake LLM).
      `pytest`: **12/12 pass** (3 P0 tests + 9 new).
    - [x] `pyproject.toml`: added `fastapi`, `uvicorn[standard]`,
      `python-multipart` to runtime deps; `httpx` to dev deps for
      `TestClient`.
    - [x] `vps/socdaily-api.service` — systemd unit running uvicorn on
      `127.0.0.1:8000` with `EnvironmentFile=/etc/socdaily/api.env`,
      hardened (`ProtectSystem=strict`, `MemoryDenyWriteExecute=true`,
      `ReadWritePaths` scoped to `/var/www/socdaily-pdfs` + repo).
    - [x] `vps/nginx/socdaily-api.conf` — public reverse proxy at
      `socdaily.example.com:443` (Let's Encrypt). Two rate-limit
      zones: `socdaily_api` (3 r/s burst 10) for cheap routes,
      `socdaily_generate` (10 r/min burst 2 nodelay) for the LLM
      route. 5-minute proxy_read_timeout on `/generate`.
    - [x] `vps/README.md` — appended a full Phase-14 section: topology
      diagram, provisioning steps (certbot + venv + systemd), curl
      examples, token-rotation procedure.
    - [x] Bug-fix carried in this commit: `pdf_extract._have_pdftotext`
      now also requires `pdfinfo`. On Git for Windows mingw64 only
      `pdftotext.exe` is on `PATH` while `pdfinfo` is not, which
      previously caused `pdfinfo` calls to crash. The pypdf fallback
      handles the Windows case after the fix.
    - **Endpoint contract for P14.B**:
      ```
      POST /generate
      Authorization: Bearer <token>
      {
        "subject_code": "soc-fundamentals",
        "subject_title": "SOC Fundamentals",
        "chapter_code": "siem",
        "chapter_title": "SIEM",
        "topic_code": "siem-core-concepts",
        "topic_title": "SIEM Core Concepts",
        "pdf_filename": "SOC Analyst Guide.pdf",  // basename in SOCDAILY_PDF_DIR
        "page_start": 12,
        "page_end": 15,
        "n_flashcards": 6,
        "n_questions": 4,
        "content_lang": "vi" | "en" | "bilingual",
        "hint": "focus on Splunk SPL examples"   // optional
      }
      → 200 application/json: TopicSeed
      ```
  - [ ] **P14.B — Flutter side: explicit "Generate more"**
    - [ ] New service `lib/src/ai/content_generator.dart` POSTs to
      `/generate` with the bearer token from settings.
    - [ ] Reuse `SeedImporter.import_topic_seed` so a generated seed
      lands in the local SQLite the same way bundled assets do.
    - [ ] UI: a "Generate more" button on Topic / Browse opens a modal
      where the user picks counts + free-form hint. On success the
      new items appear immediately.
    - [ ] Settings exposes the generator base URL + token (mirrors the
      existing AI tutor settings).
    - [ ] Sync: on successful generate, push the resulting `TopicSeed`
      JSON to Supabase under
      `kind='generated_seed', item_key='<topic_code>'` so the user's
      other devices get the same content on next sync.
  - [ ] **P14.C — Weakness-driven recommendations**
    - [ ] Query `user_question_state` and `user_card_state` to score
      every topic by `(mcq_accuracy_below_threshold, avg_ease,
      due_card_ratio)`. Surface the top-3 weak topics on Home.
    - [ ] Each weak-topic card has a "Practice weak areas" CTA that
      pre-fills the generator modal (P14.B) with the topic locked in
      and a higher MCQ count.
    - [ ] Persist generated batches under
      `assets/seed/generated/<yyyy-mm-dd>/<topic>.json` (gitignored)
      so the user can review or rollback.
    - [ ] Sync: per-topic weakness score under
      `kind='topic_weakness', item_key='<topic_code>'`.


---

## Open questions / blockers

1. Supabase credentials provided + stored as repo-scoped secrets
   (`SUPABASE_URL`, `SUPABASE_ANON_KEY`, `SUPABASE_SERVICE_ROLE_KEY`).
   Anon URL/key are embedded into release builds via `--dart-define`.
   The service-role key is *only* used by the admin-web seed-push script,
   never by the Flutter app.
2. VPS SSH / domain needed before P12 — will request when the phase starts.
3. AI key strategy: the app expects each user to supply their own OpenAI /
   Anthropic key in Settings. No shared key ships with the app.

---

## Conventions

- Tất cả commit thẳng vào branch `main` trên `nam091/SOCDaily` (private fork).
- Origin `keaume34/SOCDaily` chỉ READ-only, không push lên đó.
- Mỗi commit phải pass `flutter analyze` + `flutter test` (87+ tests) trước khi push.
- All Dart code must pass `flutter analyze` and `flutter test` before push.
- All TypeScript code (admin web) must pass `pnpm lint && pnpm typecheck` and
  `pnpm build` before push.
- The Python pipeline in `src/socdaily/` keeps its `ruff` + `pytest` checks.
