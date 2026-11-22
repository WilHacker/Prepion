"""Entrena los parámetros BKT por tema mediante Expectation-Maximization (Baum-Welch).

Se implementa directamente en NumPy en lugar de depender de `pyBKT.models.Model.fit`,
porque pyBKT 1.4.3 falla con NumPy 2.x (`EM_fit.py` asigna un arreglo en un escalar).
"""

from collections import defaultdict
from collections.abc import Sequence

import numpy as np

from app.features.conocimiento.domain.errores import DatosInsuficientesError
from app.features.conocimiento.domain.parametros_bkt import ParametrosBkt
from app.features.conocimiento.domain.respuesta_secuencial import RespuestaSecuencial

MINIMO_SECUENCIAS_BKT = 10
_EPS = 1e-12


def _ajustar_un_tema(
    tema_id: str,
    secuencias: list[np.ndarray],
    *,
    iteraciones_max: int,
    tolerancia: float,
) -> ParametrosBkt:
    p_l0 = 0.30
    p_t = 0.12
    p_g = 0.20
    p_s = 0.10

    for _ in range(iteraciones_max):
        transicion = np.array([[1.0 - p_t, p_t], [0.0, 1.0]], dtype=float)
        # emision[estado, observacion]: estado 0 = no domina, estado 1 = domina
        emision = np.array([[1.0 - p_g, p_g], [p_s, 1.0 - p_s]], dtype=float)
        inicial = np.array([1.0 - p_l0, p_l0], dtype=float)

        suma_gamma_0_domina = 0.0
        suma_xi_0_a_1 = 0.0
        suma_gamma_transicion_0 = 0.0
        suma_gamma_0_acierto = 0.0
        suma_gamma_0_total = 0.0
        suma_gamma_1_fallo = 0.0
        suma_gamma_1_total = 0.0

        for obs in secuencias:
            largo = len(obs)
            alpha = np.zeros((largo, 2), dtype=float)
            escala = np.zeros(largo, dtype=float)

            alpha[0] = inicial * emision[:, obs[0]]
            escala[0] = max(float(alpha[0].sum()), _EPS)
            alpha[0] /= escala[0]

            for t in range(1, largo):
                alpha[t] = (alpha[t - 1] @ transicion) * emision[:, obs[t]]
                escala[t] = max(float(alpha[t].sum()), _EPS)
                alpha[t] /= escala[t]

            beta = np.ones((largo, 2), dtype=float)
            for t in range(largo - 2, -1, -1):
                beta[t] = transicion @ (emision[:, obs[t + 1]] * beta[t + 1])
                beta[t] /= max(escala[t + 1], _EPS)

            gamma = alpha * beta
            gamma_sum = np.maximum(gamma.sum(axis=1, keepdims=True), _EPS)
            gamma /= gamma_sum

            suma_gamma_0_domina += float(gamma[0, 1])

            for t in range(largo - 1):
                numerador = (
                    alpha[t, :, None]
                    * transicion
                    * emision[None, :, obs[t + 1]]
                    * beta[t + 1, None, :]
                )
                denom = max(float(numerador.sum()), _EPS)
                xi = numerador / denom
                suma_xi_0_a_1 += float(xi[0, 1])
                suma_gamma_transicion_0 += float(gamma[t, 0])

            aciertos = obs == 1
            suma_gamma_0_acierto += float(gamma[aciertos, 0].sum())
            suma_gamma_0_total += float(gamma[:, 0].sum())
            suma_gamma_1_fallo += float(gamma[~aciertos, 1].sum())
            suma_gamma_1_total += float(gamma[:, 1].sum())

        nuevo_l0 = float(np.clip(suma_gamma_0_domina / len(secuencias), 0.05, 0.95))
        nuevo_t = float(np.clip(suma_xi_0_a_1 / max(suma_gamma_transicion_0, _EPS), 0.01, 0.60))
        nuevo_g = float(np.clip(suma_gamma_0_acierto / max(suma_gamma_0_total, _EPS), 0.05, 0.35))
        nuevo_s = float(np.clip(suma_gamma_1_fallo / max(suma_gamma_1_total, _EPS), 0.02, 0.35))

        delta = max(
            abs(nuevo_l0 - p_l0),
            abs(nuevo_t - p_t),
            abs(nuevo_g - p_g),
            abs(nuevo_s - p_s),
        )
        p_l0, p_t, p_g, p_s = nuevo_l0, nuevo_t, nuevo_g, nuevo_s
        if delta < tolerancia:
            break

    return ParametrosBkt(
        tema_id=tema_id,
        p_inicial=round(p_l0, 4),
        p_aprendizaje=round(p_t, 4),
        p_adivinar=round(p_g, 4),
        p_error=round(p_s, 4),
    )


def calibrar_bkt(
    respuestas: Sequence[RespuestaSecuencial],
    *,
    iteraciones_max: int = 50,
    tolerancia: float = 1e-4,
) -> dict[str, ParametrosBkt]:
    """Entrena parámetros BKT `(P(L0), P(T), P(G), P(S))` para cada tema observado."""
    por_tema: dict[str, dict[str, list[RespuestaSecuencial]]] = defaultdict(
        lambda: defaultdict(list)
    )
    for respuesta in respuestas:
        por_tema[respuesta.tema_id][respuesta.usuario_id].append(respuesta)

    if not por_tema:
        raise DatosInsuficientesError("No hay respuestas secuenciales para entrenar BKT.")

    resultado: dict[str, ParametrosBkt] = {}
    for tema_id in sorted(por_tema):
        usuarios = por_tema[tema_id]
        secuencias: list[np.ndarray] = []
        for items in usuarios.values():
            ordenados = sorted(items, key=lambda r: r.paso)
            if len(ordenados) >= 2:
                secuencias.append(np.array([int(r.es_correcta) for r in ordenados], dtype=int))

        if len(secuencias) < MINIMO_SECUENCIAS_BKT:
            raise DatosInsuficientesError(
                f"El tema {tema_id} necesita al menos {MINIMO_SECUENCIAS_BKT} secuencias "
                f"de >=2 intentos para calibrar BKT; hay {len(secuencias)}."
            )

        todos = np.concatenate(secuencias)
        if todos.min() == todos.max():
            raise DatosInsuficientesError(
                f"El tema {tema_id} tiene todas las respuestas iguales; no se puede calibrar BKT."
            )

        resultado[tema_id] = _ajustar_un_tema(
            tema_id,
            secuencias,
            iteraciones_max=iteraciones_max,
            tolerancia=tolerancia,
        )
    return resultado
