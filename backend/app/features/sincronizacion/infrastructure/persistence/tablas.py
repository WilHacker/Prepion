import uuid
from datetime import datetime

from sqlalchemy import DateTime
from sqlmodel import Field

from app.shared.infrastructure.persistence.tabla_base import ConMarcasDeTiempo


class RespuestaTabla(ConMarcasDeTiempo, table=True):
    __tablename__ = "respuestas"

    # Lo genera el celular: si un lote llega dos veces, la respuesta no se duplica.
    id_evento: uuid.UUID = Field(primary_key=True)
    usuario_id: uuid.UUID = Field(foreign_key="usuarios.id", index=True)
    pregunta_id: uuid.UUID = Field(foreign_key="preguntas.id", index=True)
    es_correcta: bool
    tiempo_ms: int
    respondida_en: datetime = Field(sa_type=DateTime(timezone=True))
