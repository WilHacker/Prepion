from collections.abc import Iterator
from pathlib import Path

import pytest
from fastapi.testclient import TestClient
from sqlalchemy import Engine
from sqlalchemy.pool import StaticPool
from sqlmodel import Session, SQLModel, create_engine

from app.core.config import settings
from app.core.database import get_session
from app.features.administracion.application import publicar_examen_curado as publicar
from app.features.administracion.domain.curabilidad import Veredicto, evaluar
from app.features.administracion.infrastructure.http.router import obtener_analizador
from app.features.auth.infrastructure.persistence.tablas import UsuarioTabla
from app.features.conocimiento.infrastructure.persistence.tablas import PaqueteConocimientoTabla
from app.features.cuentas.infrastructure.cli import main
from app.features.examenes.domain.pregunta_extraida import PreguntaExtraida
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
    ("GET", "/api/admin/examenes/2026-1-1op.pdf/preguntas"),
    ("POST", "/api/admin/examenes/2026-1-1op.pdf/publicar"),
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


ARCHIVO = "2026-1-1op.pdf"


def _pregunta(codigo: str, opciones: tuple[str, ...] = ("a", "b", "c"), **extra: object):
    return PreguntaExtraida(
        serie=1,
        codigo=codigo,
        pagina=1,
        enunciado=f"Enunciado {codigo}",
        opciones=opciones,
        requiere_imagen=False,
        **extra,  # type: ignore[arg-type]
    )


@pytest.fixture
def pdf_extraido(monkeypatch: pytest.MonkeyPatch) -> None:
    filas = [
        _pregunta("A1"),
        _pregunta("A1", ("a", "b", "c", "d")),  # misma pregunta en otra serie: gana la completa
        _pregunta("F2"),
        _pregunta("Q3", ("solo una",)),
        _pregunta("B4", duplicada_de="S1-B1"),
    ]
    monkeypatch.setattr(publicar, "extraer_preguntas", lambda ruta, destino: filas)


def _entrada(codigo: str, respuesta: str = "A") -> dict[str, str]:
    return {"codigo": codigo, "respuesta": respuesta, "tema": "Tema X", "explicacion": "Porque sí"}


def _publicar(cliente: TestClient, *entradas: dict[str, str], archivo: str = ARCHIVO):
    return cliente.post(
        f"/api/admin/examenes/{archivo}/publicar",
        json={"preguntas": list(entradas)},
        headers=_cabecera(cliente),
    )


@pytest.mark.usefixtures("pdf_extraido")
def test_lista_las_preguntas_sin_duplicadas_y_prefiere_la_version_con_mas_opciones(
    cliente: TestClient,
) -> None:
    r = cliente.get(f"/api/admin/examenes/{ARCHIVO}/preguntas", headers=_cabecera(cliente))

    assert r.status_code == 200
    por_codigo = {p["codigo"]: p for p in r.json()}
    assert sorted(por_codigo) == ["A1", "F2", "Q3"]
    assert len(por_codigo["A1"]["opciones"]) == 4


@pytest.mark.usefixtures("pdf_extraido")
def test_publicar_crea_la_primera_version_del_banco(cliente: TestClient) -> None:
    r = _publicar(cliente, _entrada("A1", "b"), _entrada("F2"))

    assert r.status_code == 200
    assert r.json() == {"version": 1, "agregadas": 2, "totalBanco": 2}


@pytest.mark.usefixtures("pdf_extraido")
def test_publicar_de_nuevo_actualiza_sin_duplicar_y_sube_la_version(
    cliente: TestClient,
) -> None:
    _publicar(cliente, _entrada("A1"))
    r = _publicar(cliente, _entrada("A1", "c"), _entrada("F2"))

    assert r.json() == {"version": 2, "agregadas": 1, "totalBanco": 2}


@pytest.mark.usefixtures("pdf_extraido")
@pytest.mark.parametrize(
    "entrada",
    [
        _entrada("Z9"),  # no existe en el PDF
        _entrada("A1", "Z"),  # respuesta fuera de A-E
        _entrada("Q3"),  # menos de dos opciones
    ],
)
def test_publicar_rechaza_entradas_invalidas(cliente: TestClient, entrada: dict[str, str]) -> None:
    assert _publicar(cliente, entrada).status_code >= 400


@pytest.mark.usefixtures("pdf_extraido")
@pytest.mark.parametrize("archivo", ["otro.pdf", "..%2Fsecreto.pdf", "nota.txt"])
def test_publicar_rechaza_archivos_inexistentes_o_con_nombre_peligroso(
    cliente: TestClient, archivo: str
) -> None:
    assert _publicar(cliente, _entrada("A1"), archivo=archivo).status_code >= 400
