"""Tests for the SOCDaily HTTP API.

We stub the LLM client so tests don't hit any real provider, and we
isolate the PDF directory + auth tokens via env vars + tmp_path.
"""

from __future__ import annotations

import json
from pathlib import Path

import pytest
from fastapi.testclient import TestClient

from socdaily.api import auth as auth_mod
from socdaily.api.app import create_app
from socdaily.llm.base import ChatMessage, LLMClient


class _FakeClient(LLMClient):
    """LLM stub: returns a hand-built TopicSeed JSON regardless of prompt.

    The fake mirrors what the real generator's system prompt asks for so
    the response validates against `TopicSeed`.
    """

    model = "fake-model"

    def list_models(self) -> list[str]:
        return [self.model]

    def complete(
        self,
        messages: list[ChatMessage],
        *,
        json_mode: bool = False,
        temperature: float | None = None,
        max_tokens: int | None = None,
    ) -> str:
        return json.dumps(
            {
                "topic_summary": "Stub summary.",
                "flashcards": [
                    {
                        "front": "Q?",
                        "back": "A.",
                        "difficulty": "easy",
                        "tags": [],
                        "source_page": 1,
                    }
                ],
                "questions": [
                    {
                        "qtype": "single",
                        "stem": "Pick A.",
                        "options": [
                            {"label": "A", "content": "A", "is_correct": True},
                            {"label": "B", "content": "B", "is_correct": False},
                        ],
                        "explanation": "A is correct.",
                        "difficulty": "easy",
                        "tags": [],
                        "source_page": 1,
                    }
                ],
            }
        )


def _make_pdf(path: Path) -> None:
    """Write a minimal valid PDF that pypdf can extract."""
    # Smallest hand-rolled 1-page PDF with the literal "Page 1" text.
    pdf = (
        b"%PDF-1.4\n"
        b"1 0 obj<</Type/Catalog/Pages 2 0 R>>endobj\n"
        b"2 0 obj<</Type/Pages/Kids[3 0 R]/Count 1>>endobj\n"
        b"3 0 obj<</Type/Page/Parent 2 0 R/MediaBox[0 0 612 792]/Resources"
        b"<</Font<</F1 5 0 R>>>>/Contents 4 0 R>>endobj\n"
        b"4 0 obj<</Length 44>>stream\n"
        b"BT /F1 24 Tf 50 700 Td (Page 1 content) Tj ET\n"
        b"endstream endobj\n"
        b"5 0 obj<</Type/Font/Subtype/Type1/BaseFont/Helvetica>>endobj\n"
        b"xref\n0 6\n0000000000 65535 f \n0000000009 00000 n \n"
        b"0000000054 00000 n \n0000000101 00000 n \n0000000196 00000 n \n"
        b"0000000284 00000 n \ntrailer<</Size 6/Root 1 0 R>>\n"
        b"startxref\n340\n%%EOF\n"
    )
    path.write_bytes(pdf)


@pytest.fixture
def api(tmp_path, monkeypatch):
    pdf_dir = tmp_path / "pdfs"
    pdf_dir.mkdir()
    monkeypatch.setenv("SOCDAILY_PDF_DIR", str(pdf_dir))
    monkeypatch.setenv("SOCDAILY_API_TOKENS", "test-token-1,test-token-2")
    auth_mod.reset_token_cache()

    # Force the API to use our fake LLM regardless of settings. The API
    # imports `build_client` from `socdaily.llm` at module load, so we
    # patch that attribute on the api.app module (the use site).
    from socdaily.api import app as app_mod

    monkeypatch.setattr(app_mod, "build_client", lambda settings: _FakeClient())

    app = create_app()
    client = TestClient(app)
    return client, pdf_dir


def test_healthz_no_auth(api):
    client, _ = api
    r = client.get("/healthz")
    assert r.status_code == 200
    assert r.json() == {"status": "ok"}


