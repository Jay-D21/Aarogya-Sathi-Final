import os
import httpx
import logging
from typing import Any, Dict
from dotenv import load_dotenv
from pathlib import Path

# Load from backend/.env specifically, not just current working directory
env_path = Path(__file__).parent.parent / ".env"
load_dotenv(dotenv_path=env_path)

logger = logging.getLogger(__name__)

WAQI_TOKEN = os.getenv("WAQI_API_TOKEN")

_USE_MOCK = (
    not WAQI_TOKEN
    or WAQI_TOKEN == "your_waqi_token_here"
)

if _USE_MOCK:
    logger.warning(
        "⚠️ WAQI_API_TOKEN not configured. AQI endpoint will return mock data. "
        "Get your free token at https://aqicn.org/data-platform/token/"
    )
else:
    logger.info("✅ WAQI_API_TOKEN found. Using real AQI data.")


async def get_aqi(lat: float, lon: float) -> Dict[str, Any]:
    """Fetch real-time AQI data from WAQI API using GPS coordinates.
    
    The geo endpoint returns data from the nearest monitoring station
    to the given lat/lon — works for any location worldwide including
    all Indian cities (Mumbai, Delhi, Pune, Shirpur, etc.).
    
    Args:
        lat: Latitude (e.g., 19.0760 for Mumbai)
        lon: Longitude (e.g., 72.8777 for Mumbai)
    
    Returns:
        Dict with AQI, PM2.5, PM10, NO2, SO2, O3, CO, station name
    """
    # Fallback to mock data when token is absent to allow offline development and testing
    if _USE_MOCK:
        return _mock_aqi(lat, lon)

    # WAQI geo endpoint: returns nearest station to coordinates
    url = f"https://api.waqi.info/feed/geo:{lat};{lon}/?token={WAQI_TOKEN}"

    try:
        # Timeout configured to 10s to prevent hanging requests when WAQI servers experience latency
        async with httpx.AsyncClient(timeout=10) as client:
            resp = await client.get(url)
            data = resp.json()

        # Check API status response from WAQI
        if data.get("status") != "ok":
            logger.error(f"WAQI API error: {data.get('data', 'Unknown error')}")
            return _mock_aqi(lat, lon)

        d = data["data"]
        iaqi = d.get("iaqi", {})

        return {
            "aqi": d.get("aqi", "N/A"),
            "pm25": iaqi.get("pm25", {}).get("v", "N/A"),
            "pm10": iaqi.get("pm10", {}).get("v", "N/A"),
            "no2": iaqi.get("no2", {}).get("v", "N/A"),
            "so2": iaqi.get("so2", {}).get("v", "N/A"),
            "o3": iaqi.get("o3", {}).get("v", "N/A"),
            "co": iaqi.get("co", {}).get("v", "N/A"),
            "station": d.get("city", {}).get("name", "Unknown"),
        }
    except Exception as e:
        # Safeguard downstream pipeline by falling back to mock readings upon network or parsing failure
        logger.error(f"WAQI API request failed: {e}")
        return _mock_aqi(lat, lon)


def _mock_aqi(lat: float, lon: float) -> Dict[str, Any]:
    """Return realistic mock AQI data for development/testing."""
    return {
        "aqi": 142,
        "pm25": 52.4,
        "pm10": 98.1,
        "no2": 18.2,
        "so2": 4.1,
        "o3": 22.0,
        "co": 1.2,
        "station": f"Mock Station ({lat:.2f}, {lon:.2f})",
    }
