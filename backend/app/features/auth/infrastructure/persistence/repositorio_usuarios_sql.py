import uuid

from sqlmodel import Session

from app.features.auth.domain.identidad import IdentidadUsuario
from app.features.auth.infrastructure.persistence.tablas import UsuarioTabla


class RepositorioUsuariosSql:
    """Adaptador SQLModel para gestionar usuarios en PostgreSQL."""

    def __init__(self, session: Session) -> None:
        self._session = session

    def asegurar_anonimo(self, usuario_id: uuid.UUID) -> IdentidadUsuario:
        usuario = self._session.get(UsuarioTabla, usuario_id)
        if usuario is None:
            usuario = UsuarioTabla(id=usuario_id, es_anonimo=True)
            self._session.add(usuario)
            self._session.commit()
            self._session.refresh(usuario)
        return IdentidadUsuario(usuario_id=usuario.id, es_anonimo=usuario.es_anonimo)
