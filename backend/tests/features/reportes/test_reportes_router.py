import uuid
from collections.abc import Iterator

import pytest
from fastapi.testclient import TestClient
from sqlalchemy import Engine
from sqlalchemy.pool import StaticPool
from sqlmodel import Session, SQLModel, create_engine

from app.core.database import get_session
from app.features.auth.infrastructure.persistence.tablas import UsuarioTabla
from app.features.examenes.infrastructure.persistence.tablas import ExamenTabla
from app.features.preguntas.infrastructure.persistence.tablas import PreguntaTabla, TemaTabla
from app.features.reportes.infrastructure.persistence.tablas import ReporteTabla
from app.main import create_app


@pytest.fixture
def motor() -> Iterator[Engine]:
    """Base SQLite en memoria con tablas requeridas para reportes."""
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
            ReporteTabla.__table__,  # type: ignore[attr-defined]
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


def test_crea_reporte_exitosamente_sin_usuario(cliente: TestClient):
    # Arrange
    pregunta_id = str(uuid.uuid4())
    payload = {
        "preguntaId": pregunta_id,
        "motivo": "respuesta_incorrecta",
        "comentario": "La clave correcta debería ser la C y no la A",
    }

    # Act
    respuesta = cliente.post("/api/reportes", json=payload)

    # Assert
    assert respuesta.status_code == 201
    datos = respuesta.json()
    assert datos["preguntaId"] == pregunta_id
    assert datos["motivo"] == "respuesta_incorrecta"
    assert datos["comentario"] == "La clave correcta debería ser la C y no la A"
    assert datos["estado"] == "pendiente"
    assert datos["usuarioId"] is None
    assert "id" in datos
    assert "creadoEn" in datos


def test_crea_reporte_con_identidad_de_usuario(cliente: TestClient):
    # Arrange
    usuario_id = str(uuid.uuid4())
    pregunta_id = str(uuid.uuid4())
    payload = {
        "pregunta_id": pregunta_id,
        "motivo": "imagen_borrosa",
    }

    # Act
    respuesta = cliente.post(
        "/api/reportes",
        json=payload,
        headers={"X-Usuario-Id": usuario_id},
    )

    # Assert
    assert respuesta.status_code == 201
    datos = respuesta.json()
    assert datos["preguntaId"] == pregunta_id
    assert datos["motivo"] == "imagen_borrosa"
    assert datos["comentario"] is None
    assert datos["usuarioId"] == usuario_id


def test_rechaza_reporte_con_motivo_invalido(cliente: TestClient):
    # Arrange
    pregunta_id = str(uuid.uuid4())
    payload = {
        "preguntaId": pregunta_id,
        "motivo": "motivo_inexistente_123",
    }

    # Act
    respuesta = cliente.post("/api/reportes", json=payload)

    # Assert
    assert respuesta.status_code == 422


def test_rechaza_reporte_con_motivo_vacio(cliente: TestClient):
    # Arrange
    pregunta_id = str(uuid.uuid4())
    payload = {
        "preguntaId": pregunta_id,
        "motivo": "   ",
    }

    # Act
    respuesta = cliente.post("/api/reportes", json=payload)

    # Assert
    assert respuesta.status_code == 422


def test_lista_reportes_pendientes_ordenados(cliente: TestClient):
    # Arrange
    pregunta_1 = str(uuid.uuid4())
    pregunta_2 = str(uuid.uuid4())

    cliente.post(
        "/api/reportes",
        json={"preguntaId": pregunta_1, "motivo": "error_tipografico", "comentario": "Falta tilde"},
    )
    cliente.post(
        "/api/reportes",
        json={"preguntaId": pregunta_2, "motivo": "otro", "comentario": "Pregunta incompleta"},
    )

    # Act
    respuesta = cliente.get("/api/reportes/pendientes")

    # Assert
    assert respuesta.status_code == 200
    datos = respuesta.json()
    assert len(datos) == 2
    motivos = [item["motivo"] for item in datos]
    assert "error_tipografico" in motivos
    assert "otro" in motivos
