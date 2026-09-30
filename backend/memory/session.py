"""
Per-user session memory manager for Aarogya Sathi.

Provides stateful session tracking for personalized agent interactions:
- Longitudinal vital readings tracking (BP, heart rate, SpO2, sleep)
- Conversation history compression and summaries
- Local filesystem JSON persistence for zero-cost recovery across server reboots
"""

import os
import json
import logging
from datetime import datetime
from pathlib import Path
from typing import Any, Dict, List, Optional

logger = logging.getLogger(__name__)

# Base path for session persistence
_SESSION_DIR = Path(__file__).parent.parent / "data" / "sessions"
_SESSION_DIR.mkdir(parents=True, exist_ok=True)


class UserSession:
    """Represents a single user's persistent health assistant session."""

    def __init__(self, user_id: str, data: Optional[Dict[str, Any]] = None):
        self.user_id = user_id
        data = data or {}
        self.profile: Dict[str, Any] = data.get("profile", {})
        self.vital_history: List[Dict[str, Any]] = data.get("vital_history", [])
        self.chat_summary: str = data.get("chat_summary", "")
        self.recent_turns: List[Dict[str, str]] = data.get("recent_turns", [])
        self.last_active: str = data.get("last_active", datetime.utcnow().isoformat())

    def update_profile(self, profile_data: Dict[str, Any]) -> None:
        """Update static health profile (age, gender, chronic conditions)."""
        if profile_data:
            self.profile.update({k: v for k, v in profile_data.items() if v is not None})
            self.last_active = datetime.utcnow().isoformat()

    def record_vitals(self, wearable_data: Dict[str, Any]) -> None:
        """Record a snapshot of wearable vitals if meaningful readings are present."""
        if not wearable_data:
            return

        has_data = any(
            wearable_data.get(k) is not None
            for k in [
                "heart_rate_bpm",
                "spo2_percent",
                "bp_systolic",
                "blood_glucose_mg_dl",
                "today_steps",
            ]
        )
        if not has_data:
            return

        snapshot = {
            "timestamp": datetime.utcnow().isoformat(),
            **{k: v for k, v in wearable_data.items() if v is not None},
        }

        self.vital_history.append(snapshot)
        # Cap vital history to the last 20 snapshots to prevent unbounded growth
        if len(self.vital_history) > 20:
            self.vital_history = self.vital_history[-20:]
        self.last_active = datetime.utcnow().isoformat()

    def add_turn(self, user_message: str, ai_response: str) -> None:
        """Append a dialogue turn to session memory."""
        self.recent_turns.append({
            "timestamp": datetime.utcnow().isoformat(),
            "user": user_message,
            "assistant": ai_response,
        })
        # Keep last 10 turns in active short-term memory
        if len(self.recent_turns) > 10:
            self.recent_turns = self.recent_turns[-10:]
        self.last_active = datetime.utcnow().isoformat()

    def get_summary_context(self) -> str:
        """Generate a concise string representation of user health trends."""
        lines = []
        if self.profile:
            conds = self.profile.get("conditions", [])
            meds = self.profile.get("medications", [])
            if conds:
                lines.append(f"Known conditions: {', '.join(conds)}")
            if meds:
                lines.append(f"Current medications: {', '.join(meds)}")

        if self.vital_history:
            latest = self.vital_history[-1]
            v_bits = []
            if latest.get("heart_rate_bpm"):
                v_bits.append(f"HR: {latest['heart_rate_bpm']} bpm")
            if latest.get("spo2_percent"):
                v_bits.append(f"SpO2: {latest['spo2_percent']}%")
            if latest.get("bp_systolic") and latest.get("bp_diastolic"):
                v_bits.append(f"BP: {latest['bp_systolic']}/{latest['bp_diastolic']} mmHg")
            if latest.get("today_steps"):
                v_bits.append(f"Steps: {latest['today_steps']}")
            if v_bits:
                lines.append(f"Latest logged vitals: {', '.join(v_bits)}")

        if self.chat_summary:
            lines.append(f"Previous chat topics: {self.chat_summary}")

        return "\n".join(lines)

    def to_dict(self) -> Dict[str, Any]:
        return {
            "user_id": self.user_id,
            "profile": self.profile,
            "vital_history": self.vital_history,
            "chat_summary": self.chat_summary,
            "recent_turns": self.recent_turns,
            "last_active": self.last_active,
        }


class SessionManager:
    """Manages active in-memory user sessions with local file persistence."""

    def __init__(self):
        self._cache: Dict[str, UserSession] = {}

    def get_session(self, user_id: Optional[str]) -> UserSession:
        """Retrieve existing session or create and cache a new one."""
        uid = (user_id or "anonymous").strip() or "anonymous"

        if uid in self._cache:
            return self._cache[uid]

        # Attempt to load from disk
        file_path = _SESSION_DIR / f"{uid}.json"
        if file_path.exists():
            try:
                with open(file_path, "r", encoding="utf-8") as f:
                    data = json.load(f)
                    session = UserSession(uid, data)
                    self._cache[uid] = session
                    logger.info(f"Loaded existing session for user={uid} from disk")
                    return session
            except Exception as e:
                logger.warning(f"Could not load session for user={uid}: {e}")

        session = UserSession(uid)
        self._cache[uid] = session
        return session

    def save_session(self, session: UserSession) -> None:
        """Persist session state to disk asynchronously or on change."""
        self._cache[session.user_id] = session
        file_path = _SESSION_DIR / f"{session.user_id}.json"
        try:
            with open(file_path, "w", encoding="utf-8") as f:
                json.dump(session.to_dict(), f, ensure_ascii=False, indent=2)
        except Exception as e:
            logger.warning(f"Failed to persist session for {session.user_id}: {e}")


# Global singleton instance for application lifetime
session_manager = SessionManager()
