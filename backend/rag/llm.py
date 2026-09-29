"""
LLM provider factory for Aarogya Sathi RAG pipeline.

Uses a cascade of free providers so the system never goes down due to one
provider's rate limits. Order: Groq (fastest) → SambaNova (highest RPD) →
Cerebras (highest daily tokens).

MULTI-KEY SUPPORT: Each provider env var accepts comma-separated keys.
On each call, keys rotate round-robin. On 429 (rate limit), the current
key is skipped and the next key is tried immediately. This lets the team
pool multiple free-tier accounts to multiply throughput.

Example .env:
    GROQ_API_KEY=gsk_key1,gsk_key2,gsk_key3
    SAMBANOVA_API_KEY=sam_key1,sam_key2

All providers expose an OpenAI-compatible /v1/chat/completions endpoint so
we use raw httpx instead of langchain to keep the cascade logic explicit.
"""

import os
import logging
import httpx
from dotenv import load_dotenv

load_dotenv()
logger = logging.getLogger(__name__)

# ---------------------------------------------------------------------------
# Provider definitions — order matters (first = primary)
# ---------------------------------------------------------------------------
_PROVIDERS = [
    {
        "name": "groq",
        "url": "https://api.groq.com/openai/v1/chat/completions",
        "key_env": "GROQ_API_KEY",
        "models": {
            # Groq model roster changes frequently — these are verified available
            "8b": "openai/gpt-oss-20b",
            "70b": "qwen/qwen3.8-27b",
        },
    },
    {
        "name": "sambanova",
        "url": "https://api.sambanova.ai/v1/chat/completions",
        "key_env": "SAMBANOVA_API_KEY",
        "models": {
            "8b": "Meta-Llama-3.1-8B-Instruct",
            "70b": "Meta-Llama-3.3-70B-Instruct",
        },
    },
    {
        "name": "cerebras",
        "url": "https://api.cerebras.ai/v1/chat/completions",
        "key_env": "CEREBRAS_API_KEY",
        "models": {
            "8b": "llama3.1-8b",
            "70b": "llama-3.3-70b",
        },
    },
]

# ---------------------------------------------------------------------------
# Multi-key state — round-robin index per provider
# ---------------------------------------------------------------------------
_key_pools: dict[str, list[str]] = {}  # provider_name → [key1, key2, ...]
_key_index: dict[str, int] = {}        # provider_name → current index


def _init_key_pools():
    """Parse comma-separated keys from env vars into pools. Called once."""
    for provider in _PROVIDERS:
        raw = os.getenv(provider["key_env"], "")
        # Split on comma, strip whitespace, drop empties
        keys = [k.strip() for k in raw.split(",") if k.strip()]
        name = provider["name"]
        _key_pools[name] = keys
        _key_index[name] = 0
        if keys:
            logger.info(f"{name}: {len(keys)} API key(s) loaded")


_init_key_pools()


def _next_key(provider_name: str) -> str | None:
    """Get the next API key for a provider (round-robin). Returns None if no keys."""
    keys = _key_pools.get(provider_name, [])
    if not keys:
        return None
    idx = _key_index.get(provider_name, 0) % len(keys)
    _key_index[provider_name] = idx + 1
    return keys[idx]


async def call_llm(
    messages: list[dict],
    size: str = "70b",
    temperature: float = 0.3,
    max_tokens: int = 1024,
) -> str:
    """
    Call an LLM with automatic provider failover + multi-key rotation.

    Strategy:
        For each provider → try all its keys (starting from round-robin position).
        On 429 → rotate to next key in same provider.
        On other failure → move to next provider.
        If all providers × all keys fail → raise RuntimeError.

    Args:
        messages: List of {role, content} dicts (OpenAI format).
        size: "8b" for navigation/grading tasks, "70b" for final generation.
        temperature: Lower = more deterministic (good for medical).
        max_tokens: Max output tokens.

    Returns:
        The LLM response text.

    Raises:
        RuntimeError: If all providers and all keys fail.
    """
    last_error = None

    for provider in _PROVIDERS:
        name = provider["name"]
        keys = _key_pools.get(name, [])
        if not keys:
            logger.debug(f"Skipping {name}: no API key set")
            continue

        model = provider["models"].get(size, provider["models"]["70b"])

        # Try each key in this provider (starting from current round-robin position)
        for attempt in range(len(keys)):
            api_key = _next_key(name)
            if not api_key:
                break

            try:
                async with httpx.AsyncClient(timeout=20) as client:
                    resp = await client.post(
                        provider["url"],
                        headers={
                            "Authorization": f"Bearer {api_key}",
                            "Content-Type": "application/json",
                        },
                        json={
                            "model": model,
                            "messages": messages,
                            "temperature": temperature,
                            "max_tokens": max_tokens,
                        },
                    )
                    resp.raise_for_status()
                    result = resp.json()
                    text = result["choices"][0]["message"]["content"].strip()
                    key_hint = api_key[:8] + "..."
                    logger.info(
                        f"LLM call succeeded via {name} ({model}) key={key_hint}"
                    )
                    return text

            except httpx.HTTPStatusError as e:
                if e.response.status_code == 429:
                    # Rate limited — try next key in this same provider
                    key_hint = api_key[:8] + "..."
                    logger.warning(f"{name} key={key_hint} rate-limited (429), rotating")
                    last_error = e
                    continue
                else:
                    # Other HTTP error — skip entire provider
                    logger.warning(f"Provider {name} failed: {e}")
                    last_error = e
                    break

            except Exception as e:
                logger.warning(f"Provider {name} failed: {e}")
                last_error = e
                break

    raise RuntimeError(
        f"All LLM providers failed. Last error: {last_error}"
    )
