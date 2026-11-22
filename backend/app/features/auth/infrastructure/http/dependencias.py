import uuid
from typing import Annotated

from fastapi import Depends, Header
from sqlmodel import Session

from app.core.database import get_session
from app.features.auth.application.use_cases.asegurar_usuario_anonimo import AsegurarUsuarioAnonimo
from app.features.auth.domain.identidad import (
    IdentidadUsuario,
    IdentidadUsuarioInvalidaError,
    SesionRequeridaError,
)
from app.features.auth.infrastructure.persistence.repositorio_usuarios_sql import (
    RepositorioUsuariosSql,
)

CABECERA_USUARIO_ID = "X-Usuario-Id"


def _parsear_usuario_id(valor: str) -> uuid.UUID:
    try:
        return uuid.UUID(valor.strip())
    except ValueError as exc:
        raise IdentidadUsuarioInvalidaError(
            "La cabecera X-Usuario-Id debe contener un UUID válido."
        ) from exc


def obtener_identidad_usuario(
    x_usuario_id: Annotated[str | None, Header(alias=CABECERA_USUARIO_ID)] = None,
) -> IdentidadUsuario:
    """Extrae la identidad anónima desde X-Usuario-Id sin exigir token JWT."""
    if x_usuario_id is None or not x_usuario_id.strip():
        raise SesionRequeridaError(
            "Se requiere la cabecera X-Usuario-Id para operar en modo anónimo."
        )
    return IdentidadUsuario(usuario_id=_parsear_usuario_id(x_usuario_id), es_anonimo=True)


def obtener_identidad_usuario_opcional(
    x_usuario_id: Annotated[str | None, Header(alias=CABECERA_USUARIO_ID)] = None,
) -> IdentidadUsuario | None:
    """Valida X-Usuario-Id si fue enviada; devuelve None en rutas públicas sin cabecera."""
    if x_usuario_id is None or not x_usuario_id.strip():
        return None
    return IdentidadUsuario(usuario_id=_parsear_usuario_id(x_usuario_id), es_anonimo=True)


def asegurar_identidad_en_bd(
    identidad: Annotated[IdentidadUsuario, Depends(obtener_identidad_usuario)],
    session: Annotated[Session, Depends(get_session)],
) -> IdentidadUsuario:
    """Dependencia para endpoints de eventos: garantiza el registro anónimo en usuarios."""
    caso_de_uso = AsegurarUsuarioAnonimo(RepositorioUsuariosSql(session))
    return caso_de_uso.ejecutar(identidad.usuario_id)
