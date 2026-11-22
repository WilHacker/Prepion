"""Crea (o actualiza) la cuenta de administrador con ADMIN_CORREO y ADMIN_CONTRASENA del entorno.

python -m app.features.cuentas.infrastructure.cli crear-admin
"""

import argparse
import sys
from collections.abc import Sequence

from sqlalchemy import Engine
from sqlmodel import Session

from app.core.config import settings
from app.core.database import engine
from app.features.cuentas.application.cuentas import crear_admin
from app.features.cuentas.infrastructure.persistence.repositorio_cuentas_sql import (
    RepositorioCuentasSql,
)

LARGO_MINIMO_CONTRASENA = 8


def main(argv: Sequence[str] | None = None, motor: Engine | None = None) -> int:
    parser = argparse.ArgumentParser(description="Cuentas de Prepion")
    parser.add_subparsers(dest="comando", required=True).add_parser(
        "crear-admin", help="crea o actualiza la cuenta de administrador"
    )
    parser.parse_args(argv)

    correo, contrasena = settings.admin_correo, settings.admin_contrasena
    if not correo or not contrasena or len(contrasena) < LARGO_MINIMO_CONTRASENA:
        sys.stderr.write(
            "Define ADMIN_CORREO y ADMIN_CONTRASENA (mínimo 8 caracteres) en el .env.\n"
        )
        return 1
    with Session(motor or engine) as sesion:
        cuenta = crear_admin(RepositorioCuentasSql(sesion), correo, contrasena)
    sys.stdout.write(f"Administrador listo: {cuenta.correo}\n")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
