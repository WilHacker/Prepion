import uuid
from dataclasses import dataclass
from datetime import datetime
from typing import Protocol

from app.shared.domain.errores import ConflictoError, NoAutorizadoError

ROL_ADMIN = "admin"
ROL_USUARIO = "usuario"


@dataclass(frozen=True)
class Cuenta:
    id: uuid.UUID
    correo: str | None
    rol: str
    es_anonimo: bool
    creado_en: datetime
    respuestas: int = 0


class CredencialesInvalidasError(NoAutorizadoError):
    """Correo o contraseña incorrectos (mismo mensaje en ambos casos)."""


class CorreoYaRegistradoError(ConflictoError):
    """Ya existe una cuenta con ese correo."""


class RepositorioCuentas(Protocol):
    def buscar_por_correo(self, correo: str) -> tuple[Cuenta, str] | None:
        """Devuelve la cuenta y su hash de contraseña."""
        ...

    def buscar_por_id(self, cuenta_id: uuid.UUID) -> Cuenta | None: ...

    def crear(self, correo: str, contrasena_hash: str, rol: str) -> Cuenta: ...

    def fijar_admin(self, correo: str, contrasena_hash: str) -> Cuenta:
        """Crea la cuenta admin o promueve la existente (y le cambia la contraseña)."""
        ...

    def listar(self) -> list[Cuenta]: ...
