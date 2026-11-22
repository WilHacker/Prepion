"""Adaptadores SQL de los puertos de conocimiento.

Leen `banco_versiones` y `respuestas` con tablas ligeras de SQLAlchemy Core para no importar
el interior de otras features.
"""

from typing import Any

from sqlalchemy import JSON, Boolean, Column, Integer, MetaData, Table, Uuid, func, select
from sqlmodel import Session, col
from sqlmodel import select as sqlmodel_select

from app.features.conocimiento.domain.respuesta_observada import RespuestaObservada
from app.features.conocimiento.infrastructure.persistence.tablas import PaqueteConocimientoTabla

_lectura = MetaData()
_banco_versiones = Table(
    "banco_versiones",
    _lectura,
    Column("version", Integer),
    Column("contenido", JSON),
)
_respuestas = Table(
    "respuestas",
    _lectura,
    Column("usuario_id", Uuid),
    Column("pregunta_id", Uuid),
    Column("es_correcta", Boolean),
)


class BancoPublicadoSql:
    def __init__(self, sesion: Session) -> None:
        self._sesion = sesion

    def obtener_ultimo(self) -> dict[str, Any] | None:
        consulta = (
            select(_banco_versiones.c.contenido)
            .order_by(_banco_versiones.c.version.desc())
            .limit(1)
        )
        return self._sesion.execute(consulta).scalar_one_or_none()


class RespuestasRealesSql:
    def __init__(self, sesion: Session) -> None:
        self._sesion = sesion

    def listar(self) -> list[RespuestaObservada]:
        filas = self._sesion.execute(
            select(_respuestas.c.usuario_id, _respuestas.c.pregunta_id, _respuestas.c.es_correcta)
        )
        return [RespuestaObservada(str(u), str(p), bool(ok)) for u, p, ok in filas]


class PaquetesConocimientoSql:
    def __init__(self, sesion: Session) -> None:
        self._sesion = sesion

    def obtener_actual(self) -> dict[str, Any] | None:
        consulta = (
            sqlmodel_select(PaqueteConocimientoTabla)
            .order_by(col(PaqueteConocimientoTabla.version).desc())
            .limit(1)
        )
        fila = self._sesion.exec(consulta).first()
        return None if fila is None else fila.contenido

    def ultima_version(self) -> int:
        consulta = select(func.max(PaqueteConocimientoTabla.version))
        return self._sesion.execute(consulta).scalar_one_or_none() or 0

    def guardar(self, version: int, contenido: dict[str, Any]) -> None:
        self._sesion.add(PaqueteConocimientoTabla(version=version, contenido=contenido))
        self._sesion.commit()
