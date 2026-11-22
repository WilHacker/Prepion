"""Recalibra el modelo con el banco publicado y guarda el paquete como versión nueva."""

from typing import Any, Literal

from pydantic import BaseModel, ConfigDict
from pydantic.alias_generators import to_camel

from app.features.conocimiento.application.calibrar_dificultad import (
    MINIMO_DE_USUARIOS,
    calibrar_dificultad,
)
from app.features.conocimiento.application.exportar_parametros import exportar_parametros
from app.features.conocimiento.application.simular_respuestas import simular_respuestas
from app.features.conocimiento.domain.errores import (
    DatosInsuficientesError,
    SinBancoPublicadoError,
)
from app.features.conocimiento.domain.puertos import (
    BancoPublicado,
    RepositorioPaquetes,
    RespuestasReales,
)

USUARIOS_SIMULADOS = 60
SEMILLA_SIMULACION = 7


class ResumenRecalibracionDto(BaseModel):
    model_config = ConfigDict(alias_generator=to_camel, populate_by_name=True)

    version: int
    origen: Literal["simulado", "real"]
    usuarios: int
    preguntas: int
    temas: int


def _calibrar_con_respuestas_reales(
    reales: RespuestasReales, temas: dict[str, str]
) -> tuple[dict[str, float], int] | None:
    respuestas = [r for r in reales.listar() if r.pregunta_id in temas]
    usuarios = len({r.usuario_id for r in respuestas})
    if usuarios < MINIMO_DE_USUARIOS:
        return None
    try:
        return calibrar_dificultad(respuestas), usuarios
    except DatosInsuficientesError:
        return None


def recalibrar_conocimiento(
    banco: BancoPublicado, reales: RespuestasReales, paquetes: RepositorioPaquetes
) -> ResumenRecalibracionDto:
    contenido = banco.obtener_ultimo()
    if contenido is None:
        raise SinBancoPublicadoError(
            "No hay un banco de preguntas publicado; publica uno antes de recalibrar"
        )
    temas = {p["id"]: p["temaId"] for p in contenido["preguntas"]}

    calibrado = _calibrar_con_respuestas_reales(reales, temas)
    origen: Literal["simulado", "real"] = "real"
    if calibrado is None:
        origen = "simulado"
        simuladas, _ = simular_respuestas(list(temas), USUARIOS_SIMULADOS, SEMILLA_SIMULACION)
        calibrado = (calibrar_dificultad(simuladas), USUARIOS_SIMULADOS)
    dificultades, usuarios = calibrado

    paquete: dict[str, Any] = exportar_parametros(
        dificultades, temas, origen=origen, usuarios=usuarios
    )
    version = paquetes.ultima_version() + 1
    paquetes.guardar(version, paquete)
    return ResumenRecalibracionDto(
        version=version,
        origen=origen,
        usuarios=usuarios,
        preguntas=len(paquete["preguntas"]),
        temas=len(paquete["bkt"]),
    )
