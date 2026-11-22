"""Puertos de la feature `examenes`."""

from pathlib import Path
from typing import Protocol

from app.features.examenes.domain.examen_remoto import ExamenRemoto


class CatalogoExamenesPort(Protocol):
    """Fuente remota de exámenes oficiales de la FCyT."""

    def listar_examenes(self, url_catalogo: str) -> list[ExamenRemoto]: ...

    def descargar_pdf(self, examen: ExamenRemoto, destino: Path) -> Path: ...
