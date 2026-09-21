import httpx
import logging
from typing import Any, Dict

logger = logging.getLogger(__name__)


async def get_weather(lat: float, lon: float) -> Dict[str, Any]:
    """Fetch current weather data from Open-Meteo (free, no API key needed).
    
    Args:
        lat: Latitude (e.g., 19.0760 for Mumbai)
        lon: Longitude (e.g., 72.8777 for Mumbai)
    
    Returns:
        Dict with temperature, humidity, feels-like, UV, wind, precipitation
    """
    # Open-Meteo forecast API provides real-time meteorological metrics without requiring authentication
    url = (
        f"https://api.open-meteo.com/v1/forecast"
        f"?latitude={lat}&longitude={lon}"
        f"&current=temperature_2m,relative_humidity_2m,apparent_temperature,"
        f"uv_index,wind_speed_10m,precipitation"
    )

    try:
        # Cap request duration to 10s to ensure timely responses in the context-gathering stage
        async with httpx.AsyncClient(timeout=10) as client:
            resp = await client.get(url)
            resp.raise_for_status()
            data = resp.json()

        current = data.get("current", {})
        return {
            "temperature": current.get("temperature_2m", "N/A"),
            "humidity": current.get("relative_humidity_2m", "N/A"),
            "feels_like": current.get("apparent_temperature", "N/A"),
            "uv_index": current.get("uv_index", "N/A"),
            "wind_speed": current.get("wind_speed_10m", "N/A"),
            "precipitation": current.get("precipitation", "N/A"),
        }
    except Exception as e:
        # Graceful fallback ensures upstream LLM prompt synthesis continues even if weather service fails
        logger.error(f"Open-Meteo API failed: {e}")
        return {
            "temperature": "N/A",
            "humidity": "N/A",
            "feels_like": "N/A",
            "uv_index": "N/A",
            "wind_speed": "N/A",
            "precipitation": "N/A",
        }
