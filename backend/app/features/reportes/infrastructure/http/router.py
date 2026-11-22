from typing import Annotated

from fastapi import APIRouter, Depends, Query, status
from sqlmodel import Session

from app.core.database import get_session
from app.features.auth.domain.identidad import IdentidadUsuario
from app.features.auth.infrastructure.http.dependencias import (
    obtener_identidad_usuario_opcional,
)
from app.features.reportes.application.dto.reporte_dto import (
    CrearReporteRequest,
    ReporteResponse,
)
from app.features.reportes.application.use_cases.crear_reporte import CrearReporte
from app.features.reportes.application.use_cases.listar_reportes_pendientes import (
    ListarReportesPendientes,
)
from app.features.reportes.infrastructure.persistence.repositorio_reportes_sql import (
    RepositorioReportesSql,
)

router = APIRouter(prefix="/reportes", tags=["reportes"])

SesionDep = Annotated[Session, Depends(get_session)]
IdentidadOpcionalDep = Annotated[
    IdentidadUsuario | None, Depends(obtener_identidad_usuario_opcional)
]


@router.post("", response_model=ReporteResponse, status_code=status.HTTP_201_CREATED)
def crear_reporte(
    payload: CrearReporteRequest,
    sesion: SesionDep,
    identidad: IdentidadOpcionalDep = None,
) -> ReporteResponse:
    repositorio = RepositorioReportesSql(sesion)
    caso_de_uso = CrearReporte(repositorio)
    usuario_id = identidad.usuario_id if identidad else None
    reporte = caso_de_uso.ejecutar(
        pregunta_id=payload.pregunta_id,
        motivo=payload.motivo,
        comentario=payload.comentario,
        usuario_id=usuario_id,
    )
    return ReporteResponse(
        id=reporte.id,
        pregunta_id=reporte.pregunta_id,
        usuario_id=reporte.usuario_id,
        motivo=reporte.motivo,
        comentario=reporte.comentario,
        estado=reporte.estado,
        creado_en=reporte.creado_en,
    )


@router.get("/pendientes", response_model=list[ReporteResponse])
def listar_reportes_pendientes(
    sesion: SesionDep,
    limite: Annotated[int, Query(ge=1, le=500)] = 100,
) -> list[ReporteResponse]:
    repositorio = RepositorioReportesSql(sesion)
    caso_de_uso = ListarReportesPendientes(repositorio)
    reportes = caso_de_uso.ejecutar(limite=limite)
    return [
        ReporteResponse(
            id=r.id,
            pregunta_id=r.pregunta_id,
            usuario_id=r.usuario_id,
            motivo=r.motivo,
            comentario=r.comentario,
            estado=r.estado,
            creado_en=r.creado_en,
        )
        for r in reportes
    ]
