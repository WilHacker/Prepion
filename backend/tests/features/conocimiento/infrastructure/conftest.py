from collections.abc import Iterator

import pytest
from fastapi.testclient import TestClient
from sqlalchemy import Engine
from sqlalchemy.pool import StaticPool
from sqlmodel import Session, SQLModel, create_engine

from app.core.database import get_session
from app.features.conocimiento.infrastructure.persistence.tablas import PaqueteConocimientoTabla
from app.features.preguntas.infrastructure.persistence.tablas import BancoVersionTabla
from app.features.sincronizacion.infrastructure.persistence.tablas import RespuestaTabla
from app.main import create_app


@pytest.fixture
def motor() -> Iterator[Engine]:
    """SQLite en memoria; no aplica llaves foráneas, así que `respuestas` no exige usuarios."""
    motor = create_engine(
        "sqlite://", connect_args={"check_same_thread": False}, poolclass=StaticPool
    )
    tablas = [BancoVersionTabla, PaqueteConocimientoTabla, RespuestaTabla]
    SQLModel.metadata.create_all(motor, tables=[t.__table__ for t in tablas])  # type: ignore[attr-defined]
    yield motor
    motor.dispose()


@pytest.fixture
def sesion(motor: Engine) -> Iterator[Session]:
    with Session(motor) as sesion:
        yield sesion


@pytest.fixture
def cliente(motor: Engine) -> Iterator[TestClient]:
    app = create_app()

    def sesion_de_prueba() -> Iterator[Session]:
        with Session(motor) as sesion:
            yield sesion

    app.dependency_overrides[get_session] = sesion_de_prueba
    yield TestClient(app)
    app.dependency_overrides.clear()
