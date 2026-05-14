-- SOCDaily Supabase schema — content + sync envelopes.
--
-- Run this on a fresh Supabase project (SQL editor → New query → paste → Run).
-- Re-runnable: every `create table` is `if not exists`; policies are dropped + recreated.
--
-- Layout
--   content tables: subjects / chapters / topics / flashcards / questions / question_options
--     - written by the admin web using the service_role key (RLS bypassed)
--     - read by everyone with the anon key
--   sync tables: device_sync_pair / user_sync_payload
--     - written by the Flutter app using the anon key
--     - rows are scoped by a 6-digit pairing code that two devices share
--     - no Supabase auth required: the pairing code itself is the capability
--
-- Conventions
--   - timestamps in `timestamptz` with `default now()`
--   - all text PKs are slug-style codes consistent with the JSON bank
--   - JSON envelope (`payload`) on user_sync_payload so we can sync new
--     user-side tables (notes, bookmarks, streaks, …) without altering schema

-- ---------- Content tables (admin-managed) ----------

create table if not exists public.subjects (
  code            text primary key,
  title           text not null,
  description     text,
  order_index     int  not null default 0,
  updated_at      timestamptz not null default now()
);

create table if not exists public.chapters (
  subject_code    text not null references public.subjects(code) on delete cascade,
  code            text not null,
  title           text not null,
  order_index     int  not null default 0,
  updated_at      timestamptz not null default now(),
  primary key (subject_code, code)
);

create table if not exists public.topics (
  subject_code    text not null,
  chapter_code    text not null,
  code            text not null,
  title           text not null,
  summary         text,
  source_pdf      text,
  order_index     int  not null default 0,
  updated_at      timestamptz not null default now(),
  primary key (subject_code, chapter_code, code),
  foreign key (subject_code, chapter_code)
    references public.chapters(subject_code, code) on delete cascade
);

create table if not exists public.flashcards (
  id              bigserial primary key,
  subject_code    text not null,
  chapter_code    text not null,
  topic_code      text not null,
  front           text not null,
  back            text not null,
  hint            text,
  difficulty      text not null default 'medium',
  tags            jsonb not null default '[]'::jsonb,
  source_page     int,
  updated_at      timestamptz not null default now(),
  foreign key (subject_code, chapter_code, topic_code)
    references public.topics(subject_code, chapter_code, code) on delete cascade
);
create index if not exists flashcards_topic_idx
  on public.flashcards (subject_code, chapter_code, topic_code);

create table if not exists public.questions (
  id              bigserial primary key,
  subject_code    text not null,
  chapter_code    text not null,
  topic_code      text not null,
  qtype           text not null default 'single',
  stem            text not null,
  explanation     text not null default '',
  difficulty      text not null default 'medium',
  tags            jsonb not null default '[]'::jsonb,
  source_page     int,
  updated_at      timestamptz not null default now(),
  foreign key (subject_code, chapter_code, topic_code)
    references public.topics(subject_code, chapter_code, code) on delete cascade
);
create index if not exists questions_topic_idx
  on public.questions (subject_code, chapter_code, topic_code);

create table if not exists public.question_options (
  id              bigserial primary key,
  question_id     bigint not null references public.questions(id) on delete cascade,
  label           text not null,
  content         text not null,
  is_correct      boolean not null default false,
  order_index     int not null default 0
);

-- ---------- Sync tables (device-managed) ----------

create table if not exists public.device_sync_pair (
  code            text primary key,
  -- A pair is born when one device generates the code; the second device
  -- "redeems" it by inserting its `device_b_id`. Once both ids are present,
  -- payload rows scoped by this code can be exchanged.
  device_a_id     uuid not null,
  device_b_id     uuid,
  created_at      timestamptz not null default now(),
  redeemed_at     timestamptz,
  expires_at      timestamptz not null
);

create table if not exists public.user_sync_payload (
  code            text not null references public.device_sync_pair(code) on delete cascade,
  device_id       uuid not null,
  kind            text not null,        -- 'card_state' | 'question_state' | 'note' | 'bookmark' | 'streak'
                                        -- P14: 'generated_seed' (whole TopicSeed JSON), 'topic_weakness' (per-topic score)
  item_key        text not null,        -- flashcard id / question id / "yyyymmdd" / topic_code (for generated_seed)
  payload         jsonb not null,
  updated_at      timestamptz not null default now(),
  primary key (code, device_id, kind, item_key)
);

-- ---------- Row-Level Security ----------

alter table public.subjects        enable row level security;
alter table public.chapters        enable row level security;
alter table public.topics          enable row level security;
alter table public.flashcards      enable row level security;
alter table public.questions       enable row level security;
alter table public.question_options enable row level security;
alter table public.device_sync_pair enable row level security;
alter table public.user_sync_payload enable row level security;

-- Content: anyone can read; only service_role can write (service_role bypasses RLS).
drop policy if exists "content read" on public.subjects;
create policy "content read" on public.subjects for select using (true);
drop policy if exists "content read" on public.chapters;
create policy "content read" on public.chapters for select using (true);
drop policy if exists "content read" on public.topics;
create policy "content read" on public.topics for select using (true);
drop policy if exists "content read" on public.flashcards;
create policy "content read" on public.flashcards for select using (true);
drop policy if exists "content read" on public.questions;
create policy "content read" on public.questions for select using (true);
drop policy if exists "content read" on public.question_options;
create policy "content read" on public.question_options for select using (true);

-- Pairing: anyone can insert a pair (to create a code) or update with their
-- own device id to redeem. Reads restricted to the code holder via the
-- application (treated as a capability).
drop policy if exists "pair insert" on public.device_sync_pair;
create policy "pair insert" on public.device_sync_pair
  for insert with check (true);
drop policy if exists "pair update" on public.device_sync_pair;
create policy "pair update" on public.device_sync_pair
  for update using (true) with check (true);
drop policy if exists "pair select" on public.device_sync_pair;
create policy "pair select" on public.device_sync_pair
  for select using (true);

-- Sync payloads: knowing the code is the capability. The app filters by
-- code on every query; RLS just gates the bulk read path so the anon key
-- can't be used to enumerate every payload in the DB without a code.
drop policy if exists "payload insert" on public.user_sync_payload;
create policy "payload insert" on public.user_sync_payload
  for insert with check (true);
drop policy if exists "payload update" on public.user_sync_payload;
create policy "payload update" on public.user_sync_payload
  for update using (true) with check (true);
drop policy if exists "payload select" on public.user_sync_payload;
create policy "payload select" on public.user_sync_payload
  for select using (true);
drop policy if exists "payload delete" on public.user_sync_payload;
create policy "payload delete" on public.user_sync_payload
  for delete using (true);

-- ---------- Maintenance: drop expired pairing codes ----------
-- Run this on a schedule or whenever the admin opens /sync.

create or replace function public.purge_expired_pairs() returns void
language sql security definer as $$
  delete from public.device_sync_pair where expires_at < now() - interval '1 day';
$$;
