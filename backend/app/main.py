from fastapi import FastAPI

from app.core.errors import registrar_manejadores_de_errores
from app.features.configuracion.infrastructure.http.router import (
    router as configuracion_router,
)
from app.features.examenes.infrastructure.http.router import router as examenes_router
from app.features.health.infrastructure.http.router import router as health_router
from app.features.preguntas.infrastructure.http.router import router as preguntas_router


def create_app() -> FastAPI:
    app = FastAPI(title="Prepion API", version="0.1.0")
    registrar_manejadores_de_errores(app)
    app.include_router(health_router, prefix="/api")
    app.include_router(configuracion_router, prefix="/api")
    app.include_router(preguntas_router, prefix="/api")
    app.include_router(examenes_router, prefix="/api")
    return app


app = create_app()
