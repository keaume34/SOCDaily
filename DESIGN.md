# SOCDaily Design Language — "Cute Sentinel"

> A SOC analyst is essentially a friendly night-shift detective: watchful, focused, slightly nerdy, but always on the user's side. The visual language should feel that way — calm and trustworthy first, then quietly playful in the corners.

## 1. Audit of the current app (Phase 0–P12)

A full set of audit screenshots lives in [`/home/ubuntu/screenshots/p13a_audit/`](app/lib/src/theme/). The condensed reading:

| Area | Today | Verdict |
|---|---|---|
| **Theme** | Material 3, `ColorScheme.fromSeed` on `AppAccent.deep` + monochrome surface (`#0B0F14` dark / `#FAFBFC` light) | Clean but flat. Reads as "internal admin tool" rather than "learning companion". |
| **Typography** | `Typography.blackMountainView` / `whiteMountainView` (Roboto) with weight bumps | Fine for body, no personality in headings. |
| **Cards** | 20-radius rounded rect, 0 elevation, 0.6α outline + 0.6α surfaceContainerHighest | Already soft, but every screen uses the same surface tone — no hierarchy. |
| **Accents** | 6 enum values (`graphite`, `azure`, `violet`, `crimson`, `forest`, `amber`), each `deep` + `soft` | Solid pro palette. Missing any "warm" / "happy" tone. |
| **Bottom nav** | Material `NavigationBar` with `indicatorColor: accent.deep × 0.18` | Works, but the active pill is barely visible (see Home screenshot). |
| **Home** | List of 7 chevron rows (`Start a study session`, `Daily challenge`, …) + a `Welcome back / SOCDaily` heading + 3 stat chips | Functional, zero delight. No mascot, no illustration, no encouragement copy. |
| **Study player** | Centered front/back text on a flat card; 4-state grading buttons (`Again / Hard / Good / Easy`) outlined in accent colors | Cards are huge empty rectangles → feels like a Notion doc, not flashcards. No flip animation polish. |
| **Stats** | Streak ring + 3 KPI tiles + 90-day GitHub-style heatmap in pure black squares | Heatmap is too "GitHub" — needs softer pastel ramp matching the active accent. |
| **Pomodoro** | Plain grey ring + `25:00` numeral, no controls visible by default | Ring is a flat outline — needs gradient stroke + breathing animation. |
| **Daily challenge / Mock exam** | Same study player but with solid blue buttons | Inconsistent button style (vs. outlined in regular study). |
| **Certificate** | Blue corner triangle on white sheet, big "SOC Analyst" headline | Already feels semi-formal; just needs better typography pairing. |
| **Empty / first-run** | None — the app shows a fresh seed import immediately | Misses the chance to introduce the mascot. |

**One-line summary:** today the app looks like a *capable* learning database. We want it to look like a *companion that's rooting for you*.

## 2. Design principles ("cute pro")

1. **Calm first, cute second.** Cute touches sit on top of a calm, hierarchical layout — never replace it. If a designer would call something "loud", we don't ship it.
2. **One mascot, sparing appearances.** The mascot shows up at meaningful moments (welcome, milestones, empty states, "Why was I wrong?" panels) — not on every card.
3. **Two type voices.** One humanist sans-serif for body/UI (legibility), one rounded display for headlines & numerals (personality). Same colour, different shape.
4. **Soft elevation, soft motion.** No hard drop shadows; we use 1–2 layered surface tones + a 1px border. Motion is short (120–220 ms) and uses `Curves.easeOutCubic`.
5. **Accent ≠ chrome.** The user's accent colour is the highlight, not the background. Most surfaces stay neutral so the accent has somewhere to land.
6. **Data screens stay data screens.** Cheatsheet tables, Mock exam timer, Certificate, and AI settings keep enterprise-grade restraint. No mascot there.
7. **Dark mode is the same vibe, not "just inverted".** Same warmth in the borders and the accent halo.

## 3. Color palette (proposed)

