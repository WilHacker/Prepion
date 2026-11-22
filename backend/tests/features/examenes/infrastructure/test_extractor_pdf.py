from pathlib import Path

import pymupdf
import pytest

from app.features.examenes.infrastructure.adapters.extractor_pdf import extraer_preguntas

ENCABEZADO = "UNIVERSIDAD MAYOR DE SAN SIMON"


def _escribir(pagina: pymupdf.Page, y: float, texto: str) -> None:
    pagina.insert_text((40, y), texto, fontsize=10)


@pytest.fixture
def pdf_de_prueba(tmp_path: Path) -> Path:
    """Examen de 2 páginas = 2 series. La Q2 de la serie 2 repite la de la serie 1."""
    documento = pymupdf.open()

    primera = documento.new_page(width=612, height=800)
    _escribir(primera, 40, ENCABEZADO)
    _escribir(primera, 70, "FISICA")
    _escribir(primera, 100, "F1. Un bloque cae libremente.")
    _escribir(primera, 115, "a) 1   b) 2   c) 3   d) 4   e) Ninguno")
    _escribir(primera, 150, "QUIMICA")
    _escribir(primera, 180, "Q2.- Ajusta la reaccion.")
    _escribir(primera, 195, "mira la figura")
    primera.draw_rect(pymupdf.Rect(40, 200, 200, 260), fill=(0.8, 0.8, 0.8))
    _escribir(primera, 280, "a) 8")
    _escribir(primera, 295, "b) 10")
    _escribir(primera, 310, "c) 4")
    _escribir(primera, 325, "d) 6")
    _escribir(primera, 340, "e) Ninguno")

    segunda = documento.new_page(width=612, height=800)
    _escribir(segunda, 40, ENCABEZADO)
    _escribir(segunda, 100, "F1. Otra pregunta distinta de fisica.")
    _escribir(segunda, 115, "a) 5   b) 6   c) 7   d) 8   e) Ninguno")
    _escribir(segunda, 180, "Q2.- Ajusta la reaccion.")
    _escribir(segunda, 195, "mira la figura")
    _escribir(segunda, 280, "a) 8   b) 10   c) 4   d) 6   e) Ninguno")

    ruta = tmp_path / "2026-2-1op.pdf"
    documento.save(ruta)
    documento.close()
    return ruta


def test_extrae_las_preguntas_de_las_dos_series(pdf_de_prueba: Path, tmp_path: Path):
    preguntas = extraer_preguntas(pdf_de_prueba, tmp_path / "imagenes")

    assert [p.codigo_completo for p in preguntas] == ["S1-F1", "S1-Q2", "S2-F1", "S2-Q2"]
    assert [p.pagina for p in preguntas] == [1, 1, 2, 2]


def test_separa_enunciado_y_opciones_sin_arrastrar_el_encabezado_de_la_siguiente_materia(
    pdf_de_prueba: Path, tmp_path: Path
):
    fisica = extraer_preguntas(pdf_de_prueba, tmp_path / "imagenes")[0]

    assert fisica.enunciado == "Un bloque cae libremente."
    assert fisica.opciones == ("1", "2", "3", "4", "Ninguno")
    assert fisica.materia == "Física"


def test_recorta_una_imagen_cuando_la_pregunta_tiene_un_grafico(
    pdf_de_prueba: Path, tmp_path: Path
):
    carpeta = tmp_path / "imagenes"

    preguntas = extraer_preguntas(pdf_de_prueba, carpeta)

    quimica = preguntas[1]
    assert quimica.requiere_imagen
    assert quimica.ruta_imagen == "assets/imagenes/2026-2-1op_S1-Q2.png"
    assert (carpeta / "2026-2-1op_S1-Q2.png").stat().st_size > 0
    assert not preguntas[0].requiere_imagen
    assert preguntas[0].ruta_imagen is None


def test_marca_la_pregunta_repetida_en_la_segunda_serie(pdf_de_prueba: Path, tmp_path: Path):
    preguntas = extraer_preguntas(pdf_de_prueba, tmp_path / "imagenes")

    assert preguntas[3].duplicada_de == "S1-Q2"
    assert preguntas[2].duplicada_de is None


def test_no_pega_al_enunciado_los_restos_de_la_linea_anterior(tmp_path: Path):
    # Preparar: un resto (fracción o letra con cola) queda pegado encima del código.
    documento = pymupdf.open()
    pagina = documento.new_page(width=612, height=800)
    _escribir(pagina, 100, "F1. Primera pregunta.")
    _escribir(pagina, 115, "a) 1   b) 2   c) 3   d) 4   e) Ninguno")
    _escribir(pagina, 177, "zz")
    _escribir(pagina, 180, "F2. Segunda pregunta.")
    _escribir(pagina, 195, "a) 1   b) 2   c) 3   d) 4   e) Ninguno")
    ruta = tmp_path / "examen.pdf"
    documento.save(ruta)
    documento.close()

    # Actuar
    primera, segunda = extraer_preguntas(ruta, tmp_path / "imagenes")

    # Verificar
    assert segunda.enunciado == "Segunda pregunta."
    assert "zz" not in segunda.enunciado
    assert primera.enunciado == "Primera pregunta."


def test_falla_cuando_el_archivo_no_existe(tmp_path: Path):
    with pytest.raises(FileNotFoundError):
        extraer_preguntas(tmp_path / "no-existe.pdf", tmp_path / "imagenes")
