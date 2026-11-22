import uuid

from sqlmodel import Field

from app.shared.infrastructure.persistence.tabla_base import TablaBase


class ReporteTabla(TablaBase, table=True):
    __tablename__ = "reportes"

    pregunta_id: uuid.UUID = Field(foreign_key="preguntas.id", index=True)
    usuario_id: uuid.UUID | None = Field(default=None, foreign_key="usuarios.id")
    motivo: str = Field(max_length=200)
    estado: str = Field(default="pendiente", max_length=20)  # pendiente, revisado, descartado
