from collections.abc import Iterator
from pathlib import Path

import pytest
from fastapi.testclient import TestClient
from sqlalchemy import Engine
from sqlalchemy.pool import StaticPool
from sqlmodel import Session, SQLModel, create_engine

from app.core.config import settings
from app.core.database import get_session
from app.features.administracion.domain.curabilidad import Veredicto, evaluar
from app.features.administracion.infrastructure.http.router import obtener_analizador
from app.features.auth.infrastructure.persistence.tablas import UsuarioTabla
from app.features.conocimiento.infrastructure.persistence.tablas import PaqueteConocimientoTabla
from app.features.cuentas.infrastructure.cli import main
from app.features.examenes.infrastructure.http.router import obtener_carpeta, obtener_portal
from app.features.examenes.infrastructure.persistence.tablas import ExamenTabla
from app.features.preguntas.infrastructure.persistence.tablas import (
    BancoVersionTabla,
    PreguntaTabla,
    TemaTabla,
)
from app.features.sincronizacion.infrastructure.persistence.tablas import RespuestaTabla
from app.main import create_app


@pytest.mark.parametrize(
    ("paginas", "texto", "preguntas", "con_cinco", "esperado"),
    [
        (2, 6000, 20, 20, Veredicto.CURABLE),
        (2, 6000, 20, 12, Veredicto.REVISAR),
        (2, 20, 0, 0, Veredicto.NO_CURABLE),  # escaneado: casi sin texto
        (108, 42000, 0, 0, Veredicto.NO_CURABLE),  # otro formato: no detecta preguntas
    ],
)
def test_el_veredicto_depende_del_texto_y_de_las_opciones_detectadas(
    paginas: int, texto: int, preguntas: int, con_cinco: int, esperado: Veredicto
) -> None:
    assert evaluar(paginas, texto, preguntas, con_cinco).veredicto is esperado


def test_el_veredicto_explica_el_motivo() -> None:
    assert "escaneado" in evaluar(2, 10, 0, 0).motivo
    assert "12/20" in evaluar(2, 6000, 20, 12).motivo


class _PortalFalso:
    def descargar_catalogo(self) -> list[object]:
        return []

    def descargar_pdf(self, examen: object) -> bytes:  # pragma: no cover - no se llama
        raise AssertionError


@pytest.fixture
def motor() -> Iterator[Engine]:
    motor = create_engine(
        "sqlite://", connect_args={"check_same_thread": False}, poolclass=StaticPool
    )
    SQLModel.metadata.create_all(
        motor,
        tables=[
            t.__table__  # type: ignore[attr-defined]
            for t in (
                UsuarioTabla,
                RespuestaTabla,
                ExamenTabla,
                TemaTabla,
                PreguntaTabla,
                BancoVersionTabla,
                PaqueteConocimientoTabla,
            )
        ],
    )
    yield motor
    motor.dispose()


@pytest.fixture
def cliente(motor: Engine, tmp_path: Path, monkeypatch: pytest.MonkeyPatch) -> Iterator[TestClient]:
    monkeypatch.setattr(settings, "jwt_secreto", "s" * 40)
    monkeypatch.setattr(settings, "admin_correo", "admin@prepion.bo")
    monkeypatch.setattr(settings, "admin_contrasena", "clave-segura-123")
    main(["crear-admin"], motor=motor)
    (tmp_path / "2026-1-1op.pdf").write_bytes(b"%PDF-falso")
    app = create_app()

    def sesion() -> Iterator[Session]:
        with Session(motor) as s:
            yield s

    app.dependency_overrides[get_session] = sesion
    app.dependency_overrides[obtener_carpeta] = lambda: tmp_path
    app.dependency_overrides[obtener_portal] = lambda: _PortalFalso()
    app.dependency_overrides[obtener_analizador] = lambda: lambda ruta: evaluar(2, 6000, 20, 20)
    yield TestClient(app)
    app.dependency_overrides.clear()


def _cabecera(cliente: TestClient, correo: str = "admin@prepion.bo") -> dict[str, str]:
    r = cliente.post("/api/auth/login", json={"correo": correo, "contrasena": "clave-segura-123"})
    return {"Authorization": f"Bearer {r.json()['token']}"}


RUTAS = [
    ("GET", "/api/admin/resumen"),
    ("GET", "/api/admin/examenes"),
    ("POST", "/api/admin/examenes/recolectar"),
    ("POST", "/api/admin/conocimiento/recalibrar"),
]


@pytest.mark.parametrize(("metodo", "ruta"), RUTAS)
def test_todas_las_rutas_exigen_ser_admin(cliente: TestClient, metodo: str, ruta: str) -> None:
    assert cliente.request(metodo, ruta).status_code == 401
    cliente.post(
        "/api/auth/registro", json={"correo": "ana@correo.com", "contrasena": "clave-segura-123"}
    )
    normal = _cabecera(cliente, "ana@correo.com")
    assert cliente.request(metodo, ruta, headers=normal).status_code == 403


def test_el_resumen_cuenta_usuarios_y_estado_del_modelo(cliente: TestClient) -> None:
    r = cliente.get("/api/admin/resumen", headers=_cabecera(cliente))

    assert r.status_code == 200
    cuerpo = r.json()
    assert cuerpo["usuarios"] == 1
    assert cuerpo["respuestas"] == 0
    assert cuerpo["preguntasPublicadas"] == 0
    assert cuerpo["bancoVersion"] is None
    assert cuerpo["paqueteVersion"] is None
    assert cuerpo["examenesDescargados"] == 1


def test_lista_los_examenes_descargados_con_su_veredicto(cliente: TestClient) -> None:
    r = cliente.get("/api/admin/examenes", headers=_cabecera(cliente))

    assert r.status_code == 200
    assert r.json() == [
        {
            "archivo": "2026-1-1op.pdf",
            "paginas": 2,
            "preguntas": 20,
            "conCincoOpciones": 20,
            "veredicto": "curable",
            "motivo": "20/20 preguntas con 5 opciones",
        }
    ]


def test_recolectar_manualmente_devuelve_el_resultado_de_la_recoleccion(
    cliente: TestClient,
) -> None:
    r = cliente.post("/api/admin/examenes/recolectar", headers=_cabecera(cliente))

    assert r.status_code == 200
    assert "descargados" in r.json()


def test_recalibrar_sin_banco_publicado_avisa_con_claridad(cliente: TestClient) -> None:
    r = cliente.post("/api/admin/conocimiento/recalibrar", headers=_cabecera(cliente))
    assert r.status_code == 409
    assert r.json()["detail"]
