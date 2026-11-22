from sqlmodel import Field

from app.shared.infrastructure.persistence.tabla_base import TablaBase


class UsuarioTabla(TablaBase, table=True):
    __tablename__ = "usuarios"

    correo: str | None = Field(default=None, unique=True, max_length=254)
    contrasena_hash: str | None = None
    es_anonimo: bool = True
    codigo_recuperacion_hash: str | None = None
