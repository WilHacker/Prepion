from typing import Annotated, Any

from fastapi import APIRouter, Depends
from sqlmodel import Session

from app.core.database import get_session
from app.features.preguntas.application.consultar_banco import (
    descargar_banco,
    obtener_banco_actual,
)
from app.features.preguntas.application.dto.banco_actual_response import BancoActualResponse
from app.features.preguntas.infrastructure.persistence.banco_repositorio import (
    BancoRepositorioSql,
)

router = APIRouter(prefix="/preguntas", tags=["preguntas"])

SesionDep = Annotated[Session, Depends(get_session)]


@router.get("/banco/actual")
def banco_actual(sesion: SesionDep) -> BancoActualResponse:
    actual = obtener_banco_actual(BancoRepositorioSql(sesion))
    return BancoActualResponse(
        version=actual.version, cantidad=actual.cantidad, publicada_en=actual.publicada_en
    )


@router.get("/banco/descargar/{version}")
def banco_descargar(version: int, sesion: SesionDep) -> dict[str, Any]:
    return descargar_banco(BancoRepositorioSql(sesion), version)
