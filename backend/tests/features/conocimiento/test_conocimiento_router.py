from collections.abc import Iterator

import pytest
from fastapi.testclient import TestClient
from sqlalchemy import Engine
from sqlalchemy.pool import StaticPool
from sqlmodel import Session, SQLModel, create_engine

from app.core.database import get_session
from app.features.conocimiento.infrastructure.persistence.tablas import PaqueteConocimientoTabla
from app.main import create_app


@pytest.fixture
def motor() -> Iterator[Engine]:
    motor = create_engine(
        "sqlite://", connect_args={"check_same_thread": False}, poolclass=StaticPool
    )
    SQLModel.metadata.create_all(
        motor,
        tables=[PaqueteConocimientoTabla.__table__],  # type: ignore[attr-defined]
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


def test_devuelve_paquete_default_cuando_la_tabla_esta_vacia(cliente: TestClient):
    # Act
    respuesta = cliente.get("/api/paquetes-conocimiento/actual")

    # Assert
    assert respuesta.status_code == 200
    cuerpo = respuesta.json()
    assert cuerpo["version"] == 1
    assert "pesos" in cuerpo["contenido"]
    assert cuerpo["actualizadoEn"]


def test_devuelve_el_paquete_con_mayor_version(cliente: TestClient, motor: Engine):
    # Arrange
    with Session(motor) as sesion:
        p1 = PaqueteConocimientoTabla(version=1, contenido={"pesos": [0.1]})
        p2 = PaqueteConocimientoTabla(version=2, contenido={"pesos": [0.2, 0.3]})
        sesion.add(p1)
        sesion.add(p2)
        sesion.commit()

    # Act
    respuesta = cliente.get("/api/paquetes-conocimiento/actual")

    # Assert
    assert respuesta.status_code == 200
    cuerpo = respuesta.json()
    assert cuerpo["version"] == 2
    assert cuerpo["contenido"]["pesos"] == [0.2, 0.3]
