import pytest

from app.features.examenes.application.exportar_banco import exportar_banco
from app.features.examenes.domain.errores import BancoInvalidoError


def _fila(**cambios: str) -> dict[str, str]:
    fila = {
        "codigo": "S1-Q16",
        "serie": "1",
        "materia": "Química",
        "pagina": "2",
        "enunciado": "Hallar el coeficiente del agente reductor.",
        "opcion_a": "8",
        "opcion_b": "10",
        "opcion_c": "4",
        "opcion_d": "6",
        "opcion_e": "Ninguno",
        "requiere_imagen": "no",
        "ruta_imagen": "",
        "duplicada_de": "",
        "respuesta": "b",
        "tema": "Redox",
        "explicacion": "El HI se oxida y cede los electrones.",
        "estado": "publicada",
    }
    return {**fila, **cambios}


def test_exporta_una_pregunta_publicada_con_el_formato_del_banco():
    banco = exportar_banco([_fila()], "2026-2-1op.pdf", version=1)

    pregunta = banco["preguntas"][0]
    assert banco["version"] == 1
    assert banco["examenes"][0]["gestion"] == "2-2026"
    assert banco["examenes"][0]["tipo"] == "1op"
    assert banco["temas"][0]["materia"] == "Química"
    assert pregunta["codigo"] == "S1-Q16"
    assert pregunta["opciones"] == ["8", "10", "4", "6", "Ninguno"]
    assert pregunta["respuesta"] == "B"
    assert pregunta["rutaImagen"] is None
    assert pregunta["examenId"] == banco["examenes"][0]["id"]
    assert pregunta["temaId"] == banco["temas"][0]["id"]
    assert pregunta["fuente"] == "Examen de ingreso FCyT · 1.ª opción · 2-2026 · Q16 (serie 1)"


def test_genera_los_mismos_identificadores_cuando_se_exporta_dos_veces():
    primera = exportar_banco([_fila()], "2026-2-1op.pdf", version=1)
    segunda = exportar_banco([_fila()], "2026-2-1op.pdf", version=1)

    assert primera == segunda


def test_ignora_las_filas_que_no_estan_publicadas():
    filas = [
        _fila(),
        _fila(codigo="S1-Q17", estado="borrador", respuesta=""),
        _fila(codigo="S2-Q13", estado="duplicada"),
    ]

    banco = exportar_banco(filas, "2026-2-1op.pdf", version=1)

    assert [p["codigo"] for p in banco["preguntas"]] == ["S1-Q16"]


def test_comparte_el_tema_entre_preguntas_de_la_misma_materia():
    filas = [_fila(), _fila(codigo="S1-Q17")]

    banco = exportar_banco(filas, "2026-2-1op.pdf", version=1)

    assert len(banco["temas"]) == 1


def test_usa_la_imagen_recortada_cuando_la_pregunta_la_requiere():
    fila = _fila(requiere_imagen="si", ruta_imagen="assets/imagenes/2026-2-1op_S1-Q16.png")

    banco = exportar_banco([fila], "2026-2-1op.pdf", version=1)

    assert banco["preguntas"][0]["rutaImagen"] == "assets/imagenes/2026-2-1op_S1-Q16.png"


def test_lista_todos_los_problemas_cuando_las_filas_publicadas_estan_incompletas():
    filas = [
        _fila(respuesta=""),
        _fila(codigo="S1-Q17", respuesta="Z"),
        _fila(codigo="S1-Q18", tema=""),
        _fila(codigo="S1-Q19", explicacion=""),
        _fila(codigo="S1-Q20", requiere_imagen="si", ruta_imagen=""),
        _fila(codigo="S2-Q13", duplicada_de="S1-Q16"),
    ]

    with pytest.raises(BancoInvalidoError) as error:
        exportar_banco(filas, "2026-2-1op.pdf", version=1)

    mensaje = error.value.mensaje
    for esperado in ["S1-Q16", "S1-Q17", "S1-Q18", "S1-Q19", "S1-Q20", "S2-Q13"]:
        assert esperado in mensaje


def test_falla_cuando_no_hay_ninguna_pregunta_publicada():
    with pytest.raises(BancoInvalidoError, match="publicada"):
        exportar_banco([_fila(estado="borrador")], "2026-2-1op.pdf", version=1)
