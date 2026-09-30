from pydantic import BaseModel


class WearableData(BaseModel):
    """Live health metrics from Health Connect SDK (Fitbit, Google Fit, etc.).

    All fields are optional because the user may not have a wearable device
    or may not have granted all Health Connect permissions.
    """
    today_steps: int | None = None
    calories_burned: int | None = None
    heart_rate_bpm: float | None = None
    resting_heart_rate: float | None = None
    spo2_percent: float | None = None
    blood_glucose_mg_dl: float | None = None
    bp_systolic: float | None = None
    bp_diastolic: float | None = None
    body_temp_celsius: float | None = None
    sleep_total_hours: float | None = None
    sleep_rem_hours: float | None = None
    sleep_deep_hours: float | None = None
    sleep_light_hours: float | None = None
    weight_kg: float | None = None


class UserProfile(BaseModel):
    """Static health profile stored in SQLite on the user's device."""
    age: int | None = None
    gender: str | None = None
    conditions: list[str] = []
    medications: list[str] = []


class ChatRequest(BaseModel):
    """Request body for POST /api/chat.

    The Flutter app sends this with every chat message, including the user's
    static profile, live wearable data, preferred language, and GPS location
    for environmental context.
    """
    user_id: str | None = None
    query: str
    language: str = "en"  # en, hi, mr
    profile: UserProfile = UserProfile()
    wearable: WearableData = WearableData()
    lat: float | None = None
    lon: float | None = None
    chat_history: list[dict] = []


class AQIResponse(BaseModel):
    """Response model for GET /api/aqi."""
    success: bool
    data: dict
