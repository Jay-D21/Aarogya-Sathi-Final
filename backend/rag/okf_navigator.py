"""
OKF Navigator — deterministic LLM-driven knowledge retrieval.

Instead of probabilistic vector similarity search, this agent reads the
icmr-knowledge-bundle like a wiki:
  1. Read root index.md to see all available categories
  2. Ask 8B LLM which files are relevant to the user's query
  3. Read those files and follow their markdown hyperlinks (depth ≤ 2)
  4. Return collected concept docs with full content

Why this approach:
- Medical info needs exact dosage tables and diagnostic criteria — chunking
  breaks these structures. Whole-file retrieval preserves them.
- Every retrieved doc is human-readable and auditable (no black-box vectors).
- Cross-condition links (diabetes → AQI impact) are captured via hyperlinks.
"""

import os
import re
import logging
from pathlib import Path
from backend.rag.llm import call_llm

logger = logging.getLogger(__name__)


class OKFNavigator:
    """Navigates the ICMR OKF knowledge bundle to retrieve relevant docs."""

    def __init__(self, bundle_path: str):
        self.bundle_path = Path(bundle_path)
        # Cap docs to keep context window manageable (~3000 tokens for docs)
        self.max_initial_files = 3
        self.max_linked_files = 3
        self.max_content_chars = 1500  # truncate each doc to this length

    async def navigate(self, query: str) -> list[dict]:
        """
        Entry point: navigate bundle and return list of relevant concept docs.

        Returns:
            List of dicts: {path, title, content, depth}
        """
        visited: set[str] = set()
        collected: list[dict] = []

        # Step 1: Read root index
        root_index = self._read_file("index.md")
        if not root_index:
            logger.error("OKF root index.md not found — check OKF_BUNDLE_PATH")
            return []

        # Step 2: Ask LLM which files to start from
        initial_paths = await self._pick_files(query, root_index)
        logger.info(f"OKF Navigator picked initial files: {initial_paths}")

        # Step 3: Read initial files + follow links up to depth 2
        for file_path in initial_paths[: self.max_initial_files]:
            await self._traverse(
                file_path, query, visited, collected, depth=0, max_depth=2
            )

        logger.info(f"OKF Navigator collected {len(collected)} docs for query")
        return collected

    async def _traverse(
        self,
        file_path: str,
        query: str,
        visited: set,
        collected: list,
        depth: int,
        max_depth: int,
    ):
        """Recursively read a file and follow its markdown links."""
        # Normalise path separators
        norm_path = file_path.replace("\\", "/")
        if norm_path in visited:
            return
        visited.add(norm_path)

        content = self._read_file(norm_path)
        if not content:
            return

        title = self._extract_title(content)
        collected.append({
            "path": norm_path,
            "title": title,
            "content": content[: self.max_content_chars],
            "depth": depth,
        })

        # Follow markdown links only if we can go deeper AND haven't hit cap
        if depth < max_depth and len(collected) < (
            self.max_initial_files + self.max_linked_files
        ):
            links = self._extract_links(content, norm_path)
            for link in links:
                await self._traverse(
                    link, query, visited, collected, depth + 1, max_depth
                )

    async def _pick_files(self, query: str, index_content: str) -> list[str]:
        """Ask 8B LLM to identify which files answer the query."""
        prompt = f"""You are a medical knowledge navigator. Given the knowledge base index below, identify which concept files are most relevant to the user's health query.

Knowledge Base Index:
{index_content}

User Query: "{query}"

Return ONLY the file paths (relative to the bundle root), one per line, most relevant first. Return at most 3 paths. Do not add any explanation."""

        try:
            response = await call_llm(
                messages=[{"role": "user", "content": prompt}],
                size="8b",
                temperature=0.0,   # deterministic — same query → same files
                max_tokens=150,
            )
            paths = [
                line.strip().lstrip("./").lstrip("-").strip()
                for line in response.splitlines()
                if line.strip() and ".md" in line
            ]
            return paths
        except Exception as e:
            logger.warning(f"OKF file picker LLM call failed: {e} — using fallback")
            # Fallback: scan index for condition keywords in the query
            return self._keyword_fallback(query, index_content)

    def _keyword_fallback(self, query: str, index_content: str) -> list[str]:
        """Simple keyword match when LLM is unavailable."""
        query_lower = query.lower()
        keywords = {
            # Conditions
            "diabetes": "conditions/diabetes-type2.md",
            "sugar": "conditions/diabetes-type2.md",
            "hba1c": "conditions/diabetes-type2.md",
            "hypertension": "conditions/hypertension.md",
            "blood pressure": "conditions/hypertension.md",
            "bp ": "conditions/hypertension.md",
            "asthma": "conditions/asthma.md",
            "wheez": "conditions/asthma.md",
            "inhaler": "conditions/asthma.md",
            "obesity": "conditions/obesity.md",
            "bmi": "conditions/obesity.md",
            "overweight": "conditions/obesity.md",
            "weight": "conditions/obesity.md",
            "copd": "conditions/copd.md",
            "chulha": "conditions/copd.md",
            "thyroid": "conditions/thyroid-disorders.md",
            "tsh": "conditions/thyroid-disorders.md",
            "anemia": "conditions/anemia.md",
            "anaemia": "conditions/anemia.md",
            "iron": "conditions/anemia.md",
            "hemoglobin": "conditions/anemia.md",
            "heart attack": "conditions/coronary-artery-disease.md",
            "coronary": "conditions/coronary-artery-disease.md",
            "chest pain": "emergency/chest-pain.md",
            "dengue": "conditions/dengue.md",
            "platelet": "conditions/dengue.md",
            "tuberculosis": "conditions/tuberculosis.md",
            "tb ": "conditions/tuberculosis.md",
            "dots": "conditions/tuberculosis.md",
            "kidney": "conditions/ckd.md",
            "creatinine": "conditions/ckd.md",
            "gfr": "conditions/ckd.md",
            "dialysis": "conditions/ckd.md",
            # Drugs
            "metformin": "drugs/metformin.md",
            "amlodipine": "drugs/amlodipine.md",
            "atenolol": "drugs/atenolol.md",
            "beta blocker": "drugs/atenolol.md",
            "insulin": "drugs/insulin.md",
            "glimepiride": "drugs/glimepiride.md",
            "aspirin": "drugs/aspirin.md",
            "paracetamol": "drugs/paracetamol.md",
            "crocin": "drugs/paracetamol.md",
            "fever": "drugs/paracetamol.md",
            # Lifestyle
            "diet": "lifestyle/diet-diabetes.md",
            "food": "lifestyle/diet-diabetes.md",
            "exercise": "lifestyle/exercise-guidelines.md",
            "walk": "lifestyle/exercise-guidelines.md",
            "yoga": "lifestyle/stress-management.md",
            "sleep": "lifestyle/sleep-hygiene.md",
            "insomnia": "lifestyle/sleep-hygiene.md",
            "stress": "lifestyle/stress-management.md",
            "anxiety": "lifestyle/stress-management.md",
            "smoking": "lifestyle/smoking-cessation.md",
            "gutka": "lifestyle/smoking-cessation.md",
            "tobacco": "lifestyle/smoking-cessation.md",
            "water": "lifestyle/hydration.md",
            "dehydrat": "lifestyle/hydration.md",
            "ors": "lifestyle/hydration.md",
            # Emergency
            "hypoglycemia": "emergency/hypoglycemia.md",
            "low sugar": "emergency/hypoglycemia.md",
            "stroke": "emergency/stroke-signs.md",
            "face droop": "emergency/stroke-signs.md",
            "allergic": "emergency/severe-allergic-reaction.md",
            "anaphylaxis": "emergency/severe-allergic-reaction.md",
            "heatstroke": "emergency/heatstroke.md",
            "heat stroke": "emergency/heatstroke.md",
            "snake": "emergency/snake-bite.md",
            "bite": "emergency/snake-bite.md",
            # Environmental
            "aqi": "environmental/aqi-health-impact.md",
            "pollution": "environmental/aqi-health-impact.md",
            "smog": "environmental/winter-respiratory.md",
            "heat wave": "environmental/heat-health.md",
            "heatwave": "environmental/heat-health.md",
            "summer": "environmental/heat-health.md",
            "monsoon": "environmental/monsoon-diseases.md",
            "rain": "environmental/monsoon-diseases.md",
            "malaria": "environmental/monsoon-diseases.md",
            "winter": "environmental/winter-respiratory.md",
        }
        matched = []
        for kw, path in keywords.items():
            if kw in query_lower and path not in matched:
                matched.append(path)
        return matched or ["conditions/diabetes-type2.md"]  # sane default

    def _read_file(self, relative_path: str) -> str | None:
        """Read a file from the bundle, return None if not found."""
        full_path = self.bundle_path / relative_path
        if full_path.exists():
            try:
                return full_path.read_text(encoding="utf-8")
            except Exception as e:
                logger.warning(f"Could not read OKF file {full_path}: {e}")
        return None

    def _extract_links(self, content: str, current_path: str) -> list[str]:
        """
        Extract markdown hyperlinks to other .md files in the bundle.

        Links like [Metformin](../drugs/metformin.md) are resolved relative
        to the current file's directory.
        """
        pattern = r'\[.*?\]\(([^)]+\.md)\)'
        raw_links = re.findall(pattern, content)

        current_dir = Path(current_path).parent
        resolved = []
        for link in raw_links:
            # Skip external links
            if link.startswith("http"):
                continue
            # Resolve relative path
            resolved_path = (current_dir / link).as_posix()
            # Normalise away leading ./
            resolved_path = re.sub(r"^\./", "", resolved_path)
            resolved.append(resolved_path)

        return resolved

    def _extract_title(self, content: str) -> str:
        """Extract the first H1 heading as the document title."""
        for line in content.splitlines():
            if line.startswith("# "):
                return line[2:].strip()
        return "Unknown"
