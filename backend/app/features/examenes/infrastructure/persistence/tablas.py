from datetime import datetime

from sqlalchemy import DateTime
from sqlmodel import Field

from app.shared.infrastructure.persistence.tabla_base import TablaBase


class ExamenTabla(TablaBase, table=True):
    __tablename__ = "examenes"

    archivo: str = Field(unique=True, max_length=200)
    gestion: str = Field(max_length=20)  # por ejemplo "2-2026"
    tipo: str = Field(max_length=30)  # 1op, 2op, 3op, unica, preu, propedeutico
    url: str
    descargado_en: datetime | None = Field(default=None, sa_type=DateTime(timezone=True))
