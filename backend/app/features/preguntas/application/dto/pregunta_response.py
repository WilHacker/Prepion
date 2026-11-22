from uuid import UUID

from pydantic import BaseModel, ConfigDict
from pydantic.alias_generators import to_camel


class PreguntaResponse(BaseModel):
    model_config = ConfigDict(alias_generator=to_camel, populate_by_name=True)

    id: UUID
    examen_id: UUID
    codigo: str
    tema_id: UUID | None = None
    enunciado: str
    opciones: list[str] = []
    ruta_imagen: str | None = None
    respuesta: str | None = None
    explicacion: str | None = None
    fuente: str | None = None
    estado: str = "publicada"
