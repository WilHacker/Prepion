from typing import Annotated

from fastapi import APIRouter, Depends
from sqlmodel import Session

from app.core.database import get_session
from app.features.conocimiento.application.dto.paquete_actual_response import (
    PaqueteActualResponse,
)
from app.features.conocimiento.application.use_cases.obtener_paquete_actual import (
    ObtenerPaqueteActual,
)
from app.features.conocimiento.infrastructure.persistence.repositorio_conocimiento_sql import (
    RepositorioConocimientoSql,
)

router = APIRouter(prefix="/paquetes-conocimiento", tags=["conocimiento"])

SesionDep = Annotated[Session, Depends(get_session)]


@router.get("/actual", response_model=PaqueteActualResponse)
def paquete_actual(sesion: SesionDep) -> PaqueteActualResponse:
    repositorio = RepositorioConocimientoSql(sesion)
    caso_de_uso = ObtenerPaqueteActual(repositorio)
    paquete = caso_de_uso.ejecutar()

    return PaqueteActualResponse(
        version=paquete.version,
        contenido=paquete.contenido,
        actualizado_en=paquete.actualizado_en,
    )
