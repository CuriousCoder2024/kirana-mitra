"""Feedback sink: keep every piece of feedback in the repository and, when
BigQuery is configured, stream-insert it into `kirana.feedback` as well.
A BigQuery failure (table not created yet, no permission, network) is logged
and never fails the request."""

from __future__ import annotations

import logging
import threading
from dataclasses import asdict
from typing import Protocol

from app.store import FeedbackRecord

logger = logging.getLogger("kirana.feedback")


class FeedbackSink(Protocol):
    name: str

    def send(self, fb: FeedbackRecord) -> None: ...


class NullSink:
    name = "none"

    def send(self, fb: FeedbackRecord) -> None:
        return None


class BigQuerySink:
    """insert_rows_json into <project>.<dataset>.feedback, off the request thread."""

    name = "bigquery"

    def __init__(self, project: str, dataset: str, location: str, table: str = "feedback") -> None:
        from google.cloud import bigquery

        self.table_id = f"{project}.{dataset}.{table}"
        self._client = bigquery.Client(project=project, location=location)

    def send(self, fb: FeedbackRecord) -> None:
        row = asdict(fb)
        threading.Thread(target=self._insert, args=(row,), daemon=True).start()

    def _insert(self, row: dict) -> None:
        try:
            errors = self._client.insert_rows_json(self.table_id, [row], row_ids=[row["feedback_id"]])
            if errors:
                logger.warning("feedback insert into %s returned errors: %s", self.table_id, errors)
        except Exception as exc:  # table missing, auth, network: never surface to the client
            logger.warning("feedback insert into %s failed: %s: %s", self.table_id,
                           type(exc).__name__, str(exc)[:300])


def make_feedback_sink(settings) -> FeedbackSink:
    if settings.forecast_source == "bigquery" and settings.google_cloud_project:
        try:
            return BigQuerySink(settings.google_cloud_project, settings.bq_dataset,
                                settings.bq_location)
        except Exception as exc:
            logger.warning("BigQuery feedback sink unavailable: %s", exc)
    return NullSink()
