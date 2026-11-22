import uuid

from sqlalchemy import func
from sqlalchemy.exc import IntegrityError
from sqlmodel import Session, col, select

from app.features.auth.infrastructure.persistence.tablas import UsuarioTabla
from app.features.cuentas.domain.cuenta import ROL_ADMIN, CorreoYaRegistradoError, Cuenta
from app.features.sincronizacion.infrastructure.persistence.tablas import RespuestaTabla


def _a_cuenta(fila: UsuarioTabla, respuestas: int = 0) -> Cuenta:
    return Cuenta(fila.id, fila.correo, fila.rol, fila.es_anonimo, fila.creado_en, respuestas)


class RepositorioCuentasSql:
    def __init__(self, sesion: Session) -> None:
        self._sesion = sesion

    def _fila_por_correo(self, correo: str) -> UsuarioTabla | None:
        return self._sesion.exec(select(UsuarioTabla).where(UsuarioTabla.correo == correo)).first()

    def buscar_por_correo(self, correo: str) -> tuple[Cuenta, str] | None:
        fila = self._fila_por_correo(correo)
        if fila is None or fila.contrasena_hash is None:
            return None
        return _a_cuenta(fila), fila.contrasena_hash

    def buscar_por_id(self, cuenta_id: uuid.UUID) -> Cuenta | None:
        fila = self._sesion.get(UsuarioTabla, cuenta_id)
        return None if fila is None else _a_cuenta(fila)

    def crear(self, correo: str, contrasena_hash: str, rol: str) -> Cuenta:
        fila = UsuarioTabla(
            correo=correo, contrasena_hash=contrasena_hash, es_anonimo=False, rol=rol
        )
        self._sesion.add(fila)
        try:
            self._sesion.commit()
        except IntegrityError as error:  # dos registros simultáneos con el mismo correo
            self._sesion.rollback()
            raise CorreoYaRegistradoError("Ya existe una cuenta con ese correo.") from error
        self._sesion.refresh(fila)
        return _a_cuenta(fila)

    def fijar_admin(self, correo: str, contrasena_hash: str) -> Cuenta:
        fila = self._fila_por_correo(correo)
        if fila is None:
            return self.crear(correo, contrasena_hash, ROL_ADMIN)
        fila.contrasena_hash = contrasena_hash
        fila.es_anonimo = False
        fila.rol = ROL_ADMIN
        self._sesion.add(fila)
        self._sesion.commit()
        self._sesion.refresh(fila)
        return _a_cuenta(fila)

    def listar(self) -> list[Cuenta]:
        cuentas = (
            select(UsuarioTabla, func.count(col(RespuestaTabla.id_evento)))
            .join(
                RespuestaTabla, col(RespuestaTabla.usuario_id) == col(UsuarioTabla.id), isouter=True
            )
            .group_by(col(UsuarioTabla.id))
            .order_by(col(UsuarioTabla.creado_en).desc())
        )
        return [_a_cuenta(fila, total) for fila, total in self._sesion.exec(cuentas).all()]
