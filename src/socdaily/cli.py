"""SOCDaily command-line interface.

Sub-commands:
    socdaily models                          List models on the configured endpoint.
    socdaily ingest <pdf_dir>                Extract every PDF in dir → raw/markdown/.
    socdaily outline <md_file>               LLM-draft outline → outline/<name>.yaml.
    socdaily generate <outline.yaml>         LLM-gen cards/MCQs → seed/.../<topic>.json.
    socdaily db-init                         Create empty SQLite DB at db/socdaily.db.
    socdaily db-import [seed_dir]            Import seed JSON files into SQLite.
    socdaily run <pdf>                       Convenience: ingest+outline+generate one PDF.
"""

from __future__ import annotations

import json
from pathlib import Path

import typer
import yaml
from rich.console import Console
from rich.table import Table

from socdaily import pdf_extract
from socdaily.config import load_settings
from socdaily.llm import build_client
from socdaily.models import Outline
from socdaily.pipeline import generate as gen_mod
from socdaily.pipeline import importer
from socdaily.pipeline import outline as outline_mod

app = typer.Typer(add_completion=False, help="SOCDaily — SOC learning DB builder.")
console = Console()

REPO_ROOT = Path(__file__).resolve().parents[2]
DEFAULT_MD_DIR = REPO_ROOT / "raw" / "markdown"
DEFAULT_OUTLINE_DIR = REPO_ROOT / "outline"
DEFAULT_SEED_DIR = REPO_ROOT / "seed"
DEFAULT_DB_PATH = REPO_ROOT / "db" / "socdaily.db"


# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------


def _rel_to_repo(p: Path) -> Path:
    try:
        return p.relative_to(REPO_ROOT)
    except ValueError:
        return p


def _slug(s: str) -> str:
    import re

    s = s.lower().strip()
    s = re.sub(r"[^a-z0-9]+", "-", s)
    return s.strip("-") or "untitled"


# ---------------------------------------------------------------------------
# Commands
# ---------------------------------------------------------------------------


@app.command()
def models() -> None:
    """List models available on the configured LLM endpoint."""
    settings = load_settings()
    client = build_client(settings)
    console.print(f"[bold]Provider:[/] {settings.provider}")
    console.print(f"[bold]Base URL:[/] {settings.base_url}")
    console.print(f"[bold]Auto-picked model:[/] {client.model}\n")
    ids = client.list_models()
    table = Table(title=f"{len(ids)} models")
    table.add_column("#", justify="right", style="dim")
    table.add_column("model id")
    for i, mid in enumerate(ids, start=1):
        table.add_row(str(i), mid)
    console.print(table)


@app.command()
def ingest(
    pdf_dir: Path = typer.Argument(REPO_ROOT / "raw" / "pdf", help="Folder of PDFs (recursive)."),
    out_dir: Path = typer.Option(DEFAULT_MD_DIR, "--out", help="Where to write markdown."),
    overwrite: bool = typer.Option(False, "--overwrite", help="Re-extract even if .md exists."),
) -> None:
    """Convert every PDF / DOCX / PPTX under `pdf_dir` to page-tagged markdown."""
    pdf_dir = pdf_dir.resolve()
    out_dir.mkdir(parents=True, exist_ok=True)
    targets: list[Path] = []
    for ext in (".pdf", ".docx", ".pptx"):
        targets.extend(pdf_dir.rglob(f"*{ext}"))
    if not targets:
        console.print(f"[yellow]No documents found under {pdf_dir}[/]")
        raise typer.Exit(code=1)

    for src in sorted(targets):
        rel = src.relative_to(pdf_dir)
        dest = out_dir / rel.with_suffix(".md")
        dest.parent.mkdir(parents=True, exist_ok=True)
        if dest.exists() and not overwrite:
            console.print(f"[dim]skip[/] {_rel_to_repo(dest)} (exists)")
            continue
        console.print(f"[green]extract[/] {rel}")
        md = pdf_extract.pdf_to_markdown(src)
        dest.write_text(md, encoding="utf-8")
    console.print(f"\n[bold green]Done.[/] Markdown in {_rel_to_repo(out_dir)}")


