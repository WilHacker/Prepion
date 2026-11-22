import uuid
from datetime import UTC, datetime, timedelta

import jwt

from app.core.config import settings
from app.features.cuentas.domain.cuenta import Cuenta
from app.shared.domain.errores import NoAutorizadoError, ServicioNoDisponibleError

ALGORITMO = "HS256"
DURACION = timedelta(hours=12)
LARGO_MINIMO_SECRETO = 32


def _secreto() -> str:
    secreto = settings.jwt_secreto
    if not secreto or len(secreto) < LARGO_MINIMO_SECRETO:
        raise ServicioNoDisponibleError("El inicio de sesión no está habilitado en este servidor")
    return secreto


def emitir_token(cuenta: Cuenta) -> str:
    ahora = datetime.now(UTC)
    datos = {"sub": str(cuenta.id), "iat": ahora, "exp": ahora + DURACION}
    return jwt.encode(datos, _secreto(), algorithm=ALGORITMO)


def leer_token(token: str) -> uuid.UUID:
    """Devuelve el id de la cuenta; el rol se consulta en la base, no se confía en el token."""
    try:
        datos = jwt.decode(
            token, _secreto(), algorithms=[ALGORITMO], options={"require": ["exp", "sub"]}
        )
        return uuid.UUID(datos["sub"])
    except (jwt.PyJWTError, ValueError) as error:
        raise NoAutorizadoError("Sesión inválida o vencida.") from error
