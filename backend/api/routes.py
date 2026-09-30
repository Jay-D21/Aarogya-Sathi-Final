from fastapi import APIRouter, Query, Path
from sse_starlette.sse import EventSourceResponse
from backend.context.aqi import get_aqi
from backend.context.weather import get_weather
from backend.safety.router import check_safety
from backend.translation.bhashini import translate
from backend.api.models import ChatRequest
from backend.rag.pipeline import CRAGPipeline
from backend.memory.session import session_manager
from backend.rag.insights import generate_proactive_insights
import os
import json
import asyncio
import logging

logger = logging.getLogger(__name__)

router = APIRouter()

# Initialize once at import time — the pipeline is reusable across requests
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


@router.get("/session/{user_id}/insights")
async def user_insights_endpoint(
    user_id: str = Path(...),
    lat: float | None = Query(None),
    lon: float | None = Query(None),
):
    """Fetch proactive clinical and environmental observations for a specific user session.

    Can be polled periodically by the mobile app to trigger proactive background notifications
    (e.g., poor AQI warnings, abnormal heart rate anomalies).
    """
    try:
        session = session_manager.get_session(user_id)
        aqi_data = {}
        if lat is not None and lon is not None:
            try:
                aqi_data = await get_aqi(lat, lon)
                weather = await get_weather(lat, lon)
                aqi_data.update(weather)
            except Exception as e:
                logger.warning(f"Could not fetch environmental data for insights: {e}")

        latest_wearable = session.vital_history[-1] if session.vital_history else {}
        insights = generate_proactive_insights(
            profile=session.profile,
            wearable=latest_wearable,
            aqi_data=aqi_data,
            vital_history=session.vital_history,
        )
        return {
            "success": True,
            "data": {
                "user_id": user_id,
                "insights": insights,
                "vital_count": len(session.vital_history),
                "has_profile": bool(session.profile),
            },
        }
    except Exception as e:
        logger.error(f"Insights endpoint error: {e}")
        return {"success": False, "error": str(e)}


@router.post("/chat")
async def chat_endpoint(req: ChatRequest):
    """Main Agentic chat endpoint — streams response via Server-Sent Events (SSE).

    Pipeline flow:
    1. Safety Check (Semantic Router) — immediate interception for emergencies/prescriptions
    2. Session Memory Retrieval — loads per-user longitudinal context
    3. Environmental context — WAQI & Open-Meteo for nearest station
    4. Agentic Pipeline execution — intent classification, tool execution & proactive synthesis
    5. Session Memory persistence — updates vital history & recent turns
    6. Streams response tokens via SSE to the mobile client
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

    # Step 2: Fetch environmental context (non-critical — continue without it)
    aqi_data = {}
    if req.lat is not None and req.lon is not None:
        try:
            aqi_data = await get_aqi(req.lat, req.lon)
            weather = await get_weather(req.lat, req.lon)
            aqi_data.update(weather)
        except Exception as e:
            logger.warning(f"Environmental data fetch failed: {e}")
            aqi_data = {"aqi": "N/A", "error": "Could not fetch environmental data"}

    # Step 3: Load or initialize per-user session memory
    session = session_manager.get_session(req.user_id)
    profile_dict = req.profile.model_dump()
    profile_dict["wearable"] = req.wearable.model_dump()

    # Step 4: Run agentic pipeline and stream response
    async def generate():
        async for token in _pipeline.run(
            query=req.query,
            profile=profile_dict,
            aqi_data=aqi_data,
            wearable=req.wearable.model_dump(),
            chat_history=req.chat_history,
            language=req.language,
            session=session,
        ):
            yield {
                "event": "message",
                "data": json.dumps({"token": token, "done": False})
            }

        # Terminal event
        yield {
            "event": "message",
            "data": json.dumps({"token": "", "done": True})
        }

        # Persist session changes upon completion of dialogue turn
        session_manager.save_session(session)

    return EventSourceResponse(generate())
