from fastapi import FastAPI

from app.core.errors import registrar_manejadores_de_errores
from app.features.health.infrastructure.http.router import router as health_router


def create_app() -> FastAPI:
    app = FastAPI(title="Prepion API", version="0.1.0")
    registrar_manejadores_de_errores(app)
    app.include_router(health_router, prefix="/api")
    return app


app = create_app()
