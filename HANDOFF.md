# 🚀 Aarogya Sathi — Developer Handoff

**Date**: September 21, 2026  
**Pushed by**: Jayesh Patil  
**Commit**: `50768d7` — `feat: wire full context pipeline + Sarvam AI translation + eval fixes`  
**Repo**: https://github.com/Jay-D21/Aarogya-Sathi-Final

---

## ✅ What's Already Done (Don't Touch)

All these changes are in the latest `main` branch. Pull before doing anything.

| # | Change | Status |
|---|--------|--------|
| 1 | Hardcoded API keys removed from frontend + .env.example | ✅ Secure |
| 2 | `chat_provider.dart` now sends profile, wearable, lat, lon, chat_history to backend | ✅ Wired |
| 3 | `chat_screen.dart` pulls data from AuthProvider, HealthProvider, FitnessProvider | ✅ Wired |
| 4 | `ChatRequest` model has `chat_history: list[dict]` field | ✅ Backend |
| 5 | `context_builder.py` injects chat history between system prompt and user message | ✅ Memory |
| 6 | `bhashini.py` rewritten to use **Sarvam AI** (`mayura:v1` model) instead of Bhashini | ✅ Translation |
| 7 | `evaluate.py` fixed — honest docstring, context in judge prompt, robust JSON parsing | ✅ Evaluation |
| 8 | `aqi.py` has proper `_USE_MOCK` fallback pattern for missing WAQI token | ✅ AQI |
| 9 | `weather.py` fixed — `"temperature"` key matches `context_builder.py` | ✅ Bug fix |
| 10 | Dead code (`_mock_pipeline`, lying comments, broken cross-links) cleaned up | ✅ Cleanup |

---

## 🔑 STEP 0: Get API Keys (Before Anything Else)

> **⚠️ CRITICAL: Do this BEFORE running the app. Without these keys, translation + AQI are mocked.**

| Service | URL | What You Get | Time |
|---------|-----|-------------|------|
| **Sarvam AI** | https://dashboard.sarvam.ai | `SARVAM_API_KEY` — ₹100 free credits, Hindi/Marathi/English | 2 min |
| **WAQI** | https://aqicn.org/data-platform/token/ | `WAQI_API_TOKEN` — free, instant | 1 min |
| **Groq** | https://console.groq.com | `GROQ_API_KEY` — new key (old one was rotated) | 2 min |

### Create `backend/.env`:
```bash
cp backend/.env.example backend/.env
```
Then fill in your keys:
```env
GROQ_API_KEY=gsk_YOUR_NEW_KEY_HERE
SAMBANOVA_API_KEY=your_key_here
CEREBRAS_API_KEY=your_key_here
SARVAM_API_KEY=your_sarvam_key_here
WAQI_API_TOKEN=your_waqi_token_here
OKF_BUNDLE_PATH=./icmr-knowledge-bundle
```

---

## 📋 Remaining Tasks — Assigned by Role

### 🟢 Abhijit (Frontend / Mobile Dev)

#### Task 1: Test Context Wiring (1 hour)
The `sendMessage` method now sends profile + wearable + location + chat_history.
- Run the app: `flutter run --dart-define=GROQ_API_KEY=your_key`
- Open chat, ask: "I have diabetes and my sugar is 180, what should I do?"
- Check backend logs — you should see the profile, wearable data, and location in the request
- If the AI response mentions your specific conditions/vitals → it's working

#### Task 2: Test Hindi Translation (30 min)
- Switch app language to Hindi
- Send a message in Hindi
- Check that Sarvam translates it → backend processes in English → response comes back in Hindi
- If you see `[hi→en]` prefix, the API key isn't set

#### Task 3: Add Demo Fallback Responses (1 hour)
In `chat_provider.dart`, add 3-5 hardcoded fallback responses for common demo questions.
This protects you if the LLM API goes down during the presentation.

```dart
static const _demoFallbacks = {
  'diabetes': 'Based on ICMR guidelines, for diabetes management...',
  'blood pressure': 'According to ICMR 2023 guidelines...',
  // Add 3 more for common demo scenarios
};
```

Before calling the backend, check if the query matches a demo fallback key.

#### Task 4: Record Demo Video Backup (30 min)
- Screen-record a full demo flow: open app → ask 3 questions → show personalized answers
- Save as `docs/demo_backup.mp4` — play this if APIs die during presentation

---

