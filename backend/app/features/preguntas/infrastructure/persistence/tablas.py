import uuid

from sqlalchemy import JSON, Text, UniqueConstraint
from sqlmodel import Field

from app.shared.infrastructure.persistence.tabla_base import TablaBase


class TemaTabla(TablaBase, table=True):
    __tablename__ = "temas"
    __table_args__ = (UniqueConstraint("materia", "nombre"),)

    materia: str = Field(max_length=60)
    nombre: str = Field(max_length=120)


class PreguntaTabla(TablaBase, table=True):
    __tablename__ = "preguntas"
    __table_args__ = (UniqueConstraint("examen_id", "codigo"),)

    examen_id: uuid.UUID = Field(foreign_key="examenes.id", index=True)
    codigo: str = Field(max_length=10)  # A5, G7, B18…
    tema_id: uuid.UUID | None = Field(default=None, foreign_key="temas.id", index=True)
    enunciado: str = Field(sa_type=Text)
    opciones: list[str] = Field(default_factory=list, sa_type=JSON)
    imagen: str | None = None
    respuesta: str | None = Field(default=None, max_length=1)
    explicacion: str | None = Field(default=None, sa_type=Text)
    # Estados: borrador, revisada, publicada, retirada.
    estado: str = Field(default="borrador", max_length=20)


class BancoVersionTabla(TablaBase, table=True):
    __tablename__ = "banco_versiones"

    version: int = Field(unique=True)
    cantidad: int
