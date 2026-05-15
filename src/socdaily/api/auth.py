"""Bearer-token auth dependency for the SOCDaily API.

The API is exposed publicly, so every request must carry a valid bearer
token in the `Authorization` header. Tokens are loaded from
`SOCDAILY_API_TOKENS` (comma-separated) — the deployer can rotate them
without redeploying code.

We intentionally avoid full OAuth/JWT here: the API serves one user
(the deployer), not a multi-tenant audience. A handful of revocable
tokens is the right fit.
"""

from __future__ import annotations

import os
from functools import lru_cache

from fastapi import Header, HTTPException, status


@lru_cache(maxsize=1)
def _load_tokens() -> frozenset[str]:
    raw = os.environ.get("SOCDAILY_API_TOKENS", "").strip()
    if not raw:
        return frozenset()
    return frozenset(t.strip() for t in raw.split(",") if t.strip())


def reset_token_cache() -> None:
    """Invalidate the token cache. Used by tests after monkeypatching env."""
    _load_tokens.cache_clear()


def require_bearer(authorization: str | None = Header(default=None)) -> str:
    """FastAPI dependency: 401 unless `Authorization: Bearer <token>` matches.

    Returns the matched token so the route can correlate logs / metrics
    per-token if it wants.
    """
    tokens = _load_tokens()
    if not tokens:
        raise HTTPException(
            status_code=status.HTTP_503_SERVICE_UNAVAILABLE,
            detail="API is not configured: SOCDAILY_API_TOKENS is empty.",
        )
    if not authorization or not authorization.lower().startswith("bearer "):
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Missing or malformed Authorization header.",
            headers={"WWW-Authenticate": "Bearer"},
        )
    token = authorization.split(" ", 1)[1].strip()
    if token not in tokens:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid bearer token.",
            headers={"WWW-Authenticate": "Bearer"},
        )
    return token
