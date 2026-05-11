"""Anthropic native chat client."""

from __future__ import annotations

import anthropic

from socdaily.llm.base import ChatMessage, LLMClient


class AnthropicClient(LLMClient):
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
        self._client = anthropic.Anthropic(
            api_key=api_key or None,
            base_url=base_url.rstrip("/") or None,
            default_headers=extra_headers or None,
        )
        self._default_temp = temperature
        self._default_max_tokens = max_tokens
        self.model = model or self._auto_pick()

    def list_models(self) -> list[str]:
        try:
            page = self._client.models.list()
        except Exception as exc:  # pragma: no cover
            raise RuntimeError(f"Failed to list Anthropic models: {exc}") from exc
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
        # Anthropic separates the system prompt from messages.
        system_parts = [m.content for m in messages if m.role == "system"]
        chat_msgs = [
            {"role": m.role, "content": m.content}
            for m in messages
            if m.role in ("user", "assistant")
        ]
        if json_mode:
            json_instruction = (
                "Respond ONLY with a single valid JSON object. "
                "Do not wrap in markdown fences. Do not add commentary."
            )
            system_parts.append(json_instruction)

        resp = self._client.messages.create(
            model=self.model,
            system="\n\n".join(system_parts) if system_parts else anthropic.NOT_GIVEN,
            messages=chat_msgs,  # type: ignore[arg-type]
            temperature=self._default_temp if temperature is None else temperature,
            max_tokens=self._default_max_tokens if max_tokens is None else max_tokens,
        )
        # Concatenate text blocks.
        out: list[str] = []
        for block in resp.content:
            if getattr(block, "type", None) == "text":
                out.append(block.text)
        return "".join(out)

    def _auto_pick(self) -> str:
        models = self.list_models()
        if not models:
            raise RuntimeError("Anthropic returned no models. Set SOCDAILY_LLM_MODEL explicitly.")
        preferred = (
            "claude-3-5-sonnet",
            "claude-3-5-haiku",
            "claude-3-7-sonnet",
            "claude-3-haiku",
            "claude-3-sonnet",
            "claude-3-opus",
        )
        for p in preferred:
            for m in models:
                if p in m:
                    return m
        return models[0]
