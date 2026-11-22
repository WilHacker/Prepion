import uuid
from datetime import UTC, datetime
from typing import Any

from app.features.conocimiento.domain.paquete import PaqueteConocimiento
from app.features.conocimiento.domain.puertos import RepositorioConocimiento

PAQUETE_DEFAULT_CONTENIDO: dict[str, Any] = {
    "version": 1,
    "algoritmo": "fsrs",
    "pesos": [
        0.40255,
        1.18385,
        3.173,
        15.69105,
        7.1949,
        0.5345,
        1.4604,
        0.0046,
        1.54575,
        0.1192,
        1.01925,
        1.9395,
        0.11,
        0.29605,
        0.22695,
        0.5698,
        2.85535,
        0.47705,
        0.4191,
    ],
    "irt_parametros_base": {
        "discriminacion_media": 1.0,
        "dificultad_media": 0.0,
    },
}


class ObtenerPaqueteActual:
    def __init__(self, repositorio: RepositorioConocimiento) -> None:
        self._repositorio = repositorio

    def ejecutar(self) -> PaqueteConocimiento:
        paquete = self._repositorio.obtener_paquete_actual()
        if paquete is not None:
            return paquete

        # Paquete semilla por defecto si la base de datos aún no fue calibrada
        return PaqueteConocimiento(
            id=uuid.UUID("00000000-0000-0000-0000-000000000001"),
            version=1,
            contenido=PAQUETE_DEFAULT_CONTENIDO,
            actualizado_en=datetime.now(UTC),
        )
