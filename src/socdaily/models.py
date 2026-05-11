"""Pydantic models for the SOCDaily JSON IO format.

Every generation step writes JSON files matching these schemas. The importer
reads them and inserts into SQLite. This decoupling lets the user review and
hand-edit generated content before it lands in the DB.
"""

from __future__ import annotations

from typing import Literal

from pydantic import BaseModel, Field

Difficulty = Literal["easy", "medium", "hard"]
QType = Literal["single", "multiple", "truefalse", "scenario"]


# ---- Outline schema (YAML in outline/, also used as JSON internally) ----


class OutlineTopic(BaseModel):
    code: str
    title: str
    pages: list[int] = Field(default_factory=list)  # [start, end]
    key_points: list[str] = Field(default_factory=list)


class OutlineChapter(BaseModel):
    code: str
    title: str
    pages: list[int] = Field(default_factory=list)
    topics: list[OutlineTopic] = Field(default_factory=list)


class Outline(BaseModel):
    pdf: str
    subject_code: str
    subject_title: str
    chapters: list[OutlineChapter] = Field(default_factory=list)


# ---- Generated learning items ----


class Flashcard(BaseModel):
    front: str
    back: str
    hint: str | None = None
    difficulty: Difficulty = "medium"
    tags: list[str] = Field(default_factory=list)
    source_page: int | None = None


class QuestionOption(BaseModel):
    label: str  # 'A', 'B', 'C', 'D'
    content: str
    is_correct: bool = False


class Question(BaseModel):
    qtype: QType = "single"
    stem: str
    options: list[QuestionOption] = Field(default_factory=list)
    explanation: str | None = None
    difficulty: Difficulty = "medium"
    tags: list[str] = Field(default_factory=list)
    source_page: int | None = None


class TopicSeed(BaseModel):
    """One JSON file per topic, lives in seed/{subject}/{chapter}/{topic}.json."""

    subject_code: str
    subject_title: str
    chapter_code: str
    chapter_title: str
    topic_code: str
    topic_title: str
    topic_summary: str | None = None
    source_pdf: str
    flashcards: list[Flashcard] = Field(default_factory=list)
    questions: list[Question] = Field(default_factory=list)
