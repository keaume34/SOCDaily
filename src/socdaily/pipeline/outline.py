"""LLM-assisted outline generation.

Given a page-tagged markdown for a PDF, produce a YAML outline (Subject →
Chapter → Topic) that maps page ranges. The user can review and edit the
outline before card generation runs.
"""

from __future__ import annotations

import json
import re

from socdaily.llm import ChatMessage, LLMClient
from socdaily.models import Outline

SYSTEM_VI = """\
Bạn là chuyên gia SOC giúp xây dựng tài liệu học. Nhiệm vụ: đọc nội dung trích
xuất từ một PDF (đã đánh dấu trang) và đề xuất outline 3 cấp:
Subject → Chapter → Topic, kèm khoảng trang.

QUY TẮC:
- CHỈ dùng nội dung trong văn bản được cung cấp. KHÔNG bịa.
- Mỗi Chapter có từ 1-6 Topic. Mỗi Topic là một bài học nhỏ (1-5 trang).
- `subject_code`, `chapter_code`, `topic_code` viết slug-kebab-case, ascii.
- `pages` là [start, end] (integer, inclusive).
- `key_points` là 2-5 ý chính của Topic, tóm tắt từ nội dung, mỗi ý 1 dòng.

CHỈ TRẢ JSON object đúng schema, KHÔNG markdown, KHÔNG giải thích.
"""

SYSTEM_EN = """\
You are a SOC expert helping build study material. Read the page-tagged
markdown extracted from a PDF and propose a 3-level outline:
Subject → Chapter → Topic, with page ranges.

RULES:
- Use ONLY content in the provided text. Do NOT invent.
- Each Chapter has 1-6 Topics. Each Topic is a small lesson (1-5 pages).
- `subject_code`, `chapter_code`, `topic_code` are slug-kebab-case, ascii.
- `pages` is [start, end] (integer, inclusive).
- `key_points` is 2-5 bullets summarizing the topic.

Return ONLY a JSON object matching the schema. No markdown fences, no prose.
"""

SCHEMA_HINT = """\
JSON schema example:
{
  "pdf": "<filename>",
  "subject_code": "soc-fundamentals",
  "subject_title": "SOC Fundamentals",
  "chapters": [
    {
      "code": "introduction",
      "title": "Introduction to SOC",
      "pages": [1, 12],
      "topics": [
        {
          "code": "soc-roles",
          "title": "SOC Tier Roles (L1/L2/L3)",
          "pages": [5, 9],
          "key_points": ["L1 monitors and triages", "L2 deep analysis", "L3 hunt + detection eng"]
        }
      ]
    }
  ]
}"""


def _strip_fence(text: str) -> str:
    """Remove ```json ... ``` fences if the model added them anyway."""
    m = re.match(r"^\s*```(?:json)?\s*(.*?)\s*```\s*$", text, re.DOTALL)
    return m.group(1) if m else text


def generate_outline(
    *,
    client: LLMClient,
    pdf_name: str,
    markdown: str,
    suggested_subject: str | None,
    content_lang: str,
) -> Outline:
    """Ask the LLM to produce an Outline for one PDF."""
    system = SYSTEM_VI if content_lang == "vi" else SYSTEM_EN
    user = (
        f"PDF filename: {pdf_name}\n"
        f"Suggested subject hint: {suggested_subject or '(none)'}\n\n"
        f"{SCHEMA_HINT}\n\n"
        "Page-tagged markdown follows:\n\n"
        f"{markdown}"
    )
    raw = client.complete(
        [ChatMessage(role="system", content=system), ChatMessage(role="user", content=user)],
        json_mode=True,
    )
    data = json.loads(_strip_fence(raw))
    data.setdefault("pdf", pdf_name)
    return Outline.model_validate(data)
