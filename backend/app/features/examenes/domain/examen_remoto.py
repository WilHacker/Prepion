"""Metadatos de un examen disponible en el portal oficial de la FCyT."""

from dataclasses import dataclass


@dataclass(frozen=True)
class ExamenRemoto:
    archivo: str
    titulo: str
    gestion: str
    tipo: str
    url: str
    tamano_kb: int | None = None
