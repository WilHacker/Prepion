import uuid
from dataclasses import dataclass
from datetime import datetime


@dataclass(frozen=True)
class RespuestaEntrante:
    id_evento: uuid.UUID
    pregunta_id: uuid.UUID
    opcion_elegida: str | None
    es_correcta: bool
    tiempo_ms: int
    respondida_en: datetime
