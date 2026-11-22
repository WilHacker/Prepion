import uuid
from datetime import UTC, datetime

import pytest
from fastapi.testclient import TestClient
from sqlalchemy import Engine
from sqlmodel import Session

from app.core.config import settings
from app.features.conocimiento.infrastructure.persistence.tablas import PaqueteConocimientoTabla
from app.features.preguntas.infrastructure.persistence.tablas import BancoVersionTabla
from app.features.sincronizacion.infrastructure.persistence.tablas import RespuestaTabla

CABECERA = {"X-Recoleccion-Token": "secreto"}
PREGUNTAS = [str(uuid.uuid4()) for _ in range(6)]
TEMAS = [str(uuid.uuid4()) for _ in range(2)]
BANCO = {"preguntas": [{"id": p, "temaId": TEMAS[i % 2]} for i, p in enumerate(PREGUNTAS)]}


@pytest.fixture
def con_token(monkeypatch: pytest.MonkeyPatch) -> None:
    monkeypatch.setattr(settings, "recoleccion_token", "secreto")


def _publicar_banco(motor: Engine) -> None:
    with Session(motor) as sesion:
        sesion.add(BancoVersionTabla(version=1, cantidad=6, contenido=BANCO))
        sesion.commit()


def _responder(motor: Engine, usuarios: int) -> None:
    with Session(motor) as sesion:
        for j in range(usuarios):
            usuario = uuid.uuid4()
            for i, p in enumerate(PREGUNTAS):
                sesion.add(
                    RespuestaTabla(
                        id_evento=uuid.uuid4(),
                        usuario_id=usuario,
                        pregunta_id=uuid.UUID(p),
                        es_correcta=j % 8 > i,
                        tiempo_ms=1000,
                        respondida_en=datetime(2026, 11, 1, tzinfo=UTC),
                    )
                )
        sesion.commit()


def test_paquete_actual_sin_paquete_publicado_entrega_el_de_por_defecto_sin_preguntas_ni_bkt(
    cliente: TestClient,
) -> None:
    respuesta = cliente.get("/api/paquetes-conocimiento/actual")

    # La app descarta este contenido (no trae preguntas ni bkt) y sigue con su paquete.
    assert respuesta.status_code == 200
    contenido = respuesta.json()["contenido"]
    assert "preguntas" not in contenido
    assert "bkt" not in contenido


def test_paquete_actual_envuelve_el_contenido_de_la_version_mas_alta(
    cliente: TestClient, motor: Engine
) -> None:
    contenido = {
        "version": 1,
        "origen": "real",
        "usuarios": 25,
        "generadoEn": "2026-11-22T18:00:00Z",
        "preguntas": [{"preguntaId": "p", "dificultad": 0.42}],
        "bkt": [
            {"temaId": "t", "pInicial": 0.3, "pAprendizaje": 0.1, "pAdivinar": 0.2, "pError": 0.1}
        ],
    }
    with Session(motor) as sesion:
        sesion.add(PaqueteConocimientoTabla(version=1, contenido={"viejo": True}))
        sesion.add(PaqueteConocimientoTabla(version=2, contenido=contenido))
        sesion.commit()

    respuesta = cliente.get("/api/paquetes-conocimiento/actual")

    cuerpo = respuesta.json()
    assert respuesta.status_code == 200
    assert cuerpo["version"] == 2
    assert cuerpo["contenido"] == contenido
    assert cuerpo["actualizadoEn"]


def test_recalibrar_sin_respuestas_reales_publica_un_paquete_simulado(
    cliente: TestClient, motor: Engine, con_token: None
) -> None:
    _publicar_banco(motor)

    respuesta = cliente.post("/api/conocimiento/recalibrar", headers=CABECERA)

    assert respuesta.status_code == 200
    assert respuesta.json() == {
        "version": 1,
        "origen": "simulado",
        "usuarios": 60,
        "preguntas": 6,
        "temas": 2,
    }
    paquete = cliente.get("/api/paquetes-conocimiento/actual").json()["contenido"]
    assert paquete["origen"] == "simulado"
    assert {p["preguntaId"] for p in paquete["preguntas"]} == set(PREGUNTAS)
    assert {t["temaId"] for t in paquete["bkt"]} == set(TEMAS)


def test_recalibrar_con_20_usuarios_reales_publica_origen_real_y_sube_la_version(
    cliente: TestClient, motor: Engine, con_token: None
) -> None:
    _publicar_banco(motor)
    _responder(motor, 20)
    cliente.post("/api/conocimiento/recalibrar", headers=CABECERA)

    respuesta = cliente.post("/api/conocimiento/recalibrar", headers=CABECERA)

    assert respuesta.json()["version"] == 2
    assert respuesta.json()["origen"] == "real"
    assert respuesta.json()["usuarios"] == 20
    assert cliente.get("/api/paquetes-conocimiento/actual").json()["contenido"]["origen"] == "real"


def test_recalibrar_sin_banco_responde_409(cliente: TestClient, con_token: None) -> None:
    respuesta = cliente.post("/api/conocimiento/recalibrar", headers=CABECERA)

    assert respuesta.status_code == 409
    assert respuesta.headers["content-type"].startswith("application/problem+json")


def test_recalibrar_sin_token_configurado_responde_503(
    cliente: TestClient, monkeypatch: pytest.MonkeyPatch
) -> None:
    monkeypatch.setattr(settings, "recoleccion_token", None)

    assert cliente.post("/api/conocimiento/recalibrar", headers=CABECERA).status_code == 503


@pytest.mark.parametrize("cabeceras", [{}, {"X-Recoleccion-Token": "otro"}])
def test_recalibrar_con_token_ausente_o_incorrecto_responde_401(
    cliente: TestClient, con_token: None, cabeceras: dict[str, str]
) -> None:
    assert cliente.post("/api/conocimiento/recalibrar", headers=cabeceras).status_code == 401
