from dataclasses import dataclass


@dataclass(frozen=True)
class ExamenPublicado:
    """Un PDF listado en el portal de la Facultad."""

    titulo: str
    archivo: str
    url: str
    tamano: str
