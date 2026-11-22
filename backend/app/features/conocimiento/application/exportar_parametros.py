"""Arma `parametros_conocimiento_v1.json`, el archivo que descarga cada celular.

Incluye las dificultades calibradas con IRT (Rasch 1PL) por pregunta y los
parámetros BKT entrenados por tema (con valores por defecto si algún tema no
fue calibrado todavía).
"""

from collections.abc import Mapping
from typing import Any

from pydantic import BaseModel, ConfigDict
from pydantic.alias_generators import to_camel

from app.features.conocimiento.domain.parametros_bkt import ParametrosBkt

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
    dificultades: Mapping[str, float],
    temas_de_pregunta: Mapping[str, str],
    parametros_bkt: Mapping[str, ParametrosBkt] | None = None,
) -> dict[str, Any]:
    """`temas_de_pregunta` mapea pregunta_id -> tema_id (los temas salen de ahí)."""
    temas = sorted(set(temas_de_pregunta.values()))
    bkt_por_tema = parametros_bkt or {}
    lista_bkt: list[_BktDto] = []
    for tema_id in temas:
        calibrado = bkt_por_tema.get(tema_id)
        if calibrado is not None:
            lista_bkt.append(
                _BktDto(
                    tema_id=tema_id,
                    p_inicial=calibrado.p_inicial,
                    p_aprendizaje=calibrado.p_aprendizaje,
                    p_adivinar=calibrado.p_adivinar,
                    p_error=calibrado.p_error,
                )
            )
        else:
            lista_bkt.append(_BktDto(tema_id=tema_id))

    dto = _ParametrosDto(
        version=VERSION,
        preguntas=[
            _PreguntaDto(pregunta_id=p, dificultad=round(b, 4)) for p, b in dificultades.items()
        ],
        bkt=lista_bkt,
    )
    return dto.model_dump(by_alias=True)
