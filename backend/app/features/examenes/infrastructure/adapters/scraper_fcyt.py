"""Adaptador de web scraping para el portal SAGAA de la FCyT (requests + BeautifulSoup)."""

from pathlib import Path
from urllib.parse import urljoin, urlparse

import requests
from bs4 import BeautifulSoup, Tag

from app.features.examenes.domain.errores import DescargaExamenError
from app.features.examenes.domain.examen_remoto import ExamenRemoto
from app.features.examenes.domain.parseo_catalogo import (
    extraer_tamano_kb,
    extraer_url_de_onclick,
    inferir_gestion_y_tipo,
)

_TIMEOUT_SEGUNDOS = 30
_USER_AGENT = "PrepionBot/0.1 (+https://github.com/WilHacker/Prepion; uso educativo)"


def parsear_catalogo_html(html: str, url_base: str) -> list[ExamenRemoto]:
    """Extrae la lista de exámenes PDF desde el HTML del catálogo de la FCyT."""
    sopa = BeautifulSoup(html, "html.parser")
    examenes: list[ExamenRemoto] = []
    vistos: set[str] = set()

    for boton in sopa.find_all("input", attrs={"onclick": True}):
        if not isinstance(boton, Tag):
            continue
        onclick = str(boton.get("onclick", ""))
        url_cruda = extraer_url_de_onclick(onclick)
        if not url_cruda or not url_cruda.lower().endswith(".pdf"):
            continue
        examen = _construir_examen_desde_fila(boton, urljoin(url_base, url_cruda))
        if examen.archivo not in vistos:
            vistos.add(examen.archivo)
            examenes.append(examen)

    for enlace in sopa.find_all("a", href=True):
        if not isinstance(enlace, Tag):
            continue
        href = str(enlace.get("href", "")).strip()
        if not href.lower().endswith(".pdf"):
            continue
        examen = _construir_examen_desde_fila(enlace, urljoin(url_base, href))
        if examen.archivo not in vistos:
            vistos.add(examen.archivo)
            examenes.append(examen)

    return examenes


def _construir_examen_desde_fila(elemento: Tag, url: str) -> ExamenRemoto:
    fila = elemento.find_parent("tr")
    celdas = [c.get_text(" ", strip=True) for c in fila.find_all("td")] if fila else []

    archivo = next((c for c in celdas if c.lower().endswith(".pdf")), "")
    if not archivo:
        archivo = Path(urlparse(url).path).name

    titulo = ""
    tamano_kb: int | None = None
    for celda in celdas:
        if celda == archivo or celda.isdigit():
            continue
        kb = extraer_tamano_kb(celda)
        if kb is not None:
            tamano_kb = kb
            continue
        if celda and not titulo:
            titulo = celda

    if not titulo:
        titulo = archivo.removesuffix(".pdf")

    gestion, tipo = inferir_gestion_y_tipo(archivo, titulo)
    return ExamenRemoto(
        archivo=archivo,
        titulo=titulo,
        gestion=gestion,
        tipo=tipo,
        url=url,
        tamano_kb=tamano_kb,
    )


class ScraperFcyt:
    """Consulta y descarga exámenes PDF desde el portal oficial de la FCyT."""

    def __init__(
        self,
        sesion: requests.Session | None = None,
        timeout: int = _TIMEOUT_SEGUNDOS,
    ) -> None:
        self._sesion = sesion or requests.Session()
        self._timeout = timeout

    def listar_examenes(self, url_catalogo: str) -> list[ExamenRemoto]:
        try:
            respuesta = self._sesion.get(
                url_catalogo,
                headers={"User-Agent": _USER_AGENT},
                timeout=self._timeout,
            )
            respuesta.raise_for_status()
        except requests.RequestException as error:
            raise DescargaExamenError(
                f"No se pudo consultar el catálogo en {url_catalogo}: {error}"
            ) from error
        return parsear_catalogo_html(respuesta.text, url_catalogo)

    def descargar_pdf(self, examen: ExamenRemoto, destino: Path) -> Path:
        try:
            respuesta = self._sesion.get(
                examen.url,
                headers={"User-Agent": _USER_AGENT},
                timeout=self._timeout,
            )
            respuesta.raise_for_status()
        except requests.RequestException as error:
            raise DescargaExamenError(
                f"No se pudo descargar {examen.archivo} desde {examen.url}: {error}"
            ) from error

        contenido = respuesta.content
        if not contenido.startswith(b"%PDF"):
            raise DescargaExamenError(
                f"El archivo descargado desde {examen.url} no es un PDF válido."
            )

        destino.parent.mkdir(parents=True, exist_ok=True)
        destino.write_bytes(contenido)
        return destino
