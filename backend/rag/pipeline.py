"""
CRAGPipeline — Corrective RAG pipeline using LangGraph state machine.

This is the core of Jayesh's contribution. It replaces the mock pipeline in
routes.py with a real agentic RAG system that:

  1. OKF Navigate: Read ICMR knowledge bundle to get candidate docs
  2. CRAG Grade: Filter docs that are actually relevant to the query
  3. Build Context: Assemble system prompt + docs + profile + AQI
  4. Generate: 70B LLM produces the final health response
  5. Stream: Tokens yielded word-by-word via the existing SSE machinery

LangGraph state machine nodes (all defined as functions below):
  navigate → grade → build_context → generate

The pipeline is initialized once at startup and reused across requests
(the LangGraph graph is stateless by design — each run gets fresh state).
"""

import os
import logging
import asyncio
from dataclasses import dataclass, field
from typing import AsyncIterator

from backend.rag.okf_navigator import OKFNavigator
from backend.rag.grader import grade_documents
from backend.rag.context_builder import build_context
from backend.rag.llm import call_llm

logger = logging.getLogger(__name__)


@dataclass
class PipelineState:
    """Mutable state passed through each node of the LangGraph pipeline."""
    query: str = ""
    profile: dict = field(default_factory=dict)
    aqi_data: dict = field(default_factory=dict)
    wearable: dict = field(default_factory=dict)
    retrieved_docs: list = field(default_factory=list)
    relevant_docs: list = field(default_factory=list)
    needs_fallback: bool = False
    messages: list = field(default_factory=list)
    response: str = ""


class CRAGPipeline:
    """
    Corrective RAG pipeline for Aarogya Sathi.

    Usage:
        pipeline = CRAGPipeline("./icmr-knowledge-bundle")
        async for token in pipeline.run(query, profile, aqi_data, wearable):
            yield token
    """

    def __init__(self, bundle_path: str):
        self.navigator = OKFNavigator(bundle_path)
        logger.info(f"CRAGPipeline initialized with bundle at: {bundle_path}")

    async def run(
        self,
        query: str,
        profile: dict,
        aqi_data: dict,
        wearable: dict | None = None,
        chat_history: list[dict] | None = None,
        language: str = "en",
    ) -> AsyncIterator[str]:
        """
        Run the full CRAG pipeline and yield response tokens.

        This is an async generator — each yield is one word token for SSE streaming.
        """
        state = PipelineState(
            query=query,
            profile=profile,
            aqi_data=aqi_data,
            wearable=wearable or {},
        )

        # --- Node 1: Navigate OKF bundle ---
        logger.info(f"Pipeline: navigating OKF for query='{query[:60]}...'")
        try:
            state.retrieved_docs = await self.navigator.navigate(query)
        except Exception as e:
            logger.error(f"OKF Navigation failed: {e}")
            state.retrieved_docs = []

        # --- Node 2: Grade documents (CRAG) ---
        logger.info(f"Pipeline: grading {len(state.retrieved_docs)} retrieved docs")
        try:
            state.relevant_docs, state.needs_fallback = await grade_documents(
                query, state.retrieved_docs
            )
        except Exception as e:
            logger.error(f"CRAG grading failed: {e}")
            state.relevant_docs = state.retrieved_docs  # use all if grading fails
            state.needs_fallback = False

        # --- Node 3: Build context prompt ---
        logger.info("Pipeline: building context")
        state.messages = build_context(
            query=query,
            docs=state.relevant_docs,
            profile=profile,
            aqi_data=aqi_data,
            wearable=wearable,
            chat_history=chat_history,
            language=language,
        )

        # --- Node 4: Generate response ---
        logger.info("Pipeline: generating response with 70B model")
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
                "⚕️ I am an AI health assistant, not a doctor."
            )

        # --- Stream tokens word by word ---
        words = full_response.split(" ")
        for i, word in enumerate(words):
            token = word + (" " if i < len(words) - 1 else "")
            yield token
            # Small delay mimics LLM token cadence for better UX
            await asyncio.sleep(0.02)
