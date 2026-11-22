import csv
import json
from pathlib import Path

import pymupdf
import pytest

from app.features.examenes.infrastructure.adapters.borrador_csv import COLUMNAS
from app.features.examenes.infrastructure.cli import main


@pytest.fixture
def pdf_de_prueba(tmp_path: Path) -> Path:
    documento = pymupdf.open()
    pagina = documento.new_page(width=612, height=800)
    pagina.insert_text((40, 100), "Q1.- Ajusta la reaccion.", fontsize=10)
    pagina.insert_text((40, 115), "a) 8   b) 10   c) 4   d) 6   e) Ninguno", fontsize=10)
    pagina.insert_text((40, 180), "A2. Simplificar la expresion.", fontsize=10)
    pagina.insert_text((40, 195), "a) 1   b) 2   c) 3   d) 4   e) Ninguno", fontsize=10)
    ruta = tmp_path / "2026-2-1op.pdf"
    documento.save(ruta)
    documento.close()
    return ruta


def _curar(ruta_csv: Path) -> None:
    """Hace lo que haría el equipo: completar y publicar solo la de Química."""
    with ruta_csv.open(newline="", encoding="utf-8-sig") as archivo:
        filas = list(csv.DictReader(archivo))
    for fila in filas:
        if fila["materia"] == "Química":
            fila.update(
                respuesta="b", tema="Redox", explicacion="Se oxida el HI.", estado="publicada"
            )
    with ruta_csv.open("w", newline="", encoding="utf-8-sig") as archivo:
        escritor = csv.DictWriter(archivo, fieldnames=COLUMNAS)
        escritor.writeheader()
        escritor.writerows(filas)


def test_extrae_cura_y_exporta_un_examen_de_punta_a_punta(pdf_de_prueba: Path, tmp_path: Path):
    borrador = tmp_path / "borradores" / "2026-2-1op.csv"
    imagenes = tmp_path / "data_imagenes"
    salida = tmp_path / "banco_v1.json"

    assert main(["extraer", str(pdf_de_prueba), str(borrador), "--imagenes", str(imagenes)]) == 0
    _curar(borrador)
    codigo = main(["exportar", str(borrador), str(salida), "--examen", "2026-2-1op.pdf"])

    banco = json.loads(salida.read_text(encoding="utf-8"))
    assert codigo == 0
    assert [p["codigo"] for p in banco["preguntas"]] == ["S1-Q1"]
    assert banco["preguntas"][0]["respuesta"] == "B"


def test_copia_las_imagenes_de_las_preguntas_publicadas(pdf_de_prueba: Path, tmp_path: Path):
    borrador = tmp_path / "2026-2-1op.csv"
    imagenes = tmp_path / "data_imagenes"
    assets = tmp_path / "assets_imagenes"
    main(["extraer", str(pdf_de_prueba), str(borrador), "--imagenes", str(imagenes)])
    with borrador.open(newline="", encoding="utf-8-sig") as archivo:
        filas = list(csv.DictReader(archivo))
    for fila in filas:
        if fila["materia"] == "Aritmética-Álgebra":
            fila.update(
                respuesta="A", tema="Fracciones", explicacion="Se simplifica.", estado="publicada"
            )
    with borrador.open("w", newline="", encoding="utf-8-sig") as archivo:
        escritor = csv.DictWriter(archivo, fieldnames=COLUMNAS)
        escritor.writeheader()
        escritor.writerows(filas)

    codigo = main(
        [
            "exportar", str(borrador), str(tmp_path / "banco.json"),
            "--examen", "2026-2-1op.pdf",
            "--copiar-imagenes", str(imagenes), str(assets),
        ]
    )  # fmt: skip

    assert codigo == 0
    assert (assets / "2026-2-1op_S1-A2.png").is_file()


def test_avisa_con_codigo_de_error_cuando_el_borrador_no_tiene_preguntas_publicadas(
    pdf_de_prueba: Path, tmp_path: Path, capsys: pytest.CaptureFixture[str]
):
    borrador = tmp_path / "2026-2-1op.csv"
    main(["extraer", str(pdf_de_prueba), str(borrador), "--imagenes", str(tmp_path / "img")])

    codigo = main(
        ["exportar", str(borrador), str(tmp_path / "banco.json"), "--examen", "2026-2-1op.pdf"]
    )

    assert codigo == 1
    assert "publicada" in capsys.readouterr().err


def test_avisa_cuando_el_borrador_ya_existe(
    pdf_de_prueba: Path, tmp_path: Path, capsys: pytest.CaptureFixture[str]
):
    borrador = tmp_path / "2026-2-1op.csv"
    borrador.write_text("trabajo previo", encoding="utf-8")

    codigo = main(
        ["extraer", str(pdf_de_prueba), str(borrador), "--imagenes", str(tmp_path / "img")]
    )

    assert codigo == 1
    assert "ya existe" in capsys.readouterr().err
    assert borrador.read_text(encoding="utf-8") == "trabajo previo"
