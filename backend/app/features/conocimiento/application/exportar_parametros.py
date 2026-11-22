"""Arma `parametros_conocimiento_v1.json`, el archivo que descarga cada celular.

Los parámetros BKT quedan en los valores por defecto de la app para cada tema.
Ajustarlos con pyBKT es trabajo futuro (es lento y frágil).
"""

from collections.abc import Mapping
from typing import Any

from pydantic import BaseModel, ConfigDict
from pydantic.alias_generators import to_camel

VERSION = 1


class _Dto(BaseModel):
    model_config = ConfigDict(alias_generator=to_camel, populate_by_name=True)


class _PreguntaDto(_Dto):
    pregunta_id: str
    dificultad: float


class _BktDto(_Dto):
    tema_id: str
    p_inicial: float = 0.3
    p_aprendizaje: float = 0.1
    p_adivinar: float = 0.2
    p_error: float = 0.1


class _ParametrosDto(_Dto):
    version: int
    preguntas: list[_PreguntaDto]
    bkt: list[_BktDto]


def exportar_parametros(
    dificultades: Mapping[str, float], temas_de_pregunta: Mapping[str, str]
) -> dict[str, Any]:
    """`temas_de_pregunta` mapea pregunta_id -> tema_id (los temas salen de ahí)."""
    temas = sorted(set(temas_de_pregunta.values()))
    dto = _ParametrosDto(
        version=VERSION,
        preguntas=[_PreguntaDto(pregunta_id=p, dificultad=b) for p, b in dificultades.items()],
        bkt=[_BktDto(tema_id=t) for t in temas],
    )
    return dto.model_dump(by_alias=True)
