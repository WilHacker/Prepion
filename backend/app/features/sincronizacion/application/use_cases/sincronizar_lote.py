import uuid

from app.features.sincronizacion.domain.puertos import RepositorioSincronizacion
from app.features.sincronizacion.domain.respuesta import RespuestaEntrante


class SincronizarLote:
    def __init__(self, repositorio: RepositorioSincronizacion) -> None:
        self._repositorio = repositorio

    def ejecutar(
        self, usuario_id: uuid.UUID, respuestas: list[RespuestaEntrante]
    ) -> tuple[int, int]:
        if not respuestas:
            return 0, 0
        return self._repositorio.guardar_lote_respuestas(usuario_id, respuestas)
