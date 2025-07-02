from fastapi import APIRouter, Depends, HTTPException, status
from pydantic import BaseModel
from pathlib import Path
from datetime import datetime
import yaml, litellm, os, asyncpg

# ── Auth dependency ────────────────────────────────────────────────────────────
from app.auth import get_current_user    # <- validates JWT and returns its claims

router = APIRouter()

# ── 1. Load model list from YAML ───────────────────────────────────────────────
CONFIG_PATH = Path(__file__).parent.parent.parent / "litellm_config.yaml"
with CONFIG_PATH.open() as f:
    cfg = yaml.safe_load(f)

model_list = cfg.get("model_list", [])
if not model_list:
    raise RuntimeError(f"No model_list in {CONFIG_PATH}")

llm_router = litellm.Router(model_list=model_list)

# ── 2. Initialise a global asyncpg pool (lazy) ────────────────────────────────
PG_URL = os.getenv("DATABASE_URL")          # must be set in env vars / ECS task
DB_POOL: asyncpg.Pool | None = None         # type hint for IDEs


async def get_pool() -> asyncpg.Pool:
    global DB_POOL
    if DB_POOL is None:
        if not PG_URL:
            raise RuntimeError("DATABASE_URL is not configured")
        DB_POOL = await asyncpg.create_pool(PG_URL, min_size=1, max_size=5)
    return DB_POOL


async def save_report(user_id: str, tenant: str, summary: str):
    pool = await get_pool()
    async with pool.acquire() as conn:
        await conn.execute(
            """
            INSERT INTO reports (user_id, tenant, summary)
            VALUES ($1, $2, $3)
            """,
            user_id,
            tenant,
            summary,
        )


# ── 3. Pydantic models ────────────────────────────────────────────────────────
class ReportRequest(BaseModel):
    symptoms: list[str]


class ReportResponse(BaseModel):
    user_id: str
    tenant: str
    summary: str
    timestamp: datetime


# ── 4. The secured endpoint ───────────────────────────────────────────────────
@router.post(
    "/report",
    response_model=ReportResponse,
    status_code=status.HTTP_200_OK,
)
async def generate_report(
    data: ReportRequest,
    user=Depends(get_current_user),  # claims from JWT
):
    """
    • Summarises symptoms with an LLM
    • Tags the LiteLLM spend log with user/tenant
    • Persists the summary in Postgres
    """
    if "sub" not in user:
        raise HTTPException(
            status_code=400, detail="Token missing 'sub' claim"
        )

    prompt = f"Summarise these symptoms: {', '.join(data.symptoms)}"

    resp = await llm_router.acompletion(
        model="gpt-3.5-turbo",
        messages=[{"role": "user", "content": prompt}],
        metadata={
            "user_id": user["sub"],
            "tenant": user.get("tenant", "unknown"),
        },
    )

    summary = resp["choices"][0]["message"]["content"]

    # Persist to DB
    await save_report(user["sub"], user.get("tenant", "unknown"), summary)

    return ReportResponse(
        user_id=user["sub"],
        tenant=user.get("tenant", "unknown"),
        summary=summary,
        timestamp=datetime.utcnow(),
    )

