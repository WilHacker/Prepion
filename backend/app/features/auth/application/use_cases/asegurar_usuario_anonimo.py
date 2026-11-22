import uuid

from app.features.auth.domain.identidad import IdentidadUsuario
from app.features.auth.domain.puertos import RepositorioUsuarios


class AsegurarUsuarioAnonimo:
    """Garantiza que exista un registro anónimo para el UUID enviado por la app."""

    def __init__(self, repositorio: RepositorioUsuarios) -> None:
        self._repositorio = repositorio

    def ejecutar(self, usuario_id: uuid.UUID) -> IdentidadUsuario:
        return self._repositorio.asegurar_anonimo(usuario_id)
