"""
ICMR clinical threshold classifiers.

Uses Indian/Asian-specific cutoffs (not the Western NHANES standards) because
ICMR guidelines use different thresholds for BMI and blood sugar for South Asian
populations who develop metabolic risk at lower values.

Source: ICMR Biomedical Research 2023 guidelines + Indian NAQI standards.
Ported from the earlier Aarogya Sathi MVP codebase.
"""


def classify_bp(systolic: int, diastolic: int) -> dict:
    """Classify blood pressure using Indian/Asian cutoffs."""
    if systolic < 120 and diastolic < 80:
        status, severity, color = "Normal", "none", "green"
    elif 120 <= systolic <= 129 and diastolic < 80:
        status, severity, color = "Elevated", "low", "yellow"
    elif 130 <= systolic <= 139 or 80 <= diastolic <= 89:
        status, severity, color = "Stage 1 Hypertension", "medium", "orange"
    else:
        status, severity, color = "Stage 2 Hypertension", "high", "red"

    return {"status": status, "severity": severity, "color": color,
            "reading": f"{systolic}/{diastolic}"}


def classify_sugar(value: float, reading_type: str = "fasting") -> dict:
    """
    Classify blood sugar using ICMR thresholds.

    reading_type: "fasting", "random", or "postmeal"
    """
    if reading_type == "fasting":
        if value < 70:
            status, severity, color = "Hypoglycemia", "critical", "red"
        elif value <= 100:
            status, severity, color = "Normal", "none", "green"
        elif value <= 125:
            status, severity, color = "Pre-diabetes", "medium", "yellow"
        else:
            status, severity, color = "Diabetes Range", "high", "orange"
    else:
        # Random / post-meal thresholds
        if value < 70:
            status, severity, color = "Hypoglycemia", "critical", "red"
        elif value <= 139:
            status, severity, color = "Normal", "none", "green"
        elif value <= 199:
            status, severity, color = "Pre-diabetes Range", "medium", "yellow"
        else:
            status, severity, color = "Diabetes Range", "high", "orange"

    return {"status": status, "severity": severity, "color": color,
            "value": value, "unit": "mg/dL", "type": reading_type}


def classify_bmi(weight_kg: float, height_cm: float) -> dict:
    """
    Classify BMI using Asian cutoffs (ICMR recommendation).

    Asian populations develop metabolic risk at BMI ≥23, not ≥25 as in
    Western standards — this is critical for Indian health advice accuracy.
    """
    height_m = height_cm / 100
    bmi = round(weight_kg / (height_m ** 2), 1)

    if bmi < 18.5:
        category, color = "Underweight", "yellow"
    elif bmi <= 22.9:
        category, color = "Normal (Asian Standard)", "green"
    elif bmi <= 27.4:
        category, color = "Overweight", "orange"
    else:
        category, color = "Obese", "red"

    return {"bmi": bmi, "category": category, "color": color}


def classify_aqi(aqi: int) -> dict:
    """Classify AQI using Indian NAQI (National Air Quality Index) scale."""
    if aqi <= 50:
        level, color, advice = "Good", "green", "Safe for all activities"
    elif aqi <= 100:
        level, color, advice = "Satisfactory", "yellow", "Normal activities OK"
    elif aqi <= 200:
        level, color, advice = "Moderately Polluted", "orange", \
            "Limit prolonged outdoor activity"
    elif aqi <= 300:
        level, color, advice = "Poor", "red", \
            "Avoid outdoor activity; use N95 mask if going out"
    elif aqi <= 400:
        level, color, advice = "Severe", "darkred", \
            "Stay indoors; all outdoor activity harmful"
    else:
        level, color, advice = "Hazardous", "maroon", \
            "Emergency conditions — do not go outside"

    return {"aqi": aqi, "level": level, "color": color, "advice": advice}
