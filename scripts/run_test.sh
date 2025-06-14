#!/bin/bash

echo "Testing OpenAI routing..."
curl -X POST http://localhost:8000/chat \
     -H 'Content-Type: application/json' \
  -d '{"model": "gpt-3.5-turbo", "prompt": "Give me a productivity tip"}'

echo "Testing Claude routing..."
curl -X POST http://localhost:8000/chat \
     -H 'Content-Type: application/json' \
     -d '{"model":"claude-haiku","prompt":"Explain blockchain simply."}'