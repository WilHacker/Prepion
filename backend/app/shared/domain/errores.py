class DominioError(Exception):
    """Error de negocio con un mensaje seguro para mostrar al usuario."""

    codigo_http = 422

    def __init__(self, mensaje: str) -> None:
        super().__init__(mensaje)
        self.mensaje = mensaje


class RecursoNoEncontradoError(DominioError):
    codigo_http = 404


class ConflictoError(DominioError):
    codigo_http = 409


class ReglaDeNegocioError(DominioError):
    codigo_http = 422
