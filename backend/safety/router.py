"""Safety router for blocking unsafe queries before they reach the RAG pipeline.

Uses Semantic Router for fast (<100ms) vector-based intent classification.
Falls back to keyword matching if the semantic-router package isn't installed
or if its embedding model fails to load.
"""

import logging

logger = logging.getLogger(__name__)

EMERGENCY_RESPONSE = (
    "🚨 **EMERGENCY DETECTED** 🚨\n\n"
    "Please call **112** (India Emergency) immediately.\n"
    "If someone is unconscious, start CPR.\n"
    "Do NOT wait for AI advice in emergencies.\n\n"
    "📞 Emergency: 112\n"
    "🏥 Ambulance: 102\n"
    "☠️ Poison Control: 1800-11-6117"
)

PRESCRIPTION_RESPONSE = (
    "I cannot prescribe medication or recommend specific drugs. "
    "Only a licensed doctor can prescribe after examining you.\n\n"
    "Please consult your nearest healthcare provider.\n\n"
    "⚕️ I am an AI health assistant, not a doctor."
)

NON_MEDICAL_RESPONSE = (
    "I'm Aarogya Sathi, a health assistant. I can only help with "
    "health-related questions based on ICMR guidelines.\n\n"
    "Try asking me about:\n"
    "- Managing diabetes, hypertension, or asthma\n"
    "- Exercise advice based on air quality\n"
    "- Diet recommendations for your conditions"
)

# Try to initialize Semantic Router — if it fails, keyword fallback is used
_router = None
_use_keyword_fallback = False

try:
    from semantic_router import RouteLayer
    from backend.safety.routes import emergency, prescription, non_medical, ROUTES_AVAILABLE

    if ROUTES_AVAILABLE:
        _router = RouteLayer(routes=[emergency, prescription, non_medical])
        logger.info("✅ Semantic Router initialized successfully.")
    else:
        _use_keyword_fallback = True
        logger.warning("⚠️ semantic-router routes unavailable. Using keyword fallback.")
except Exception as e:
    _use_keyword_fallback = True
    logger.warning(f"⚠️ Semantic Router init failed ({e}). Using keyword fallback.")


# Keyword lists for fallback matching — covers major emergency/prescription/off-topic phrases
_EMERGENCY_KEYWORDS = [
    "heart attack", "can't breathe", "cannot breathe", "unconscious",
    "chest pain", "stroke", "bleeding", "choking", "collapsed",
    "ambulance", "emergency", "dying", "death",
    "सांस नहीं", "सीने में दर्द", "बेहोश", "खून",
    "छातीत दुख", "श्वास घेता",
    "sans nahi", "seene mein", "heart attack ho",
]

_PRESCRIPTION_KEYWORDS = [
    "prescribe", "prescription", "which drug", "which medicine",
    "what medication", "give me medicine", "medicine for",
    "dawai", "tablet konsi", "medicine likh", "dosage should",
    "दवाई", "औषध", "गोळी",
]

_NON_MEDICAL_KEYWORDS = [
    "joke", "story", "homework", "essay", "game",
    "stock price", "cricket", "score", "prime minister",
    "recipe", "movie", "song", "play",
    "कहानी", "खेल",
]


def _keyword_check(query: str) -> tuple[bool, str | None]:
    """Fallback safety check using simple keyword matching.

    Less accurate than Semantic Router but requires zero ML models,
    making it useful for development and testing environments.
    """
    query_lower = query.lower()

    for kw in _EMERGENCY_KEYWORDS:
        if kw in query_lower:
            return False, EMERGENCY_RESPONSE

    for kw in _PRESCRIPTION_KEYWORDS:
        if kw in query_lower:
            return False, PRESCRIPTION_RESPONSE

    for kw in _NON_MEDICAL_KEYWORDS:
        if kw in query_lower:
            return False, NON_MEDICAL_RESPONSE

    return True, None


def check_safety(query: str) -> tuple[bool, str | None]:
    """Check if a query is safe to process through the RAG pipeline.

    Returns:
        (is_safe, blocked_response) tuple:
        - is_safe=True, blocked_response=None → query is safe, continue to RAG
        - is_safe=False, blocked_response=str → query is blocked, return this message
    """
    if _use_keyword_fallback or _router is None:
        return _keyword_check(query)

    try:
        result = _router(query)
        if result.name == "emergency":
            return False, EMERGENCY_RESPONSE
        elif result.name == "prescription":
            return False, PRESCRIPTION_RESPONSE
        elif result.name == "non_medical":
            return False, NON_MEDICAL_RESPONSE
        else:
            return True, None  # Safe — continue to RAG pipeline
    except Exception as e:
        # Semantic Router can fail on unusual inputs — fall back gracefully
        logger.error(f"Semantic Router error: {e}. Falling back to keyword check.")
        return _keyword_check(query)
