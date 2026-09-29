"""
Sarvam AI translation wrapper with multi-key rotation.

Supports comma-separated SARVAM_API_KEY for pooling multiple free accounts.
On failure or rate limit, rotates to the next key automatically.
"""

import os
import httpx
import logging
from dotenv import load_dotenv
from pathlib import Path

env_path = Path(__file__).parent.parent / ".env"
load_dotenv(dotenv_path=env_path)
logger = logging.getLogger(__name__)

# ---------------------------------------------------------------------------
# Multi-key pool for Sarvam AI
# ---------------------------------------------------------------------------
_raw_keys = os.getenv("SARVAM_API_KEY", "")
_sarvam_keys = [k.strip() for k in _raw_keys.split(",") if k.strip() and k.strip() != "your_sarvam_api_key_here"]
_sarvam_index = 0

_USE_MOCK = len(_sarvam_keys) == 0

if _USE_MOCK:
    logger.warning(
        "⚠️ Sarvam API credentials not found. Running in MOCK translation mode. "
        "Set SARVAM_API_KEY in backend/.env for real translation."
    )
else:
    logger.info(f"✅ Sarvam AI: {len(_sarvam_keys)} API key(s) loaded for rotation.")


def _next_sarvam_key() -> str | None:
    """Get next Sarvam key (round-robin)."""
    global _sarvam_index
    if not _sarvam_keys:
        return None
    key = _sarvam_keys[_sarvam_index % len(_sarvam_keys)]
    _sarvam_index += 1
    return key


def _map_lang_code(lang: str) -> str:
    """Map internal lang codes to Sarvam format."""
    if lang == "hi":
        return "hi-IN"
    if lang == "mr":
        return "mr-IN"
    if lang == "en":
        return "en-IN"
    return f"{lang}-IN"

def _mock_translate(text: str, source_lang: str, target_lang: str) -> str:
    """Returns the original text with a language tag prefix.
    This is a placeholder until real Sarvam API credentials are available."""
    return f"[{source_lang}→{target_lang}] {text}"


async def translate(text: str, source_lang: str, target_lang: str) -> str:
    """Translate text using Sarvam AI with multi-key rotation.
    
    Tries each key on failure/rate-limit before falling back to mock.
    
    Args:
        text: The text to translate
        source_lang: Source language code (en, hi, mr)
        target_lang: Target language code (en, hi, mr)
    
    Returns:
        Translated text string
    """
    # No-op if source and target are the same
    if source_lang == target_lang:
        return text

    # Use mock if no credentials available
    if _USE_MOCK:
        return _mock_translate(text, source_lang, target_lang)

    # Mayura has a 1000 char limit
    if len(text) > 1000:
        logger.warning("Text exceeds Sarvam 1000 char limit. Truncating for safety.")
        text = text[:1000]

    url = "https://api.sarvam.ai/translate"
    payload = {
        "input": text,
        "source_language_code": _map_lang_code(source_lang),
        "target_language_code": _map_lang_code(target_lang),
        "model": "mayura:v1"
    }

    # Try each key in the pool
    last_error = None
    for _ in range(len(_sarvam_keys)):
        api_key = _next_sarvam_key()
        if not api_key:
            break

        headers = {
            "Content-Type": "application/json",
            "api-subscription-key": api_key,
        }

        try:
            async with httpx.AsyncClient(timeout=30) as client:
                response = await client.post(url, json=payload, headers=headers)
                response.raise_for_status()
                result = response.json()
                translated = result.get("translated_text", text)
                key_hint = api_key[:10] + "..."
                logger.info(f"Sarvam {source_lang}→{target_lang} OK (key={key_hint})")
                return translated

        except httpx.HTTPStatusError as e:
            key_hint = api_key[:10] + "..."
            if e.response.status_code == 429:
                logger.warning(f"Sarvam key={key_hint} rate-limited (429), rotating")
                last_error = e
                continue
            else:
                logger.error(f"Sarvam key={key_hint} failed: {e}")
                last_error = e
                continue

        except Exception as e:
            logger.error(f"Sarvam API error: {e}")
            last_error = e
            continue

    # All keys exhausted — fall back to mock
    logger.error(f"All {len(_sarvam_keys)} Sarvam keys failed. Last: {last_error}. Using mock.")
    return _mock_translate(text, source_lang, target_lang)
