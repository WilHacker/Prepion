from typing import Annotated, Any

from fastapi import APIRouter, Depends
from sqlmodel import Session

from app.core.database import get_session
from app.core.seguridad import exigir_token
from app.features.conocimiento.application.consultar_paquete import obtener_paquete_actual
from app.features.conocimiento.application.recalibrar_conocimiento import (
    ResumenRecalibracionDto,
    recalibrar_conocimiento,
)
from app.features.conocimiento.infrastructure.persistence.adaptadores_sql import (
    BancoPublicadoSql,
    PaquetesConocimientoSql,
    RespuestasRealesSql,
)

router = APIRouter(tags=["conocimiento"])

SesionDep = Annotated[Session, Depends(get_session)]


@router.get("/paquetes-conocimiento/actual")
def paquete_actual(sesion: SesionDep) -> dict[str, Any]:
    return obtener_paquete_actual(PaquetesConocimientoSql(sesion))


@router.post("/conocimiento/recalibrar", dependencies=[Depends(exigir_token)])
def recalibrar(sesion: SesionDep) -> ResumenRecalibracionDto:
    return recalibrar_conocimiento(
        BancoPublicadoSql(sesion), RespuestasRealesSql(sesion), PaquetesConocimientoSql(sesion)
    )
