import uuid
from dataclasses import dataclass
from datetime import datetime

from app.features.reportes.domain.errores import MotivoReporteInvalidoError

MOTIVOS_VALIDOS = {
    "respuesta_incorrecta",
    "imagen_borrosa",
    "error_tipografico",
    "otro",
}

ESTADO_PENDIENTE = "pendiente"
ESTADO_REVISADO = "revisado"
ESTADO_DESCARTADO = "descartado"


@dataclass(frozen=True)
class Reporte:
    id: uuid.UUID
    pregunta_id: uuid.UUID
    usuario_id: uuid.UUID | None
    motivo: str
    comentario: str | None
    estado: str
    creado_en: datetime
    actualizado_en: datetime

    def __post_init__(self) -> None:
        if not self.motivo or not self.motivo.strip():
            raise MotivoReporteInvalidoError("El motivo del reporte no puede estar vacío.")
        if self.motivo.strip().lower() not in MOTIVOS_VALIDOS:
            permitidos = ", ".join(sorted(MOTIVOS_VALIDOS))
            raise MotivoReporteInvalidoError(
                f"Motivo '{self.motivo}' inválido. Permitidos: {permitidos}."
            )
