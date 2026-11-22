from typing import Annotated

from fastapi import APIRouter, Depends

from app.features.auth.domain.identidad import IdentidadUsuario
from app.features.auth.infrastructure.http.dependencias import (
    obtener_identidad_usuario_opcional,
)
from app.features.configuracion.application.dto.parametros_publicos_response import (
    ParametrosPublicosResponse,
)
from app.features.configuracion.application.use_cases.obtener_parametros_publicos import (
    ObtenerParametrosPublicos,
)

router = APIRouter(prefix="/configuracion", tags=["configuracion"])


@router.get("/parametros-publicos")
def obtener_parametros_publicos(
    _identidad: Annotated[IdentidadUsuario | None, Depends(obtener_identidad_usuario_opcional)],
) -> ParametrosPublicosResponse:
    parametros = ObtenerParametrosPublicos().ejecutar()
    return ParametrosPublicosResponse.desde_dominio(parametros)
