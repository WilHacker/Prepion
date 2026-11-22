from abc import ABC, abstractmethod

from app.features.reportes.domain.reporte import Reporte


class RepositorioReportesInterface(ABC):
    @abstractmethod
    def guardar(self, reporte: Reporte) -> Reporte:
        """Persiste un nuevo reporte."""
        ...

    @abstractmethod
    def listar_pendientes(self, limite: int = 100) -> list[Reporte]:
        """Obtiene los reportes en estado pendiente ordenados por fecha de creación."""
        ...
