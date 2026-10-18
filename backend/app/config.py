"""Runtime settings, all read from the environment (see .env.example)."""

from __future__ import annotations

import os
from functools import lru_cache

from pydantic import BaseModel


class Settings(BaseModel):
    google_cloud_project: str | None = None
    google_cloud_location: str = "global"
    gemini_model: str = "gemini-3.8-flash"
    mock_gemini: bool = False
    confirm_threshold: float = 0.7
    undo_window: int = 10
    timezone: str = "Asia/Kolkata"
    scheduler_token: str | None = None  # X-Scheduler-Token for POST /auto-restock/run
    store: str = "memory"  # firestore | memory
    firestore_database: str = "(default)"
    forecast_source: str = "local"  # bigquery | local
    bq_dataset: str = "kirana"
    bq_location: str = "asia-south1"
    data_dir: str = os.path.join(os.path.dirname(os.path.dirname(os.path.dirname(__file__))), "data")

    @classmethod
    def from_env(cls) -> "Settings":
        mock = os.getenv("MOCK_GEMINI", "0").lower()
        return cls(
            google_cloud_project=os.getenv("GOOGLE_CLOUD_PROJECT") or None,
            google_cloud_location=os.getenv("GOOGLE_CLOUD_LOCATION", "global"),
            gemini_model=os.getenv("GEMINI_MODEL", "gemini-3.8-flash"),
            mock_gemini=os.getenv("MOCK_GEMINI", "0").lower() in {"1", "true", "yes"},
            confirm_threshold=float(os.getenv("CONFIRM_THRESHOLD", "0.7")),
            scheduler_token=os.getenv("SCHEDULER_TOKEN") or None,
            store=(os.getenv("STORE") or ("firestore" if os.getenv("GOOGLE_CLOUD_PROJECT") else "memory")).lower(),
            firestore_database=os.getenv("FIRESTORE_DATABASE", "(default)"),
            forecast_source=os.getenv(
                "FORECAST_SOURCE",
                "bigquery" if os.getenv("GOOGLE_CLOUD_PROJECT") and mock not in {"1", "true", "yes"}
                else "local",
            ).lower(),
            bq_dataset=os.getenv("BQ_DATASET", "kirana"),
            bq_location=os.getenv("BQ_LOCATION", "asia-south1"),
            data_dir=os.getenv("DATA_DIR") or cls.model_fields["data_dir"].default,
        )


@lru_cache
def get_settings() -> Settings:
    # Load a local .env if present, without overriding real env vars.
    env_path = os.path.join(os.path.dirname(os.path.dirname(__file__)), ".env")
    if os.path.exists(env_path):
        with open(env_path, encoding="utf-8") as fh:
            for line in fh:
                line = line.strip()
                if not line or line.startswith("#") or "=" not in line:
                    continue
                key, _, value = line.partition("=")
                os.environ.setdefault(key.strip(), value.strip().strip('"').strip("'"))
    return Settings.from_env()
