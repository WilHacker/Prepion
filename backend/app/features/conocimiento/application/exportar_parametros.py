"""Arma el paquete de conocimiento (`parametros_conocimiento_v1.json`) que descarga cada celular.

Incluye las dificultades calibradas con IRT (Rasch 1PL) por pregunta y los
parámetros BKT entrenados por tema. Si un tema no tiene parámetros BKT
calibrados, `pInicial` se estima desde IRT como el promedio de `1/(1+exp(b))`
acotado a `[0.1, 0.9]` y los demás parámetros quedan en los valores por defecto.
"""

import math
from collections import defaultdict
from collections.abc import Callable, Mapping
from datetime import UTC, datetime
from typing import Any, Literal

from pydantic import BaseModel, ConfigDict
from pydantic.alias_generators import to_camel

from app.features.conocimiento.domain.parametros_bkt import ParametrosBkt

VERSION = 1
P_INICIAL_POR_DEFECTO = 0.3
P_INICIAL_MIN = 0.1
P_INICIAL_MAX = 0.9


class _Dto(BaseModel):
    model_config = ConfigDict(alias_generator=to_camel, populate_by_name=True)


class _PreguntaDto(_Dto):
    pregunta_id: str
    dificultad: float


class _BktDto(_Dto):
    tema_id: str
    p_inicial: float = P_INICIAL_POR_DEFECTO
    p_aprendizaje: float = 0.1
    p_adivinar: float = 0.2
    p_error: float = 0.1


class _ParametrosDto(_Dto):
    version: int
    origen: Literal["simulado", "real"]
    usuarios: int
    generado_en: str
    preguntas: list[_PreguntaDto]
    bkt: list[_BktDto]


def _ahora_utc() -> datetime:
    return datetime.now(UTC)


def _p_inicial_por_tema(
    dificultades: Mapping[str, float], temas_de_pregunta: Mapping[str, str]
) -> dict[str, float]:
    por_tema: dict[str, list[float]] = defaultdict(list)
    for pregunta, b in dificultades.items():
        if pregunta in temas_de_pregunta:
            por_tema[temas_de_pregunta[pregunta]].append(1 / (1 + math.exp(b)))
    return {
        tema: round(min(P_INICIAL_MAX, max(P_INICIAL_MIN, sum(ps) / len(ps))), 4)
        for tema, ps in por_tema.items()
    }


def exportar_parametros(
    dificultades: Mapping[str, float],
    temas_de_pregunta: Mapping[str, str],
    parametros_bkt: Mapping[str, ParametrosBkt] | None = None,
    *,
    origen: Literal["simulado", "real"] = "simulado",
    usuarios: int = 0,
    reloj: Callable[[], datetime] = _ahora_utc,
) -> dict[str, Any]:
    """`temas_de_pregunta` mapea pregunta_id -> tema_id (los temas salen de ahí)."""
    p_iniciales = _p_inicial_por_tema(dificultades, temas_de_pregunta)
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
            lista_bkt.append(
                _BktDto(
                    tema_id=tema_id,
                    p_inicial=p_iniciales.get(tema_id, P_INICIAL_POR_DEFECTO),
                )
            )

    dto = _ParametrosDto(
        version=VERSION,
        origen=origen,
        usuarios=usuarios,
        generado_en=reloj().astimezone(UTC).strftime("%Y-%m-%dT%H:%M:%SZ"),
        preguntas=[_PreguntaDto(pregunta_id=p, dificultad=b) for p, b in dificultades.items()],
        bkt=lista_bkt,
    )
    return dto.model_dump(by_alias=True)
