from collections.abc import Iterator
from pathlib import Path

import pytest
from fastapi.testclient import TestClient

from app.core.config import settings
from app.features.examenes.domain.examen_publicado import ExamenPublicado
from app.features.examenes.infrastructure.http.router import obtener_carpeta, obtener_portal
from app.main import app


class _PortalFalso:
    def descargar_catalogo(self) -> list[ExamenPublicado]:
        return [
            ExamenPublicado(titulo=n, archivo=n, url=f"u/{n}", tamano="1 KB")
            for n in ("a.pdf", "b.pdf", "c.pdf")
        ]

    def descargar_pdf(self, examen: ExamenPublicado) -> bytes:
        if examen.archivo == "b.pdf":
            raise RuntimeError("roto")
        return b"%PDF-x"


@pytest.fixture
def cliente(tmp_path: Path) -> Iterator[TestClient]:
    app.dependency_overrides[obtener_portal] = _PortalFalso
    app.dependency_overrides[obtener_carpeta] = lambda: tmp_path
    yield TestClient(app)
    app.dependency_overrides.clear()


@pytest.fixture
def con_token(monkeypatch: pytest.MonkeyPatch) -> None:
    monkeypatch.setattr(settings, "recoleccion_token", "secreto")


def test_devuelve_el_resultado_en_camel_case(cliente: TestClient, con_token: None):
    respuesta = cliente.post(
        "/api/examenes/recolectar?limite=2", headers={"X-Recoleccion-Token": "secreto"}
    )

    assert respuesta.status_code == 200
    assert respuesta.json() == {
        "encontrados": 3,
        "yaDescargados": 0,
        "nuevos": ["c.pdf", "b.pdf", "a.pdf"],
        "descargados": ["c.pdf"],
        "pendientes": 2,
        "errores": [{"archivo": "b.pdf", "motivo": "roto"}],
    }


def test_sin_token_configurado_responde_503_problem_json(cliente: TestClient, monkeypatch):
    monkeypatch.setattr(settings, "recoleccion_token", None)
    respuesta = cliente.post("/api/examenes/recolectar", headers={"X-Recoleccion-Token": "x"})
    assert respuesta.status_code == 503
    assert respuesta.headers["content-type"].startswith("application/problem+json")
    assert respuesta.json()["detail"] == "La recolección no está habilitada en este servidor"


@pytest.mark.parametrize("cabeceras", [{}, {"X-Recoleccion-Token": "otro"}])
def test_token_ausente_o_incorrecto_responde_401(
    cliente: TestClient, con_token: None, cabeceras: dict[str, str]
):
    respuesta = cliente.post("/api/examenes/recolectar", headers=cabeceras)
    assert respuesta.status_code == 401
    assert respuesta.headers["content-type"].startswith("application/problem+json")


@pytest.mark.parametrize("limite", [0, 51, "abc"])
def test_limite_fuera_de_rango_responde_422(cliente: TestClient, con_token: None, limite):
    respuesta = cliente.post(
        f"/api/examenes/recolectar?limite={limite}", headers={"X-Recoleccion-Token": "secreto"}
    )
    assert respuesta.status_code == 422


def test_obtener_portal_y_carpeta_usan_los_valores_por_defecto():
    assert obtener_portal().__class__.__name__ == "PortalFcyt"
    assert obtener_carpeta() == settings.examenes_pdf_dir
