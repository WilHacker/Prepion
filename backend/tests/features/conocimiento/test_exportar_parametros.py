from app.features.conocimiento.application.exportar_parametros import exportar_parametros


def test_exporta_el_formato_exacto_con_una_entrada_bkt_por_tema() -> None:
    resultado = exportar_parametros({"p1": 0.5, "p2": -1.0}, {"p1": "t1", "p2": "t1"})

    assert resultado == {
        "version": 1,
        "preguntas": [
            {"preguntaId": "p1", "dificultad": 0.5},
            {"preguntaId": "p2", "dificultad": -1.0},
        ],
        "bkt": [
            {
                "temaId": "t1",
                "pInicial": 0.3,
                "pAprendizaje": 0.1,
                "pAdivinar": 0.2,
                "pError": 0.1,
            }
        ],
    }
