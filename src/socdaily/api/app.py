"""FastAPI app factory + endpoints for the SOCDaily content generator.

Endpoints:
    GET  /healthz                 — liveness probe (no auth, returns "ok").
    GET  /pdfs                    — list PDFs available under SOCDAILY_PDF_DIR.
    POST /pdfs                    — upload a new PDF (multipart/form-data).
    POST /generate                — run pipeline.generate.generate_topic_seed,
                                    return one TopicSeed JSON.

Auth: every route except /healthz requires `Authorization: Bearer <token>`.
Tokens are loaded from `SOCDAILY_API_TOKENS` (comma-separated).

PDF storage: `SOCDAILY_PDF_DIR` (default: `./raw/pdf`). The directory is
created if missing. Uploads keep their basename, sanitized.
"""

from __future__ import annotations

import os
import re
from pathlib import Path
from typing import Literal

from fastapi import Depends, FastAPI, HTTPException, UploadFile, status
from pydantic import BaseModel, Field

from socdaily import pdf_extract
from socdaily.api.auth import require_bearer
from socdaily.config import load_settings
from socdaily.llm import build_client
from socdaily.models import Outline, OutlineTopic, TopicSeed
from socdaily.pipeline import generate as gen_mod


def _pdf_dir() -> Path:
    p = Path(os.environ.get("SOCDAILY_PDF_DIR", "raw/pdf")).resolve()
    p.mkdir(parents=True, exist_ok=True)
    return p


_SAFE = re.compile(r"[^A-Za-z0-9._-]+")


def _safe_name(name: str) -> str:
    """Strip path components and disallowed characters from an upload name."""
    base = Path(name).name
    cleaned = _SAFE.sub("-", base).strip("-.")
    return cleaned or "upload.pdf"


# -- request/response schemas ------------------------------------------------


class GenerateRequest(BaseModel):
    """Inputs for /generate.

    `subject_code`/`chapter_code`/`topic_code` decide where the resulting
    seed lands when imported into the local DB. The free-form `hint` lets
    the user steer the generator ("focus on Splunk SPL examples").
    """

    subject_code: str = Field(min_length=1)
    subject_title: str = Field(min_length=1)
    chapter_code: str = Field(min_length=1)
    chapter_title: str = Field(min_length=1)
    topic_code: str = Field(min_length=1)
    topic_title: str = Field(min_length=1)
    pdf_filename: str = Field(min_length=1, description="basename under SOCDAILY_PDF_DIR")
    page_start: int = Field(ge=1)
    page_end: int = Field(ge=1)
    hint: str | None = None
    n_flashcards: int = Field(default=6, ge=1, le=30)
    n_questions: int = Field(default=4, ge=0, le=20)
    content_lang: Literal["vi", "en", "bilingual"] | None = None


class PdfInfo(BaseModel):
    name: str
    size_bytes: int


# -- factory -----------------------------------------------------------------


def create_app() -> FastAPI:
    app = FastAPI(
        title="SOCDaily API",
        version="0.1.0",
        description="On-demand flashcard + MCQ generator for the SOCDaily app.",
    )

    @app.get("/healthz")
    def healthz() -> dict[str, str]:
        return {"status": "ok"}

    @app.get("/pdfs", response_model=list[PdfInfo])
    def list_pdfs(_: str = Depends(require_bearer)) -> list[PdfInfo]:
        out: list[PdfInfo] = []
        for p in sorted(_pdf_dir().rglob("*.pdf")):
            out.append(
                PdfInfo(name=str(p.relative_to(_pdf_dir())), size_bytes=p.stat().st_size)
            )
        return out

    @app.post("/pdfs", response_model=PdfInfo, status_code=status.HTTP_201_CREATED)
    async def upload_pdf(
        file: UploadFile,
        _: str = Depends(require_bearer),
    ) -> PdfInfo:
        if not (file.filename or "").lower().endswith(".pdf"):
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="Only .pdf uploads are accepted.",
            )
        name = _safe_name(file.filename or "upload.pdf")
        dest = _pdf_dir() / name
        body = await file.read()
        dest.write_bytes(body)
        return PdfInfo(name=name, size_bytes=dest.stat().st_size)

    @app.post("/generate", response_model=dict)
    def generate(
        req: GenerateRequest,
        _: str = Depends(require_bearer),
    ) -> dict:
        if req.page_end < req.page_start:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="page_end must be >= page_start.",
            )
        pdf_path = _pdf_dir() / _safe_name(req.pdf_filename)
        if not pdf_path.exists():
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail=f"PDF not found on server: {pdf_path.name}. Upload it via POST /pdfs first.",
            )

        # Extract markdown for the requested page range only.
        markdown = pdf_extract.pdf_to_markdown(pdf_path)
        slice_md = pdf_extract.slice_pages(markdown, req.page_start, req.page_end)
        if not slice_md.strip():
            raise HTTPException(
                status_code=status.HTTP_422_UNPROCESSABLE_ENTITY,
                detail="Page slice is empty. Verify the PDF text-extracts and the page range.",
            )

        settings = load_settings()
        if req.content_lang is not None:
            # Allow request to override server default (e.g. user wants vi today).
            object.__setattr__(settings, "content_lang", req.content_lang)
        client = build_client(settings)

        outline = Outline(
            pdf=pdf_path.stem,
            subject_code=req.subject_code,
            subject_title=req.subject_title,
        )
        topic = OutlineTopic(
            code=req.topic_code,
            title=req.topic_title,
            pages=[req.page_start, req.page_end],
            key_points=[req.hint] if req.hint else [],
        )

        try:
            seed: TopicSeed = gen_mod.generate_topic_seed(
                client=client,
                outline=outline,
                topic=topic,
                chapter_code=req.chapter_code,
                chapter_title=req.chapter_title,
                topic_markdown=slice_md,
                content_lang=settings.content_lang,
                n_flashcards=req.n_flashcards,
                n_questions=req.n_questions,
            )
        except Exception as exc:  # LLM / parse errors bubble up as 502
            raise HTTPException(
                status_code=status.HTTP_502_BAD_GATEWAY,
                detail=f"Generator failed: {exc}",
            ) from exc

        return seed.model_dump()

    return app


# Module-level instance so `uvicorn socdaily.api.app:app` works directly.
app = create_app()
