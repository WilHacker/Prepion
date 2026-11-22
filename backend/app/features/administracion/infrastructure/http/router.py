from collections.abc import Callable
from pathlib import Path
from typing import Annotated

from fastapi import APIRouter, Depends, Query
from pydantic import BaseModel, ConfigDict
from pydantic.alias_generators import to_camel
from sqlalchemy import func
from sqlmodel import Session, col, select

from app.core.database import get_session
from app.features.administracion.domain.curabilidad import Curabilidad
from app.features.administracion.infrastructure.analizador_pdf import analizar_pdf
from app.features.auth.infrastructure.persistence.tablas import UsuarioTabla
from app.features.conocimiento.application.recalibrar_conocimiento import (
    ResumenRecalibracionDto,
    recalibrar_conocimiento,
)
from app.features.conocimiento.infrastructure.persistence.adaptadores_sql import (
    BancoPublicadoSql,
    PaquetesConocimientoSql,
    RespuestasRealesSql,
)
from app.features.conocimiento.infrastructure.persistence.tablas import PaqueteConocimientoTabla
from app.features.cuentas.infrastructure.http.router import cuenta_admin
from app.features.examenes.application.recolectar_examenes import (
    Portal,
    ResultadoRecoleccionDto,
    recolectar_examenes,
)
from app.features.examenes.infrastructure.http.router import obtener_carpeta, obtener_portal
from app.features.preguntas.infrastructure.persistence.tablas import (
    BancoVersionTabla,
    PreguntaTabla,
)
from app.features.sincronizacion.infrastructure.persistence.tablas import RespuestaTabla

router = APIRouter(prefix="/admin", tags=["administracion"], dependencies=[Depends(cuenta_admin)])
SesionDep = Annotated[Session, Depends(get_session)]
Analizador = Callable[[Path], Curabilidad]


def obtener_analizador() -> Analizador:
    return analizar_pdf


class _Dto(BaseModel):
    model_config = ConfigDict(alias_generator=to_camel, populate_by_name=True)


class ResumenDto(_Dto):
    usuarios: int
    respuestas: int
    preguntas_publicadas: int
    banco_version: int | None
    paquete_version: int | None
    paquete_origen: str | None
    examenes_descargados: int


class ExamenAnalizadoDto(_Dto):
    archivo: str
    paginas: int
    preguntas: int
    con_cinco_opciones: int
    veredicto: str
    motivo: str


def _contar(sesion: Session, tabla: type) -> int:
    return sesion.exec(select(func.count()).select_from(tabla)).one()


@router.get("/resumen")
def resumen(sesion: SesionDep, carpeta: Annotated[Path, Depends(obtener_carpeta)]) -> ResumenDto:
    banco = sesion.exec(
        select(col(BancoVersionTabla.version)).order_by(col(BancoVersionTabla.version).desc())
    ).first()
    paquete = sesion.exec(
        select(PaqueteConocimientoTabla).order_by(col(PaqueteConocimientoTabla.version).desc())
    ).first()
    return ResumenDto(
        usuarios=_contar(sesion, UsuarioTabla),
        respuestas=_contar(sesion, RespuestaTabla),
        preguntas_publicadas=sesion.exec(
            select(func.count())
            .select_from(PreguntaTabla)
            .where(col(PreguntaTabla.estado) == "publicada")
        ).one(),
        banco_version=banco,
        paquete_version=None if paquete is None else paquete.version,
        paquete_origen=None if paquete is None else str(paquete.contenido.get("origen")),
        examenes_descargados=len(list(carpeta.glob("*.pdf"))) if carpeta.exists() else 0,
    )


@router.get("/examenes")
def examenes(
    carpeta: Annotated[Path, Depends(obtener_carpeta)],
    analizador: Annotated[Analizador, Depends(obtener_analizador)],
) -> list[ExamenAnalizadoDto]:
    pdfs = sorted(carpeta.glob("*.pdf")) if carpeta.exists() else []
    resultados = ((p, analizador(p)) for p in pdfs)
    return [
        ExamenAnalizadoDto(
            archivo=p.name,
            paginas=c.paginas,
            preguntas=c.preguntas,
            con_cinco_opciones=c.con_cinco_opciones,
            veredicto=c.veredicto.value,
            motivo=c.motivo,
        )
        for p, c in resultados
    ]


@router.post("/examenes/recolectar")
def recolectar(
    portal: Annotated[Portal, Depends(obtener_portal)],
    carpeta: Annotated[Path, Depends(obtener_carpeta)],
    limite: Annotated[int, Query(ge=1, le=50)] = 10,
) -> ResultadoRecoleccionDto:
    return ResultadoRecoleccionDto.desde(recolectar_examenes(portal, carpeta, limite))


@router.post("/conocimiento/recalibrar")
def recalibrar(sesion: SesionDep) -> ResumenRecalibracionDto:
    return recalibrar_conocimiento(
        BancoPublicadoSql(sesion), RespuestasRealesSql(sesion), PaquetesConocimientoSql(sesion)
    )
