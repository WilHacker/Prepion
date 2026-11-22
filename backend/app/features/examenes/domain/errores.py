from app.shared.domain.errores import ReglaDeNegocioError


class BancoInvalidoError(ReglaDeNegocioError):
    """El borrador curado no cumple las reglas para publicarse como banco."""
