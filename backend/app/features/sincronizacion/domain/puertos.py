import uuid
from abc import ABC, abstractmethod

from app.features.sincronizacion.domain.respuesta import RespuestaEntrante


class RepositorioSincronizacion(ABC):
    @abstractmethod
    def guardar_lote_respuestas(
        self, usuario_id: uuid.UUID, respuestas: list[RespuestaEntrante]
    ) -> tuple[int, int]:
        """Inserta respuestas en lote omitiendo duplicados por id_evento.

        Devuelve una tupla (insertados, duplicados).
        """
        ...
