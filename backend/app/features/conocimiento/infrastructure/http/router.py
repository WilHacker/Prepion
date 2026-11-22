from typing import Annotated

from fastapi import APIRouter, Depends
from sqlmodel import Session

from app.core.database import get_session
from app.core.seguridad import exigir_token
from app.features.conocimiento.application.dto.paquete_actual_response import (
    PaqueteActualResponse,
)
from app.features.conocimiento.application.recalibrar_conocimiento import (
    ResumenRecalibracionDto,
    recalibrar_conocimiento,
)
from app.features.conocimiento.application.use_cases.obtener_paquete_actual import (
    ObtenerPaqueteActual,
)
from app.features.conocimiento.infrastructure.persistence.adaptadores_sql import (
    BancoPublicadoSql,
    PaquetesConocimientoSql,
    RespuestasRealesSql,
)
from app.features.conocimiento.infrastructure.persistence.repositorio_conocimiento_sql import (
    RepositorioConocimientoSql,
)

router = APIRouter(tags=["conocimiento"])

SesionDep = Annotated[Session, Depends(get_session)]


@router.get("/paquetes-conocimiento/actual", response_model=PaqueteActualResponse)
def paquete_actual(sesion: SesionDep) -> PaqueteActualResponse:
    repositorio = RepositorioConocimientoSql(sesion)
    caso_de_uso = ObtenerPaqueteActual(repositorio)
    paquete = caso_de_uso.ejecutar()

    return PaqueteActualResponse(
        version=paquete.version,
        contenido=paquete.contenido,
        actualizado_en=paquete.actualizado_en,
    )


@router.post("/conocimiento/recalibrar", dependencies=[Depends(exigir_token)])
def recalibrar(sesion: SesionDep) -> ResumenRecalibracionDto:
    return recalibrar_conocimiento(
        BancoPublicadoSql(sesion), RespuestasRealesSql(sesion), PaquetesConocimientoSql(sesion)
    )
