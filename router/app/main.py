from fastapi import FastAPI
from litellm.proxy.proxy_server import app as litellm_proxy
from prometheus_fastapi_instrumentator import Instrumentator
from app.api import reports

app = FastAPI(title="LLM Router + Custom API")

Instrumentator().instrument(app).expose(app)

# Existing LiteLLM proxy
app.mount("/v1", litellm_proxy)

app.include_router(reports.router, prefix="/api")

@app.get("/healthz")
def health():
    return {"status": "ok"}

