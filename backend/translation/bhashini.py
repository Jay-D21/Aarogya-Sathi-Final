import os
import httpx
import logging
from dotenv import load_dotenv
from pathlib import Path

env_path = Path(__file__).parent.parent / ".env"
load_dotenv(dotenv_path=env_path)
logger = logging.getLogger(__name__)

BHASHINI_URL = os.getenv("BHASHINI_PIPELINE_URL")
BHASHINI_USER_ID = os.getenv("BHASHINI_USER_ID")
BHASHINI_API_KEY = os.getenv("BHASHINI_API_KEY")

# Check if real credentials are available
_USE_MOCK = (
    not BHASHINI_USER_ID
    or not BHASHINI_API_KEY
    or BHASHINI_USER_ID == "your_user_id_here"
    or BHASHINI_API_KEY == "your_api_key_here"
)

if _USE_MOCK:
    logger.warning(
        "⚠️ Bhashini API credentials not found. Running in MOCK translation mode. "
        "Set BHASHINI_USER_ID and BHASHINI_API_KEY in backend/.env for real translation."
    )
else:
    logger.info("✅ Bhashini API credentials found. Using real translation.")

HEADERS = {
    "Content-Type": "application/json",
    "userID": BHASHINI_USER_ID or "",
    "ulcaApiKey": BHASHINI_API_KEY or "",
}

# Bhashini uses AI4Bharat IndicTrans v2 for all Indian language pairs
TRANSLATION_MODELS = {
    ("hi", "en"): "ai4bharat/indictrans-v2-all-gpu--t4",
    ("en", "hi"): "ai4bharat/indictrans-v2-all-gpu--t4",
    ("mr", "en"): "ai4bharat/indictrans-v2-all-gpu--t4",
    ("en", "mr"): "ai4bharat/indictrans-v2-all-gpu--t4",
}


def _mock_translate(text: str, source_lang: str, target_lang: str) -> str:
    """Returns the original text with a language tag prefix.
    This is a placeholder until real Bhashini API credentials are available.
    The mock clearly marks output so developers can see translation points."""
    return f"[{source_lang}→{target_lang}] {text}"


async def translate(text: str, source_lang: str, target_lang: str) -> str:
    """Translate text using Bhashini API (Government of India).
    
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

    # Validate language pair is supported
    model_id = TRANSLATION_MODELS.get((source_lang, target_lang))
    if not model_id:
        logger.warning(f"Unsupported language pair: {source_lang}→{target_lang}. Using mock.")
        return _mock_translate(text, source_lang, target_lang)

    payload = {
        "pipelineTasks": [{
            "taskType": "translation",
            "config": {
                "language": {
                    "sourceLanguage": source_lang,
                    "targetLanguage": target_lang
                },
                "serviceId": model_id
            }
        }],
        "inputData": {
            "input": [{"source": text}]
        }
    }

    try:
        async with httpx.AsyncClient(timeout=30) as client:
            response = await client.post(BHASHINI_URL, json=payload, headers=HEADERS)
            response.raise_for_status()
            result = response.json()
            translated = result["pipelineResponse"][0]["output"][0]["target"]
            logger.info(f"Bhashini translation: {source_lang}→{target_lang} successful")
            return translated
    except Exception as e:
        # Graceful degradation: return mock if Bhashini fails
        logger.error(f"Bhashini API failed ({e}). Falling back to mock translation.")
        return _mock_translate(text, source_lang, target_lang)