Keep the 6 existing accents (`graphite`, `azure`, `violet`, `crimson`, `forest`, `amber`) — they're already balanced. Add **three pastel "soft" accents** for users who want a lighter, friendlier feel:

| Token | Hex (`deep`) | Hex (`soft`) | Vibe |
|---|---|---|---|
| `sakura` | `#DB2777` | `#FCE7F3` | Friendly pink, great for "Daily challenge". |
| `mint` | `#0F766E` | `#CCFBF1` | Calming teal-mint, good default for studying. |
| `mocha` | `#92400E` | `#FEF3C7` | Warm cocoa, fits Pomodoro and Cheatsheet. |

Plus a new **support palette** used only inside widgets, not user-selectable:

- `success.50/500/700` — soft mint background, mid green text. Used in MCQ "Correct" banner.
- `warning.50/500/700` — soft amber. Used in "Hard" rating and Pomodoro break.
- `danger.50/500/700` — soft rose. Used in "Again" rating and "Why was I wrong?" tutor card.

## 4. Typography

| Role | Family | Notes |
|---|---|---|
| Headlines / displays / numerals | **Quicksand** (rounded geometric sans) | Friendly, used for `Welcome back`, streak counts, exam scores, certificate name. |
| Body / UI labels | **Plus Jakarta Sans** | Humanist sans, slightly playful but very legible at 14–16. |
| Mono (cheatsheet, AI raw text) | Default `JetBrains Mono` via `google_fonts` | Already needed for code snippets in cards. |

Loaded via `google_fonts` (caches at runtime; we can fall back to system if offline). The existing `_textTheme` builder gains a font family per text role.

## 5. Shape & elevation

- **Card radius**: bump from `20` to `22`, but every nested item uses `16`. Two radii max per screen — readable hierarchy.
- **Buttons**: `14 → 16` radius, add a subtle 1px inner highlight (white@8% top edge).
- **Bottom nav**: indicator pill goes from `accent.deep@18%` → `accent.soft × 70%` plus a 1px accent.deep border so it actually reads as "selected".
- **Shadows**: none on cards. Floating mascot speech bubble uses `BoxShadow(blurRadius:24, offset:(0,8), color:accent.deep@8%)` — that's the only place a real shadow exists.

## 6. Motion

- Card tap: 120 ms scale 1.0 → 0.97 → 1.0 (Curves.easeOutBack).
- Page transitions: stick with `MaterialPage` but custom transition = 220 ms fade + 12px slide-up.
- Pomodoro ring: stroke draws with `TweenAnimationBuilder` (no jank); pulses 1.0 → 1.02 every breath (4s) while focus is running.
- Streak milestone (3 / 7 / 30 / 100 days): one-shot `confetti` burst centred on the streak chip + mascot peeks from the bottom of the screen for 2s with a thumbs-up.
- MCQ correct: green check icon bounces in (Curves.elasticOut, 320 ms), banner fades in.
- MCQ wrong: card shakes 6px once (180 ms), then "Why was I wrong?" button glows softly.

## 7. Mascot — proposal

I'd like to settle on the mascot before P13.B starts. Three directions, all share the same constraint: must read clearly at 24×24px (used in the home greeting) and at 256×256px (welcome / milestone screens). All would be vector SVG / Lottie, no rasters.

### Option A — **Sentinel Owl** ("Otto")
A small, round owl with oversized round glasses and a hoodie. Night-shift defender vibe. Reactions: 🦉 hooded squint when wrong, glasses-glare when correct, sleeping cap on Pomodoro break.

> Strengths: matches "night shift", already used in cyber-mascot tradition (HTB-ish but cuter, less aggressive). Glasses imply analyst.
> Risks: owl mascots are common in cyber, might feel derivative.

### Option B — **Sherlock Magnifier** ("Loupe")
A magnifying glass with a friendly face on the lens. The handle is shaped like a `?`. Reactions: zoomed-in pupils when investigating, sparkle when finding evidence, tea-cup on break.

