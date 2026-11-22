from app.shared.domain.errores import ConflictoError, RecursoNoEncontradoError, ReglaDeNegocioError


class DatosInsuficientesError(ReglaDeNegocioError):
    """No hay respuestas suficientes (o útiles) para calibrar la dificultad."""


class SinBancoPublicadoError(ConflictoError):
    """No hay banco publicado: sin banco no hay qué calibrar (409)."""


class PaqueteNoEncontradoError(RecursoNoEncontradoError):
    """Todavía no se publicó ningún paquete de conocimiento (404)."""
