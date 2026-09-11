"""
LLM provider factory for Aarogya Sathi RAG pipeline.

Uses a cascade of free providers so the system never goes down due to one
provider's rate limits. Order: Groq (fastest) → SambaNova (highest RPD) →
Cerebras (highest daily tokens).

All providers expose an OpenAI-compatible /v1/chat/completions endpoint so
we use raw httpx instead of langchain to keep the cascade logic explicit and
easy to understand for the capstone evaluator.
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
            "8b": "llama-3.1-8b-instant",
            "70b": "llama-3.3-70b-versatile",
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


async def call_llm(
    messages: list[dict],
    size: str = "70b",
    temperature: float = 0.3,
    max_tokens: int = 1024,
) -> str:
    """
    Call an LLM with automatic provider failover.

    Args:
        messages: List of {role, content} dicts (OpenAI format).
        size: "8b" for navigation/grading tasks, "70b" for final generation.
        temperature: Lower = more deterministic (good for medical).
        max_tokens: Max output tokens.

    Returns:
        The LLM response text.

    Raises:
        RuntimeError: If all providers fail.
    """
    last_error = None

    for provider in _PROVIDERS:
        api_key = os.getenv(provider["key_env"], "")
        if not api_key:
            # Skip providers with no key configured — not a hard failure
            logger.debug(f"Skipping {provider['name']}: no API key set")
            continue

        model = provider["models"].get(size, provider["models"]["70b"])

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
                logger.info(f"LLM call succeeded via {provider['name']} ({model})")
                return text

        except Exception as e:
            logger.warning(f"Provider {provider['name']} failed: {e}")
            last_error = e
            continue

    raise RuntimeError(
        f"All LLM providers failed. Last error: {last_error}"
    )
