"""
CRAG Relevance Grader.

For each document retrieved by the OKF Navigator, ask the 8B model a simple
yes/no question: "Does this document contain information useful for answering
the query?"

If ALL docs are irrelevant → set needs_fallback=True so the pipeline can
switch to a simpler response or web search.

Uses the 8B model here (not 70B) because this is a binary classification
task — fast and cheap. Runs docs in parallel via asyncio.gather.
"""

import asyncio
import logging
from backend.rag.llm import call_llm

logger = logging.getLogger(__name__)


async def _grade_one(query: str, doc: dict) -> tuple[dict, bool]:
    """Grade a single document for relevance to the query."""
    prompt = f"""Does the following document contain information useful for answering the user's health query?

Document title: {doc['title']}
Document content (excerpt):
{doc['content'][:800]}

User query: "{query}"

Answer with ONLY "yes" or "no"."""

    try:
        answer = await call_llm(
            messages=[{"role": "user", "content": prompt}],
            size="70b",
            temperature=0.0,
            max_tokens=5,
        )
        is_relevant = answer.strip().lower().startswith("yes")
        logger.debug(f"Graded '{doc['title']}': {'relevant' if is_relevant else 'not relevant'}")
        return doc, is_relevant
    except Exception as e:
        # If grading fails, assume relevant to avoid blocking the pipeline
        logger.warning(f"Grading failed for '{doc['title']}': {e} — assuming relevant")
        return doc, True


async def grade_documents(
    query: str, docs: list[dict]
) -> tuple[list[dict], bool]:
    """
    Grade all retrieved docs in parallel.

    Returns:
        (relevant_docs, needs_fallback)
        needs_fallback is True when no docs are relevant.
    """
    if not docs:
        return [], True

    # Grade docs sequentially with a small delay to respect rate limits
    results = []
    for doc in docs:
        result = await _grade_one(query, doc)
        results.append(result)
        await asyncio.sleep(0.3)  # respect Groq free-tier rate limit

    relevant_docs = [doc for doc, is_relevant in results if is_relevant]
    needs_fallback = len(relevant_docs) == 0

    if needs_fallback:
        logger.info("CRAG: No relevant docs found — pipeline will use fallback response")
    else:
        logger.info(f"CRAG: {len(relevant_docs)}/{len(docs)} docs are relevant")

    return relevant_docs, needs_fallback
