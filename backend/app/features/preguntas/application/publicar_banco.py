from typing import Any

from app.features.preguntas.domain.banco import BancoRepositorio
from app.features.preguntas.domain.errores import (
    BancoPublicadoInvalidoError,
    BancoYaPublicadoError,
)


def publicar_banco(repositorio: BancoRepositorio, contenido: dict[str, Any]) -> int:
    """Guarda el banco curado como una versión nueva y devuelve su número."""
    version = contenido.get("version")
    # bool es subclase de int: 'true' no es una versión.
    if not isinstance(version, int) or isinstance(version, bool) or version < 1:
        raise BancoPublicadoInvalidoError("El banco necesita una 'version' entera desde 1.")
    preguntas = contenido.get("preguntas")
    if not isinstance(preguntas, list) or not preguntas:
        raise BancoPublicadoInvalidoError("El banco no trae ninguna pregunta.")
    if repositorio.existe_version(version):
        raise BancoYaPublicadoError(
            f"La versión {version} ya está publicada; sube el número de versión."
        )
    repositorio.guardar(version, len(preguntas), contenido)
    return version