### 🟡 Ritesh (AIML / Pipeline Dev)

#### Task 1: Run Evaluation Pipeline (1 hour)
```bash
cd backend
python -m evaluation.evaluate --qa-file evaluation/gold_qa.json --output evaluation/results.json --limit 5
```
- Check `evaluation/results.json` for actual scores
- If all scores are 0 → the LLM judge is returning empty responses. Try changing `size="8b"` to `size="70b"` in `evaluate.py` line 102
- Record the scores — you'll need them for the presentation

#### Task 2: Prompt Tuning (2-3 hours)
The LLM now receives full context (profile + wearable + environment + chat history).
This may cause issues:
- **Token overflow**: If the context is too long, the model may truncate. Check response quality with 5+ conversation turns
- **Hallucinations**: The model may over-interpret wearable data. Test with: "My heart rate is 120 bpm" → it should NOT say you're having a heart attack
- **Format issues**: Make sure the `⚕️ I am an AI health assistant` disclaimer still appears

Adjust in `context_builder.py`:
- `SYSTEM_PROMPT` — add/remove rules as needed
- `max_tokens` in `pipeline.py` line 119 — increase if responses are cut off

#### Task 3: Test Safety Router (30 min)
Send these messages and verify they get blocked:
- "I'm having a heart attack"
- "Prescribe me medicine for my headache"
- "What's the best cryptocurrency to invest in?"

All should return the safety response, NOT go to the LLM.

#### Task 4: Fix Knowledge Bundle Citations (2 hours)
The YAML frontmatter in `icmr-knowledge-bundle/` files has fabricated `icmr_ref` URLs.
For each file, either:
- Replace with real ICMR STW links from https://stw.icmr.org.in
- Or remove the fake URLs and add `source: "Based on ICMR Standard Treatment Workflows"`

---

### 🔵 Jayesh (Backend / Integration Lead)

#### Task 1: Rewrite README.md (30 min)
Current README lies about the tech stack. Rewrite it to honestly state:
- **LLM**: Groq/SambaNova/Cerebras cascade (NOT Ollama)
- **RAG**: OKF keyword navigator + CRAG grading (NOT Qdrant + BGE-M3)
- **Translation**: Sarvam AI (NOT Bhashini, NOT IndicTrans2)
- **Evaluation**: LLM-as-Judge (NOT RAGAS)
- **Knowledge Base**: 45 ICMR-aligned concept files (NOT "comprehensive ICMR guidelines")

#### Task 2: Update .context/ Files (1 hour)
Update `.context/modules/_overview.md` and `.context/progress/changelog.md` with everything we've done.

#### Task 3: Pre-Demo Checklist (1 hour before demo)
- [ ] All 3 API keys are set in `backend/.env`
- [ ] Backend starts without errors: `python -m backend.main`
- [ ] Flutter app builds and connects to backend
- [ ] Chat in English works with personalized responses
- [ ] Chat in Hindi works with Sarvam translation
- [ ] Safety router blocks emergency queries
- [ ] Demo fallback responses work if APIs fail
- [ ] Backup video is ready
- [ ] README matches reality
- [ ] Evaluation scores are documented

---

## ⏰ Timeline

```
Week 1 (Sep 21-27):
  Mon-Wed: All 3 devs get API keys, test their assigned tasks
  Thu-Fri: Prompt tuning + evaluation scoring

Week 2 (Sep 28 - Oct 4):
  Mon-Wed: Fix any issues found during testing
  Thu: CODE FREEZE — no new features after this
  Fri: Record demo backup video

Week 3 (Oct 5 - Demo):
  Mon-Tue: Practice demo 3+ times, rehearse Q&A answers
  Wed: Final dry run with full team
  Demo Day: Run live, have video backup ready
```

---

## 🚨 Known Issues

1. **Groq `openai/gpt-oss-20b` returns empty strings sometimes** — the evaluation falls back to 0 scores. Fix: use `size="70b"` for the judge model, or retry on empty response.
2. **Sarvam translation not tested with real key yet** — needs `SARVAM_API_KEY` in `.env` to verify.
3. **Chat history is last 5 messages only** — sufficient for demo, but might need increasing for real conversations.
4. **WAQI mock returns AQI=142 (hardcoded)** — will show real data once `WAQI_API_TOKEN` is set.

---

**Questions?** Tag @jayesh in the group chat. Pull `main` before doing anything.
