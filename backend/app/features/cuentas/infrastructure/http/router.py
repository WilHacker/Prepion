import uuid
from datetime import datetime
from typing import Annotated

from fastapi import APIRouter, Depends, Header
from pydantic import BaseModel, ConfigDict, Field, StringConstraints
from pydantic.alias_generators import to_camel
from sqlmodel import Session

from app.core.database import get_session
from app.features.cuentas.application.cuentas import es_admin, iniciar_sesion, registrar
from app.features.cuentas.domain.cuenta import Cuenta
from app.features.cuentas.infrastructure.persistence.repositorio_cuentas_sql import (
    RepositorioCuentasSql,
)
from app.features.cuentas.infrastructure.tokens import emitir_token, leer_token
from app.shared.domain.errores import NoAutorizadoError, ProhibidoError

router = APIRouter(tags=["cuentas"])
SesionDep = Annotated[Session, Depends(get_session)]

CORREO = r"^[^@\s]+@[^@\s]+\.[^@\s]+$"


class _Dto(BaseModel):
    model_config = ConfigDict(alias_generator=to_camel, populate_by_name=True)


class CredencialesRegistro(_Dto):
    correo: Annotated[str, StringConstraints(strip_whitespace=True, pattern=CORREO, max_length=254)]
    contrasena: str = Field(min_length=8, max_length=128)


class CredencialesLogin(_Dto):
    correo: str = Field(max_length=254)
    contrasena: str = Field(max_length=128)


class CuentaDto(_Dto):
    id: uuid.UUID
    correo: str | None
    rol: str
    es_anonimo: bool
    creado_en: datetime
    respuestas: int

    @classmethod
    def desde(cls, c: Cuenta) -> "CuentaDto":
        return cls(
            id=c.id,
            correo=c.correo,
            rol=c.rol,
            es_anonimo=c.es_anonimo,
            creado_en=c.creado_en,
            respuestas=c.respuestas,
        )


class SesionDto(_Dto):
    token: str
    cuenta: CuentaDto


def _sesion(cuenta: Cuenta) -> SesionDto:
    return SesionDto(token=emitir_token(cuenta), cuenta=CuentaDto.desde(cuenta))


def cuenta_actual(
    sesion: SesionDep, authorization: Annotated[str | None, Header()] = None
) -> Cuenta:
    esquema, _, token = (authorization or "").partition(" ")
    if esquema.lower() != "bearer" or not token.strip():
        raise NoAutorizadoError("Inicia sesión para continuar.")
    cuenta = RepositorioCuentasSql(sesion).buscar_por_id(leer_token(token.strip()))
    if cuenta is None:
        raise NoAutorizadoError("Sesión inválida o vencida.")
    return cuenta


def cuenta_admin(cuenta: Annotated[Cuenta, Depends(cuenta_actual)]) -> Cuenta:
    if not es_admin(cuenta):
        raise ProhibidoError("Esta sección es solo para administradores.")
    return cuenta


@router.post("/auth/registro", status_code=201)
def registro(datos: CredencialesRegistro, sesion: SesionDep) -> SesionDto:
    return _sesion(registrar(RepositorioCuentasSql(sesion), datos.correo, datos.contrasena))


@router.post("/auth/login")
def login(datos: CredencialesLogin, sesion: SesionDep) -> SesionDto:
    return _sesion(iniciar_sesion(RepositorioCuentasSql(sesion), datos.correo, datos.contrasena))


@router.get("/auth/yo")
def yo(cuenta: Annotated[Cuenta, Depends(cuenta_actual)]) -> CuentaDto:
    return CuentaDto.desde(cuenta)


@router.get("/admin/usuarios", dependencies=[Depends(cuenta_admin)])
def listar_usuarios(sesion: SesionDep) -> list[CuentaDto]:
    return [CuentaDto.desde(c) for c in RepositorioCuentasSql(sesion).listar()]
