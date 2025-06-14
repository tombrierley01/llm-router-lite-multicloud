#!/bin/bash

echo "Testing OpenAI routing..."
curl http://localhost:4000/completions \
  -H "Content-Type: application/json" \
  -d '{"model": "gpt-3.5-turbo", "prompt": "Give me a productivity tip"}'

# echo "Testing Claude routing..."
# curl http://localhost:4000/completions \
#   -H "Content-Type: application/json" \
#   -d '{"model": "anthropic.claude-instant-v1", "prompt": "What is Claude AI?"}'