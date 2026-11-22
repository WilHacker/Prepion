import uuid
from datetime import UTC, datetime

from app.features.reportes.domain.puertos import RepositorioReportesInterface
from app.features.reportes.domain.reporte import ESTADO_PENDIENTE, Reporte


class CrearReporte:
    def __init__(self, repositorio: RepositorioReportesInterface) -> None:
        self._repositorio = repositorio

    def ejecutar(
        self,
        pregunta_id: uuid.UUID,
        motivo: str,
        comentario: str | None = None,
        usuario_id: uuid.UUID | None = None,
    ) -> Reporte:
        ahora = datetime.now(UTC)
        reporte = Reporte(
            id=uuid.uuid4(),
            pregunta_id=pregunta_id,
            usuario_id=usuario_id,
            motivo=motivo.strip().lower(),
            comentario=comentario.strip() if comentario and comentario.strip() else None,
            estado=ESTADO_PENDIENTE,
            creado_en=ahora,
            actualizado_en=ahora,
        )
        return self._repositorio.guardar(reporte)
