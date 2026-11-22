import json
from pathlib import Path

import pytest
from sqlalchemy import Engine
from sqlmodel import Session

from app.features.preguntas.infrastructure.cli import main
from app.features.preguntas.infrastructure.persistence.banco_repositorio import (
    BancoRepositorioSql,
)


def _archivo(tmp_path: Path, contenido: object) -> Path:
    ruta = tmp_path / "banco.json"
    ruta.write_text(json.dumps(contenido), encoding="utf-8")
    return ruta


def test_publica_el_banco_curado_en_la_base(motor: Engine, tmp_path: Path):
    ruta = _archivo(tmp_path, {"version": 1, "preguntas": [{"id": "p1"}]})

    codigo = main(["publicar", str(ruta)], motor=motor)

    with Session(motor) as sesion:
        actual = BancoRepositorioSql(sesion).obtener_actual()
    assert codigo == 0
    assert actual is not None
    assert (actual.version, actual.cantidad) == (1, 1)


def test_avisa_con_codigo_de_error_cuando_la_version_ya_estaba_publicada(
    motor: Engine, tmp_path: Path, capsys: pytest.CaptureFixture[str]
):
    ruta = _archivo(tmp_path, {"version": 1, "preguntas": [{"id": "p1"}]})
    main(["publicar", str(ruta)], motor=motor)

    codigo = main(["publicar", str(ruta)], motor=motor)

    assert codigo == 1
    assert "ya está publicada" in capsys.readouterr().err


def test_avisa_cuando_el_archivo_no_existe(
    motor: Engine, tmp_path: Path, capsys: pytest.CaptureFixture[str]
):
    codigo = main(["publicar", str(tmp_path / "no-existe.json")], motor=motor)

    assert codigo == 1
    assert "no-existe.json" in capsys.readouterr().err


def test_avisa_cuando_el_archivo_no_es_json(
    motor: Engine, tmp_path: Path, capsys: pytest.CaptureFixture[str]
):
    ruta = tmp_path / "banco.json"
    ruta.write_text("esto no es json", encoding="utf-8")

    codigo = main(["publicar", str(ruta)], motor=motor)

    assert codigo == 1
    assert "JSON" in capsys.readouterr().err
