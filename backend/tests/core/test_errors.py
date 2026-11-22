from fastapi import FastAPI
from fastapi.testclient import TestClient

from app.core.errors import registrar_manejadores_de_errores
from app.shared.domain.errores import RecursoNoEncontradoError


def crear_app_que_falla() -> FastAPI:
    app = FastAPI()
    registrar_manejadores_de_errores(app)

    @app.get("/preguntas/{codigo}")
    def obtener_pregunta(codigo: str) -> None:
        raise RecursoNoEncontradoError(f"No existe la pregunta {codigo}")

    return app


def test_responde_problem_json_cuando_se_lanza_un_error_de_dominio():
    # Preparar
    cliente = TestClient(crear_app_que_falla())

    # Actuar
    respuesta = cliente.get("/preguntas/A5")

    # Verificar
    assert respuesta.status_code == 404
    assert respuesta.headers["content-type"] == "application/problem+json"
    assert respuesta.json() == {
        "type": "about:blank",
        "title": "No encontrado",
        "status": 404,
        "detail": "No existe la pregunta A5",
        "instance": "/preguntas/A5",
        "codigo": "RecursoNoEncontradoError",
    }
