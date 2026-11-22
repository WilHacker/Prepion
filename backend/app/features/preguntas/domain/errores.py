from app.shared.domain.errores import ConflictoError, RecursoNoEncontradoError, ReglaDeNegocioError


class BancoNoEncontradoError(RecursoNoEncontradoError):
    """No hay banco publicado, o no existe la versión pedida."""


class BancoYaPublicadoError(ConflictoError):
    """Las versiones publicadas no se reemplazan: se publica una nueva."""


class BancoPublicadoInvalidoError(ReglaDeNegocioError):
    """El archivo del banco no tiene versión válida o no trae preguntas."""
