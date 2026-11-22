from collections.abc import Iterator

import pytest
from fastapi.testclient import TestClient
from sqlalchemy import Engine
from sqlalchemy.pool import StaticPool
from sqlmodel import Session, SQLModel, create_engine

from app.core.config import settings
from app.core.database import get_session
from app.features.auth.infrastructure.persistence.tablas import UsuarioTabla
from app.features.cuentas.infrastructure.cli import main
from app.features.sincronizacion.infrastructure.persistence.tablas import RespuestaTabla
from app.main import create_app

SECRETO = "s" * 40
CLAVE = "clave-segura-123"


@pytest.fixture
def motor() -> Iterator[Engine]:
    motor = create_engine(
        "sqlite://", connect_args={"check_same_thread": False}, poolclass=StaticPool
    )
    SQLModel.metadata.create_all(
        motor,
        tables=[UsuarioTabla.__table__, RespuestaTabla.__table__],  # type: ignore[attr-defined]
    )
    yield motor
    motor.dispose()


@pytest.fixture
def cliente(motor: Engine, monkeypatch: pytest.MonkeyPatch) -> Iterator[TestClient]:
    monkeypatch.setattr(settings, "jwt_secreto", SECRETO)
    app = create_app()

    def sesion_de_prueba() -> Iterator[Session]:
        with Session(motor) as sesion:
            yield sesion

    app.dependency_overrides[get_session] = sesion_de_prueba
    yield TestClient(app)
    app.dependency_overrides.clear()


def _registrar(cliente: TestClient, correo: str = "ana@correo.com") -> dict[str, object]:
    return cliente.post("/api/auth/registro", json={"correo": correo, "contrasena": CLAVE}).json()


def _admin(cliente: TestClient, motor: Engine, monkeypatch: pytest.MonkeyPatch) -> str:
    monkeypatch.setattr(settings, "admin_correo", "admin@prepion.bo")
    monkeypatch.setattr(settings, "admin_contrasena", CLAVE)
    assert main(["crear-admin"], motor=motor) == 0
    r = cliente.post("/api/auth/login", json={"correo": "admin@prepion.bo", "contrasena": CLAVE})
    return str(r.json()["token"])


def test_registro_crea_un_usuario_normal_y_devuelve_token(cliente: TestClient) -> None:
    r = cliente.post("/api/auth/registro", json={"correo": " Ana@Correo.com ", "contrasena": CLAVE})

    assert r.status_code == 201
    cuerpo = r.json()
    assert cuerpo["token"]
    assert cuerpo["cuenta"]["correo"] == "ana@correo.com"
    assert cuerpo["cuenta"]["rol"] == "usuario"


def test_registro_rechaza_correo_repetido(cliente: TestClient) -> None:
    _registrar(cliente)
    r = cliente.post("/api/auth/registro", json={"correo": "ANA@correo.com", "contrasena": CLAVE})
    assert r.status_code == 409


@pytest.mark.parametrize(
    "cuerpo",
    [
        {"correo": "no-es-correo", "contrasena": CLAVE},
        {"correo": "a@b.com", "contrasena": "corta"},
        {"correo": "a@b.com"},
    ],
)
def test_registro_valida_la_entrada(cliente: TestClient, cuerpo: dict[str, str]) -> None:
    assert cliente.post("/api/auth/registro", json=cuerpo).status_code == 422


def test_login_correcto_e_incorrecto(cliente: TestClient) -> None:
    _registrar(cliente)

    ok = cliente.post("/api/auth/login", json={"correo": "ana@correo.com", "contrasena": CLAVE})
    mal = cliente.post(
        "/api/auth/login", json={"correo": "ana@correo.com", "contrasena": "otra-clave-1"}
    )
    nadie = cliente.post("/api/auth/login", json={"correo": "x@correo.com", "contrasena": CLAVE})

    assert ok.status_code == 200
    assert mal.status_code == 401
    assert nadie.status_code == 401
    assert mal.json()["detail"] == nadie.json()["detail"]  # no revela si el correo existe


def test_yo_devuelve_la_cuenta_del_token(cliente: TestClient) -> None:
    token = _registrar(cliente)["token"]
    r = cliente.get("/api/auth/yo", headers={"Authorization": f"Bearer {token}"})
    assert r.status_code == 200
    assert r.json()["correo"] == "ana@correo.com"


@pytest.mark.parametrize("cabecera", [None, "Bearer basura", "Token abc", "Bearer "])
def test_yo_rechaza_tokens_ausentes_o_invalidos(cliente: TestClient, cabecera: str | None) -> None:
    cabeceras = {} if cabecera is None else {"Authorization": cabecera}
    assert cliente.get("/api/auth/yo", headers=cabeceras).status_code == 401


def test_sin_secreto_jwt_el_login_esta_apagado(
    cliente: TestClient, monkeypatch: pytest.MonkeyPatch
) -> None:
    monkeypatch.setattr(settings, "jwt_secreto", None)
    r = cliente.post("/api/auth/registro", json={"correo": "a@b.com", "contrasena": CLAVE})
    assert r.status_code == 503


def test_admin_ve_a_todos_los_usuarios_con_su_actividad(
    cliente: TestClient, motor: Engine, monkeypatch: pytest.MonkeyPatch
) -> None:
    _registrar(cliente)
    token = _admin(cliente, motor, monkeypatch)

    r = cliente.get("/api/admin/usuarios", headers={"Authorization": f"Bearer {token}"})

    assert r.status_code == 200
    correos = {u["correo"]: u for u in r.json()}
    assert set(correos) == {"ana@correo.com", "admin@prepion.bo"}
    assert correos["admin@prepion.bo"]["rol"] == "admin"
    assert correos["ana@correo.com"]["respuestas"] == 0
    assert "contrasenaHash" not in r.text and "hash" not in r.text.lower()


def test_un_usuario_normal_no_entra_a_las_rutas_de_admin(cliente: TestClient) -> None:
    token = _registrar(cliente)["token"]
    r = cliente.get("/api/admin/usuarios", headers={"Authorization": f"Bearer {token}"})
    assert r.status_code == 403
    assert cliente.get("/api/admin/usuarios").status_code == 401


def test_crear_admin_es_idempotente_y_promueve_una_cuenta_existente(
    cliente: TestClient, motor: Engine, monkeypatch: pytest.MonkeyPatch
) -> None:
    _registrar(cliente, "jefe@correo.com")
    monkeypatch.setattr(settings, "admin_correo", "jefe@correo.com")
    monkeypatch.setattr(settings, "admin_contrasena", "otra-clave-999")

    assert main(["crear-admin"], motor=motor) == 0
    assert main(["crear-admin"], motor=motor) == 0

    with Session(motor) as sesion:
        filas = sesion.query(UsuarioTabla).filter(UsuarioTabla.rol == "admin").all()
    assert [f.correo for f in filas] == ["jefe@correo.com"]


def test_crear_admin_exige_las_variables_de_entorno(
    motor: Engine, monkeypatch: pytest.MonkeyPatch, capsys: pytest.CaptureFixture[str]
) -> None:
    monkeypatch.setattr(settings, "admin_correo", None)
    monkeypatch.setattr(settings, "admin_contrasena", None)
    assert main(["crear-admin"], motor=motor) == 1
    assert "ADMIN_CORREO" in capsys.readouterr().err
