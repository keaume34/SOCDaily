"""Import generated TopicSeed JSON files into the SQLite database."""

from __future__ import annotations

import json
import sqlite3
from pathlib import Path

from socdaily.models import TopicSeed

SCHEMA_PATH = Path(__file__).resolve().parents[3] / "db" / "schema.sql"


def apply_schema(conn: sqlite3.Connection, schema_path: Path | None = None) -> None:
    p = schema_path or SCHEMA_PATH
    sql = p.read_text(encoding="utf-8")
    conn.executescript(sql)


def _upsert_subject(conn: sqlite3.Connection, code: str, title: str) -> int:
    cur = conn.execute("SELECT id FROM subjects WHERE code=?", (code,))
    row = cur.fetchone()
    if row:
        return int(row[0])
    cur = conn.execute(
        "INSERT INTO subjects(code, title) VALUES (?, ?)", (code, title)
    )
    return int(cur.lastrowid)


def _upsert_chapter(
    conn: sqlite3.Connection, subject_id: int, code: str, title: str
) -> int:
    cur = conn.execute(
        "SELECT id FROM chapters WHERE subject_id=? AND code=?", (subject_id, code)
    )
    row = cur.fetchone()
    if row:
        return int(row[0])
    cur = conn.execute(
        "INSERT INTO chapters(subject_id, code, title) VALUES (?, ?, ?)",
        (subject_id, code, title),
    )
    return int(cur.lastrowid)


def _upsert_topic(
    conn: sqlite3.Connection,
    chapter_id: int,
    code: str,
    title: str,
    summary: str | None,
) -> int:
    cur = conn.execute(
        "SELECT id FROM topics WHERE chapter_id=? AND code=?", (chapter_id, code)
    )
    row = cur.fetchone()
    if row:
        topic_id = int(row[0])
        if summary:
            conn.execute("UPDATE topics SET summary=? WHERE id=?", (summary, topic_id))
        return topic_id
    cur = conn.execute(
        "INSERT INTO topics(chapter_id, code, title, summary) VALUES (?, ?, ?, ?)",
        (chapter_id, code, title, summary),
    )
    return int(cur.lastrowid)


def _upsert_source(conn: sqlite3.Connection, pdf_path: str) -> int:
    cur = conn.execute("SELECT id FROM sources WHERE pdf_path=?", (pdf_path,))
    row = cur.fetchone()
    if row:
        return int(row[0])
    cur = conn.execute(
        "INSERT INTO sources(pdf_path, title) VALUES (?, ?)",
        (pdf_path, Path(pdf_path).stem),
    )
    return int(cur.lastrowid)


def import_topic_seed(conn: sqlite3.Connection, seed: TopicSeed) -> dict[str, int]:
    """Insert one TopicSeed; returns counts of items inserted."""
    sid = _upsert_subject(conn, seed.subject_code, seed.subject_title)
    cid = _upsert_chapter(conn, sid, seed.chapter_code, seed.chapter_title)
    tid = _upsert_topic(conn, cid, seed.topic_code, seed.topic_title, seed.topic_summary)
    src_id = _upsert_source(conn, seed.source_pdf)

    n_cards = 0
    for card in seed.flashcards:
        conn.execute(
            "INSERT INTO flashcards(topic_id, front, back, hint, difficulty, "
            "tags_json, source_id, source_page) VALUES (?,?,?,?,?,?,?,?)",
            (
                tid,
                card.front,
                card.back,
                card.hint,
                card.difficulty,
                json.dumps(card.tags, ensure_ascii=False),
                src_id,
                card.source_page,
            ),
        )
        n_cards += 1

    n_q = 0
    for q in seed.questions:
        cur = conn.execute(
            "INSERT INTO questions(topic_id, qtype, stem, explanation, difficulty, "
            "tags_json, source_id, source_page) VALUES (?,?,?,?,?,?,?,?)",
            (
                tid,
                q.qtype,
                q.stem,
                q.explanation,
                q.difficulty,
                json.dumps(q.tags, ensure_ascii=False),
                src_id,
                q.source_page,
            ),
        )
        qid = int(cur.lastrowid)
        for i, opt in enumerate(q.options):
            conn.execute(
                "INSERT INTO question_options(question_id, label, content, "
                "is_correct, order_index) VALUES (?,?,?,?,?)",
                (qid, opt.label, opt.content, 1 if opt.is_correct else 0, i),
            )
        n_q += 1

    return {"flashcards": n_cards, "questions": n_q}


def import_directory(db_path: Path, seed_dir: Path) -> dict[str, int]:
    """Walk `seed_dir`, importing every *.json TopicSeed file."""
    db_path.parent.mkdir(parents=True, exist_ok=True)
    conn = sqlite3.connect(db_path)
    try:
        apply_schema(conn)
        totals = {"flashcards": 0, "questions": 0, "topics": 0}
        for jf in sorted(seed_dir.rglob("*.json")):
            data = json.loads(jf.read_text(encoding="utf-8"))
            seed = TopicSeed.model_validate(data)
            counts = import_topic_seed(conn, seed)
            totals["flashcards"] += counts["flashcards"]
            totals["questions"] += counts["questions"]
            totals["topics"] += 1
        conn.commit()
        return totals
    finally:
        conn.close()
