"""Casos de uso para listar y descargar exámenes oficiales desde el portal de la FCyT."""

from collections.abc import Sequence
from pathlib import Path

from app.features.examenes.domain.examen_remoto import ExamenRemoto
from app.features.examenes.domain.puertos import CatalogoExamenesPort

URL_CATALOGO_FCYT = "https://sagaa.fcyt.umss.edu.bo/admision/examenes.php"


def filtrar_examenes(
    examenes: Sequence[ExamenRemoto],
    *,
    gestion: str | None = None,
    tipo: str | None = None,
    limite: int | None = None,
) -> list[ExamenRemoto]:
    """Filtra exámenes por gestión/tipo y toma los últimos `limite` (los más recientes)."""
    resultado = list(examenes)
    if gestion:
        gestion_norm = gestion.strip().lower()
        resultado = [e for e in resultado if e.gestion.lower() == gestion_norm]
    if tipo:
        tipo_norm = tipo.strip().lower()
        resultado = [e for e in resultado if e.tipo.lower() == tipo_norm]
    if limite is not None and limite > 0:
        resultado = resultado[-limite:]
    return resultado


def descargar_examenes(
    catalogo: CatalogoExamenesPort,
    carpeta_destino: Path,
    *,
    url_catalogo: str = URL_CATALOGO_FCYT,
    gestion: str | None = None,
    tipo: str | None = None,
    limite: int | None = None,
    sobrescribir: bool = False,
) -> list[Path]:
    """Descarga los PDFs seleccionados a `carpeta_destino`, omitiendo los ya existentes."""
    examenes = filtrar_examenes(
        catalogo.listar_examenes(url_catalogo),
        gestion=gestion,
        tipo=tipo,
        limite=limite,
    )
    carpeta_destino.mkdir(parents=True, exist_ok=True)
    descargados: list[Path] = []
    for examen in examenes:
        destino = carpeta_destino / examen.archivo
        if destino.exists() and not sobrescribir:
            continue
        descargados.append(catalogo.descargar_pdf(examen, destino))
    return descargados
