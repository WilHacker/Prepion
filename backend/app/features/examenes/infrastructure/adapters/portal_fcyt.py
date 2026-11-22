"""Lector del portal de admisión de la FCyT (UMSS): catálogo de exámenes y descarga de PDF."""

import re
from urllib.parse import unquote, urlsplit

import requests
from bs4 import BeautifulSoup, Tag

from app.features.examenes.domain.errores import ArchivoInseguroError, PortalNoDisponibleError
from app.features.examenes.domain.examen_publicado import ExamenPublicado

URL_CATALOGO = "https://sagaa.fcyt.umss.edu.bo/admision/examenes.php"
HOST_PERMITIDO = "sagaa.fcyt.umss.edu.bo"
RUTA_PERMITIDA = "/admision/archivos/"
USER_AGENT = "Prepion-recolector-educativo (Abstracthon 2026)"
TIMEOUT_SEGUNDOS = 20
TAMANO_MAXIMO = 10 * 1024 * 1024
_NOMBRE_VALIDO = re.compile(r"^[A-Za-z0-9][A-Za-z0-9_.-]*\.pdf$")
_URL_EN_ONCLICK = re.compile(r"window\.location\s*=\s*'([^']+)'")


def archivo_seguro(url: str) -> str | None:
    """Devuelve el nombre del PDF si la URL es del portal oficial; si no, None."""
    try:
        partes = urlsplit(url)
        puerto = partes.port
    except ValueError:
        return None
    if partes.scheme not in ("http", "https") or partes.hostname != HOST_PERMITIDO:
        return None
    if puerto is not None or partes.username or partes.password:
        return None
    if not partes.path.startswith(RUTA_PERMITIDA) or "%" in partes.path:
        return None
    nombre = unquote(partes.path[len(RUTA_PERMITIDA) :])
    return nombre if _NOMBRE_VALIDO.fullmatch(nombre) and ".." not in nombre else None


def _texto(celda: Tag) -> str:
    return " ".join(celda.get_text(" ").split())


def extraer_examenes(html: str) -> list[ExamenPublicado]:
    """Lee las filas con botón «Descargar»; descarta las que no pasan la validación."""
    examenes: list[ExamenPublicado] = []
    for fila in BeautifulSoup(html, "html.parser").find_all("tr"):
        boton = fila.find("input", attrs={"type": "button"})
        celdas = fila.find_all("td")
        onclick = boton.get("onclick") if boton else None
        coincidencia = _URL_EN_ONCLICK.search(onclick) if isinstance(onclick, str) else None
        if not coincidencia or len(celdas) < 4:
            continue
        url = coincidencia.group(1)
        archivo = archivo_seguro(url)
        if archivo is None:
            continue
        examenes.append(
            ExamenPublicado(
                titulo=_texto(celdas[1]), archivo=archivo, url=url, tamano=_texto(celdas[3])
            )
        )
    return examenes


class PortalFcyt:
    """Cliente HTTP del portal; solo habla con el host oficial."""

    def __init__(self, sesion: requests.Session | None = None) -> None:
        self._sesion = sesion or requests.Session()
        self._sesion.headers["User-Agent"] = USER_AGENT

    def descargar_catalogo(self) -> list[ExamenPublicado]:
        try:
            respuesta = self._sesion.get(URL_CATALOGO, timeout=TIMEOUT_SEGUNDOS)
            respuesta.raise_for_status()
        except requests.RequestException as error:
            raise PortalNoDisponibleError(f"No se pudo leer el portal: {error}") from error
        return extraer_examenes(respuesta.content.decode("iso-8859-1"))

    def descargar_pdf(self, examen: ExamenPublicado) -> bytes:
        if archivo_seguro(examen.url) != examen.archivo:
            raise ArchivoInseguroError(f"URL no permitida para {examen.archivo}.")
        try:
            # Sin redirecciones: una redirección podría llevar a otro host (SSRF).
            with self._sesion.get(
                examen.url, timeout=TIMEOUT_SEGUNDOS, stream=True, allow_redirects=False
            ) as respuesta:
                respuesta.raise_for_status()
                contenido = respuesta.raw.read(TAMANO_MAXIMO + 1, decode_content=True)
        except requests.RequestException as error:
            raise PortalNoDisponibleError(f"No se pudo bajar {examen.archivo}: {error}") from error
        if len(contenido) > TAMANO_MAXIMO:
            raise PortalNoDisponibleError(f"{examen.archivo} supera los 10 MB.")
        if not contenido.startswith(b"%PDF"):
            raise PortalNoDisponibleError(f"{examen.archivo} no es un PDF.")
        return contenido
