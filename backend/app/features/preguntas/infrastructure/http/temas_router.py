from typing import Annotated

from fastapi import APIRouter, Depends
from sqlmodel import Session

from app.core.database import get_session
from app.features.preguntas.application.consultar_catalogo import consultar_arbol_temas
from app.features.preguntas.application.dto.arbol_temas_response import (
    MateriaResponse,
    TemaResponse,
)
from app.features.preguntas.infrastructure.persistence.catalogo_repositorio import (
    CatalogoRepositorioSql,
)

router = APIRouter(prefix="/temas", tags=["temas"])

SesionDep = Annotated[Session, Depends(get_session)]


@router.get("", response_model=list[MateriaResponse])
def obtener_arbol_temas(sesion: SesionDep) -> list[MateriaResponse]:
    materias = consultar_arbol_temas(CatalogoRepositorioSql(sesion))
    return [
        MateriaResponse(
            materia=m.materia,
            cantidad_preguntas=m.cantidad_preguntas,
            temas=[
                TemaResponse(
                    tema_id=t.id,
                    nombre=t.nombre,
                    cantidad_preguntas=t.cantidad_preguntas,
                )
                for t in m.temas
            ],
        )
        for m in materias
    ]
