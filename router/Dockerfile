FROM python:3.10-slim
WORKDIR /app
COPY . .
RUN pip install litellm fastapi uvicorn
CMD ["litellm", "--model", "gpt-3.5-turbo"]