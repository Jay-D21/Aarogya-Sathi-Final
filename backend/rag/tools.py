"""
Agentic Tools Definition for Aarogya Sathi.

Provides discrete functional tools callable by the Agentic Pipeline
to gather knowledge, evaluate vitals, inspect environmental context,
and examine historical profile data.
"""

import logging
from typing import Any, Dict, List, Optional
from backend.rag.okf_navigator import OKFNavigator
from backend.rag.grader import grade_documents
from backend.utils.icmr import classify_bp, classify_sugar, classify_aqi

logger = logging.getLogger(__name__)


async def tool_search_knowledge(query: str, navigator: OKFNavigator) -> List[Dict[str, Any]]:
    """
    Tool: Search ICMR Knowledge Bundle.
    Traverses concept files and applies CRAG relevance grading.
    """
    logger.info(f"[Tool] search_knowledge: '{query}'")
    retrieved = await navigator.navigate(query)
    if not retrieved:
        return []

    relevant, _ = await grade_documents(query, retrieved)
    return relevant if relevant else retrieved[:2]


def tool_analyze_vitals(wearable: Dict[str, Any]) -> str:
    """
    Tool: Analyze Wearable Health Data against ICMR / clinical ranges.
    """
    logger.info("[Tool] analyze_vitals")
    if not wearable:
        return "No wearable device data connected or available for this user."

    lines = []
    if wearable.get("heart_rate_bpm"):
        hr = int(wearable["heart_rate_bpm"])
        status = "normal" if 60 <= hr <= 100 else ("elevated" if hr > 100 else "low")
        lines.append(f"- Heart Rate: {hr} bpm ({status})")

    if wearable.get("spo2_percent"):
        spo2 = wearable["spo2_percent"]
        status = "optimal" if spo2 >= 95 else "low (needs monitoring)"
        lines.append(f"- Blood Oxygen (SpO2): {spo2}% ({status})")

    if wearable.get("bp_systolic") and wearable.get("bp_diastolic"):
        s = int(wearable["bp_systolic"])
        d = int(wearable["bp_diastolic"])
        classification = classify_bp(s, d)
        lines.append(f"- Blood Pressure: {s}/{d} mmHg ({classification['level']} — {classification['advice']})")

    if wearable.get("blood_glucose_mg_dl"):
        glu = float(wearable["blood_glucose_mg_dl"])
        classification = classify_sugar(glu, reading_type="random")
        lines.append(f"- Blood Glucose: {int(glu)} mg/dL ({classification['level']})")

    if wearable.get("today_steps") is not None:
        lines.append(f"- Daily Steps: {wearable['today_steps']} steps")

    if wearable.get("sleep_total_hours") is not None:
        lines.append(f"- Sleep Duration: {wearable['sleep_total_hours']:.1f} hours")

    return "\n".join(lines) if lines else "Wearable connected but no active vitals recorded."


def tool_get_environmental_data(aqi_data: Dict[str, Any]) -> str:
    """
    Tool: Format real-time environmental context.
    """
    logger.info("[Tool] get_environmental_data")
    if not aqi_data or aqi_data.get("aqi") == "N/A":
        return "Environmental and AQI data currently unavailable."

    lines = []
    aqi_val = aqi_data.get("aqi")
    if aqi_val:
        try:
            aqi_int = int(aqi_val)
            c = classify_aqi(aqi_int)
            lines.append(f"- AQI: {aqi_int} ({c['level']} — {c['advice']})")
        except (ValueError, TypeError):
            lines.append(f"- AQI: {aqi_val}")

    if aqi_data.get("temperature"):
        lines.append(f"- Temperature: {aqi_data['temperature']}°C")
    if aqi_data.get("humidity"):
        lines.append(f"- Humidity: {aqi_data['humidity']}%")
    if aqi_data.get("station"):
        lines.append(f"- Monitoring Station: {aqi_data['station']}")

    return "\n".join(lines)
