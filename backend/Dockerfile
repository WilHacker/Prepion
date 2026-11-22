FROM python:3.13-slim AS base
COPY --from=ghcr.io/astral-sh/uv:0.12 /uv /usr/local/bin/uv
WORKDIR /srv
COPY pyproject.toml uv.lock ./

# API: sin las librerías pesadas de ML.
FROM base AS api
RUN uv sync --frozen --no-dev --no-group ml
COPY app ./app
COPY alembic.ini ./
COPY migrations ./migrations
EXPOSE 8000
CMD ["uv", "run", "--no-sync", "uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8000"]

# ML: extracción de PDF y recalibración; se corre bajo demanda.
FROM base AS ml
RUN uv sync --frozen --no-dev --group ml
COPY app ./app
CMD ["uv", "run", "--no-sync", "python", "-c", "print('Contenedor ml listo')"]
