import os
import httpx
import logging
from dotenv import load_dotenv
from pathlib import Path

env_path = Path(__file__).parent.parent / ".env"
load_dotenv(dotenv_path=env_path)
logger = logging.getLogger(__name__)

SARVAM_API_KEY = os.getenv("SARVAM_API_KEY")

# Check if real credentials are available
_USE_MOCK = (
    not SARVAM_API_KEY
    or SARVAM_API_KEY == "your_sarvam_api_key_here"
)

if _USE_MOCK:
    logger.warning(
        "⚠️ Sarvam API credentials not found. Running in MOCK translation mode. "
        "Set SARVAM_API_KEY in backend/.env for real translation."
    )
else:
    logger.info("✅ Sarvam API credentials found. Using real translation.")

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
    """Translate text using Sarvam AI.
    
    Falls back to mock translation if:
    - API credentials are not configured
    - API call fails (network error, rate limit, etc.)
    
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

    # Use mock if credentials aren't available
    if _USE_MOCK:
        return _mock_translate(text, source_lang, target_lang)

    # Mayura has a 1000 char limit
    if len(text) > 1000:
        logger.warning("Text exceeds Sarvam 1000 char limit. Truncating for safety.")
        text = text[:1000]

    url = "https://api.sarvam.ai/translate"
    headers = {
        "Content-Type": "application/json",
        "api-subscription-key": SARVAM_API_KEY or "",
    }
    payload = {
        "input": text,
        "source_language_code": _map_lang_code(source_lang),
        "target_language_code": _map_lang_code(target_lang),
        "model": "mayura:v1"
    }

    try:
        async with httpx.AsyncClient(timeout=30) as client:
            response = await client.post(url, json=payload, headers=headers)
            response.raise_for_status()
            result = response.json()
            translated = result.get("translated_text", text)
            logger.info(f"Sarvam translation: {source_lang}→{target_lang} successful")
            return translated
    except Exception as e:
        # Graceful degradation: return mock if Sarvam fails
        logger.error(f"Sarvam API failed ({e}). Falling back to mock translation.")
        return _mock_translate(text, source_lang, target_lang)
