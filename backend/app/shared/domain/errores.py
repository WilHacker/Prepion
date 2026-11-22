class DominioError(Exception):
    """Error de negocio con un mensaje seguro para mostrar al usuario."""

    codigo_http = 422

    def __init__(self, mensaje: str) -> None:
        super().__init__(mensaje)
        self.mensaje = mensaje


class NoAutorizadoError(DominioError):
    codigo_http = 401


class ProhibidoError(DominioError):
    codigo_http = 403


class RecursoNoEncontradoError(DominioError):
    codigo_http = 404


class ConflictoError(DominioError):
    codigo_http = 409


class ReglaDeNegocioError(DominioError):
    codigo_http = 422


class ServicioNoDisponibleError(DominioError):
    codigo_http = 503
