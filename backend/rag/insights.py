"""
Proactive Health Insights Engine for Aarogya Sathi.

Analyzes incoming wearable data, environmental parameters, and longitudinal
vital history to synthesize actionable, ICMR-aligned proactive observations.
"""

from typing import Any, Dict, List, Optional
from backend.utils.icmr import classify_bp, classify_sugar, classify_aqi


def generate_proactive_insights(
    profile: Dict[str, Any],
    wearable: Dict[str, Any],
    aqi_data: Dict[str, Any],
    vital_history: Optional[List[Dict[str, Any]]] = None,
) -> List[str]:
    """
    Generate rule-based clinical observations and ambient alerts based on user context.
    """
    insights: List[str] = []

    # 1. Vital Threshold Checks (ICMR / Clinical standards)
    hr = wearable.get("heart_rate_bpm") or wearable.get("resting_heart_rate")
    if hr is not None:
        if hr > 115:
            insights.append(f"Heart rate is currently elevated at {int(hr)} bpm. Take a moment to rest and hydrate.")
        elif hr < 50:
            insights.append(f"Heart rate is on the lower side ({int(hr)} bpm). Consult your physician if feeling fatigued or dizzy.")

    spo2 = wearable.get("spo2_percent")
    if spo2 is not None:
        if spo2 < 93:
            insights.append(f"SpO2 oxygen saturation is low at {spo2}%. If you feel short of breath, please seek prompt medical care.")
        elif spo2 < 95:
            insights.append(f"SpO2 is slightly reduced ({spo2}%). Continue to monitor your breathing.")

    bp_sys = wearable.get("bp_systolic")
    bp_dia = wearable.get("bp_diastolic")
    if bp_sys is not None and bp_dia is not None:
        classification = classify_bp(int(bp_sys), int(bp_dia))
        if classification.get("level") in ["Stage 1", "Stage 2"]:
            insights.append(f"Recent Blood Pressure reading ({int(bp_sys)}/{int(bp_dia)} mmHg) indicates {classification['level']} hypertension.")

    glucose = wearable.get("blood_glucose_mg_dl")
    if glucose is not None:
        sugar_class = classify_sugar(float(glucose), reading_type="random")
        if sugar_class.get("level") in ["High", "Diabetes"]:
            insights.append(f"Blood glucose reading of {int(glucose)} mg/dL is elevated above normal ranges.")

    # 2. Environmental & Pollution Alerts (CPCB NAQI)
    aqi_val = aqi_data.get("aqi")
    if aqi_val is not None and str(aqi_val) != "N/A":
        try:
            aqi_int = int(aqi_val)
            aqi_class = classify_aqi(aqi_int)
            if aqi_int >= 201:
                insights.append(f"Local air quality is {aqi_class['level']} (AQI {aqi_int}). Recommend minimizing intense outdoor exertion.")
        except (ValueError, TypeError):
            pass

    # 3. Longitudinal Trend Analysis (if prior session records exist)
    if vital_history and len(vital_history) >= 2:
        prev = vital_history[-2]
        curr = vital_history[-1]

        # BP Trend
        if prev.get("bp_systolic") and curr.get("bp_systolic"):
            diff = curr["bp_systolic"] - prev["bp_systolic"]
            if diff >= 15:
                insights.append(f"Systolic BP has increased by {int(diff)} mmHg since previous check.")

        # Resting HR Trend
        if prev.get("resting_heart_rate") and curr.get("resting_heart_rate"):
            hr_diff = curr["resting_heart_rate"] - prev["resting_heart_rate"]
            if hr_diff >= 12:
                insights.append(f"Resting heart rate has increased by {int(hr_diff)} bpm compared to earlier readings.")

    return insights
