import uuid
from collections.abc import Iterator
from datetime import UTC, datetime

import pytest
from fastapi.testclient import TestClient
from sqlalchemy import Engine
from sqlalchemy.pool import StaticPool
from sqlmodel import Session, SQLModel, create_engine

from app.core.database import get_session
from app.features.auth.infrastructure.persistence.tablas import UsuarioTabla
from app.features.examenes.infrastructure.persistence.tablas import ExamenTabla
from app.features.preguntas.infrastructure.persistence.tablas import PreguntaTabla, TemaTabla
from app.features.sincronizacion.infrastructure.persistence.tablas import RespuestaTabla
from app.main import create_app


@pytest.fixture
def motor() -> Iterator[Engine]:
    """Base SQLite en memoria con todas las tablas involucradas en sincronización."""
    motor = create_engine(
        "sqlite://", connect_args={"check_same_thread": False}, poolclass=StaticPool
    )
    SQLModel.metadata.create_all(
        motor,
        tables=[
            UsuarioTabla.__table__,  # type: ignore[attr-defined]
            ExamenTabla.__table__,  # type: ignore[attr-defined]
            TemaTabla.__table__,  # type: ignore[attr-defined]
            PreguntaTabla.__table__,  # type: ignore[attr-defined]
            RespuestaTabla.__table__,  # type: ignore[attr-defined]
        ],
    )
    yield motor
    motor.dispose()


@pytest.fixture
def cliente(motor: Engine) -> Iterator[TestClient]:
    app = create_app()

    def sesion_de_prueba() -> Iterator[Session]:
        with Session(motor) as sesion:
            yield sesion

    app.dependency_overrides[get_session] = sesion_de_prueba
    yield TestClient(app)
    app.dependency_overrides.clear()


def test_inserta_lote_de_respuestas_satisfactoriamente(cliente: TestClient):
    # Arrange
    usuario_id = str(uuid.uuid4())
    pregunta_id = str(uuid.uuid4())
    evento_id_1 = str(uuid.uuid4())
    evento_id_2 = str(uuid.uuid4())

    payload = {
        "respuestas": [
            {
                "idEvento": evento_id_1,
                "preguntaId": pregunta_id,
                "opcionElegida": "B",
                "esCorrecta": True,
                "tiempoMs": 1420,
                "respondidaEn": datetime.now(UTC).isoformat(),
            },
            {
                "idEvento": evento_id_2,
                "preguntaId": pregunta_id,
                "opcionElegida": None,
                "esCorrecta": False,
                "tiempoMs": 3000,
                "respondidaEn": datetime.now(UTC).isoformat(),
            },
        ]
    }

    # Act
    respuesta = cliente.post(
        "/api/sincronizacion/lote",
        json=payload,
        headers={"X-Usuario-Id": usuario_id},
    )

    # Assert
    assert respuesta.status_code == 200
    cuerpo = respuesta.json()
    assert cuerpo["recibidos"] == 2
    assert cuerpo["insertados"] == 2
    assert cuerpo["duplicados"] == 0


def test_ignora_respuestas_duplicadas_garantizando_idempotencia(cliente: TestClient):
    # Arrange
    usuario_id = str(uuid.uuid4())
    pregunta_id = str(uuid.uuid4())
    evento_id = str(uuid.uuid4())

    payload = {
        "respuestas": [
            {
                "idEvento": evento_id,
                "preguntaId": pregunta_id,
                "opcionElegida": "C",
                "esCorrecta": True,
                "tiempoMs": 2100,
                "respondidaEn": datetime.now(UTC).isoformat(),
            }
        ]
    }

    # Act: primer envío
    res1 = cliente.post(
        "/api/sincronizacion/lote",
        json=payload,
        headers={"X-Usuario-Id": usuario_id},
    )
    assert res1.status_code == 200
    assert res1.json()["insertados"] == 1
    assert res1.json()["duplicados"] == 0

    # Act: segundo envío idéntico
    res2 = cliente.post(
        "/api/sincronizacion/lote",
        json=payload,
        headers={"X-Usuario-Id": usuario_id},
    )

    # Assert
    assert res2.status_code == 200
    cuerpo = res2.json()
    assert cuerpo["recibidos"] == 1
    assert cuerpo["insertados"] == 0
    assert cuerpo["duplicados"] == 1


def test_rechaza_sincronizacion_si_falta_cabecera_usuario(cliente: TestClient):
    payload = {"respuestas": []}
    respuesta = cliente.post("/api/sincronizacion/lote", json=payload)

    assert respuesta.status_code == 401
    assert respuesta.headers["content-type"] == "application/problem+json"


def test_sincroniza_lote_vacio_sin_errores(cliente: TestClient):
    usuario_id = str(uuid.uuid4())
    respuesta = cliente.post(
        "/api/sincronizacion/lote",
        json={"respuestas": []},
        headers={"X-Usuario-Id": usuario_id},
    )

    assert respuesta.status_code == 200
    assert respuesta.json() == {"recibidos": 0, "insertados": 0, "duplicados": 0}
