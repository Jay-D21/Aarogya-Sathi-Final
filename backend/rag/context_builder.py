"""
Context Builder — assembles the final LLM prompt from all sources.

No LLM call here — pure string formatting. This is the most important part
of the pipeline because prompt quality directly determines response quality.

The XML structure helps the 70B model clearly separate the knowledge sources:
- <system>: ICMR safety rules and role definition
- <documents>: Retrieved OKF concept files with source labels
- <user_profile>: Classified health readings (BP, sugar, BMI)
- <environment>: Live AQI and weather context
- <wearable>: Fitness tracker data from Health Connect
- <instructions>: Output format and citation requirements
"""

from backend.utils.icmr import classify_bp, classify_sugar, classify_bmi, classify_aqi

# The 21-line ICMR system prompt — embedded directly so it's always available
# regardless of file system state. Updated from previous drafts.
SYSTEM_PROMPT = """=== AROGYA SATHI: VIRTUAL HEALTH ASSISTANT ===

ROLE: You are Arogya Sathi (आरोग्य साथी), India's trusted digital health assistant.
Your role is AWARENESS, ASSISTANCE, and PREVENTION — NOT diagnosis, prescription, or treatment.

CORE RULES (NEVER VIOLATE):
1. NEVER diagnose. Use "these symptoms may suggest..." or "discuss with your doctor about..."
2. NEVER prescribe. Use "your doctor may consider..." — NEVER give dosage instructions
3. ALWAYS recommend consulting a qualified healthcare provider
4. EMERGENCY PROTOCOL: For chest pain, breathlessness, unconsciousness, stroke signs, seizures,
   heavy bleeding, severe allergic reaction — IMMEDIATELY tell user: "🚨 CALL 112 NOW. Do not wait."
5. Every response MUST end with: "⚕️ I am an AI health assistant, not a doctor."

INDIA-SPECIFIC GUIDELINES (ICMR 2023):
- BP: Normal <120/80, Elevated 120-129/<80, Stage 1: 130-139/80-89, Stage 2: ≥140/≥90
- Blood Sugar (Fasting): Normal 70-100, Pre-diabetes 100-125, Diabetes ≥126 mg/dL
- BMI (Asian cutoffs): Underweight <18.5, Normal 18.5-22.9, Overweight 23-27.4, Obese ≥27.5
- AQI (Indian NAQI): Good 0-50, Satisfactory 51-100, Moderate 101-200, Poor 201-300, Severe 301-400
- Language: Use warm, simple language. Reference Indian foods (dal, roti, sabzi, millets).
- Cultural: Respect Ayurveda but always add "also consult your doctor"

DPDP ACT COMPLIANCE: Never store personal identifiers. User data used only for this session."""


