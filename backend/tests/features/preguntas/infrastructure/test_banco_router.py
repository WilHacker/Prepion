from fastapi.testclient import TestClient
from sqlalchemy import Engine
from sqlmodel import Session

from app.features.preguntas.application.publicar_banco import publicar_banco
from app.features.preguntas.infrastructure.persistence.banco_repositorio import (
    BancoRepositorioSql,
)

BANCO = {
    "version": 1,
    "examenes": [],
    "temas": [],
    "preguntas": [{"id": "p1", "enunciado": "¿Cuánto es 2+2?"}, {"id": "p2"}],
}


def _publicar(motor: Engine, banco: dict) -> None:
    with Session(motor) as sesion:
        publicar_banco(BancoRepositorioSql(sesion), banco)


def test_responde_404_cuando_todavia_no_hay_banco_publicado(cliente: TestClient):
    respuesta = cliente.get("/api/preguntas/banco/actual")

    assert respuesta.status_code == 404
    assert respuesta.headers["content-type"] == "application/problem+json"
    assert "Todavía no hay" in respuesta.json()["detail"]


def test_devuelve_la_version_actual_con_cantidad_y_fecha(cliente: TestClient, motor: Engine):
    _publicar(motor, BANCO)

    respuesta = cliente.get("/api/preguntas/banco/actual")

    cuerpo = respuesta.json()
    assert respuesta.status_code == 200
    assert cuerpo["version"] == 1
    assert cuerpo["cantidad"] == 2
    assert cuerpo["publicadaEn"]  # ISO 8601


def test_descarga_el_banco_completo_de_una_version(cliente: TestClient, motor: Engine):
    _publicar(motor, BANCO)

    respuesta = cliente.get("/api/preguntas/banco/descargar/1")

    assert respuesta.status_code == 200
    assert respuesta.json() == BANCO


def test_responde_404_cuando_la_version_no_existe(cliente: TestClient):
    respuesta = cliente.get("/api/preguntas/banco/descargar/7")

    assert respuesta.status_code == 404
    assert "versión 7" in respuesta.json()["detail"]


def test_responde_422_cuando_la_version_no_es_un_numero(cliente: TestClient):
    assert cliente.get("/api/preguntas/banco/descargar/abc").status_code == 422
