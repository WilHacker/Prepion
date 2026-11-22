import uuid
from datetime import datetime

from pydantic import BaseModel, ConfigDict, Field
from pydantic.alias_generators import to_camel


class CrearReporteRequest(BaseModel):
    model_config = ConfigDict(alias_generator=to_camel, populate_by_name=True)

    pregunta_id: uuid.UUID
    motivo: str = Field(min_length=1, max_length=200)
    comentario: str | None = Field(default=None, max_length=1000)


class ReporteResponse(BaseModel):
    model_config = ConfigDict(alias_generator=to_camel, populate_by_name=True)

    id: uuid.UUID
    pregunta_id: uuid.UUID
    usuario_id: uuid.UUID | None
    motivo: str
    comentario: str | None
    estado: str
    creado_en: datetime
