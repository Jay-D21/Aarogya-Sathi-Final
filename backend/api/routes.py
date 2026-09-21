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
    async def generate():
        if req.language == "en":
            async for token in _pipeline.run(query_en, profile_dict, aqi_data, req.wearable.model_dump(), req.chat_history):
                yield {
                    "event": "message",
                    "data": json.dumps({"token": token, "done": False})
                }
            yield {
                "event": "message",
                "data": json.dumps({"token": "", "done": True})
            }
        else:
            full_response = ""
            async for token in _pipeline.run(query_en, profile_dict, aqi_data, req.wearable.model_dump(), req.chat_history):
                full_response += token
            
            # Translate full response, chunking if it exceeds the 1000 char limit
            if len(full_response) > 900:
                import re
                sentences = re.split(r'(?<=[.!?\n])\s+', full_response)
                translated = ""
                current_chunk = ""
                for s in sentences:
                    if len(current_chunk) + len(s) > 900:
                        if current_chunk:
                            translated += await translate(current_chunk.strip(), "en", req.language) + " "
                        current_chunk = s + " "
                    else:
                        current_chunk += s + " "
                if current_chunk.strip():
                    translated += await translate(current_chunk.strip(), "en", req.language)
            else:
                translated = await translate(full_response, "en", req.language)
            
            # Stream translated text word-by-word
            words = translated.split(" ")
            for i, word in enumerate(words):
                token = word + (" " if i < len(words) - 1 else "")
                yield {
                    "event": "message",
                    "data": json.dumps({"token": token, "done": False})
                }
                await asyncio.sleep(0.01)
                
            yield {
                "event": "message",
                "data": json.dumps({
                    "token": "", "done": True, "translated": True
                })
            }

    return EventSourceResponse(generate())
