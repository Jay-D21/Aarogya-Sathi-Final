# === Build stage ===
FROM python:3.11-slim AS builder

WORKDIR /app

# Install system deps for building Python packages
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

COPY backend/requirements.txt .
RUN pip install --no-cache-dir --prefix=/install -r requirements.txt

# === Runtime stage ===
FROM python:3.11-slim

WORKDIR /app

# Copy installed Python packages from builder
COPY --from=builder /install /usr/local

# Copy application code
COPY backend/ ./backend/
COPY icmr-knowledge-bundle/ ./icmr-knowledge-bundle/

# Default OKF bundle path inside the container
ENV OKF_BUNDLE_PATH=./icmr-knowledge-bundle
ENV PYTHONUNBUFFERED=1

# Render assigns a dynamic PORT — uvicorn must listen on it
# Default to 8000 for local development
ENV PORT=8000

EXPOSE ${PORT}

# Health check for Render
HEALTHCHECK --interval=30s --timeout=5s --retries=3 \
    CMD python -c "import urllib.request; urllib.request.urlopen('http://localhost:${PORT}/api/health')" || exit 1

# Run the FastAPI app — Render injects PORT env var at runtime
CMD uvicorn backend.main:app --host 0.0.0.0 --port ${PORT}
