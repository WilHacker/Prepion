from app.features.conocimiento.application.exportar_parametros import exportar_parametros
from app.features.conocimiento.domain.parametros_bkt import ParametrosBkt


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


def test_exporta_parametros_bkt_calibrados_cuando_se_proporcionan() -> None:
    bkt = {
        "t1": ParametrosBkt(
            tema_id="t1", p_inicial=0.41, p_aprendizaje=0.18, p_adivinar=0.22, p_error=0.09
        )
    }

    resultado = exportar_parametros({"p1": 0.25}, {"p1": "t1"}, bkt)

    assert resultado["bkt"] == [
        {
            "temaId": "t1",
            "pInicial": 0.41,
            "pAprendizaje": 0.18,
            "pAdivinar": 0.22,
            "pError": 0.09,
        }
    ]
