import uuid
from typing import Protocol

from app.features.auth.domain.identidad import IdentidadUsuario


class RepositorioUsuarios(Protocol):
    """Puerto de persistencia para usuarios anónimos y registrados."""

    def asegurar_anonimo(self, usuario_id: uuid.UUID) -> IdentidadUsuario: ...
