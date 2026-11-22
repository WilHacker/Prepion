from app.features.preguntas.domain.banco import BancoRepositorio
from app.features.preguntas.domain.errores import BancoNoEncontradoError


def volcar_banco_publicado(repositorio: BancoRepositorio) -> int:
    """Escribe en las tablas relacionales el banco publicado más reciente y devuelve su versión.

    `publicar` ya lo hace con cada banco nuevo; esto sirve para un banco publicado antes de que
    existiera ese volcado. Sin las filas de `preguntas`, la sincronización de respuestas (que
    apunta a ellas con una llave foránea) y el catálogo de temas no tienen nada que ver.
    Es idempotente: se puede repetir sin duplicar filas.
    """
    actual = repositorio.obtener_actual()
    contenido = None if actual is None else repositorio.obtener_contenido(actual.version)
    if actual is None or contenido is None:
        raise BancoNoEncontradoError("Todavía no hay un banco de preguntas publicado.")
    repositorio.volcar_a_tablas(contenido)
    return actual.version
