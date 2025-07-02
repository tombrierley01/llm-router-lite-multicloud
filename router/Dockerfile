FROM ghcr.io/berriai/litellm:main-latest

WORKDIR /app

COPY app ./app
COPY litellm_config.yaml ./litellm_config.yaml

RUN pip install fastapi "uvicorn[standard]" pydantic asyncpg PyJWT prometheus-fastapi-instrumentator

EXPOSE 8000

ENTRYPOINT []
CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8000"]

