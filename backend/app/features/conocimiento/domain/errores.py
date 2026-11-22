from app.shared.domain.errores import ReglaDeNegocioError


class DatosInsuficientesError(ReglaDeNegocioError):
    """No hay respuestas suficientes (o útiles) para calibrar la dificultad."""
