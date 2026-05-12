# Supabase

This directory holds the Postgres schema + RLS policies for the SOCDaily
Supabase project (used by P11 cloud sync and the admin web).

## One-time setup

1. Create a free Supabase project at <https://supabase.com/dashboard>
   (Singapore region is closest to VN).
2. Open **Settings → API** and grab three values:
   - **Project URL** → `SUPABASE_URL`
   - **anon public key** → `SUPABASE_ANON_KEY`
   - **service_role secret key** → `SUPABASE_SERVICE_ROLE_KEY`
3. In the Supabase **SQL editor**, open `schema.sql` from this folder, paste
   the whole file, and click **Run**. The script is idempotent — re-running
   it is safe.
4. Wire the keys into your environment:
   - **Flutter app** (`app/`): set `SUPABASE_URL` + `SUPABASE_ANON_KEY` via
     `--dart-define=SUPABASE_URL=... --dart-define=SUPABASE_ANON_KEY=...`
     when building, or copy into a `.env` consumed by your build script.
   - **Admin web** (`admin/`): copy `.env.example` to `.env.local` and
     fill in `SUPABASE_URL` + `SUPABASE_SERVICE_ROLE_KEY` (server-side
     only; never exposed to the browser).

## What lives in Postgres

- **Content** — `subjects / chapters / topics / flashcards / questions /
  question_options`. Edited by the admin web using the `service_role` key
  (RLS bypassed). Read by everyone via the `anon` key.
- **Sync** — `device_sync_pair / user_sync_payload`. Pairing-code based:
  two devices that share a 6-digit code can read/write each other's
  payload rows. No Supabase auth involved — the code itself is the
  capability.

RLS is enabled on every table; see the `create policy …` blocks in
`schema.sql` for the details.

## Free-tier sizing

The free tier ships 500 MB of Postgres storage. Flashcards + questions
average ~1 KB each as JSON, so a 50 K-card library fits well under the
limit. **PDFs do NOT go here** — they live on your own VPS (see P12) and
are fetched over HTTP only when a user opens the "view source page"
action.

## Sync flow at a glance

```
device A                 Supabase                 device B
   │  generate code 123456   │                       │
   ├────── INSERT pair ──────▶│                       │
   │                          │                       │
   │  upload my user_state    │                       │
   ├──── UPSERT payload ─────▶│                       │
   │                          │   enter 123456        │
   │                          │◀──── UPDATE pair ─────┤
   │                          │      device_b_id      │
   │                          │                       │
   │                          │   pull A's payload    │
   │                          ├──── SELECT payload ──▶│
   │                          │                       │
   │                          │   upload B's state    │
   │                          │◀──── UPSERT payload ──┤
   │                          │                       │
   │   pull B's new rows      │                       │
   │◀── SELECT payload ───────┤                       │
```

Conflict resolution is last-write-wins per `(code, kind, item_key)`,
keyed on `updated_at`.
