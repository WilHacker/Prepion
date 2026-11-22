from fastapi import FastAPI, Request
from fastapi.responses import JSONResponse

from app.shared.domain.errores import DominioError

TITULOS_HTTP = {
    401: "No autorizado",
    404: "No encontrado",
    409: "Conflicto",
    422: "Regla de negocio incumplida",
}


def registrar_manejadores_de_errores(app: FastAPI) -> None:
    @app.exception_handler(DominioError)
    async def manejar_error_de_dominio(request: Request, error: DominioError) -> JSONResponse:
        # Formato RFC 9457 (problem+json); el mensaje es seguro para el usuario.
        return JSONResponse(
            status_code=error.codigo_http,
            media_type="application/problem+json",
            content={
                "type": "about:blank",
                "title": TITULOS_HTTP.get(error.codigo_http, "Error"),
                "status": error.codigo_http,
                "detail": error.mensaje,
                "instance": request.url.path,
                "codigo": type(error).__name__,
            },
        )
