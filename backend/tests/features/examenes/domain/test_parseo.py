import pytest

from app.features.examenes.domain.parseo import (
    describir_examen,
    es_encabezado_de_seccion,
    etiqueta_de_tipo,
    normalizar_para_comparar,
    parsear_cabecera,
    separar_enunciado_y_opciones,
    tiene_formula,
)


@pytest.mark.parametrize(
    ("linea", "esperado"),
    [
        ("A1.  Simplificar", ("A", 1, "Simplificar")),
        ("Q16.- Ajusta por el método", ("Q", 16, "Ajusta por el método")),
        ("B18. Las biomoléculas", ("B", 18, "Las biomoléculas")),
        ("F 11. Un bloque", ("F", 11, "Un bloque")),
    ],
)
def test_parsea_la_cabecera_cuando_la_linea_empieza_una_pregunta(linea, esperado):
    assert parsear_cabecera(linea) == esperado


@pytest.mark.parametrize(
    "linea",
    ["Calcule el valor de x.", "a) 50", "K2Cr2O7 + HI → Cr", "FACULTAD DE CIENCIAS Y TECNOLOGIA"],
)
def test_no_parsea_cabecera_cuando_la_linea_no_empieza_una_pregunta(linea):
    assert parsear_cabecera(linea) is None


@pytest.mark.parametrize(
    "linea",
    ["GEOMETRIA – TRIGONOMETRIA", "QUÍMICA", "FISICA", "ARITMETICA  - ALGEBRA", " BIOLOGÍA "],
)
def test_reconoce_encabezados_de_seccion(linea):
    assert es_encabezado_de_seccion(linea)


@pytest.mark.parametrize(
    "linea", ["Calcule la física del problema", "FACULTAD DE CIENCIAS Y TECNOLOGIA", ""]
)
def test_no_confunde_texto_normal_con_un_encabezado_de_seccion(linea):
    assert not es_encabezado_de_seccion(linea)


def test_separa_las_opciones_cuando_estan_en_lineas_distintas():
    texto = "Hallar x.\na) 8\n \nb) 10\nc) 4\nd) 6\ne) Ninguno"

    enunciado, opciones = separar_enunciado_y_opciones(texto)

    assert enunciado == "Hallar x."
    assert opciones == ("8", "10", "4", "6", "Ninguno")


def test_separa_las_opciones_cuando_estan_todas_en_una_linea_con_mayusculas():
    texto = "¿Cuál es?\nA) Lípidos  B) Carbohidratos C) Proteínas D) Agua E) Sal"

    enunciado, opciones = separar_enunciado_y_opciones(texto)

    assert enunciado == "¿Cuál es?"
    assert opciones == ("Lípidos", "Carbohidratos", "Proteínas", "Agua", "Sal")


def test_usa_la_ultima_serie_de_opciones_cuando_el_enunciado_tiene_un_a_con_parentesis():
    texto = "En el punto a) se ve algo.\na) 1\nb) 2\nc) 3\nd) 4\ne) 5"

    enunciado, opciones = separar_enunciado_y_opciones(texto)

    assert enunciado == "En el punto a) se ve algo."
    assert opciones == ("1", "2", "3", "4", "5")


def test_devuelve_sin_opciones_cuando_el_texto_no_las_trae():
    enunciado, opciones = separar_enunciado_y_opciones("Solo un enunciado\ncon dos líneas")

    assert enunciado == "Solo un enunciado con dos líneas"
    assert opciones == ()


@pytest.mark.parametrize(
    ("texto", "seccion", "hay_grafico", "esperado"),
    [
        ("Simplificar la expresión", "Aritmética-Álgebra", False, True),
        ("Hallar el ángulo", "Geometría-Trigonometría", False, True),
        ("Calcule 𝑥 + 𝑦", "Física", False, True),
        ("Según la figura", "Física", True, True),
        ("Calcule el punto de congelación", "Química", False, False),
        ("K2Cr2O7 + HI → Cr(ClO4)3", "Química", False, False),
        ("Las biomoléculas son", "Biología", False, False),
    ],
)
def test_detecta_si_la_pregunta_necesita_imagen(texto, seccion, hay_grafico, esperado):
    assert tiene_formula(texto, seccion, hay_grafico=hay_grafico) is esperado


@pytest.mark.parametrize(
    ("archivo", "esperado"),
    [
        ("2026-2-1op.pdf", ("2-2026", "1op")),
        ("2025-1-3op.pdf", ("1-2025", "3op")),
        ("2026-1-preu.pdf", ("1-2026", "preu")),
        ("raro.pdf", ("raro", "raro")),
    ],
)
def test_describe_el_examen_a_partir_del_nombre_del_archivo(archivo, esperado):
    assert describir_examen(archivo) == esperado


@pytest.mark.parametrize(
    ("tipo", "esperado"),
    [("1op", "1.ª opción"), ("preu", "Preuniversitario"), ("otro", "otro")],
)
def test_traduce_el_tipo_de_examen_a_un_texto_para_el_usuario(tipo, esperado):
    assert etiqueta_de_tipo(tipo) == esperado


def test_normaliza_el_texto_para_detectar_preguntas_repetidas():
    assert normalizar_para_comparar("  Hallar  X.\n¿Cuánto?") == normalizar_para_comparar(
        "hallar x. ¿cuánto?"
    )
