"""Smoke tests that don't hit any LLM."""

from __future__ import annotations

import json
import sqlite3
import sys
from pathlib import Path

# Make src/ importable when running `pytest` straight from the repo root,
# without requiring an editable install.
REPO_ROOT = Path(__file__).resolve().parents[1]
SRC = REPO_ROOT / "src"
if str(SRC) not in sys.path:
    sys.path.insert(0, str(SRC))

from socdaily import pdf_extract  # noqa: E402
from socdaily.models import (  # noqa: E402
    Flashcard,
    Outline,
    OutlineChapter,
    OutlineTopic,
    Question,
    QuestionOption,
    TopicSeed,
)
from socdaily.pipeline.importer import apply_schema, import_topic_seed  # noqa: E402


def test_slice_pages_keeps_only_requested_range() -> None:
    md = (
        "<!-- page=1 -->\nintro\n\n"
        "<!-- page=2 -->\nbody A\n\n"
        "<!-- page=3 -->\nbody B\n\n"
        "<!-- page=4 -->\noutro\n"
    )
    sliced = pdf_extract.slice_pages(md, 2, 3)
    assert "body A" in sliced
    assert "body B" in sliced
    assert "intro" not in sliced
    assert "outro" not in sliced


def test_outline_roundtrip() -> None:
    o = Outline(
        pdf="test.pdf",
        subject_code="soc-fundamentals",
        subject_title="SOC Fundamentals",
        chapters=[
            OutlineChapter(
                code="intro",
                title="Introduction",
                pages=[1, 5],
                topics=[
                    OutlineTopic(
                        code="roles",
                        title="Tier roles",
                        pages=[2, 3],
                        key_points=["L1 monitors", "L2 deep dive"],
                    )
                ],
            )
        ],
    )
    dumped = o.model_dump()
    again = Outline.model_validate(dumped)
    assert again.chapters[0].topics[0].code == "roles"


def test_importer_inserts_into_sqlite(tmp_path: Path) -> None:
    seed = TopicSeed(
        subject_code="soc-fundamentals",
        subject_title="SOC Fundamentals",
        chapter_code="intro",
        chapter_title="Introduction",
        topic_code="roles",
        topic_title="Tier roles",
        topic_summary="L1/L2/L3 responsibilities.",
        source_pdf="SOC Analyst Tools.pdf",
        flashcards=[
            Flashcard(
                front="L1 làm gì?",
                back="Triage + escalate.",
                difficulty="easy",
                tags=["tier"],
                source_page=5,
            )
        ],
        questions=[
            Question(
                qtype="single",
                stem="L1 escalate khi nào?",
                options=[
                    QuestionOption(label="A", content="Ngay khi nhận alert", is_correct=False),
                    QuestionOption(label="B", content="Sau khi confirm", is_correct=True),
                ],
                explanation="L1 triage trước, escalate khi confirmed.",
                difficulty="medium",
                source_page=6,
            )
        ],
    )
    db = tmp_path / "test.db"
    conn = sqlite3.connect(db)
    try:
        apply_schema(conn)
        counts = import_topic_seed(conn, seed)
        conn.commit()
        assert counts == {"flashcards": 1, "questions": 1}

        (n_cards,) = conn.execute("SELECT COUNT(*) FROM flashcards").fetchone()
        (n_qs,) = conn.execute("SELECT COUNT(*) FROM questions").fetchone()
        (n_opts,) = conn.execute("SELECT COUNT(*) FROM question_options").fetchone()
        assert n_cards == 1
        assert n_qs == 1
        assert n_opts == 2

        # Idempotent re-import should not duplicate taxonomy rows.
        import_topic_seed(conn, seed)
        conn.commit()
        (n_subj,) = conn.execute("SELECT COUNT(*) FROM subjects").fetchone()
        assert n_subj == 1

        # Tags round-trip as JSON.
        (tags_json,) = conn.execute("SELECT tags_json FROM flashcards LIMIT 1").fetchone()
        assert json.loads(tags_json) == ["tier"]
    finally:
        conn.close()
