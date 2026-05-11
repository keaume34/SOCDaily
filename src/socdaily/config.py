"""Configuration loader for SOCDaily.

Reads `.env` (or environment variables) and produces a typed `Settings` object
that the rest of the codebase consumes. Designed so the user can switch between
OpenAI-compatible endpoints (OpenAI itself, LM Studio, Ollama, vLLM, OpenRouter,
etc.) and Anthropic's native API by changing only env vars.
"""

from __future__ import annotations

import json
import os
from pathlib import Path
from typing import Literal

from dotenv import load_dotenv
from pydantic import BaseModel, Field, field_validator

Provider = Literal["openai", "anthropic"]
ContentLang = Literal["vi", "en", "bilingual"]

# Default base URLs per provider.
DEFAULT_BASE_URLS: dict[Provider, str] = {
    "openai": "https://api.openai.com/v1",
    "anthropic": "https://api.anthropic.com",
}


class Settings(BaseModel):
    """Runtime settings for the LLM pipeline."""

    provider: Provider = "openai"
    base_url: str = DEFAULT_BASE_URLS["openai"]
    api_key: str = ""
    model: str = ""  # empty => auto-pick first available chat model
    extra_headers: dict[str, str] = Field(default_factory=dict)
    temperature: float = 0.2
    max_tokens: int = 4096
    content_lang: ContentLang = "vi"

    @field_validator("provider", mode="before")
    @classmethod
    def _norm_provider(cls, v: str) -> str:
        v = (v or "openai").strip().lower()
        # Aliases for user convenience.
        aliases = {
            "openai_compat": "openai",
            "openai-compatible": "openai",
            "compat": "openai",
            "local": "openai",
        }
        return aliases.get(v, v)


def _parse_headers(raw: str) -> dict[str, str]:
    """Parse SOCDAILY_LLM_EXTRA_HEADERS.

    Accepts either a JSON object or a `key1=val1;key2=val2` string.
    """
    raw = (raw or "").strip()
    if not raw:
        return {}
    try:
        obj = json.loads(raw)
        if isinstance(obj, dict):
            return {str(k): str(v) for k, v in obj.items()}
    except json.JSONDecodeError:
        pass
    out: dict[str, str] = {}
    for part in raw.split(";"):
        if "=" not in part:
            continue
        k, _, v = part.partition("=")
        k, v = k.strip(), v.strip()
        if k:
            out[k] = v
    return out


def load_settings(env_file: str | Path | None = None) -> Settings:
    """Load settings from `.env` (if present) + process env vars."""
    if env_file is None:
        # Try `.env` in CWD, fall back to repo root next to pyproject.
        for candidate in (Path.cwd() / ".env", Path(__file__).resolve().parents[2] / ".env"):
            if candidate.exists():
                env_file = candidate
                break
    if env_file is not None:
        load_dotenv(env_file)

    provider_raw = os.environ.get("SOCDAILY_LLM_PROVIDER", "openai")
    provider: Provider = "anthropic" if provider_raw.strip().lower().startswith("anthropic") else "openai"

    base_url = os.environ.get("SOCDAILY_LLM_BASE_URL", "").strip() or DEFAULT_BASE_URLS[provider]

    return Settings(
        provider=provider,
        base_url=base_url,
        api_key=os.environ.get("SOCDAILY_LLM_API_KEY", "").strip(),
        model=os.environ.get("SOCDAILY_LLM_MODEL", "").strip(),
        extra_headers=_parse_headers(os.environ.get("SOCDAILY_LLM_EXTRA_HEADERS", "")),
        temperature=float(os.environ.get("SOCDAILY_LLM_TEMPERATURE", "0.2")),
        max_tokens=int(os.environ.get("SOCDAILY_LLM_MAX_TOKENS", "4096")),
        content_lang=os.environ.get("SOCDAILY_CONTENT_LANG", "vi").strip().lower() or "vi",  # type: ignore[arg-type]
    )
