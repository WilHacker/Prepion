from abc import ABC, abstractmethod

from app.features.conocimiento.domain.paquete import PaqueteConocimiento


class RepositorioConocimiento(ABC):
    @abstractmethod
    def obtener_paquete_actual(self) -> PaqueteConocimiento | None:
        """Devuelve el paquete de conocimiento con mayor versión, o None si no hay registros."""
        ...
