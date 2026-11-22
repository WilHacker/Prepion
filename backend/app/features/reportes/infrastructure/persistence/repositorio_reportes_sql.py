from sqlmodel import Session, col, select

from app.features.reportes.domain.puertos import RepositorioReportesInterface
from app.features.reportes.domain.reporte import ESTADO_PENDIENTE, Reporte
from app.features.reportes.infrastructure.persistence.tablas import ReporteTabla


class RepositorioReportesSql(RepositorioReportesInterface):
    def __init__(self, session: Session) -> None:
        self._session = session

    def guardar(self, reporte: Reporte) -> Reporte:
        tabla = ReporteTabla(
            id=reporte.id,
            pregunta_id=reporte.pregunta_id,
            usuario_id=reporte.usuario_id,
            motivo=reporte.motivo,
            comentario=reporte.comentario,
            estado=reporte.estado,
            creado_en=reporte.creado_en,
            actualizado_en=reporte.actualizado_en,
        )
        self._session.add(tabla)
        self._session.commit()
        self._session.refresh(tabla)
        return self._a_dominio(tabla)

    def listar_pendientes(self, limite: int = 100) -> list[Reporte]:
        statement = (
            select(ReporteTabla)
            .where(ReporteTabla.estado == ESTADO_PENDIENTE)
            .order_by(col(ReporteTabla.creado_en).desc())
            .limit(limite)
        )
        filas = self._session.exec(statement).all()
        return [self._a_dominio(fila) for fila in filas]

    @staticmethod
    def _a_dominio(tabla: ReporteTabla) -> Reporte:
        return Reporte(
            id=tabla.id,
            pregunta_id=tabla.pregunta_id,
            usuario_id=tabla.usuario_id,
            motivo=tabla.motivo,
            comentario=tabla.comentario,
            estado=tabla.estado,
            creado_en=tabla.creado_en,
            actualizado_en=tabla.actualizado_en,
        )
