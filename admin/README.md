# SOCDaily Admin

A Next.js 14 (App Router) admin web for editing the JSON content bank
consumed by the SOCDaily Flutter app.

## What it does

- Lists the manifest taxonomy: Subject → Chapter → Topic, with per-topic
  counts of flashcards and questions.
- Edit any topic in place: edit the title and summary, edit/delete
  individual flashcards (front/back/hint/tags/difficulty/source_page),
  edit/delete questions (stem/options/correctness/explanation), add new
  flashcards inline.
- All saves write back to the same JSON files under
  `app/assets/seed/` that the Flutter app bundles at build time — there
  is no separate database. The next `flutter build` picks up the
  changes automatically.

## Quick start

```bash
cd admin
pnpm install
pnpm dev          # http://localhost:3000
```

By default the admin reads from `../app/assets/seed` (i.e. the seed
bundle the Flutter app ships with). Override with `SOCDAILY_SEED_DIR`.

## Auth

If `ADMIN_PASSWORD` is unset, the admin runs in **open** mode (useful on
your own laptop). Set `ADMIN_PASSWORD=...` to enable a cookie-based
password gate served at `/login`.

## Scripts

| Script | What |
|---|---|
| `pnpm dev` | Next.js dev server |
| `pnpm build` | Production build |
| `pnpm start` | Run the production build |
| `pnpm lint` | ESLint (next config) |
| `pnpm typecheck` | `tsc --noEmit` |
| `pnpm test` | Vitest unit tests |

## How it fits with the rest of the repo

```
src/socdaily/      Python ETL pipeline
       │
       ▼ produces
app/assets/seed/   JSON content bank   ←── admin/  edits this in place
       │
       ▼ bundled into
app/               Flutter app
```

The pipeline produces the bank; the Flutter app consumes it; the admin
gives a friendly UI for editing the bank between pipeline runs.

In a future phase (P11) the data layer in `src/lib/content.ts` will be
swapped for a Supabase client so the same admin can edit a hosted DB.