@app.command()
def outline(
    md_file: Path = typer.Argument(..., help="Page-tagged markdown file."),
    out_dir: Path = typer.Option(DEFAULT_OUTLINE_DIR, "--out"),
    subject_hint: str = typer.Option("", "--subject", help="Hint for the LLM."),
) -> None:
    """Generate an outline draft (YAML) for one markdown file."""
    md_file = md_file.resolve()
    if not md_file.exists():
        console.print(f"[red]Markdown not found:[/] {md_file}")
        raise typer.Exit(code=1)
    settings = load_settings()
    client = build_client(settings)
    md = md_file.read_text(encoding="utf-8")
    console.print(f"[cyan]Generating outline using {client.model}...[/]")
    o = outline_mod.generate_outline(
        client=client,
        pdf_name=md_file.stem,
        markdown=md,
        suggested_subject=subject_hint or None,
        content_lang=settings.content_lang,
    )
    out_dir.mkdir(parents=True, exist_ok=True)
    dest = out_dir / f"{md_file.stem}.yaml"
    dest.write_text(
        yaml.safe_dump(o.model_dump(), allow_unicode=True, sort_keys=False),
        encoding="utf-8",
    )
    console.print(
        f"[green]Wrote[/] {_rel_to_repo(dest)} "
        f"({len(o.chapters)} chapters, {sum(len(c.topics) for c in o.chapters)} topics)"
    )


@app.command()
def generate(
    outline_yaml: Path = typer.Argument(..., help="Outline YAML produced by `socdaily outline`."),
    md_file: Path = typer.Option(..., "--md", help="Page-tagged markdown for the same PDF."),
    seed_dir: Path = typer.Option(DEFAULT_SEED_DIR, "--out"),
    n_flashcards: int = typer.Option(6, "--cards", help="Target flashcards per topic."),
    n_questions: int = typer.Option(4, "--questions", help="Target MCQs per topic."),
    only_topic: str = typer.Option("", "--only", help="Generate only one topic_code."),
) -> None:
    """Generate flashcards + MCQs for every topic in an outline."""
    outline_yaml = outline_yaml.resolve()
    md_file = md_file.resolve()
    if not outline_yaml.exists() or not md_file.exists():
        console.print("[red]Outline or markdown file missing.[/]")
        raise typer.Exit(code=1)

    settings = load_settings()
    client = build_client(settings)
    o = Outline.model_validate(yaml.safe_load(outline_yaml.read_text(encoding="utf-8")))
    md = md_file.read_text(encoding="utf-8")

    total_cards = total_qs = 0
    for chapter in o.chapters:
        for topic in chapter.topics:
            if only_topic and topic.code != only_topic:
                continue
            if not topic.pages or len(topic.pages) < 2:
                console.print(f"[yellow]skip {topic.code}: missing pages[/]")
                continue
            start, end = topic.pages[0], topic.pages[-1]
            slice_md = pdf_extract.slice_pages(md, start, end)
            if not slice_md.strip():
                console.print(f"[yellow]skip {topic.code}: empty slice[/]")
                continue
            console.print(f"[cyan]generate[/] {chapter.code}/{topic.code} (p.{start}-{end})")
            seed = gen_mod.generate_topic_seed(
                client=client,
                outline=o,
                topic=topic,
                chapter_code=chapter.code,
                chapter_title=chapter.title,
                topic_markdown=slice_md,
                content_lang=settings.content_lang,
                n_flashcards=n_flashcards,
                n_questions=n_questions,
            )
            dest_dir = seed_dir / o.subject_code / chapter.code
            dest_dir.mkdir(parents=True, exist_ok=True)
            dest = dest_dir / f"{topic.code}.json"
            dest.write_text(
                json.dumps(seed.model_dump(), ensure_ascii=False, indent=2),
                encoding="utf-8",
            )
            total_cards += len(seed.flashcards)
            total_qs += len(seed.questions)
            console.print(
                f"  [green]+{len(seed.flashcards)} flashcards, "
                f"+{len(seed.questions)} questions[/] → {_rel_to_repo(dest)}"
            )
    console.print(f"\n[bold green]Done.[/] {total_cards} flashcards, {total_qs} questions.")


