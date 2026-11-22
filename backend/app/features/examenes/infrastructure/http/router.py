from pathlib import Path
from typing import Annotated

from fastapi import APIRouter, Depends, Query

from app.core.config import settings
from app.core.seguridad import exigir_token
from app.features.examenes.application.recolectar_examenes import (
    Portal,
    ResultadoRecoleccionDto,
    recolectar_examenes,
)
from app.features.examenes.infrastructure.adapters.portal_fcyt import PortalFcyt

router = APIRouter(prefix="/examenes", tags=["examenes"])


def obtener_portal() -> Portal:
    return PortalFcyt()


def obtener_carpeta() -> Path:
    return settings.examenes_pdf_dir


@router.post("/recolectar", dependencies=[Depends(exigir_token)])
def recolectar(
    portal: Annotated[Portal, Depends(obtener_portal)],
    carpeta: Annotated[Path, Depends(obtener_carpeta)],
    limite: Annotated[int, Query(ge=1, le=50)] = 10,
) -> ResultadoRecoleccionDto:
    return ResultadoRecoleccionDto.desde(recolectar_examenes(portal, carpeta, limite))
