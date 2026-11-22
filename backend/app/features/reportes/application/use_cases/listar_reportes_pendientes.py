from app.features.reportes.domain.puertos import RepositorioReportesInterface
from app.features.reportes.domain.reporte import Reporte


class ListarReportesPendientes:
    def __init__(self, repositorio: RepositorioReportesInterface) -> None:
        self._repositorio = repositorio

    def ejecutar(self, limite: int = 100) -> list[Reporte]:
        return self._repositorio.listar_pendientes(limite=limite)
