# Minimal FastAPI MCP-like Server

This is a minimal template for a Model Context Protocol (MCP)-like server using FastAPI.

## Features
- Set and get context (in-memory)
- Dummy prediction endpoint

## Usage

1. Install dependencies:
   ```bash
   pip install -r requirements.txt
   ```
2. Start the server:
   ```bash
   uvicorn main:app --reload --host 0.0.0.0 --port 8000
   ```
3. Test endpoints:
   - Health check: `GET /`
   - Set context: `POST /context/set` with JSON `{ "key": "foo", "value": "bar" }`
   - Get context: `GET /context/get/foo`
   - Predict: `POST /predict` with any JSON payload
