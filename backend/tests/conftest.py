import pytest
from fastapi.testclient import TestClient

from app.config import Settings
from app.gemini import MockExtractor
from app.main import create_app
from app.models import Entities, ExtractedItem, Extraction, ShelfItem, ShelfScan
from app.store import InMemoryRepository


class ScriptedExtractor:
    """Returns pre-canned Extractions so tests never touch Gemini."""

    model = "scripted"

    def __init__(self) -> None:
        self.queue: list[Extraction] = []
        self.calls: list[tuple[str | None, bytes | None]] = []

    def push(self, **kw) -> Extraction:
        ent = kw.pop("entities", {})
        ext = Extraction(
            intent=kw.pop("intent"),
            confidence=kw.pop("confidence", 0.9),
            language=kw.pop("language", "hi-Latn"),
            transcript=kw.pop("transcript", None),
            reply_text=kw.pop("reply_text", "Samjha."),
            entities=Entities(
                items=[ExtractedItem(**i) for i in ent.get("items", [])],
                customer_name=ent.get("customer_name"),
                amount=ent.get("amount"),
                date=ent.get("date"),
            ),
        )
        self.queue.append(ext)
        return ext

    def extract(self, text, audio, catalogue, shop_language):
        self.calls.append((text, audio[0] if audio else None))
        return self.queue.pop(0)

    def push_scan(self, items: list[tuple[str, int, float]], reply_text="Shelf pe dikha: ...") -> ShelfScan:
        scan = ShelfScan(items=[ShelfItem(name=n, count=c, confidence=cf) for n, c, cf in items],
                         reply_text=reply_text)
        self.queue.append(scan)
        return scan

    def scan_shelf(self, image, catalogue, shop_language):
        self.calls.append((None, image[0]))
        return self.queue.pop(0)

    summary_text: str | None = None  # None -> raise, so the template fallback is exercised

    def summarize(self, facts, shop_language):
        from app.gemini import GeminiFailed

        self.calls.append(("summary", facts))
        if self.summary_text is None:
            raise GeminiFailed("scripted failure")
        return self.summary_text

    transcript: str = "Forecast screen thoda slow hai"

    def transcribe(self, audio, shop_language):
        self.calls.append(("transcribe", audio[0]))
        return self.transcript


class RecordingSink:
    name = "recording"

    def __init__(self) -> None:
        self.sent = []

    def send(self, fb):
        self.sent.append(fb)


import os


def _store_params():
    """memory always; firestore too when an emulator or FIRESTORE_INTEGRATION=1 is available."""
    params = ["memory"]
    if os.getenv("FIRESTORE_EMULATOR_HOST") or os.getenv("FIRESTORE_INTEGRATION") == "1":
        params.append("firestore")
    return params


@pytest.fixture(params=_store_params())
def repo(request):
    if request.param == "firestore":
        from app.config import get_settings
        from app.store_firestore import FirestoreRepository

        settings = get_settings()
        project = os.getenv("GOOGLE_CLOUD_PROJECT") or settings.google_cloud_project or "demo-kirana"
        # a separate root collection keeps test shops out of the production "shops" collection
        return FirestoreRepository(project=project, database=settings.firestore_database,
                                   root="shops_test", undo_window=10)
    return InMemoryRepository(undo_window=10)


@pytest.fixture
def scripted():
    return ScriptedExtractor()


@pytest.fixture
def client(repo, scripted):
    from app.forecast import LocalForecastSource

    settings = Settings(mock_gemini=True, forecast_source="local", scheduler_token="test-token")
    app = create_app(settings, repo=repo, extractor=scripted,
                     forecast_source=LocalForecastSource(settings.data_dir),
                     feedback_sink=RecordingSink())
    return TestClient(app)


@pytest.fixture
def mock_client(repo):
    app = create_app(Settings(mock_gemini=True), repo=repo, extractor=MockExtractor())
    return TestClient(app)


@pytest.fixture
def shop_id(client):
    r = client.post("/shops", json={"shop_name": "Gupta General Store",
                                    "owner_name": "Ramesh Gupta", "language": "hi-Latn"})
    assert r.status_code == 201, r.text
    return r.json()["shop_id"]
