from app.shared.domain.errores import ReglaDeNegocioError


class BancoInvalidoError(ReglaDeNegocioError):
    """El borrador curado no cumple las reglas para publicarse como banco."""


class PortalNoDisponibleError(ReglaDeNegocioError):
    """El portal de la Facultad no respondió o devolvió algo inesperado."""


class ArchivoInseguroError(ReglaDeNegocioError):
    """La URL o el nombre de un archivo del portal no pasan las comprobaciones de seguridad."""
