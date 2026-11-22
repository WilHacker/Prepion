"""Seguridad compartida: token de las tareas programadas (n8n)."""

import secrets
from typing import Annotated

from fastapi import Header

from app.core.config import settings
from app.shared.domain.errores import NoAutorizadoError, ServicioNoDisponibleError


def exigir_token(x_recoleccion_token: Annotated[str | None, Header()] = None) -> None:
    esperado = settings.recoleccion_token
    if not esperado:
        raise ServicioNoDisponibleError("La recolección no está habilitada en este servidor")
    if x_recoleccion_token is None or not secrets.compare_digest(
        x_recoleccion_token.encode(), esperado.encode()
    ):
        raise NoAutorizadoError("Token de recolección ausente o incorrecto")
