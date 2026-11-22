"""Observación secuencial de una respuesta de un estudiante en un tema (para BKT)."""

from dataclasses import dataclass


@dataclass(frozen=True)
class RespuestaSecuencial:
    usuario_id: str
    tema_id: str
    paso: int
    es_correcta: bool
