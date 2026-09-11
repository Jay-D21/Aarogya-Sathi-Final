from fastapi import APIRouter, Query
from sse_starlette.sse import EventSourceResponse
from backend.context.aqi import get_aqi
from backend.context.weather import get_weather
from backend.safety.router import check_safety
from backend.translation.bhashini import translate
from backend.api.models import ChatRequest
from backend.rag.pipeline import CRAGPipeline
import os
import json
import asyncio
import logging

logger = logging.getLogger(__name__)

router = APIRouter()

# Initialize once at import time — the pipeline is stateless and reusable
_pipeline = CRAGPipeline(
    bundle_path=os.getenv("OKF_BUNDLE_PATH", "./icmr-knowledge-bundle")
)


@router.get("/aqi")
async def aqi_endpoint(lat: float = Query(...), lon: float = Query(...)):
    """Get real-time AQI + weather data for a GPS location.

    The WAQI geo endpoint returns the nearest monitoring station data,
    so Indian cities are fully supported via lat/lon coordinates.
    """
    try:
        aqi_data = await get_aqi(lat, lon)
        weather_data = await get_weather(lat, lon)
        return {"success": True, "data": {**aqi_data, **weather_data}}
    except Exception as e:
        logger.error(f"AQI endpoint error: {e}")
        return {"success": False, "error": str(e)}


async def _mock_pipeline(query: str, profile: dict, aqi_data: dict):
    """Temporary mock pipeline until Jayesh completes CRAGPipeline.

    Generates a realistic-looking streamed response to test SSE streaming,
    safety routing, and translation integration end-to-end.
    """
    mock_response = (
        f"Based on ICMR guidelines, here is information related to your query "
        f"about '{query}':\n\n"
        "**General Guidance** [Doc 1]:\n"
        "For managing chronic conditions, ICMR recommends regular monitoring, "
        "adherence to prescribed medication, and lifestyle modifications including "
        "a balanced diet and regular physical activity.\n\n"
        "**Environmental Considerations** [Doc 2]:\n"
    )

    # Inject AQI-aware advice when environmental data is available
    aqi_val = aqi_data.get("aqi", "N/A")
    if aqi_val != "N/A" and isinstance(aqi_val, (int, float)) and aqi_val > 100:
        mock_response += (
            f"Current AQI in your area is {aqi_val} (Unhealthy). "
            "ICMR advises reducing outdoor physical activity and exercising indoors "
            "when air quality is poor, especially for patients with respiratory or "
            "cardiovascular conditions.\n\n"
        )
    else:
        mock_response += (
            f"Current AQI in your area is {aqi_val}. "
            "Air quality is acceptable for moderate outdoor activities.\n\n"
        )

    mock_response += (
        "\n⚕️ I am an AI health assistant, not a doctor. "
        "For emergencies, call 112."
    )

    # Stream word by word to simulate real LLM token generation
    words = mock_response.split(" ")
    for i, word in enumerate(words):
        token = word + (" " if i < len(words) - 1 else "")
        yield token
        await asyncio.sleep(0.03)  # ~30ms delay mimics LLM token latency


@router.post("/chat")
async def chat_endpoint(req: ChatRequest):
    """Main chat endpoint — streams response via Server-Sent Events (SSE).

    Full pipeline flow:
    1. Safety Check (Semantic Router) — block emergencies/prescriptions
    2. Translate query to English (Bhashini) — if Hindi/Marathi
    3. Fetch AQI + Weather data (WAQI + Open-Meteo) — for environmental context
    4. Run CRAG Pipeline (mock until Jayesh delivers) — generate response
    5. Translate response back to user's language
    6. Stream all tokens via SSE to Flutter app
    """
    # Step 1: Safety check — ultra-fast intent classification
    is_safe, blocked_response = check_safety(req.query)
    if not is_safe:
        async def blocked_stream():
            yield {
                "event": "message",
                "data": json.dumps({"token": blocked_response, "done": True})
            }
        return EventSourceResponse(blocked_stream())

    # Step 2: Translate user query to English for RAG processing
    query_en = req.query
    if req.language != "en":
        query_en = await translate(req.query, req.language, "en")

    # Step 3: Fetch environmental context (non-critical — continue without it)
    aqi_data = {}
    if req.lat is not None and req.lon is not None:
        try:
            aqi_data = await get_aqi(req.lat, req.lon)
            weather = await get_weather(req.lat, req.lon)
            aqi_data.update(weather)
        except Exception as e:
            logger.warning(f"Environmental data fetch failed: {e}")
            aqi_data = {"aqi": "N/A", "error": "Could not fetch environmental data"}

    # Step 4: Build profile context for the pipeline
    profile_dict = req.profile.model_dump()
    profile_dict["wearable"] = req.wearable.model_dump()

    # Step 5: Run pipeline and stream response
    # TODO: Replace _mock_pipeline with Jayesh's CRAGPipeline when ready:
    #   from backend.rag.pipeline import CRAGPipeline
    #   pipeline = CRAGPipeline("./icmr-knowledge-bundle")

    async def generate():
        full_response = ""
        async for token in _pipeline.run(query_en, profile_dict, aqi_data, req.wearable.model_dump()):
            full_response += token
            yield {
                "event": "message",
                "data": json.dumps({"token": token, "done": False})
            }

        # Step 6: Translate full response back to user's language
        if req.language != "en":
            translated = await translate(full_response, "en", req.language)
            yield {
                "event": "message",
                "data": json.dumps({
                    "token": translated, "done": True, "translated": True
                })
            }
        else:
            yield {
                "event": "message",
                "data": json.dumps({"token": "", "done": True})
            }

    return EventSourceResponse(generate())
