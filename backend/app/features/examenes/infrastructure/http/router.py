import secrets
from pathlib import Path
from typing import Annotated

from fastapi import APIRouter, Depends, Header, Query

from app.core.config import settings
from app.features.examenes.application.recolectar_examenes import (
    Portal,
    ResultadoRecoleccionDto,
    recolectar_examenes,
)
from app.features.examenes.infrastructure.adapters.portal_fcyt import PortalFcyt
from app.shared.domain.errores import NoAutorizadoError, ServicioNoDisponibleError

router = APIRouter(prefix="/examenes", tags=["examenes"])


def obtener_portal() -> Portal:
    return PortalFcyt()


def obtener_carpeta() -> Path:
    return settings.examenes_pdf_dir


def exigir_token(x_recoleccion_token: Annotated[str | None, Header()] = None) -> None:
    esperado = settings.recoleccion_token
    if not esperado:
        raise ServicioNoDisponibleError("La recolección no está habilitada en este servidor")
    if x_recoleccion_token is None or not secrets.compare_digest(
        x_recoleccion_token.encode(), esperado.encode()
    ):
        raise NoAutorizadoError("Token de recolección ausente o incorrecto")


@router.post("/recolectar", dependencies=[Depends(exigir_token)])
def recolectar(
    portal: Annotated[Portal, Depends(obtener_portal)],
    carpeta: Annotated[Path, Depends(obtener_carpeta)],
    limite: Annotated[int, Query(ge=1, le=50)] = 10,
) -> ResultadoRecoleccionDto:
    return ResultadoRecoleccionDto.desde(recolectar_examenes(portal, carpeta, limite))
