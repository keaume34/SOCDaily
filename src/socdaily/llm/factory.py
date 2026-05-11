"""Build the right LLMClient from Settings."""

from __future__ import annotations

from socdaily.config import Settings
from socdaily.llm.anthropic_client import AnthropicClient
from socdaily.llm.base import LLMClient
from socdaily.llm.openai_compat import OpenAICompatClient


def build_client(settings: Settings) -> LLMClient:
    common = dict(
        base_url=settings.base_url,
        api_key=settings.api_key,
        model=settings.model,
        extra_headers=settings.extra_headers,
        temperature=settings.temperature,
        max_tokens=settings.max_tokens,
    )
    if settings.provider == "anthropic":
        return AnthropicClient(**common)
    return OpenAICompatClient(**common)
