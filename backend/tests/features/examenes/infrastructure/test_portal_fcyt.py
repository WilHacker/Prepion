import io
from pathlib import Path
from types import SimpleNamespace
from typing import Any

import pytest
import requests

from app.features.examenes.domain.errores import ArchivoInseguroError, PortalNoDisponibleError
from app.features.examenes.domain.examen_publicado import ExamenPublicado
from app.features.examenes.infrastructure.adapters.portal_fcyt import (
    PortalFcyt,
    archivo_seguro,
    extraer_examenes,
)

FIXTURE = Path(__file__).parent.parent / "fixtures" / "portal_fcyt.html"
BASE = "https://sagaa.fcyt.umss.edu.bo/admision/archivos/"


def test_extrae_las_filas_reales_y_descarta_las_hostiles():
    # Arrange
    html = FIXTURE.read_text(encoding="ascii")

    # Act
    examenes = extraer_examenes(html)

    # Assert
    assert len(examenes) == 6
    assert examenes[0] == ExamenPublicado(
        titulo="Primer Examen de Ingreso FCyT 1-2005",
        archivo="050_ExamenAdmisionPrimerOpcion1-2005.pdf",
        url=BASE + "050_ExamenAdmisionPrimerOpcion1-2005.pdf",
        tamano="139 KB",
    )
    assert examenes[-1].archivo == "2026-2-2op.pdf"
    assert all(e.url.startswith(BASE) for e in examenes)


@pytest.mark.parametrize(
    "url",
    [
        "https://evil.example.com/admision/archivos/a.pdf",
        "https://sagaa.fcyt.umss.edu.bo.evil.com/admision/archivos/a.pdf",
        "https://sagaa.fcyt.umss.edu.bo@evil.com/admision/archivos/a.pdf",
        "https://sagaa.fcyt.umss.edu.bo:8080/admision/archivos/a.pdf",
        "ftp://sagaa.fcyt.umss.edu.bo/admision/archivos/a.pdf",
        BASE + "../../secreto.pdf",
        BASE + "..%2f..%2fsecreto.pdf",
        BASE + "sub/a.pdf",
        BASE + "a.exe",
        BASE + ".oculto.pdf",
        "https://sagaa.fcyt.umss.edu.bo/otra/a.pdf",
        "no es una url",
    ],
)
def test_rechaza_urls_que_no_son_del_portal(url: str):
    assert archivo_seguro(url) is None


def test_acepta_http_y_https_del_host_oficial():
    assert archivo_seguro(BASE + "2026-2-1op.pdf") == "2026-2-1op.pdf"
    assert archivo_seguro(BASE.replace("https", "http") + "a_b-1.pdf") == "a_b-1.pdf"


class _Sesion:
    def __init__(self, cuerpo: bytes = b"", error: Exception | None = None) -> None:
        self.headers: dict[str, str] = {}
        self.cuerpo, self.error, self.llamadas = cuerpo, error, []

    def get(self, url: str, **kwargs: Any) -> "_Respuesta":
        self.llamadas.append((url, kwargs))
        if self.error:
            raise self.error
        return _Respuesta(self.cuerpo)


class _Respuesta:
    def __init__(self, cuerpo: bytes) -> None:
        self.content = cuerpo
        self.raw = SimpleNamespace(read=lambda n, decode_content: io.BytesIO(cuerpo).read(n))

    def raise_for_status(self) -> None:
        return None

    def __enter__(self) -> "_Respuesta":
        return self

    def __exit__(self, *_: object) -> None:
        return None


def _examen(url: str = BASE + "a.pdf", archivo: str = "a.pdf") -> ExamenPublicado:
    return ExamenPublicado(titulo="t", archivo=archivo, url=url, tamano="1 KB")


def test_catalogo_se_decodifica_como_iso_8859_1_y_manda_user_agent():
    # Arrange
    html = FIXTURE.read_text(encoding="ascii").replace("Primer Examen", "Primer Exámen")
    sesion = _Sesion(html.encode("iso-8859-1"))

    # Act
    examenes = PortalFcyt(sesion).descargar_catalogo()  # type: ignore[arg-type]

    # Assert
    assert examenes[0].titulo == "Primer Exámen de Ingreso FCyT 1-2005"
    assert sesion.headers["User-Agent"] == "Prepion-recolector-educativo (Abstracthon 2026)"
    assert sesion.llamadas[0][1]["timeout"] == 20


def test_catalogo_traduce_fallos_de_red_a_error_de_dominio():
    sesion = _Sesion(error=requests.ConnectionError("sin red"))
    with pytest.raises(PortalNoDisponibleError):
        PortalFcyt(sesion).descargar_catalogo()  # type: ignore[arg-type]


def test_descarga_un_pdf_valido_sin_seguir_redirecciones():
    sesion = _Sesion(b"%PDF-1.4 contenido")
    contenido = PortalFcyt(sesion).descargar_pdf(_examen())  # type: ignore[arg-type]
    assert contenido == b"%PDF-1.4 contenido"
    assert sesion.llamadas[0][1]["allow_redirects"] is False


def test_rechaza_un_archivo_que_no_es_pdf():
    with pytest.raises(PortalNoDisponibleError, match="no es un PDF"):
        PortalFcyt(_Sesion(b"<html>")).descargar_pdf(_examen())  # type: ignore[arg-type]


def test_rechaza_un_archivo_mayor_a_10_mb():
    grande = b"%PDF" + b"0" * (10 * 1024 * 1024)
    with pytest.raises(PortalNoDisponibleError, match="10 MB"):
        PortalFcyt(_Sesion(grande)).descargar_pdf(_examen())  # type: ignore[arg-type]


def test_rechaza_descargar_de_un_host_ajeno_sin_hacer_la_peticion():
    # Arrange
    sesion = _Sesion(b"%PDF")
    examen = _examen("https://evil.example.com/admision/archivos/a.pdf")

    # Act / Assert
    with pytest.raises(ArchivoInseguroError):
        PortalFcyt(sesion).descargar_pdf(examen)  # type: ignore[arg-type]
    assert sesion.llamadas == []


def test_descarga_traduce_fallos_de_red_a_error_de_dominio():
    sesion = _Sesion(error=requests.Timeout("lento"))
    with pytest.raises(PortalNoDisponibleError):
        PortalFcyt(sesion).descargar_pdf(_examen())  # type: ignore[arg-type]
