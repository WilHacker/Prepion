import uuid
from datetime import UTC, datetime
from typing import Any

from sqlalchemy.dialects.postgresql import insert as pg_insert
from sqlalchemy.dialects.sqlite import insert as sqlite_insert
from sqlmodel import Session, col, select

from app.features.sincronizacion.domain.puertos import RepositorioSincronizacion
from app.features.sincronizacion.domain.respuesta import RespuestaEntrante
from app.features.sincronizacion.infrastructure.persistence.tablas import RespuestaTabla


class RepositorioRespuestasSql(RepositorioSincronizacion):
    def __init__(self, sesion: Session) -> None:
        self._sesion = sesion

    def guardar_lote_respuestas(
        self, usuario_id: uuid.UUID, respuestas: list[RespuestaEntrante]
    ) -> tuple[int, int]:
        if not respuestas:
            return 0, 0

        # Detectar qué eventos ya existen para calcular inserciones vs duplicados
        ids = [r.id_evento for r in respuestas]
        existentes_query = select(RespuestaTabla.id_evento).where(
            col(RespuestaTabla.id_evento).in_(ids)
        )
        existentes_ids = set(self._sesion.exec(existentes_query).all())

        ahora = datetime.now(UTC)
        filas: list[dict[str, Any]] = [
            {
                "id_evento": r.id_evento,
                "usuario_id": usuario_id,
                "pregunta_id": r.pregunta_id,
                "opcion_elegida": r.opcion_elegida,
                "es_correcta": r.es_correcta,
                "tiempo_ms": r.tiempo_ms,
                "respondida_en": r.respondida_en,
                "creado_en": ahora,
                "actualizado_en": ahora,
            }
            for r in respuestas
        ]

        # Detectar el dialecto del motor conectado
        dialecto = "sqlite"
        if self._sesion.bind is not None and hasattr(self._sesion.bind, "dialect"):
            dialecto = self._sesion.bind.dialect.name

        if dialecto == "postgresql":
            stmt_pg = pg_insert(RespuestaTabla).values(filas)
            stmt_pg = stmt_pg.on_conflict_do_nothing(index_elements=["id_evento"])
            self._sesion.exec(stmt_pg)
        else:
            stmt_sqlite = sqlite_insert(RespuestaTabla).values(filas)
            stmt_sqlite = stmt_sqlite.on_conflict_do_nothing(index_elements=["id_evento"])
            self._sesion.exec(stmt_sqlite)

        self._sesion.commit()

        # Calcular cuántos fueron insertados efectivamente
        duplicados = len(existentes_ids)
        insertados = len(respuestas) - duplicados
        return insertados, duplicados
