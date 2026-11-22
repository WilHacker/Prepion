from app.shared.domain.errores import ReglaDeNegocioError


class MotivoReporteInvalidoError(ReglaDeNegocioError):
    """Lanzado cuando el motivo del reporte está vacío o no es válido."""
