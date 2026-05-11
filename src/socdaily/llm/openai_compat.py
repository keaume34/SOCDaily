"""OpenAI-compatible chat client.

Works with the real OpenAI API as well as any server that speaks the
`/v1/chat/completions` and `/v1/models` shape (LM Studio, Ollama, vLLM,
OpenRouter, DeepInfra, Together, llama.cpp's server, etc.).
"""

from __future__ import annotations

import httpx
from openai import OpenAI

from socdaily.llm.base import ChatMessage, LLMClient


class OpenAICompatClient(LLMClient):
    def __init__(
        self,
        *,
        base_url: str,
        api_key: str,
        model: str = "",
        extra_headers: dict[str, str] | None = None,
        temperature: float = 0.2,
        max_tokens: int = 4096,
    ) -> None:
        # OpenAI SDK refuses empty keys; many local servers don't check, so we
        # default to a sentinel so the SDK is happy.
        self._client = OpenAI(
            base_url=base_url.rstrip("/"),
            api_key=api_key or "sk-local-no-auth",
            default_headers=extra_headers or None,
            http_client=httpx.Client(timeout=httpx.Timeout(120.0, connect=15.0)),
        )
        self._default_temp = temperature
        self._default_max_tokens = max_tokens
        self.model = model or self._auto_pick()

    # ----- LLMClient API -----

    def list_models(self) -> list[str]:
        try:
            page = self._client.models.list()
        except Exception as exc:  # pragma: no cover - depends on remote
            raise RuntimeError(
                f"Failed to list models from {self._client.base_url}: {exc}"
            ) from exc
        ids = [m.id for m in page.data]
        ids.sort()
        return ids

    def complete(
        self,
        messages: list[ChatMessage],
        *,
        json_mode: bool = False,
        temperature: float | None = None,
        max_tokens: int | None = None,
    ) -> str:
        kwargs: dict[str, object] = {
            "model": self.model,
            "messages": [m.model_dump() for m in messages],
            "temperature": self._default_temp if temperature is None else temperature,
            "max_tokens": self._default_max_tokens if max_tokens is None else max_tokens,
        }
        if json_mode:
            # OpenAI supports response_format; local servers usually ignore
            # unknown fields, so this is safe.
            kwargs["response_format"] = {"type": "json_object"}
        resp = self._client.chat.completions.create(**kwargs)  # type: ignore[arg-type]
        choice = resp.choices[0].message.content or ""
        return choice

    # ----- helpers -----

    def _auto_pick(self) -> str:
        """Heuristic to pick a chat-capable model when the user didn't set one."""
        models = self.list_models()
        if not models:
            raise RuntimeError("Endpoint returned no models. Set SOCDAILY_LLM_MODEL explicitly.")
        # Prefer common chat models in this priority.
        preferred = (
            "gpt-4o-mini",
            "gpt-4o",
            "gpt-4.1-mini",
            "gpt-4.1",
            "o4-mini",
            "deepseek-chat",
            "qwen",
            "llama",
            "mistral",
        )
        for p in preferred:
            for m in models:
                if p in m.lower():
                    return m
        return models[0]
