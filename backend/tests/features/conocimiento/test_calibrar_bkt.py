import pytest

from app.features.conocimiento.application.calibrar_bkt import calibrar_bkt
from app.features.conocimiento.application.simular_secuencias_bkt import simular_secuencias_bkt
from app.features.conocimiento.domain.errores import DatosInsuficientesError
from app.features.conocimiento.domain.respuesta_secuencial import RespuestaSecuencial


def test_simulador_bkt_es_determinista_con_la_misma_semilla() -> None:
    primera = simular_secuencias_bkt(["t1", "t2"], usuarios=15, intentos_por_tema=5, semilla=11)
    segunda = simular_secuencias_bkt(["t1", "t2"], usuarios=15, intentos_por_tema=5, semilla=11)

    assert primera == segunda


def test_calibrar_bkt_estima_parametros_cercanos_a_los_verdaderos() -> None:
    respuestas, verdaderos = simular_secuencias_bkt(
        ["t1", "t2"], usuarios=200, intentos_por_tema=10, semilla=7
    )

    estimados = calibrar_bkt(respuestas)

    assert set(estimados) == {"t1", "t2"}
    for tema_id, real in verdaderos.items():
        est = estimados[tema_id]
        assert abs(est.p_inicial - real.p_inicial) < 0.15
        assert abs(est.p_aprendizaje - real.p_aprendizaje) < 0.15
        assert abs(est.p_adivinar - real.p_adivinar) < 0.15
        assert abs(est.p_error - real.p_error) < 0.15


def test_calibrar_bkt_falla_cuando_no_hay_respuestas() -> None:
    with pytest.raises(DatosInsuficientesError, match="No hay respuestas secuenciales"):
        calibrar_bkt([])


def test_calibrar_bkt_falla_cuando_hay_pocas_secuencias() -> None:
    respuestas, _ = simular_secuencias_bkt(["t1"], usuarios=5, intentos_por_tema=4, semilla=3)

    with pytest.raises(DatosInsuficientesError, match="al menos 10 secuencias"):
        calibrar_bkt(respuestas)


def test_calibrar_bkt_falla_cuando_todas_las_respuestas_son_iguales() -> None:
    respuestas = [
        RespuestaSecuencial(f"u{u}", "t1", paso, True) for u in range(12) for paso in range(3)
    ]

    with pytest.raises(DatosInsuficientesError, match="todas las respuestas iguales"):
        calibrar_bkt(respuestas)
