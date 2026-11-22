from pathlib import Path
from unittest.mock import MagicMock

import pytest
import requests

from app.features.examenes.domain.errores import DescargaExamenError
from app.features.examenes.domain.examen_remoto import ExamenRemoto
from app.features.examenes.infrastructure.adapters.scraper_fcyt import (
    ScraperFcyt,
    parsear_catalogo_html,
)
from app.features.examenes.infrastructure.cli import main

_URL_EXAMEN_1 = "https://sagaa.fcyt.umss.edu.bo/admision/archivos/2026-2-1op.pdf"
_HTML_MUESTRA = f"""
<html><body><table>
  <tr>
    <td>141</td>
    <td>Primer Examen de Ingreso FCyT 2-2026</td>
    <td>2026-2-1op.pdf</td>
    <td>585 KB</td>
    <td><input type="button" value="Descargar"
         onclick="window.location='{_URL_EXAMEN_1}'" /></td>
  </tr>
  <tr>
    <td>142</td>
    <td>Segundo Examen de Ingreso FCyT 2-2026</td>
    <td>2026-2-2op.pdf</td>
    <td>408 KB</td>
    <td><a href="archivos/2026-2-2op.pdf">Descargar</a></td>
  </tr>
</table></body></html>
"""


def test_parsea_catalogo_html_con_botones_onclick_y_enlaces_pdf() -> None:
    examenes = parsear_catalogo_html(
        _HTML_MUESTRA, "https://sagaa.fcyt.umss.edu.bo/admision/examenes.php"
    )

    assert len(examenes) == 2
    assert examenes[0] == ExamenRemoto(
        archivo="2026-2-1op.pdf",
        titulo="Primer Examen de Ingreso FCyT 2-2026",
        gestion="2-2026",
        tipo="1op",
        url="https://sagaa.fcyt.umss.edu.bo/admision/archivos/2026-2-1op.pdf",
        tamano_kb=585,
    )
    assert examenes[1].url == "https://sagaa.fcyt.umss.edu.bo/admision/archivos/2026-2-2op.pdf"
    assert examenes[1].tipo == "2op"


def test_scraper_lista_y_descarga_pdf_valido(tmp_path: Path) -> None:
    sesion = MagicMock(spec=requests.Session)
    resp_html = MagicMock(text=_HTML_MUESTRA)
    resp_pdf = MagicMock(content=b"%PDF-1.7\ncontenido")
    sesion.get.side_effect = [resp_html, resp_pdf]
    scraper = ScraperFcyt(sesion=sesion)

    examenes = scraper.listar_examenes("https://sagaa.fcyt.umss.edu.bo/admision/examenes.php")
    destino = scraper.descargar_pdf(examenes[0], tmp_path / examenes[0].archivo)

    assert destino.read_bytes().startswith(b"%PDF")


def test_scraper_rechaza_contenido_que_no_es_pdf(tmp_path: Path) -> None:
    sesion = MagicMock(spec=requests.Session)
    sesion.get.return_value = MagicMock(content=b"<html>404 Not Found</html>")
    scraper = ScraperFcyt(sesion=sesion)
    examen = ExamenRemoto("x.pdf", "X", "2-2026", "1op", "https://ex/x.pdf")

    with pytest.raises(DescargaExamenError, match="no es un PDF válido"):
        scraper.descargar_pdf(examen, tmp_path / "x.pdf")


def test_scraper_envuelve_errores_de_red() -> None:
    sesion = MagicMock(spec=requests.Session)
    sesion.get.side_effect = requests.ConnectionError("sin red")
    scraper = ScraperFcyt(sesion=sesion)

    with pytest.raises(DescargaExamenError, match="No se pudo consultar el catálogo"):
        scraper.listar_examenes("https://sagaa.fcyt.umss.edu.bo/admision/examenes.php")


def test_cli_lista_y_descarga_examenes(
    monkeypatch: pytest.MonkeyPatch, tmp_path: Path, capsys: pytest.CaptureFixture[str]
) -> None:
    examen = ExamenRemoto("2026-2-1op.pdf", "Primer", "2-2026", "1op", "https://ex/1.pdf")

    class _ScraperMock:
        def listar_examenes(self, url_catalogo: str) -> list[ExamenRemoto]:
            return [examen]

        def descargar_pdf(self, ex: ExamenRemoto, destino: Path) -> Path:
            destino.write_bytes(b"%PDF-ok")
            return destino

    monkeypatch.setattr(
        "app.features.examenes.infrastructure.cli.ScraperFcyt", lambda: _ScraperMock()
    )

    assert main(["listar", "--gestion", "2-2026"]) == 0
    assert "2026-2-1op.pdf" in capsys.readouterr().out

    assert main(["descargar", str(tmp_path), "--limite", "1"]) == 0
    assert (tmp_path / "2026-2-1op.pdf").exists()
