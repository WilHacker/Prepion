import uuid
from dataclasses import dataclass

from app.shared.domain.errores import NoAutorizadoError, ReglaDeNegocioError


@dataclass(frozen=True)
class IdentidadUsuario:
    """Identidad del postulante en una petición (anónima o con cuenta)."""

    usuario_id: uuid.UUID
    es_anonimo: bool = True


class SesionRequeridaError(NoAutorizadoError):
    """Se lanza cuando una petición no incluye X-Usuario-Id ni sesión autenticada."""


class IdentidadUsuarioInvalidaError(ReglaDeNegocioError):
    """Se lanza cuando la cabecera X-Usuario-Id no contiene un UUID válido."""