> Strengths: extremely on-brand for SOC ("detect, investigate, respond"). Reads great at 24×24. Original.
> Risks: less universally "cute" than an animal; ironically more "cool" than warm.

### Option C — **Shield Bunny** ("Buni")
A pastel shield with bunny ears poking out the top. Friendly face on the shield surface. Reactions: ears droop when wrong, ears perked when right, helmet on for Mock exam.

> Strengths: maximum cute, very approachable for a "Vietnamese L1/L2 learner" audience. Shield = defensive security.
> Risks: might feel too kawaii for the certificate / mock exam screens (we'd hide it there).

**My recommendation: Option B (Loupe).** It's the only one that *also* reads as professional in the certificate footer, and it gives us a built-in visual language for "Explain deeper" (zoom-in) and "Why was I wrong?" (looking at evidence).

But anh chọn cuối cùng — em sẽ vẽ vector SVG cho lựa chọn của anh ở P13.C.

## 8. Phase plan (`P13.A` → `P13.E`)

Each sub-phase = own branch off `devin/1778578590-phase12-pdf-source-viewer`, own PR (stacked), one commit per phase (force-with-lease only if rebase needed), `memory_bank.md` updated at the end of each.

| Phase | Scope | Acceptance |
|---|---|---|
| **P13.A** (this PR) | Install Flutter SDK on VM, write `DESIGN.md` (this file), screenshot every screen, push to memory bank. No code changes to the app. | DESIGN.md committed; 20 screenshots saved (kept locally, not committed); user picks mascot + confirms pastel palette. |
| **P13.B** | Theme refinements: add `google_fonts` (Quicksand + Plus Jakarta Sans), bump radii, add 3 pastel accents, fix nav-bar indicator, soft inner highlight on buttons. No widgets relocated. | `flutter analyze` clean; existing tests still 84/84; visual diff: bottom-nav active state clearly visible, headings render in Quicksand on Home/Stats. |
| **P13.C** | Vector mascot (1 file `assets/mascot/<name>.svg` + 4 reaction variants) + empty-state widget + 3-step onboarding shown once on first launch. | New `Mascot` widget; `OnboardingScreen` route; mascot appears on Home greeting + empty Stats; new test: "Onboarding only shows on first launch". |
| **P13.D** | Micro-interactions: `confetti` on streak milestones, scale-bounce on card taps, MCQ correct/wrong animations, Pomodoro ring breathing pulse. | Frame budget < 16 ms on Linux desktop; new test: "Streak controller emits milestone event at 7/30/100 days". |
| **P13.E** | Screen polish: Home dashboard cards get icon tiles in accent.soft, Stats heatmap uses pastel ramp, Daily Challenge gets mascot summary, Certificate gets new font pair, Cheatsheet keeps current restraint. | Visual sweep: every screen screenshot before/after, attached to PR description. |

Total ETA: ~1 day of focused work per sub-phase. Each phase is independently mergeable — if anh muốn dừng sau P13.B (chỉ refresh theme), em dừng và phần sau đóng dạng follow-up.

## 9. Risks & decisions to make before P13.B

1. **Mascot choice** (A / B / C above) — em đề xuất B nhưng anh quyết.
2. **Font CDN vs. bundled** — `google_fonts` mặc định download lúc runtime. Anh có muốn bundle Quicksand + Plus Jakarta Sans làm offline assets không? Em đề xuất bundle (APK lớn hơn ~600 KB nhưng app dùng được offline 100%).
3. **Whether to keep the 6 pro accents or also surface the 3 pastel ones in Settings.** Em đề xuất giữ cả 9 và đặt 3 cái pastel ở 1 nhóm "Friendly" trong picker. Default vẫn `graphite`.
4. **Onboarding length** — 3 steps là max em sẽ ship; ít hơn cũng được. Anh có muốn skip onboarding hoàn toàn (bypass = "Bắt đầu ngay" button) không?

Khi anh chốt 1–4, em vào P13.B.
