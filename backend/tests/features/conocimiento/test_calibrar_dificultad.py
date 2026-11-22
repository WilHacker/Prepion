import numpy as np
import pytest

from app.features.conocimiento.application.calibrar_dificultad import calibrar_dificultad
from app.features.conocimiento.application.simular_respuestas import simular_respuestas
from app.features.conocimiento.domain.errores import DatosInsuficientesError
from app.features.conocimiento.domain.respuesta_observada import RespuestaObservada

IDS = [f"p{i}" for i in range(12)]


def test_la_dificultad_calibrada_correlaciona_con_la_verdadera() -> None:
    respuestas, verdaderas = simular_respuestas(IDS, usuarios=80, semilla=7)

    calibradas = calibrar_dificultad(respuestas)

    real = [verdaderas[p] for p in IDS]
    estimada = [calibradas[p] for p in IDS]
    assert np.corrcoef(real, estimada)[0, 1] > 0.8
    assert min(IDS, key=verdaderas.get) in sorted(IDS, key=calibradas.get)[:3]  # type: ignore[arg-type]
    assert max(IDS, key=verdaderas.get) in sorted(IDS, key=calibradas.get)[-3:]  # type: ignore[arg-type]


def test_admite_respuestas_faltantes() -> None:
    respuestas, _ = simular_respuestas(IDS, usuarios=60)

    calibradas = calibrar_dificultad(respuestas[5:])

    assert set(calibradas) == set(IDS)


def test_falla_con_pocos_usuarios() -> None:
    respuestas, _ = simular_respuestas(IDS, usuarios=10)

    with pytest.raises(DatosInsuficientesError, match="al menos 20 usuarios"):
        calibrar_dificultad(respuestas)


def test_falla_si_todos_aciertan_una_pregunta() -> None:
    respuestas, _ = simular_respuestas(IDS, usuarios=40)
    sin_p0 = [r for r in respuestas if r.pregunta_id != "p0"]
    todos_aciertan = [RespuestaObservada(f"u{j}", "p0", True) for j in range(40)]

    with pytest.raises(DatosInsuficientesError, match="p0"):
        calibrar_dificultad(sin_p0 + todos_aciertan)
