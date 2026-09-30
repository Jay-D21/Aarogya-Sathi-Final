"""
Query Intent Classifier for Aarogya Sathi Agentic Pipeline.

Classifies incoming queries to short-circuit trivial or domain-specific requests,
saving expensive document retrieval and LLM context overhead.

Supported Intents:
- greeting: Casual greetings, pleasantries, or introductions
- health_query: Clinical, condition, symptom, or treatment questions needing ICMR guidelines
- vital_check: Questions specifically regarding user's wearable readings or logged vitals
- aqi_query: Weather, environmental air quality, pollution inquiries
- lifestyle: Diet, exercise, fitness, preventive health
"""

import re
import logging
from backend.rag.llm import call_llm

logger = logging.getLogger(__name__)

# Fast heuristic rules to avoid LLM latency on obvious conversational inputs
_GREETING_PATTERNS = [
    r"^\s*(hi|hello|hey|helo|hlo|hola|namaste|namaskar|pranam)\b",
    r"^\s*(good\s*(morning|afternoon|evening|night))\b",
    r"^\s*(how\s*are\s*you|who\s*are\s*you|kaisa\s*hai|kaise\s*ho|kasa\s*aahes)\b",
    r"^\s*(kya\s*haal\s*hai|what('?s|\s+is)\s*up)\b",
]

_AQI_PATTERNS = [
    r"\b(aqi|air\s*quality|pollution|pm2\.?5|pm10|smog|pradushan|hawa|weather|humidity|mausam)\b",
]

_VITAL_PATTERNS = [
    r"\b(my\s*(bp|blood\s*pressure|sugar|glucose|heart\s*rate|pulse|spo2|sleep|steps))\b",
    r"\b(mera\s*(bp|sugar|heart\s*rate|pulse|steps|wajan))\b",
    r"\b(majha\s*(bp|sugar))\b",
    r"\b(how\s*many\s*steps|my\s*reading|my\s*vitals)\b",
]


async def classify_intent(query: str) -> str:
    """
    Classify the query intent using rapid regex heuristics first,
    falling back to a fast LLM classification if ambiguous.
    """
    q_clean = query.strip().lower()

    # 1. Check greeting regex
    for pattern in _GREETING_PATTERNS:
        if re.search(pattern, q_clean, re.IGNORECASE):
            logger.info(f"Intent classified via heuristic: 'greeting' for '{query[:30]}'")
            return "greeting"

    # 2. Check AQI / environment regex
    for pattern in _AQI_PATTERNS:
        if re.search(pattern, q_clean, re.IGNORECASE):
            logger.info(f"Intent classified via heuristic: 'aqi_query' for '{query[:30]}'")
            return "aqi_query"

    # 3. Check vitals regex
    for pattern in _VITAL_PATTERNS:
        if re.search(pattern, q_clean, re.IGNORECASE):
            logger.info(f"Intent classified via heuristic: 'vital_check' for '{query[:30]}'")
            return "vital_check"

    # 4. Fallback to LLM classification for nuanced queries
    system_prompt = (
        "Classify the user's message into exactly ONE of the following intent labels:\n"
        "- greeting (pleasantries, greetings, small talk)\n"
        "- health_query (symptoms, diseases, medications, medical conditions)\n"
        "- vital_check (asking about their personal health data, heart rate, BP, steps)\n"
        "- aqi_query (air quality, pollution, weather, outdoor safety)\n"
        "- lifestyle (diet, nutrition, exercise, sleep advice)\n\n"
        "Output ONLY the single label, nothing else."
    )

    try:
        response = await call_llm(
            messages=[
                {"role": "system", "content": system_prompt},
                {"role": "user", "content": f"Query: {query}"},
            ],
            size="70b",
            temperature=0.0,
            max_tokens=10,
        )
        cleaned = response.strip().lower()
        for valid in ["greeting", "health_query", "vital_check", "aqi_query", "lifestyle"]:
            if valid in cleaned:
                logger.info(f"Intent classified via LLM: '{valid}' for '{query[:30]}'")
                return valid

    except Exception as e:
        logger.warning(f"LLM intent classification failed ({e}), defaulting to 'health_query'")

    return "health_query"
