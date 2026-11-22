from dataclasses import dataclass
from datetime import datetime
from typing import Any, Protocol


@dataclass(frozen=True)
class BancoVersion:
    """Resumen de una versión publicada del banco de preguntas."""

    version: int
    cantidad: int
    publicada_en: datetime


class BancoRepositorio(Protocol):
    """Puerto: dónde se guardan las versiones publicadas del banco."""

    def obtener_actual(self) -> BancoVersion | None: ...

    def obtener_contenido(self, version: int) -> dict[str, Any] | None: ...

    def existe_version(self, version: int) -> bool: ...

    def guardar(self, version: int, cantidad: int, contenido: dict[str, Any]) -> None: ...
