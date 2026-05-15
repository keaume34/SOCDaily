"""SOCDaily HTTP API.

Phase 14.A: thin FastAPI wrapper around the existing Python pipeline so
the Flutter app can request newly-generated TopicSeed JSON without the
user opening a terminal. The API is **public** (deployed behind nginx +
Let's Encrypt on the user's VPS), so every endpoint requires a Bearer
token and rate-limits per token (TODO: P14.A.2).

Run locally:

    uv run uvicorn socdaily.api.app:app --host 127.0.0.1 --port 8000

The reverse-proxy config lives at vps/nginx/socdaily-api.conf.
"""

from .app import create_app

__all__ = ["create_app"]
