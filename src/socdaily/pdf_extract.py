"""PDF → page-tagged markdown.

We need page numbers to flow through to flashcards/MCQs so anyone can verify
generated content against the source. Two extraction backends:

  1. `pdftotext -layout` (poppler) — preferred for typical text PDFs.
  2. `pypdf.PdfReader` — fallback when poppler isn't installed.

Both backends emit the same structure:

    <!-- page=1 -->
    ...text of page 1...

    <!-- page=2 -->
    ...
"""

from __future__ import annotations

import shutil
import subprocess
from pathlib import Path

PAGE_MARK = "<!-- page={n} -->"


def _have_pdftotext() -> bool:
    # We use both pdftotext (extract) and pdfinfo (page count). On some
    # Windows installs (e.g. Git for Windows mingw64) only pdftotext is
    # bundled, so require both before opting into the poppler path.
    return shutil.which("pdftotext") is not None and shutil.which("pdfinfo") is not None


def _extract_with_pdftotext(pdf: Path) -> list[str]:
    """Run pdftotext once per page; returns list[page_text] indexed from 0."""
    # First, get total page count via pdfinfo, then extract per-page so we can
    # tag pages. Pdftotext supports -f / -l for first/last page.
    info = subprocess.run(
        ["pdfinfo", str(pdf)], capture_output=True, text=True, check=False
    )
    pages = 0
    for line in info.stdout.splitlines():
        if line.lower().startswith("pages:"):
            try:
                pages = int(line.split(":", 1)[1].strip())
            except ValueError:
                pages = 0
    if pages <= 0:
        # Last resort: extract whole doc.
        out = subprocess.run(
            ["pdftotext", "-layout", str(pdf), "-"],
            capture_output=True, text=True, check=False,
        )
        return [out.stdout]

    texts: list[str] = []
    for p in range(1, pages + 1):
        out = subprocess.run(
            ["pdftotext", "-layout", "-f", str(p), "-l", str(p), str(pdf), "-"],
            capture_output=True, text=True, check=False,
        )
        texts.append(out.stdout)
    return texts


def _extract_with_pypdf(pdf: Path) -> list[str]:
    from pypdf import PdfReader

    reader = PdfReader(str(pdf))
    return [page.extract_text() or "" for page in reader.pages]


def extract_docx(path: Path) -> str:
    """Best-effort extraction for .docx (Helpful Links.docx, SIEM Notes.docx)."""
    from docx import Document

    doc = Document(str(path))
    parts: list[str] = []
    for para in doc.paragraphs:
        if para.text.strip():
            parts.append(para.text)
    # Pull tables too.
    for table in doc.tables:
        for row in table.rows:
            cells = [c.text.strip() for c in row.cells]
            parts.append(" | ".join(cells))
    return "\n\n".join(parts)


def extract_pptx(path: Path) -> list[str]:
    """Extract each slide as a 'page' so the same page-marker model applies."""
    from pptx import Presentation

    prs = Presentation(str(path))
    slides: list[str] = []
    for slide in prs.slides:
        chunks: list[str] = []
        for shape in slide.shapes:
            text = getattr(shape, "text", "") or ""
            if text.strip():
                chunks.append(text)
        slides.append("\n".join(chunks))
    return slides


def pdf_to_markdown(pdf: Path) -> str:
    """Extract a PDF (or .docx / .pptx) to page-tagged markdown."""
    suffix = pdf.suffix.lower()
    if suffix == ".docx":
        body = extract_docx(pdf)
        return f"{PAGE_MARK.format(n=1)}\n{body}\n"
    if suffix == ".pptx":
        slides = extract_pptx(pdf)
        out: list[str] = []
        for i, s in enumerate(slides, start=1):
            out.append(PAGE_MARK.format(n=i))
            out.append(s)
            out.append("")
        return "\n".join(out)

    # PDF.
    if _have_pdftotext():
        pages = _extract_with_pdftotext(pdf)
    else:
        pages = _extract_with_pypdf(pdf)
    out_parts: list[str] = []
    for i, text in enumerate(pages, start=1):
        out_parts.append(PAGE_MARK.format(n=i))
        # Compact runs of blank lines to keep tokens reasonable.
        compact = "\n".join(line.rstrip() for line in text.splitlines())
        out_parts.append(compact.strip("\n"))
        out_parts.append("")
    return "\n".join(out_parts)


def slice_pages(markdown: str, start: int, end: int) -> str:
    """Return the markdown slice covering pages [start, end] inclusive."""
    lines = markdown.splitlines()
    in_range = False
    out: list[str] = []
    for line in lines:
        if line.startswith("<!-- page="):
            try:
                n = int(line.split("page=", 1)[1].split(" ", 1)[0].rstrip("-> "))
            except ValueError:
                continue
            in_range = start <= n <= end
        if in_range:
            out.append(line)
    return "\n".join(out)
