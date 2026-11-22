from typing import Any

from app.features.preguntas.domain.banco import BancoRepositorio, BancoVersion
from app.features.preguntas.domain.errores import BancoNoEncontradoError


def obtener_banco_actual(repositorio: BancoRepositorio) -> BancoVersion:
    actual = repositorio.obtener_actual()
    if actual is None:
        raise BancoNoEncontradoError("Todavía no hay un banco de preguntas publicado.")
    return actual


def descargar_banco(repositorio: BancoRepositorio, version: int) -> dict[str, Any]:
    contenido = repositorio.obtener_contenido(version)
    if contenido is None:
        raise BancoNoEncontradoError(f"No existe la versión {version} del banco.")
    return contenido
