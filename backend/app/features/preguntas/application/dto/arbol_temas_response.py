from uuid import UUID

from pydantic import BaseModel, ConfigDict
from pydantic.alias_generators import to_camel


class TemaResponse(BaseModel):
    model_config = ConfigDict(alias_generator=to_camel, populate_by_name=True)

    tema_id: UUID
    nombre: str
    cantidad_preguntas: int


class MateriaResponse(BaseModel):
    model_config = ConfigDict(alias_generator=to_camel, populate_by_name=True)

    materia: str
    cantidad_preguntas: int
    temas: list[TemaResponse]
