from typing import Annotated

from fastapi import APIRouter, Depends
from sqlmodel import Session

from app.core.database import get_session
from app.features.auth.domain.identidad import IdentidadUsuario
from app.features.auth.infrastructure.http.dependencias import asegurar_identidad_en_bd
from app.features.sincronizacion.application.dto.lote_respuestas_dto import (
    LoteRespuestasRequest,
    LoteRespuestasResponse,
)
from app.features.sincronizacion.application.use_cases.sincronizar_lote import SincronizarLote
from app.features.sincronizacion.domain.respuesta import RespuestaEntrante
from app.features.sincronizacion.infrastructure.persistence.repositorio_respuestas_sql import (
    RepositorioRespuestasSql,
)

router = APIRouter(prefix="/sincronizacion", tags=["sincronizacion"])

SesionDep = Annotated[Session, Depends(get_session)]
IdentidadDep = Annotated[IdentidadUsuario, Depends(asegurar_identidad_en_bd)]


@router.post("/lote", response_model=LoteRespuestasResponse)
def sincronizar_respuestas_lote(
    lote: LoteRespuestasRequest,
    identidad: IdentidadDep,
    sesion: SesionDep,
) -> LoteRespuestasResponse:
    repositorio = RepositorioRespuestasSql(sesion)
    caso_de_uso = SincronizarLote(repositorio)

    respuestas_dominio = [
        RespuestaEntrante(
            id_evento=item.id_evento,
            pregunta_id=item.pregunta_id,
            opcion_elegida=item.opcion_elegida,
            es_correcta=item.es_correcta,
            tiempo_ms=item.tiempo_ms,
            respondida_en=item.respondida_en,
        )
        for item in lote.respuestas
    ]

    insertados, duplicados = caso_de_uso.ejecutar(identidad.usuario_id, respuestas_dominio)
    return LoteRespuestasResponse(
        recibidos=len(lote.respuestas),
        insertados=insertados,
        duplicados=duplicados,
    )
