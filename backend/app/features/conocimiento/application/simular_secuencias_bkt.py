"""Simulador determinista de secuencias de práctica por tema (para entrenar/probar BKT)."""

from collections.abc import Sequence

import numpy as np

from app.features.conocimiento.domain.parametros_bkt import ParametrosBkt
from app.features.conocimiento.domain.respuesta_secuencial import RespuestaSecuencial


def simular_secuencias_bkt(
    temas_ids: Sequence[str],
    usuarios: int = 60,
    intentos_por_tema: int = 8,
    semilla: int = 7,
) -> tuple[list[RespuestaSecuencial], dict[str, ParametrosBkt]]:
    """Devuelve `(respuestas_secuenciales, parametros_verdaderos)` según BKT estándar."""
    azar = np.random.default_rng(semilla)
    verdaderos: dict[str, ParametrosBkt] = {}
    respuestas: list[RespuestaSecuencial] = []

    for tema_id in sorted(set(temas_ids)):
        p_inicial = float(azar.uniform(0.15, 0.45))
        p_aprendizaje = float(azar.uniform(0.08, 0.28))
        p_adivinar = float(azar.uniform(0.15, 0.25))
        p_error = float(azar.uniform(0.06, 0.16))
        verdaderos[tema_id] = ParametrosBkt(
            tema_id=tema_id,
            p_inicial=round(p_inicial, 4),
            p_aprendizaje=round(p_aprendizaje, 4),
            p_adivinar=round(p_adivinar, 4),
            p_error=round(p_error, 4),
        )

        for indice_usuario in range(usuarios):
            usuario_id = f"u{indice_usuario}"
            domina = bool(azar.random() < p_inicial)
            for paso in range(intentos_por_tema):
                prob_acierto = (1.0 - p_error) if domina else p_adivinar
                es_correcta = bool(azar.random() < prob_acierto)
                respuestas.append(RespuestaSecuencial(usuario_id, tema_id, paso, es_correcta))
                if not domina and azar.random() < p_aprendizaje:
                    domina = True

    return respuestas, verdaderos