@app.command("db-init")
def db_init(db_path: Path = typer.Option(DEFAULT_DB_PATH, "--db")) -> None:
    """Create the SQLite DB (or apply schema to an existing one)."""
    import sqlite3

    db_path.parent.mkdir(parents=True, exist_ok=True)
    conn = sqlite3.connect(db_path)
    try:
        importer.apply_schema(conn)
        conn.commit()
    finally:
        conn.close()
    console.print(f"[green]Schema applied to[/] {_rel_to_repo(db_path)}")


@app.command("db-import")
def db_import(
    seed_dir: Path = typer.Argument(DEFAULT_SEED_DIR),
    db_path: Path = typer.Option(DEFAULT_DB_PATH, "--db"),
) -> None:
    """Import every TopicSeed JSON under seed_dir into SQLite."""
    totals = importer.import_directory(db_path, seed_dir)
    console.print(
        f"[bold green]Imported[/] {totals['topics']} topics, "
        f"{totals['flashcards']} flashcards, {totals['questions']} questions "
        f"→ {_rel_to_repo(db_path)}"
    )


@app.command()
def run(
    pdf: Path = typer.Argument(..., help="Path to a PDF (under raw/pdf/)."),
    n_flashcards: int = typer.Option(6, "--cards"),
    n_questions: int = typer.Option(4, "--questions"),
    subject_hint: str = typer.Option("", "--subject"),
) -> None:
    """Run the full pipeline for ONE PDF: ingest → outline → generate."""
    pdf = pdf.resolve()
    if not pdf.exists():
        console.print(f"[red]PDF not found:[/] {pdf}")
        raise typer.Exit(code=1)
    settings = load_settings()
    client = build_client(settings)

    console.print("[cyan]1/3 extract markdown[/]")
    md = pdf_extract.pdf_to_markdown(pdf)
    md_path = DEFAULT_MD_DIR / f"{pdf.stem}.md"
    md_path.parent.mkdir(parents=True, exist_ok=True)
    md_path.write_text(md, encoding="utf-8")
    console.print(f"  → {_rel_to_repo(md_path)}")

    console.print("[cyan]2/3 generate outline[/]")
    o = outline_mod.generate_outline(
        client=client,
        pdf_name=pdf.stem,
        markdown=md,
        suggested_subject=subject_hint or None,
        content_lang=settings.content_lang,
    )
    outline_path = DEFAULT_OUTLINE_DIR / f"{pdf.stem}.yaml"
    outline_path.parent.mkdir(parents=True, exist_ok=True)
    outline_path.write_text(
        yaml.safe_dump(o.model_dump(), allow_unicode=True, sort_keys=False),
        encoding="utf-8",
    )
    console.print(
        f"  → {_rel_to_repo(outline_path)} "
        f"({len(o.chapters)} chapters, {sum(len(c.topics) for c in o.chapters)} topics)"
    )

    console.print("[cyan]3/3 generate flashcards + MCQs[/]")
    total_cards = total_qs = 0
    for chapter in o.chapters:
        for topic in chapter.topics:
            if not topic.pages or len(topic.pages) < 2:
                continue
            start, end = topic.pages[0], topic.pages[-1]
            slice_md = pdf_extract.slice_pages(md, start, end)
            if not slice_md.strip():
                continue
            seed = gen_mod.generate_topic_seed(
                client=client,
                outline=o,
                topic=topic,
                chapter_code=chapter.code,
                chapter_title=chapter.title,
                topic_markdown=slice_md,
                content_lang=settings.content_lang,
                n_flashcards=n_flashcards,
                n_questions=n_questions,
            )
            dest_dir = DEFAULT_SEED_DIR / o.subject_code / chapter.code
            dest_dir.mkdir(parents=True, exist_ok=True)
            dest = dest_dir / f"{topic.code}.json"
            dest.write_text(
                json.dumps(seed.model_dump(), ensure_ascii=False, indent=2),
                encoding="utf-8",
            )
            total_cards += len(seed.flashcards)
            total_qs += len(seed.questions)
            console.print(f"  [green]{chapter.code}/{topic.code}[/]: +{len(seed.flashcards)}/+{len(seed.questions)}")
    console.print(
        f"\n[bold green]Pipeline done.[/] {total_cards} flashcards, {total_qs} questions."
    )


if __name__ == "__main__":
    app()
