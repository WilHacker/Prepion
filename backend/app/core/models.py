"""Registra todas las tablas en la metadata para que Alembic las vea."""

from app.features.auth.infrastructure.persistence.tablas import UsuarioTabla
from app.features.conocimiento.infrastructure.persistence.tablas import PaqueteConocimientoTabla
from app.features.examenes.infrastructure.persistence.tablas import ExamenTabla
from app.features.preguntas.infrastructure.persistence.tablas import (
    BancoVersionTabla,
    PreguntaTabla,
    TemaTabla,
)
from app.features.reportes.infrastructure.persistence.tablas import ReporteTabla
from app.features.sincronizacion.infrastructure.persistence.tablas import RespuestaTabla

__all__ = [
    "BancoVersionTabla",
    "ExamenTabla",
    "PaqueteConocimientoTabla",
    "PreguntaTabla",
    "ReporteTabla",
    "RespuestaTabla",
    "TemaTabla",
    "UsuarioTabla",
]
