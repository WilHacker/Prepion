"""Publica el banco curado en la base (se corre cuando el equipo termina de curar).

python -m app.features.preguntas.infrastructure.cli publicar <banco_v1.json>
"""

import argparse
import json
import sys
from collections.abc import Sequence
from pathlib import Path
from typing import Any

from sqlalchemy import Engine
from sqlmodel import Session

from app.core.database import engine
from app.features.preguntas.application.publicar_banco import publicar_banco
from app.features.preguntas.application.volcar_banco import volcar_banco_publicado
from app.features.preguntas.infrastructure.persistence.banco_repositorio import (
    BancoRepositorioSql,
)
from app.shared.domain.errores import DominioError


def _leer_json(ruta: Path) -> dict[str, Any]:
    try:
        contenido = json.loads(ruta.read_text(encoding="utf-8"))
    except json.JSONDecodeError as error:
        raise ValueError(f"{ruta} no es un JSON válido: {error}") from error
    if not isinstance(contenido, dict):
        raise ValueError(f"{ruta} debe contener un objeto JSON.")
    return contenido


def main(argv: Sequence[str] | None = None, motor: Engine | None = None) -> int:
    parser = argparse.ArgumentParser(description="Publicación del banco de preguntas")
    comandos = parser.add_subparsers(dest="comando", required=True)
    publicar = comandos.add_parser("publicar", help="guarda banco_vN.json como versión nueva")
    publicar.add_argument("banco", type=Path)
    comandos.add_parser(
        "volcar",
        help="vuelca a las tablas el banco ya publicado (examenes, temas y preguntas)",
    )
    args = parser.parse_args(argv)

    try:
        with Session(motor or engine) as sesion:
            repositorio = BancoRepositorioSql(sesion)
            if args.comando == "volcar":
                version = volcar_banco_publicado(repositorio)
                sys.stdout.write(f"Banco versión {version} volcado a las tablas.\n")
                return 0
            version = publicar_banco(repositorio, _leer_json(args.banco))
    except (DominioError, ValueError, FileNotFoundError) as error:
        sys.stderr.write(f"{getattr(error, 'mensaje', error)}\n")
        return 1
    sys.stdout.write(f"Banco versión {version} publicado.\n")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
