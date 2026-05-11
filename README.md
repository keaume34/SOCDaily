# SOCDaily

Build a **SOC Analyst learning database** (flashcards + multiple-choice
questions) from a folder of raw, unstructured PDFs.

The pipeline:

```
PDF / DOCX / PPTX
   │  (1) pdf_extract
   ▼
raw/markdown/<name>.md          page-tagged markdown (<!-- page=N -->)
   │  (2) LLM: outline
   ▼
outline/<name>.yaml             Subject → Chapter → Topic
   │  (3) LLM: generate
   ▼
seed/<subject>/<chapter>/<topic>.json   flashcards + MCQs + source_page
   │  (4) importer
   ▼
db/socdaily.db                  SQLite, ready for the study app
```

Every flashcard and MCQ carries a `source_page` so you can verify the LLM
didn't hallucinate.

---

## Quick start

```bash
# 0. Install poppler for pdftotext (used by the ingest step).
sudo apt-get install -y poppler-utils      # Linux
# brew install poppler                     # macOS

# 1. Install Python deps (uv recommended).
uv sync               # or:  pip install -e .[dev]

# 2. Configure your LLM.
cp .env.example .env
$EDITOR .env          # pick provider, base URL, key, model

# 3. Drop your PDFs into raw/pdf/<category>/  (see raw/pdf/MANIFEST.md).

# 4. Run the full pipeline on one PDF (recommended starting point):
uv run socdaily run "raw/pdf/blue-team/SOC Analyst Tools.pdf"

# 5. Or do each stage manually:
uv run socdaily ingest raw/pdf
uv run socdaily outline raw/markdown/blue-team/SOC\ Analyst\ Tools.md
uv run socdaily generate outline/SOC\ Analyst\ Tools.yaml \
    --md raw/markdown/blue-team/SOC\ Analyst\ Tools.md

# 6. Import into SQLite.
uv run socdaily db-import seed/
```

## LLM configuration

SOCDaily is **provider-agnostic**. Set these in `.env`:

| variable | purpose |
|---|---|
| `SOCDAILY_LLM_PROVIDER` | `openai` (OpenAI-compatible) or `anthropic` |
| `SOCDAILY_LLM_BASE_URL` | endpoint URL — works with OpenAI, LM Studio, Ollama, vLLM, OpenRouter, Together, … |
| `SOCDAILY_LLM_API_KEY`  | API key. For local servers that ignore auth, any non-empty string is fine. |
| `SOCDAILY_LLM_MODEL`    | model id, or **leave blank** to auto-pick from the endpoint's `/models` list |
| `SOCDAILY_LLM_TEMPERATURE` | default `0.2` |
| `SOCDAILY_LLM_MAX_TOKENS` | default `4096` |
| `SOCDAILY_CONTENT_LANG`   | `vi` (default), `en`, or `bilingual` |

List what's available on your endpoint:

```bash
uv run socdaily models
```

### Example configs

**OpenAI:**
```env
SOCDAILY_LLM_PROVIDER=openai
SOCDAILY_LLM_BASE_URL=https://api.openai.com/v1
SOCDAILY_LLM_API_KEY=sk-...
SOCDAILY_LLM_MODEL=gpt-4o-mini
```

**Anthropic:**
```env
SOCDAILY_LLM_PROVIDER=anthropic
SOCDAILY_LLM_BASE_URL=https://api.anthropic.com
SOCDAILY_LLM_API_KEY=sk-ant-...
SOCDAILY_LLM_MODEL=claude-3-5-sonnet-latest
```

**Local LM Studio / Ollama / vLLM (OpenAI-compatible):**
```env
SOCDAILY_LLM_PROVIDER=openai
SOCDAILY_LLM_BASE_URL=http://localhost:1234/v1
SOCDAILY_LLM_API_KEY=local
SOCDAILY_LLM_MODEL=           # leave blank → auto-pick from /models
```

## Hybrid workflow with NotebookLM

NotebookLM is great at high-level chapter summaries. SOCDaily plays nicely with
that workflow:

1. Drop a PDF into NotebookLM, get a "Study Guide" / "Briefing".
2. Paste the bulleted outline straight into `outline/<name>.yaml` (the schema
   is plain YAML — easy to hand-edit).
3. Run `socdaily generate outline/<name>.yaml --md raw/markdown/<name>.md` to
   let your local/OpenAI/Anthropic LLM produce flashcards + MCQs grounded on
   the same PDF.

## Repo layout

```
SOCDaily/
├── db/
│   ├── schema.sql              SQLite schema (committed)
│   └── socdaily.db             built artifact (gitignored)
├── outline/                    YAML outlines (committed, hand-editable)
├── raw/
│   ├── pdf/                    your source PDFs (gitignored, see MANIFEST.md)
│   └── markdown/               extracted text (gitignored)
├── seed/                       generated JSON (committed)
├── src/socdaily/
│   ├── cli.py                  the `socdaily` command
│   ├── config.py
│   ├── models.py               Pydantic IO schemas
│   ├── pdf_extract.py
│   ├── llm/
│   │   ├── base.py
│   │   ├── openai_compat.py
│   │   ├── anthropic_client.py
│   │   └── factory.py
│   └── pipeline/
│       ├── outline.py
│       ├── generate.py
│       └── importer.py
└── tests/
```

## Status

This is a **scaffolding release**. It builds the DB from PDFs; the study UI
(web / mobile / desktop) is the next milestone — schema and JSON contracts are
stable enough for the app to consume directly.
