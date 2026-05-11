"""Flashcard + MCQ generation per topic.

Strategy: for each topic in the outline, slice the PDF markdown to that
topic's page range and ask the LLM to emit a `TopicSeed` JSON. Strong
guardrails:
  - "use only the provided text, do not invent"
  - every item must have `source_page` within the slice
  - exactly one correct option for `single`, 2+ for `multiple`
"""

from __future__ import annotations

import json
import re

from socdaily.llm import ChatMessage, LLMClient
from socdaily.models import Outline, OutlineTopic, TopicSeed

SYSTEM_VI = """\
Bạn là chuyên gia SOC viết tài liệu học tập (flashcard + trắc nghiệm) bằng
TIẾNG VIỆT (giữ nguyên thuật ngữ kỹ thuật tiếng Anh khi cần).

QUY TẮC TUYỆT ĐỐI:
- CHỈ dùng nội dung trong đoạn markdown được cung cấp. KHÔNG bịa, KHÔNG bổ sung
  kiến thức ngoài.
- Nếu thông tin không đủ cho 1 item, BỎ QUA item đó. Thà ít mà đúng còn hơn
  nhiều mà sai.
- Mỗi item phải gắn `source_page` trỏ tới trang chứa thông tin gốc (lấy từ
  marker `<!-- page=N -->`).
- Flashcard: front là thuật ngữ / câu hỏi ngắn; back là định nghĩa / câu trả
  lời ngắn gọn (1-3 câu).
- Question kiểu `single`: ĐÚNG MỘT lựa chọn `is_correct=true`. Distractor phải
  hợp lý (đừng quá ngớ ngẩn).
- Question kiểu `multiple`: từ 2 lựa chọn đúng trở lên.
- Explanation: giải thích ngắn tại sao đáp án đúng và vì sao các distractor sai.
- Khó: easy (nhận biết), medium (hiểu), hard (vận dụng/scenario).

CHỈ TRẢ JSON object đúng schema. KHÔNG markdown fence, KHÔNG prose.
"""

SYSTEM_EN = """\
You are a SOC expert writing study material (flashcards + MCQs) in ENGLISH.

ABSOLUTE RULES:
- Use ONLY the provided markdown content. NEVER invent. NEVER add outside
  knowledge.
- If information is insufficient for an item, SKIP it. Few-and-correct beats
  many-and-wrong.
- Every item MUST include `source_page` pointing to the page that contains
  the source info (from `<!-- page=N -->` markers).
- Flashcards: `front` is a term / short question; `back` is a concise
  definition / answer (1-3 sentences).
- `single` questions: EXACTLY one option with `is_correct=true`. Distractors
  must be plausible.
- `multiple` questions: 2+ correct options.
- `explanation` should justify the correct answer briefly and (when useful)
  explain why distractors are wrong.
- Difficulty: easy (recall), medium (understand), hard (apply / scenario).

Return ONLY a JSON object matching the schema. No markdown fences, no prose.
"""

SCHEMA_HINT = """\
JSON schema example:
{
  "topic_summary": "Tier roles in a SOC: who does what.",
  "flashcards": [
    {
      "front": "L1 SOC Analyst chịu trách nhiệm chính việc gì?",
      "back": "Giám sát alert, triage ban đầu, escalate khi xác nhận incident.",
      "hint": null,
      "difficulty": "easy",
      "tags": ["soc","tier"],
      "source_page": 5
    }
  ],
  "questions": [
    {
      "qtype": "single",
      "stem": "Khi nào L1 nên escalate alert cho L2?",
      "options": [
        {"label":"A","content":"Ngay khi nhận alert","is_correct":false},
        {"label":"B","content":"Sau khi triage và xác nhận incident","is_correct":true},
        {"label":"C","content":"Không bao giờ","is_correct":false},
        {"label":"D","content":"Cuối ca trực","is_correct":false}
      ],
      "explanation": "L1 triage trước; chỉ escalate khi đã xác nhận có incident.",
      "difficulty": "medium",
      "tags": ["soc","workflow"],
      "source_page": 6
    }
  ]
}"""


def _strip_fence(text: str) -> str:
    m = re.match(r"^\s*```(?:json)?\s*(.*?)\s*```\s*$", text, re.DOTALL)
    return m.group(1) if m else text


def generate_topic_seed(
    *,
    client: LLMClient,
    outline: Outline,
    topic: OutlineTopic,
    chapter_code: str,
    chapter_title: str,
    topic_markdown: str,
    content_lang: str,
    n_flashcards: int = 6,
    n_questions: int = 4,
) -> TopicSeed:
    """Ask the LLM to produce a TopicSeed for one topic."""
    system = SYSTEM_VI if content_lang == "vi" else SYSTEM_EN
    user = (
        f"Subject: {outline.subject_title} ({outline.subject_code})\n"
        f"Chapter: {chapter_title} ({chapter_code})\n"
        f"Topic: {topic.title} ({topic.code})\n"
        f"Source PDF: {outline.pdf}\n"
        f"Target counts: ~{n_flashcards} flashcards, ~{n_questions} questions "
        "(skip if content is thin).\n\n"
        f"{SCHEMA_HINT}\n\n"
        "Markdown slice for this topic:\n\n"
        f"{topic_markdown}"
    )
    raw = client.complete(
        [ChatMessage(role="system", content=system), ChatMessage(role="user", content=user)],
        json_mode=True,
    )
    data = json.loads(_strip_fence(raw))
    # Fill in fields the LLM doesn't need to repeat.
    data.setdefault("subject_code", outline.subject_code)
    data.setdefault("subject_title", outline.subject_title)
    data.setdefault("chapter_code", chapter_code)
    data.setdefault("chapter_title", chapter_title)
    data.setdefault("topic_code", topic.code)
    data.setdefault("topic_title", topic.title)
    data.setdefault("source_pdf", outline.pdf)
    return TopicSeed.model_validate(data)
