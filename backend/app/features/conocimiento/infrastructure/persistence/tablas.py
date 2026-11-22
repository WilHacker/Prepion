from typing import Any

from sqlalchemy import JSON
from sqlmodel import Field

from app.shared.infrastructure.persistence.tabla_base import TablaBase


class PaqueteConocimientoTabla(TablaBase, table=True):
    __tablename__ = "paquetes_conocimiento"

    version: int = Field(unique=True)
    contenido: dict[str, Any] = Field(default_factory=dict, sa_type=JSON)
