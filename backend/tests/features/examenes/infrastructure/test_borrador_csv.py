from pathlib import Path

import pytest

from app.features.examenes.domain.pregunta_extraida import PreguntaExtraida
from app.features.examenes.infrastructure.adapters.borrador_csv import (
    escribir_borrador,
    leer_borrador,
)


def _pregunta(**cambios) -> PreguntaExtraida:
    base = {
        "serie": 1,
        "codigo": "Q16",
        "pagina": 2,
        "enunciado": "Ajusta la reacción, con coma",
        "opciones": ("8", "10", "4", "6", "Ninguno"),
        "requiere_imagen": False,
    }
    return PreguntaExtraida(**{**base, **cambios})


def test_escribe_y_lee_el_borrador_con_las_columnas_para_curar(tmp_path: Path):
    ruta = tmp_path / "borrador.csv"
    imagen = _pregunta(codigo="A1", requiere_imagen=True, ruta_imagen="assets/imagenes/x.png")

    escribir_borrador([_pregunta(), imagen], ruta)
    filas = leer_borrador(ruta)

    assert filas[0]["codigo"] == "S1-Q16"
    assert filas[0]["materia"] == "Química"
    assert filas[0]["enunciado"] == "Ajusta la reacción, con coma"
    assert filas[0]["opcion_e"] == "Ninguno"
    assert filas[0]["requiere_imagen"] == "no"
    assert filas[0]["estado"] == "borrador"
    assert filas[0]["respuesta"] == ""
    assert filas[1]["requiere_imagen"] == "si"
    assert filas[1]["ruta_imagen"] == "assets/imagenes/x.png"


def test_marca_como_duplicada_la_pregunta_repetida(tmp_path: Path):
    ruta = tmp_path / "borrador.csv"

    escribir_borrador([_pregunta(serie=2, duplicada_de="S1-Q16")], ruta)

    fila = leer_borrador(ruta)[0]
    assert fila["estado"] == "duplicada"
    assert fila["duplicada_de"] == "S1-Q16"


def test_no_pisa_un_borrador_que_ya_existe(tmp_path: Path):
    ruta = tmp_path / "borrador.csv"
    ruta.write_text("trabajo de curación", encoding="utf-8")

    with pytest.raises(FileExistsError):
        escribir_borrador([_pregunta()], ruta)

    assert ruta.read_text(encoding="utf-8") == "trabajo de curación"


def test_lee_el_borrador_cuando_excel_lo_guarda_con_punto_y_coma(tmp_path: Path):
    ruta = tmp_path / "excel.csv"
    ruta.write_text("codigo;respuesta;tema\nS1-Q16;B;Redox, ácido\n", encoding="utf-8-sig")

    filas = leer_borrador(ruta)

    assert filas == [{"codigo": "S1-Q16", "respuesta": "B", "tema": "Redox, ácido"}]


def test_deja_vacias_las_opciones_que_faltan(tmp_path: Path):
    ruta = tmp_path / "borrador.csv"

    escribir_borrador([_pregunta(opciones=("1", "2"))], ruta)

    fila = leer_borrador(ruta)[0]
    assert fila["opcion_b"] == "2"
    assert fila["opcion_c"] == ""
