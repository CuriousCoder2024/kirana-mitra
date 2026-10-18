# Cloud Run image for the Kirana Mitra backend (Phase 6 deploy; not deployed yet).
FROM python:3.12-slim AS base
COPY --from=ghcr.io/astral-sh/uv:0.13.1 /uv /uvx /bin/

WORKDIR /srv
ENV UV_COMPILE_BYTECODE=1 UV_LINK_MODE=copy UV_PROJECT_ENVIRONMENT=/srv/.venv

COPY pyproject.toml uv.lock ./
RUN uv sync --frozen --no-dev

COPY app ./app

ENV PATH="/srv/.venv/bin:$PATH" PORT=8080 GOOGLE_GENAI_USE_VERTEXAI=true
EXPOSE 8080
# Cloud Run sets $PORT; ADC comes from the service account at runtime.
CMD ["sh", "-c", "uvicorn app.main:app --host 0.0.0.0 --port ${PORT}"]
