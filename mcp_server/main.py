from fastapi import FastAPI, Request
from pydantic import BaseModel
from typing import Any, Dict

app = FastAPI(title="Minimal MCP-like Server")

# Example context store (in-memory)
context_store: Dict[str, Any] = {}

class ContextRequest(BaseModel):
    key: str
    value: Any

@app.get("/")
def root():
    return {"message": "MCP-like server is running!"}

@app.post("/context/set")
def set_context(req: ContextRequest):
    context_store[req.key] = req.value
    return {"status": "ok", "key": req.key, "value": req.value}

@app.get("/context/get/{key}")
def get_context(key: str):
    value = context_store.get(key)
    return {"key": key, "value": value}

@app.post("/predict")
def predict(data: Dict[str, Any]):
    # Dummy prediction logic
    return {"prediction": "dummy_result", "input": data}
