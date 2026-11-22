import uuid
from datetime import datetime

from pydantic import BaseModel, ConfigDict, Field
from pydantic.alias_generators import to_camel


class RespuestaItemRequest(BaseModel):
    model_config = ConfigDict(alias_generator=to_camel, populate_by_name=True)

    id_evento: uuid.UUID
    pregunta_id: uuid.UUID
    opcion_elegida: str | None = Field(default=None, max_length=1)
    es_correcta: bool
    tiempo_ms: int = Field(ge=0)
    respondida_en: datetime


class LoteRespuestasRequest(BaseModel):
    model_config = ConfigDict(alias_generator=to_camel, populate_by_name=True)

    respuestas: list[RespuestaItemRequest] = Field(..., max_length=100)


class LoteRespuestasResponse(BaseModel):
    model_config = ConfigDict(alias_generator=to_camel, populate_by_name=True)

    recibidos: int
    insertados: int
    duplicados: int
