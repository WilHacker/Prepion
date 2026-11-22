from app.features.conocimiento.application.simular_respuestas import simular_respuestas


def test_es_determinista_con_la_misma_semilla() -> None:
    assert simular_respuestas(["a", "b"], 5, 1) == simular_respuestas(["a", "b"], 5, 1)


def test_genera_una_respuesta_por_usuario_y_pregunta() -> None:
    respuestas, verdaderas = simular_respuestas(["a", "b", "c"], usuarios=4)

    assert len(respuestas) == 12
    assert set(verdaderas) == {"a", "b", "c"}
