import uuid
from collections.abc import Iterator
from typing import Annotated

from fastapi import Depends, FastAPI
from fastapi.testclient import TestClient
from sqlmodel import Session, SQLModel, create_engine
from sqlmodel.pool import StaticPool

from app.core.database import get_session
from app.core.errors import registrar_manejadores_de_errores
from app.features.auth.domain.identidad import IdentidadUsuario
from app.features.auth.infrastructure.http.dependencias import (
    asegurar_identidad_en_bd,
    obtener_identidad_usuario,
)
from app.features.auth.infrastructure.persistence.tablas import UsuarioTabla


def _crear_app_eventos() -> FastAPI:
    app = FastAPI()
    registrar_manejadores_de_errores(app)

    @app.post("/api/eventos-prueba")
    def registrar_evento(
        identidad: Annotated[IdentidadUsuario, Depends(obtener_identidad_usuario)],
    ) -> dict[str, object]:
        return {
            "usuarioId": str(identidad.usuario_id),
            "esAnonimo": identidad.es_anonimo,
        }

    @app.post("/api/eventos-bd")
    def registrar_evento_bd(
        identidad: Annotated[IdentidadUsuario, Depends(asegurar_identidad_en_bd)],
    ) -> dict[str, object]:
        return {
            "usuarioId": str(identidad.usuario_id),
            "esAnonimo": identidad.es_anonimo,
        }

    return app


def test_acepta_cabecera_x_usuario_id_cuando_es_uuid_valido() -> None:
    # Preparar
    cliente = TestClient(_crear_app_eventos())
    usuario_id = str(uuid.uuid4())

    # Actuar
    respuesta = cliente.post(
        "/api/eventos-prueba",
        headers={"X-Usuario-Id": usuario_id},
    )

    # Verificar
    assert respuesta.status_code == 200
    assert respuesta.json() == {"usuarioId": usuario_id, "esAnonimo": True}


def test_responde_401_cuando_falta_cabecera_x_usuario_id() -> None:
    # Preparar
    cliente = TestClient(_crear_app_eventos())

    # Actuar
    respuesta = cliente.post("/api/eventos-prueba")

    # Verificar
    assert respuesta.status_code == 401
    assert respuesta.headers["content-type"] == "application/problem+json"
    cuerpo = respuesta.json()
    assert cuerpo["title"] == "No autorizado"
    assert cuerpo["codigo"] == "SesionRequeridaError"


def test_responde_422_cuando_x_usuario_id_no_es_uuid_valido() -> None:
    # Preparar
    cliente = TestClient(_crear_app_eventos())

    # Actuar
    respuesta = cliente.post(
        "/api/eventos-prueba",
        headers={"X-Usuario-Id": "no-es-un-uuid"},
    )

    # Verificar
    assert respuesta.status_code == 422
    assert respuesta.headers["content-type"] == "application/problem+json"
    cuerpo = respuesta.json()
    assert cuerpo["codigo"] == "IdentidadUsuarioInvalidaError"


def test_crea_usuario_anonimo_una_sola_vez_cuando_se_asegura_identidad_en_bd() -> None:
    # Preparar
    engine = create_engine(
        "sqlite://",
        connect_args={"check_same_thread": False},
        poolclass=StaticPool,
    )
    SQLModel.metadata.create_all(engine, tables=[UsuarioTabla.__table__])  # type: ignore[attr-defined]

    def obtener_sesion_prueba() -> Iterator[Session]:
        with Session(engine) as session:
            yield session

    app = _crear_app_eventos()
    app.dependency_overrides[get_session] = obtener_sesion_prueba
    cliente = TestClient(app)
    usuario_id = uuid.uuid4()

    # Actuar (dos llamadas consecutivas con el mismo UUID anónimo)
    primera = cliente.post("/api/eventos-bd", headers={"X-Usuario-Id": str(usuario_id)})
    segunda = cliente.post("/api/eventos-bd", headers={"X-Usuario-Id": str(usuario_id)})

    # Verificar
    assert primera.status_code == 200
    assert segunda.status_code == 200
    with Session(engine) as session:
        usuario = session.get(UsuarioTabla, usuario_id)
        assert usuario is not None
        assert usuario.es_anonimo is True
        assert usuario.correo is None
