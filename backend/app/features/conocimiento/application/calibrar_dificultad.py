"""Calibra la dificultad de cada pregunta con el modelo de Rasch (IRT de 1 parámetro)."""

from collections.abc import Sequence

import numpy as np
from girth import rasch_mml  # type: ignore[import-untyped]

from app.features.conocimiento.domain.errores import DatosInsuficientesError
from app.features.conocimiento.domain.respuesta_observada import RespuestaObservada

MINIMO_DE_USUARIOS = 20
_FALTANTE = -99999  # marca de dato faltante que entiende girth


def calibrar_dificultad(respuestas: Sequence[RespuestaObservada]) -> dict[str, float]:
    """Devuelve la dificultad b por pregunta (mayor = más difícil).

    Admite que no todos respondan todo: las celdas vacías se tratan como faltantes.
    """
    usuarios = sorted({r.usuario_id for r in respuestas})
    preguntas = sorted({r.pregunta_id for r in respuestas})
    if len(usuarios) < MINIMO_DE_USUARIOS:
        raise DatosInsuficientesError(
            f"Se necesitan al menos {MINIMO_DE_USUARIOS} usuarios para calibrar; "
            f"hay {len(usuarios)}."
        )
    fila = {p: i for i, p in enumerate(preguntas)}
    columna = {u: j for j, u in enumerate(usuarios)}
    matriz = np.full((len(preguntas), len(usuarios)), _FALTANTE, dtype=int)
    for r in respuestas:
        matriz[fila[r.pregunta_id], columna[r.usuario_id]] = int(r.es_correcta)

    for pregunta, i in fila.items():
        validas = matriz[i][matriz[i] != _FALTANTE]
        if validas.min() == validas.max():
            raise DatosInsuficientesError(
                f"La pregunta {pregunta} la acertaron o fallaron todos; no se puede calibrar."
            )
    dificultades = rasch_mml(matriz)["Difficulty"]
    return {p: float(dificultades[i]) for p, i in fila.items()}
