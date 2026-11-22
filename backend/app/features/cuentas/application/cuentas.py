from argon2 import PasswordHasher
from argon2.exceptions import InvalidHashError, VerificationError

from app.features.cuentas.domain.cuenta import (
    ROL_ADMIN,
    ROL_USUARIO,
    CorreoYaRegistradoError,
    CredencialesInvalidasError,
    Cuenta,
    RepositorioCuentas,
)

_hasher = PasswordHasher()
# Hash de relleno: el login tarda lo mismo exista o no el correo (no revela cuentas).
_HASH_RELLENO = _hasher.hash("relleno-para-igualar-tiempos")


def normalizar_correo(correo: str) -> str:
    return correo.strip().lower()


def registrar(repo: RepositorioCuentas, correo: str, contrasena: str) -> Cuenta:
    correo = normalizar_correo(correo)
    if repo.buscar_por_correo(correo) is not None:
        raise CorreoYaRegistradoError("Ya existe una cuenta con ese correo.")
    return repo.crear(correo, _hasher.hash(contrasena), ROL_USUARIO)


def iniciar_sesion(repo: RepositorioCuentas, correo: str, contrasena: str) -> Cuenta:
    encontrada = repo.buscar_por_correo(normalizar_correo(correo))
    hash_guardado = encontrada[1] if encontrada else _HASH_RELLENO
    try:
        _hasher.verify(hash_guardado, contrasena)
    except (VerificationError, InvalidHashError):
        encontrada = None
    if encontrada is None:
        raise CredencialesInvalidasError("Correo o contraseña incorrectos.")
    return encontrada[0]


def crear_admin(repo: RepositorioCuentas, correo: str, contrasena: str) -> Cuenta:
    return repo.fijar_admin(normalizar_correo(correo), _hasher.hash(contrasena))


def es_admin(cuenta: Cuenta) -> bool:
    return cuenta.rol == ROL_ADMIN
