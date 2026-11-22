"""Simulador determinista de respuestas (demo y pruebas)."""

from collections.abc import Sequence

import numpy as np

from app.features.conocimiento.domain.respuesta_observada import RespuestaObservada


def simular_respuestas(
    pregunta_ids: Sequence[str], usuarios: int = 60, semilla: int = 7
) -> tuple[list[RespuestaObservada], dict[str, float]]:
    """Devuelve (respuestas, dificultades verdaderas) con el modelo de Rasch."""
    azar = np.random.default_rng(semilla)
    dificultad = np.linspace(-2, 2, len(pregunta_ids))
    azar.shuffle(dificultad)
    habilidad = azar.normal(size=usuarios)
    probabilidad = 1 / (1 + np.exp(-(habilidad[None, :] - dificultad[:, None])))
    aciertos = azar.random(probabilidad.shape) < probabilidad
    respuestas = [
        RespuestaObservada(f"u{j}", pregunta, bool(aciertos[i, j]))
        for i, pregunta in enumerate(pregunta_ids)
        for j in range(usuarios)
    ]
    verdaderas = {p: float(dificultad[i]) for i, p in enumerate(pregunta_ids)}
    return respuestas, verdaderas
