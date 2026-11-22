from pathlib import Path

import pytest

from app.features.examenes.domain.examen_publicado import ExamenPublicado
from app.features.examenes.infrastructure import cli


class _PortalFalso:
    def __init__(self, falla: bool = False) -> None:
        self.falla = falla

    def descargar_catalogo(self) -> list[ExamenPublicado]:
        return [ExamenPublicado(titulo="t", archivo="a.pdf", url="u", tamano="1 KB")]

    def descargar_pdf(self, examen: ExamenPublicado) -> bytes:
        if self.falla:
            raise RuntimeError("roto")
        return b"%PDF-x"


def test_recolectar_imprime_el_resumen_y_guarda_el_pdf(
    tmp_path: Path, monkeypatch: pytest.MonkeyPatch, capsys: pytest.CaptureFixture[str]
):
    monkeypatch.setattr(cli, "PortalFcyt", _PortalFalso)
    codigo = cli.main(["recolectar", "--carpeta", str(tmp_path), "--limite", "1"])
    salida = capsys.readouterr().out
    assert codigo == 0
    assert "1 descargados ahora" in salida and "+ a.pdf" in salida
    assert (tmp_path / "a.pdf").is_file()


def test_recolectar_con_errores_sale_con_codigo_1_y_escribe_en_stderr(
    tmp_path: Path, monkeypatch: pytest.MonkeyPatch, capsys: pytest.CaptureFixture[str]
):
    monkeypatch.setattr(cli, "PortalFcyt", lambda: _PortalFalso(falla=True))
    codigo = cli.main(["recolectar", "--carpeta", str(tmp_path)])
    assert codigo == 1
    assert "a.pdf: roto" in capsys.readouterr().err
