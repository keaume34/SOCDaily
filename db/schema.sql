-- SOCDaily SQLite schema
-- Apply with: sqlite3 db/socdaily.db < db/schema.sql
-- (or via `socdaily db-init`)

PRAGMA foreign_keys = ON;

-- ============================================================
-- Taxonomy
-- ============================================================

CREATE TABLE IF NOT EXISTS subjects (
    id           INTEGER PRIMARY KEY AUTOINCREMENT,
    code         TEXT NOT NULL UNIQUE,
    title        TEXT NOT NULL,
    description  TEXT,
    order_index  INTEGER NOT NULL DEFAULT 0
);

CREATE TABLE IF NOT EXISTS chapters (
    id           INTEGER PRIMARY KEY AUTOINCREMENT,
    subject_id   INTEGER NOT NULL REFERENCES subjects(id) ON DELETE CASCADE,
    code         TEXT NOT NULL,
    title        TEXT NOT NULL,
    description  TEXT,
    order_index  INTEGER NOT NULL DEFAULT 0,
    UNIQUE(subject_id, code)
);

CREATE TABLE IF NOT EXISTS topics (
    id           INTEGER PRIMARY KEY AUTOINCREMENT,
    chapter_id   INTEGER NOT NULL REFERENCES chapters(id) ON DELETE CASCADE,
    code         TEXT NOT NULL,
    title        TEXT NOT NULL,
    summary      TEXT,
    order_index  INTEGER NOT NULL DEFAULT 0,
    UNIQUE(chapter_id, code)
);

-- ============================================================
-- Source tracking (which PDF + which page each item came from)
-- ============================================================

CREATE TABLE IF NOT EXISTS sources (
    id          INTEGER PRIMARY KEY AUTOINCREMENT,
    pdf_path    TEXT NOT NULL UNIQUE,
    category    TEXT,
    title       TEXT,
    page_count  INTEGER
);

-- ============================================================
-- Learning items
-- ============================================================

CREATE TABLE IF NOT EXISTS flashcards (
    id           INTEGER PRIMARY KEY AUTOINCREMENT,
    topic_id     INTEGER NOT NULL REFERENCES topics(id) ON DELETE CASCADE,
    front        TEXT NOT NULL,
    back         TEXT NOT NULL,
    hint         TEXT,
    difficulty   TEXT NOT NULL DEFAULT 'medium'
                 CHECK(difficulty IN ('easy','medium','hard')),
    tags_json    TEXT NOT NULL DEFAULT '[]',
    source_id    INTEGER REFERENCES sources(id),
    source_page  INTEGER,
    created_at   TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS questions (
    id            INTEGER PRIMARY KEY AUTOINCREMENT,
    topic_id      INTEGER NOT NULL REFERENCES topics(id) ON DELETE CASCADE,
    qtype         TEXT NOT NULL
                  CHECK(qtype IN ('single','multiple','truefalse','scenario')),
    stem          TEXT NOT NULL,
    explanation   TEXT,
    difficulty    TEXT NOT NULL DEFAULT 'medium'
                  CHECK(difficulty IN ('easy','medium','hard')),
    tags_json     TEXT NOT NULL DEFAULT '[]',
    source_id     INTEGER REFERENCES sources(id),
    source_page   INTEGER,
    created_at    TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS question_options (
    id           INTEGER PRIMARY KEY AUTOINCREMENT,
    question_id  INTEGER NOT NULL REFERENCES questions(id) ON DELETE CASCADE,
    label        TEXT NOT NULL,        -- 'A','B','C','D' or '1','2','3'
    content      TEXT NOT NULL,
    is_correct   INTEGER NOT NULL DEFAULT 0,
    order_index  INTEGER NOT NULL DEFAULT 0
);

-- ============================================================
-- Spaced-repetition state (optional, populated by the app)
-- ============================================================

CREATE TABLE IF NOT EXISTS user_card_state (
    flashcard_id   INTEGER PRIMARY KEY REFERENCES flashcards(id) ON DELETE CASCADE,
    ease           REAL NOT NULL DEFAULT 2.5,
    interval_days  INTEGER NOT NULL DEFAULT 1,
    next_review    DATE,
    last_result    TEXT,
    review_count   INTEGER NOT NULL DEFAULT 0
);

-- ============================================================
-- Indexes
-- ============================================================

CREATE INDEX IF NOT EXISTS idx_chapters_subject     ON chapters(subject_id);
CREATE INDEX IF NOT EXISTS idx_topics_chapter       ON topics(chapter_id);
CREATE INDEX IF NOT EXISTS idx_flashcards_topic     ON flashcards(topic_id);
CREATE INDEX IF NOT EXISTS idx_questions_topic      ON questions(topic_id);
CREATE INDEX IF NOT EXISTS idx_qoptions_question    ON question_options(question_id);
CREATE INDEX IF NOT EXISTS idx_flashcards_source    ON flashcards(source_id);
CREATE INDEX IF NOT EXISTS idx_questions_source     ON questions(source_id);