def test_pdfs_requires_auth(api):
    client, _ = api
    assert client.get("/pdfs").status_code == 401
    assert (
        client.get("/pdfs", headers={"Authorization": "Bearer wrong"}).status_code == 401
    )
    r = client.get("/pdfs", headers={"Authorization": "Bearer test-token-1"})
    assert r.status_code == 200
    assert r.json() == []


def test_503_when_no_tokens_configured(tmp_path, monkeypatch):
    monkeypatch.setenv("SOCDAILY_PDF_DIR", str(tmp_path))
    monkeypatch.setenv("SOCDAILY_API_TOKENS", "")
    auth_mod.reset_token_cache()
    client = TestClient(create_app())
    r = client.get("/pdfs", headers={"Authorization": "Bearer anything"})
    assert r.status_code == 503


def test_pdfs_lists_uploaded_files(api):
    client, pdf_dir = api
    _make_pdf(pdf_dir / "first.pdf")
    _make_pdf(pdf_dir / "second.pdf")
    r = client.get("/pdfs", headers={"Authorization": "Bearer test-token-1"})
    assert r.status_code == 200
    names = sorted(p["name"] for p in r.json())
    assert names == ["first.pdf", "second.pdf"]


def test_upload_pdf_writes_safe_filename(api):
    client, pdf_dir = api
    body = b"%PDF-1.4\n%fake\n"
    r = client.post(
        "/pdfs",
        headers={"Authorization": "Bearer test-token-1"},
        files={"file": ("../etc/passwd evil name.PDF", body, "application/pdf")},
    )
    assert r.status_code == 201
    safe = r.json()["name"]
    # Path components stripped, spaces collapsed, but the suffix kept.
    assert "/" not in safe and "\\" not in safe
    assert safe.lower().endswith(".pdf")
    assert (pdf_dir / safe).exists()


def test_upload_rejects_non_pdf(api):
    client, _ = api
    r = client.post(
        "/pdfs",
        headers={"Authorization": "Bearer test-token-1"},
        files={"file": ("notes.txt", b"hello", "text/plain")},
    )
    assert r.status_code == 400


def test_generate_requires_existing_pdf(api):
    client, _ = api
    payload = {
        "subject_code": "soc",
        "subject_title": "SOC",
        "chapter_code": "ch",
        "chapter_title": "Chapter",
        "topic_code": "t",
        "topic_title": "Topic",
        "pdf_filename": "missing.pdf",
        "page_start": 1,
        "page_end": 1,
    }
    r = client.post(
        "/generate",
        headers={"Authorization": "Bearer test-token-1"},
        json=payload,
    )
    assert r.status_code == 404


def test_generate_returns_topic_seed(api):
    client, pdf_dir = api
    _make_pdf(pdf_dir / "demo.pdf")
    payload = {
        "subject_code": "soc",
        "subject_title": "SOC",
        "chapter_code": "ch",
        "chapter_title": "Chapter",
        "topic_code": "t",
        "topic_title": "Topic",
        "pdf_filename": "demo.pdf",
        "page_start": 1,
        "page_end": 1,
        "n_flashcards": 1,
        "n_questions": 1,
        "content_lang": "en",
    }
    r = client.post(
        "/generate",
        headers={"Authorization": "Bearer test-token-1"},
        json=payload,
    )
    assert r.status_code == 200, r.text
    body = r.json()
    assert body["subject_code"] == "soc"
    assert body["topic_code"] == "t"
    assert len(body["flashcards"]) == 1
    assert len(body["questions"]) == 1


def test_generate_validates_page_range(api):
    client, pdf_dir = api
    _make_pdf(pdf_dir / "demo.pdf")
    payload = {
        "subject_code": "soc",
        "subject_title": "SOC",
        "chapter_code": "ch",
        "chapter_title": "Chapter",
        "topic_code": "t",
        "topic_title": "Topic",
        "pdf_filename": "demo.pdf",
        "page_start": 5,
        "page_end": 1,
    }
    r = client.post(
        "/generate",
        headers={"Authorization": "Bearer test-token-1"},
        json=payload,
    )
    assert r.status_code == 400
