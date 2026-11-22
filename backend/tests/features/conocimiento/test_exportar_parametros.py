import math
from datetime import UTC, datetime

from app.features.conocimiento.application.exportar_parametros import exportar_parametros

_RELOJ = lambda: datetime(2026, 11, 22, 18, 0, tzinfo=UTC)  # noqa: E731


def test_exporta_el_formato_exacto_del_contrato() -> None:
    resultado = exportar_parametros(
        {"p1": 0.0, "p2": math.log(3)},
        {"p1": "t1", "p2": "t1"},
        origen="real",
        usuarios=25,
        reloj=_RELOJ,
    )

    assert resultado == {
        "version": 1,
        "origen": "real",
        "usuarios": 25,
        "generadoEn": "2026-11-22T18:00:00Z",
        "preguntas": [
            {"preguntaId": "p1", "dificultad": 0.0},
            {"preguntaId": "p2", "dificultad": math.log(3)},
        ],
        "bkt": [
            {
                "temaId": "t1",
                "pInicial": 0.375,  # promedio de 1/(1+e^0)=0.5 y 1/(1+3)=0.25
                "pAprendizaje": 0.1,
                "pAdivinar": 0.2,
                "pError": 0.1,
            }
        ],
    }


def test_p_inicial_se_acota_a_0_1_y_0_9() -> None:
    resultado = exportar_parametros({"facil": -8.0, "dificil": 8.0}, {"facil": "a", "dificil": "b"})

    assert {t["temaId"]: t["pInicial"] for t in resultado["bkt"]} == {"a": 0.9, "b": 0.1}


def test_tema_sin_preguntas_calibradas_usa_0_3() -> None:
    resultado = exportar_parametros({"p1": 0.0}, {"p1": "a", "p2": "b"})

    assert {t["temaId"]: t["pInicial"] for t in resultado["bkt"]} == {"a": 0.5, "b": 0.3}


def test_redondea_a_cuatro_decimales_y_usa_el_reloj_real_por_defecto() -> None:
    resultado = exportar_parametros({"p1": 1.0}, {"p1": "a"})

    assert resultado["bkt"][0]["pInicial"] == 0.2689  # 1/(1+e) = 0.26894...
    assert resultado["origen"] == "simulado"
    assert resultado["generadoEn"].endswith("Z")