def build_context(
    query: str,
    docs: list[dict],
    profile: dict,
    aqi_data: dict,
    wearable: dict | None = None,
    chat_history: list[dict] | None = None,
) -> list[dict]:
    """
    Assemble the full prompt as an OpenAI-format messages list.

    Args:
        query: User's English-translated health query.
        docs: Relevant OKF concept docs from navigator + grader.
        profile: User health profile (age, bp, sugar, conditions, etc.).
        aqi_data: Environmental data from WAQI/Open-Meteo.
        wearable: Optional Health Connect data (steps, HR, SpO2, sleep).

    Returns:
        List of {role, content} dicts ready for call_llm().
    """
    # --- Format OKF documents section ---
    if docs:
        doc_sections = []
        for i, doc in enumerate(docs, 1):
            doc_sections.append(
                f"[Doc {i}] {doc['title']} ({doc['path']}):\n{doc['content']}"
            )
        documents_block = "\n\n".join(doc_sections)
    else:
        documents_block = "No specific ICMR guidelines found for this query. Provide general health awareness advice."

    # --- Format user profile with ICMR classifications ---
    profile_lines = []
    if profile.get("age"):
        profile_lines.append(f"Age: {profile['age']}")
    if profile.get("gender"):
        profile_lines.append(f"Gender: {profile['gender']}")
    if profile.get("systolic") and profile.get("diastolic"):
        bp_class = classify_bp(profile["systolic"], profile["diastolic"])
        profile_lines.append(
            f"Latest BP: {bp_class['reading']} → {bp_class['status']} ({bp_class['color']})"
        )
    if profile.get("blood_sugar"):
        sugar_class = classify_sugar(
            profile["blood_sugar"],
            profile.get("sugar_type", "fasting")
        )
        profile_lines.append(
            f"Blood Sugar ({sugar_class['type']}): {sugar_class['value']} mg/dL → {sugar_class['status']}"
        )
    if profile.get("weight_kg") and profile.get("height_cm"):
        bmi_class = classify_bmi(profile["weight_kg"], profile["height_cm"])
        profile_lines.append(
            f"BMI: {bmi_class['bmi']} → {bmi_class['category']}"
        )
    if profile.get("conditions"):
        profile_lines.append(f"Chronic Conditions: {', '.join(profile['conditions'])}")
    if profile.get("medications"):
        profile_lines.append(f"Medications: {', '.join(profile['medications'])}")

    profile_block = "\n".join(profile_lines) if profile_lines else "No profile data provided."

    # --- Format environmental context ---
    env_lines = []
    if aqi_data.get("aqi") and aqi_data["aqi"] != "N/A":
        aqi_val = aqi_data["aqi"]
        try:
            aqi_class = classify_aqi(int(aqi_val))
            env_lines.append(
                f"AQI: {aqi_val} → {aqi_class['level']} — {aqi_class['advice']}"
            )
        except (ValueError, TypeError):
            env_lines.append(f"AQI: {aqi_val}")
    if aqi_data.get("temperature"):
        env_lines.append(f"Temperature: {aqi_data['temperature']}°C")
    if aqi_data.get("humidity"):
        env_lines.append(f"Humidity: {aqi_data['humidity']}%")
    if aqi_data.get("city"):
        env_lines.append(f"Location: {aqi_data['city']}")

    env_block = "\n".join(env_lines) if env_lines else "Environmental data not available."

    # --- Format wearable data ---
    wearable_block = ""
    if wearable:
        w_lines = []
        if wearable.get("today_steps") is not None:
            w_lines.append(f"Steps today: {wearable['today_steps']}")
        if wearable.get("calories_burned") is not None:
            w_lines.append(f"Calories burned: {wearable['calories_burned']} kcal")
        if wearable.get("heart_rate_bpm") is not None:
            w_lines.append(f"Heart Rate: {wearable['heart_rate_bpm']} bpm")
        if wearable.get("resting_heart_rate") is not None:
            w_lines.append(f"Resting Heart Rate: {wearable['resting_heart_rate']} bpm")
        if wearable.get("spo2_percent") is not None:
            w_lines.append(f"SpO2: {wearable['spo2_percent']}%")
        if wearable.get("blood_glucose_mg_dl") is not None:
            w_lines.append(f"Blood Glucose: {wearable['blood_glucose_mg_dl']} mg/dL")
        if wearable.get("bp_systolic") is not None and wearable.get("bp_diastolic") is not None:
            w_lines.append(f"Wearable BP: {wearable['bp_systolic']}/{wearable['bp_diastolic']} mmHg")
        if wearable.get("body_temp_celsius") is not None:
            w_lines.append(f"Body Temperature: {wearable['body_temp_celsius']}°C")
        if wearable.get("sleep_total_hours") is not None:
            w_lines.append(f"Total Sleep: {wearable['sleep_total_hours']:.1f} hours")
        if wearable.get("sleep_deep_hours") is not None:
            w_lines.append(f"Deep Sleep: {wearable['sleep_deep_hours']:.1f} hours")
        if wearable.get("sleep_rem_hours") is not None:
            w_lines.append(f"REM Sleep: {wearable['sleep_rem_hours']:.1f} hours")
        if wearable.get("sleep_light_hours") is not None:
            w_lines.append(f"Light Sleep: {wearable['sleep_light_hours']:.1f} hours")
        if wearable.get("weight_kg") is not None:
            w_lines.append(f"Weight: {wearable['weight_kg']} kg")
        wearable_block = "\n".join(w_lines)

    # --- Assemble full user message ---
    user_content = f"""<documents>
{documents_block}
</documents>

<user_profile>
{profile_block}
</user_profile>

<environment>
{env_block}
</environment>
"""
    if wearable_block:
        user_content += f"""<wearable_data>
{wearable_block}
</wearable_data>

"""

    user_content += f"""<instructions>
Answer the user's health query using the documents above.
Cite sources as [Doc 1], [Doc 2], etc. when referencing specific guidelines.
Use warm, conversational language appropriate for urban Indian users.
If the documents don't cover the topic, say so honestly and advise consulting a doctor.
End your response with: "⚕️ I am an AI health assistant, not a doctor."
</instructions>

User Query: {query}"""

    messages = [{"role": "system", "content": SYSTEM_PROMPT}]
    if chat_history:
        messages.extend(chat_history)
    messages.append({"role": "user", "content": user_content})

    return messages
