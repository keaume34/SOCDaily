"""Abstract LLM client interface.

We only need two operations:
  - `list_models()` to discover what's available on the configured endpoint
  - `complete(messages, ...)` to run a chat completion

Both OpenAI-compatible servers and Anthropic implement the same logical surface
with different SDKs; concrete clients live in `openai_compat.py` and
`anthropic.py`.
"""

from __future__ import annotations

from abc import ABC, abstractmethod
from typing import Literal

from pydantic import BaseModel

Role = Literal["system", "user", "assistant"]


class ChatMessage(BaseModel):
    role: Role
    content: str


class LLMClient(ABC):
    """Provider-agnostic chat client."""

    #: The model name actually used for completions. May be auto-picked.
    model: str

    @abstractmethod
    def list_models(self) -> list[str]:
        """Return the list of model IDs available on this endpoint."""

    @abstractmethod
    def complete(
        self,
        messages: list[ChatMessage],
        *,
        json_mode: bool = False,
        temperature: float | None = None,
        max_tokens: int | None = None,
    ) -> str:
        """Run a chat completion and return the assistant's text content.

        If `json_mode=True`, the implementation should try to coerce the model
        into emitting a valid JSON object (using provider-native JSON mode if
        available, otherwise via a stern system prompt).
        """
