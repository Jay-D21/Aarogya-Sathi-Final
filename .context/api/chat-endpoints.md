# Chat & Agentic RAG API Endpoints

This document outlines the core endpoints for the Aarogya Sathi Agentic ReAct flow and session memory system.

## 1. Chat Interaction (Agentic ReAct Flow)

Main endpoint for user interactions, utilizing the ReAct agent for intent classification, tool execution, and native Qwen 27B generation.

**Endpoint:** `POST /api/chat`

**Authentication:** Required (Bearer token)

**Request Body:**
```json
{
  "user_id": "usr_7890123",         // Required: Unique user identifier for session tracking
  "message": "I have a headache",   // Required: The user's input query
  "language": "en",                 // Optional: "en", "hi", "mr" (default: "en")
  "context": {                      // Optional: Overrides for real-time telemetry
    "lat": 19.0760,
    "lon": 72.8777,
    "heart_rate": 82
  }
}
```

**Success Response (200 OK) - Server-Sent Events (SSE):**
Returns a streaming response of server-sent events for low-latency feedback.

```text
data: {"event": "intent_classified", "intent": "symptom_check"}
data: {"event": "tool_call", "tool": "tool_search_knowledge"}
data: {"event": "chunk", "text": "Based on ICMR guidelines, "}
data: {"event": "chunk", "text": "please rest and drink water."}
data: {"event": "done"}
```

**Error Responses:**
- `400 Bad Request` - Missing `message` or `user_id`
  ```json
  {
    "error": "VALIDATION_ERROR",
    "message": "user_id is required for session tracking"
  }
  ```
- `429 Too Many Requests` - Pool exhausted (all Groq/Sarvam keys hit limits)
- `500 Internal Server Error` - Model failure or safety boundary triggered by SemanticRouter

**Example Request (cURL):**
```bash
curl -X POST http://localhost:8000/api/chat \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "user_id": "usr_7890123",
    "message": "What should I eat for diabetes?",
    "language": "hi"
  }'
```

---

## 2. Environmental Telemetry (AQI)

Fetches real-time Air Quality Index using the WAQI token, with fallback to Open-Meteo. Used internally by the Agentic flow, but exposed for frontend widgets.

**Endpoint:** `GET /api/aqi`

**Authentication:** Required (Bearer token)

**Query Parameters:**
- `lat` (Required): Latitude (e.g., 19.0760)
- `lon` (Required): Longitude (e.g., 72.8777)

**Success Response (200 OK):**
```json
{
  "success": true,
  "data": {
    "aqi": 152,
    "category": "Unhealthy",
    "dominant_pollutant": "pm25",
    "recommendation": "Stay indoors if you have asthma."
  }
}
```

**Error Responses:**
- `400 Bad Request` - Missing coordinates
- `502 Bad Gateway` - Upstream WAQI API failure

---

## 3. Session Memory & Proactive Insights

Retrieves the longitudinal session memory and proactive insights generated from wearable telemetry and past conversations.

**Endpoint:** `GET /api/session/{user_id}/insights`

**Authentication:** Required (Bearer token)

**Path Parameters:**
- `user_id` (Required): The unique identifier for the user.

**Success Response (200 OK):**
```json
{
  "success": true,
  "data": {
    "user_id": "usr_7890123",
    "last_interaction": "2026-10-01T14:30:00Z",
    "active_conditions": ["hypertension", "diabetes_type_2"],
    "proactive_insights": [
      {
        "id": "insight_991",
        "type": "environmental_warning",
        "message": "AQI in your area is 152. Because of your hypertension, avoid outdoor exercise today."
      }
    ]
  }
}
```

**Error Responses:**
- `404 Not Found` - User session file does not exist.
  ```json
  {
    "success": false,
    "error": "SESSION_NOT_FOUND",
    "message": "No active memory profile found for this user."
  }
  ```
