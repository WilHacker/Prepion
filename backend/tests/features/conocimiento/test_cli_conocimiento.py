import json
from pathlib import Path

from app.features.conocimiento.infrastructure.cli import main


def _banco(ruta: Path) -> Path:
    preguntas = [{"id": f"p{i}", "temaId": f"t{i % 2}"} for i in range(8)]
    ruta.write_text(json.dumps({"preguntas": preguntas}), encoding="utf-8")
    return ruta


def test_simula_calibra_y_escribe_los_parametros(tmp_path: Path) -> None:
    salida = tmp_path / "sub" / "parametros.json"

    codigo = main(
        [
            "simular-y-calibrar",
            "--banco",
            str(_banco(tmp_path / "b.json")),
            "--salida",
            str(salida),
            "--usuarios",
            "40",
        ]
    )

    datos = json.loads(salida.read_text(encoding="utf-8"))
    assert codigo == 0
    assert len(datos["preguntas"]) == 8
    assert [t["temaId"] for t in datos["bkt"]] == ["t0", "t1"]


def test_informa_error_con_pocos_usuarios(tmp_path: Path, capsys) -> None:  # type: ignore[no-untyped-def]
    codigo = main(
        [
            "simular-y-calibrar",
            "--banco",
            str(_banco(tmp_path / "b.json")),
            "--salida",
            str(tmp_path / "o.json"),
            "--usuarios",
            "5",
        ]
    )

    assert codigo == 1
    assert "al menos 20 usuarios" in capsys.readouterr().err


def test_informa_error_si_falta_el_banco(tmp_path: Path) -> None:
    assert (
        main(
            [
                "simular-y-calibrar",
                "--banco",
                str(tmp_path / "x.json"),
                "--salida",
                str(tmp_path / "o.json"),
            ]
        )
        == 1
    )


def test_informa_error_si_el_banco_no_tiene_el_formato_esperado(tmp_path: Path) -> None:
    banco = tmp_path / "b.json"
    banco.write_text('{"otro": 1}', encoding="utf-8")

    assert (
        main(["simular-y-calibrar", "--banco", str(banco), "--salida", str(tmp_path / "o.json")])
        == 1
    )
