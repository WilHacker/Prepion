from abc import ABC, abstractmethod
from typing import Any, Protocol

from app.features.conocimiento.domain.paquete import PaqueteConocimiento
from app.features.conocimiento.domain.respuesta_observada import RespuestaObservada


class BancoPublicado(Protocol):
    def obtener_ultimo(self) -> dict[str, Any] | None:
        """Contenido JSON del banco publicado más reciente, o None."""


class RespuestasReales(Protocol):
    def listar(self) -> list[RespuestaObservada]: ...


class RepositorioPaquetes(Protocol):
    def obtener_actual(self) -> dict[str, Any] | None: ...

    def ultima_version(self) -> int:
        """Versión más alta guardada (0 si no hay)."""

    def guardar(self, version: int, contenido: dict[str, Any]) -> None: ...


class RepositorioConocimiento(ABC):
    @abstractmethod
    def obtener_paquete_actual(self) -> PaqueteConocimiento | None:
        """Devuelve el paquete de conocimiento con mayor versión, o None si no hay registros."""
        ...
