from pathlib import Path
import os, yaml

from fastapi import FastAPI, Request, HTTPException
import litellm
import uvicorn

# ------------------------------------------------------------
# 1.  Load router/model_list.yaml into a Python list
# ------------------------------------------------------------
BASE_DIR   = Path(__file__).parent
CONFIG_YML = BASE_DIR / "model_list.yaml"

with CONFIG_YML.open() as f:
    cfg = yaml.safe_load(f)

model_list = cfg.get("model_list", [])
if not model_list:
    raise RuntimeError(f"No `model_list` found in {CONFIG_YML}")

# ------------------------------------------------------------
# 2.  Create the Router from model list
# ------------------------------------------------------------
router = litellm.Router(model_list=model_list)

app = FastAPI()


@app.post("/chat")
async def chat(req: Request):
    data   = await req.json()
    prompt = data.get("prompt")
    model  = data.get("model", "gpt-3.5-turbo")     # alias or full ID

    if prompt is None:
        raise HTTPException(422, detail="`prompt` is required")

    try:
        resp = router.completion(
            model=model,
            messages=[{"role": "user", "content": prompt}],
        )
        return {"response": resp["choices"][0]["message"]["content"]}
    except Exception as exc:
        # surface provider errors to the caller
        return {"error": str(exc)}


if __name__ == "__main__":
    uvicorn.run("router.main:app", host="0.0.0.0", port=8000, reload=True)
