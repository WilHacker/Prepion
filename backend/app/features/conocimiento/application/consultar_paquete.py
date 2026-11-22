from typing import Any

from app.features.conocimiento.domain.errores import PaqueteNoEncontradoError
from app.features.conocimiento.domain.puertos import RepositorioPaquetes


def obtener_paquete_actual(paquetes: RepositorioPaquetes) -> dict[str, Any]:
    paquete = paquetes.obtener_actual()
    if paquete is None:
        raise PaqueteNoEncontradoError("Todavía no hay un paquete de conocimiento publicado")
    return paquete
