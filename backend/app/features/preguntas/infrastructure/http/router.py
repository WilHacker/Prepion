from typing import Annotated, Any
from uuid import UUID

from fastapi import APIRouter, Depends, Query
from sqlmodel import Session

from app.core.database import get_session
from app.features.preguntas.application.consultar_banco import (
    descargar_banco,
    obtener_banco_actual,
)
from app.features.preguntas.application.consultar_catalogo import (
    consultar_preguntas_filtradas,
)
from app.features.preguntas.application.dto.banco_actual_response import BancoActualResponse
from app.features.preguntas.application.dto.pregunta_response import PreguntaResponse
from app.features.preguntas.infrastructure.persistence.banco_repositorio import (
    BancoRepositorioSql,
)
from app.features.preguntas.infrastructure.persistence.catalogo_repositorio import (
    CatalogoRepositorioSql,
)

router = APIRouter(prefix="/preguntas", tags=["preguntas"])

SesionDep = Annotated[Session, Depends(get_session)]


@router.get("", response_model=list[PreguntaResponse])
def listar_preguntas(
    sesion: SesionDep,
    materia: str | None = None,
    tema_id: Annotated[UUID | None, Query(alias="temaId")] = None,
) -> list[PreguntaResponse]:
    preguntas = consultar_preguntas_filtradas(
        CatalogoRepositorioSql(sesion), materia=materia, tema_id=tema_id
    )
    return [
        PreguntaResponse(
            id=p.id,
            examen_id=p.examen_id,
            codigo=p.codigo,
            tema_id=p.tema_id,
            enunciado=p.enunciado,
            opciones=p.opciones,
            ruta_imagen=p.ruta_imagen,
            respuesta=p.respuesta,
            explicacion=p.explicacion,
            fuente=p.fuente,
            estado=p.estado,
        )
        for p in preguntas
    ]


@router.get("/banco/actual")
def banco_actual(sesion: SesionDep) -> BancoActualResponse:
    actual = obtener_banco_actual(BancoRepositorioSql(sesion))
    return BancoActualResponse(
        version=actual.version, cantidad=actual.cantidad, publicada_en=actual.publicada_en
    )


@router.get("/banco/descargar/{version}")
def banco_descargar(version: int, sesion: SesionDep) -> dict[str, Any]:
    return descargar_banco(BancoRepositorioSql(sesion), version)
