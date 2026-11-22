"""Comandos de calibración y entrenamiento ML (se corren en el contenedor `ml`).

    python -m app.features.conocimiento.infrastructure.cli simular-y-calibrar \\
        --banco banco.json --salida parametros_conocimiento_v1.json
"""

import argparse
import json
import sys
from collections.abc import Sequence
from pathlib import Path

from app.features.conocimiento.application.calibrar_bkt import calibrar_bkt
from app.features.conocimiento.application.calibrar_dificultad import calibrar_dificultad
from app.features.conocimiento.application.exportar_parametros import exportar_parametros
from app.features.conocimiento.application.simular_respuestas import simular_respuestas
from app.features.conocimiento.application.simular_secuencias_bkt import simular_secuencias_bkt
from app.shared.domain.errores import DominioError


def _crear_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(description="Calibración IRT (Rasch) y entrenamiento BKT")
    comandos = parser.add_subparsers(dest="comando", required=True)
    simular = comandos.add_parser("simular-y-calibrar", help="banco JSON -> parámetros JSON")
    simular.add_argument("--banco", type=Path, required=True)
    simular.add_argument("--salida", type=Path, required=True)
    simular.add_argument("--usuarios", type=int, default=60)
    simular.add_argument("--intentos", type=int, default=8)
    simular.add_argument("--semilla", type=int, default=7)
    return parser


def _simular_y_calibrar(args: argparse.Namespace) -> None:
    banco = json.loads(args.banco.read_text(encoding="utf-8"))
    temas = {p["id"]: p["temaId"] for p in banco["preguntas"]}

    respuestas_irt, _ = simular_respuestas(list(temas), args.usuarios, args.semilla)
    dificultades = calibrar_dificultad(respuestas_irt)

    secuencias_bkt, _ = simular_secuencias_bkt(
        list(temas.values()),
        usuarios=args.usuarios,
        intentos_por_tema=args.intentos,
        semilla=args.semilla,
    )
    parametros_bkt = calibrar_bkt(secuencias_bkt)

    parametros = exportar_parametros(dificultades, temas, parametros_bkt)
    args.salida.parent.mkdir(parents=True, exist_ok=True)
    args.salida.write_text(
        json.dumps(parametros, ensure_ascii=False, indent=2) + "\n", encoding="utf-8"
    )
    sys.stdout.write(
        f"{len(parametros['preguntas'])} preguntas (IRT) y "
        f"{len(parametros['bkt'])} temas (BKT) calibrados -> {args.salida}\n"
    )


def main(argv: Sequence[str] | None = None) -> int:
    args = _crear_parser().parse_args(argv)
    try:
        _simular_y_calibrar(args)
    except (DominioError, FileNotFoundError, KeyError, json.JSONDecodeError) as error:
        sys.stderr.write(f"{error!r}\n" if isinstance(error, KeyError) else f"{error}\n")
        return 1
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
