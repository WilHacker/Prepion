import uuid
from dataclasses import dataclass
from datetime import datetime
from typing import Any


@dataclass(frozen=True)
class PaqueteConocimiento:
    id: uuid.UUID
    version: int
    contenido: dict[str, Any]
    actualizado_en: datetime
