from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
import logging

# Configure logging so all modules emit visible output during development
logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s | %(name)s | %(levelname)s | %(message)s"
)

app = FastAPI(title="Aarogya Sathi API", version="1.0.0")

# Allow all origins during development — Flutter app on Android emulator
# connects via 10.0.2.2 which maps to host localhost
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_methods=["*"],
    allow_headers=["*"],
)

@app.get("/")
async def root():
    """Root endpoint — confirms the API is running."""
    return {"success": True, "data": {"service": "Aarogya Sathi API", "version": "1.0.0", "docs": "/docs"}}


@app.get("/api/health")
async def health_check():
    """Simple health check endpoint for monitoring and Flutter connectivity test."""
    return {"success": True, "data": {"status": "ok", "model": "llama3.1-8b"}}


# Import routes after app creation to avoid circular imports
from backend.api.routes import router  # noqa: E402
app.include_router(router, prefix="/api")
