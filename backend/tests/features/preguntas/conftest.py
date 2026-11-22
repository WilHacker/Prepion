from collections.abc import Iterator

import pytest
from fastapi.testclient import TestClient
from sqlalchemy import Engine
from sqlalchemy.pool import StaticPool
from sqlmodel import Session, SQLModel, create_engine

from app.core.database import get_session
from app.features.examenes.infrastructure.persistence.tablas import ExamenTabla
from app.features.preguntas.infrastructure.persistence.tablas import (
    BancoVersionTabla,
    PreguntaTabla,
    TemaTabla,
)
from app.main import create_app


@pytest.fixture
def motor() -> Iterator[Engine]:
    motor = create_engine(
        "sqlite://", connect_args={"check_same_thread": False}, poolclass=StaticPool
    )
    SQLModel.metadata.create_all(
        motor,
        tables=[
            BancoVersionTabla.__table__,  # type: ignore[attr-defined]
            ExamenTabla.__table__,  # type: ignore[attr-defined]
            TemaTabla.__table__,  # type: ignore[attr-defined]
            PreguntaTabla.__table__,  # type: ignore[attr-defined]
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
