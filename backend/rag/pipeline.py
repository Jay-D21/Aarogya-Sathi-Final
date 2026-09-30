"""
Agentic RAG Pipeline for Aarogya Sathi.

Combines:
1. Fast Intent Classification (greeting, vital_check, aqi_query, health_query)
2. Selective Tool Execution (search_knowledge, analyze_vitals, get_environmental_data)
3. Proactive Health Insights & Ambient Alerts (vital thresholds, AQI advisory)
4. Per-User Session Memory tracking across multi-turn interactions
5. Streaming token generation via Server-Sent Events (SSE)
"""

import os
import logging
import asyncio
from dataclasses import dataclass, field
from typing import AsyncIterator, Dict, List, Optional, Any

from backend.rag.okf_navigator import OKFNavigator
from backend.rag.grader import grade_documents
from backend.rag.context_builder import build_context
from backend.rag.llm import call_llm
from backend.rag.intent import classify_intent
from backend.rag.insights import generate_proactive_insights
from backend.rag.tools import tool_search_knowledge, tool_analyze_vitals, tool_get_environmental_data
from backend.memory.session import UserSession

logger = logging.getLogger(__name__)


@dataclass
class AgentState:
    """Working state for an agentic turn."""
    query: str = ""
    intent: str = "health_query"
    profile: Dict[str, Any] = field(default_factory=dict)
    aqi_data: Dict[str, Any] = field(default_factory=dict)
    wearable: Dict[str, Any] = field(default_factory=dict)
    docs: List[Dict[str, Any]] = field(default_factory=list)
    insights: List[str] = field(default_factory=list)
    messages: List[Dict[str, str]] = field(default_factory=list)
    response: str = ""


class CRAGPipeline:
    """
    Agentic Corrective RAG (CRAG) Pipeline for Aarogya Sathi.
    """

    def __init__(self, bundle_path: str):
        self.navigator = OKFNavigator(bundle_path)
        logger.info(f"Agentic CRAGPipeline initialized with bundle at: {bundle_path}")

    async def run(
        self,
        query: str,
        profile: dict,
        aqi_data: dict,
        wearable: dict | None = None,
        chat_history: list[dict] | None = None,
        language: str = "en",
        session: Optional[UserSession] = None,
    ) -> AsyncIterator[str]:
        """
        Run the agentic workflow and yield response tokens word-by-word.
        """
        wearable = wearable or {}
        profile = profile or {}
        aqi_data = aqi_data or {}

        # 1. Classify Intent
        intent = await classify_intent(query)
        logger.info(f"Agent turn intent: '{intent}' for query: '{query[:50]}'")

        state = AgentState(
            query=query,
            intent=intent,
            profile=profile,
            aqi_data=aqi_data,
            wearable=wearable,
        )

        # 2. Update Session Memory if active
        if session:
            session.update_profile(profile)
            session.record_vitals(wearable)

        # 3. Compute Proactive Insights
        vital_hist = session.vital_history if session else None
        state.insights = generate_proactive_insights(profile, wearable, aqi_data, vital_hist)

        # 4. Route Actions Based on Intent
        if intent == "greeting":
            # Fast-path for greetings: skip document retrieval entirely
            lang_greeting = {
                "hi": "नमस्ते! मैं आरोग्य साथी हूँ, आपका स्वास्थ्य मित्र। आज मैं आपकी क्या सहायता कर सकता हूँ?",
                "mr": "नमस्कार! मी आरोग्य साथी आहे, आपला आरोग्य मित्र. आज मी आपल्याला कशी मदत करू शकतो?",
                "en": "Hello! I am Aarogya Sathi, your digital health companion. How can I assist you with your health and wellness today?",
            }
            greeting_text = lang_greeting.get(language, lang_greeting["en"])
            greeting_text += "\n\n⚕️ I am an AI health assistant, not a doctor."

            for word in greeting_text.split(" "):
                yield word + " "
                await asyncio.sleep(0.01)

            if session:
                session.add_turn(query, greeting_text)
            return

        elif intent == "vital_check":
            # Prioritize wearable vitals analysis
            logger.info("Executing vital_check tool analysis")
            state.docs = []  # Vitals inquiries usually don't need clinical disease monographs

        elif intent == "aqi_query":
            # Prioritize environmental & respiratory health analysis
            logger.info("Executing aqi_query environmental analysis")
            try:
                state.docs = await tool_search_knowledge("air quality pollution aqi respiratory health", self.navigator)
            except Exception as e:
                logger.error(f"AQI knowledge search failed: {e}")
                state.docs = []

        else:
            # Default health_query / lifestyle: execute full OKF search and CRAG grading
            logger.info("Executing full OKF knowledge search and grading")
            try:
                state.docs = await tool_search_knowledge(query, self.navigator)
            except Exception as e:
                logger.error(f"OKF knowledge search failed: {e}")
                state.docs = []

        # 5. Build Context with Session Context and Proactive Insights
        session_summary = session.get_summary_context() if session else None
        state.messages = build_context(
            query=query,
            docs=state.docs,
            profile=profile,
            aqi_data=aqi_data,
            wearable=wearable,
            chat_history=chat_history,
            language=language,
            insights=state.insights,
            session_summary=session_summary,
        )

        # 6. Generate Response with 70B Model
        logger.info(f"Agent generating response with 70B model (docs={len(state.docs)}, insights={len(state.insights)})")
        try:
            full_response = await call_llm(
                messages=state.messages,
                size="70b",
                temperature=0.3,
                max_tokens=400,
            )
        except Exception as e:
            logger.error(f"LLM generation failed: {e}")
            full_response = (
                "I'm having trouble connecting to the AI service right now. "
                "Please try again in a moment. For urgent health concerns, "
                "please call your doctor or 112 for emergencies. "
                "\n\n⚕️ I am an AI health assistant, not a doctor."
            )

        # 7. Update Session Memory with Dialogue Turn
        if session:
            session.add_turn(query, full_response)

        # 8. Stream Response Tokens
        words = full_response.split(" ")
        for i, word in enumerate(words):
            token = word + (" " if i < len(words) - 1 else "")
            yield token
            await asyncio.sleep(0.015)
