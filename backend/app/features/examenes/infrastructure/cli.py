"""Comandos del equipo de curación (se corren en el contenedor `ml`).

    python -m app.features.examenes.infrastructure.cli extraer <pdf> <borrador.csv>
    python -m app.features.examenes.infrastructure.cli exportar <borrador.csv> <banco.json> \\
        --examen 2026-2-1op.pdf
    python -m app.features.examenes.infrastructure.cli recolectar --carpeta ../data/examenes_pdf
"""

import argparse
import json
import shutil
import sys
from collections.abc import Sequence
from pathlib import Path

from app.core.config import settings
from app.features.examenes.application.exportar_banco import exportar_banco
from app.features.examenes.application.recolectar_examenes import recolectar_examenes
from app.features.examenes.domain.errores import (
    BancoInvalidoError,
    PortalNoDisponibleError,
)
from app.features.examenes.infrastructure.adapters.borrador_csv import (
    escribir_borrador,
    leer_borrador,
)
from app.features.examenes.infrastructure.adapters.extractor_pdf import extraer_preguntas
from app.features.examenes.infrastructure.adapters.portal_fcyt import PortalFcyt


def _crear_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(description="Extracción y curación de exámenes de la FCyT")
    comandos = parser.add_subparsers(dest="comando", required=True)

    extraer = comandos.add_parser("extraer", help="PDF -> borrador CSV + imágenes de fórmulas")
    extraer.add_argument("pdf", type=Path)
    extraer.add_argument("borrador", type=Path, help="CSV nuevo; nunca se pisa uno existente")
    extraer.add_argument("--imagenes", type=Path, default=Path("data/imagenes"))

    exportar = comandos.add_parser("exportar", help="borrador curado -> banco JSON")
    exportar.add_argument("borrador", type=Path)
    exportar.add_argument("salida", type=Path)
    exportar.add_argument("--examen", required=True, help="nombre del PDF, p. ej. 2026-2-1op.pdf")
    exportar.add_argument("--version", type=int, default=1)
    exportar.add_argument(
        "--copiar-imagenes",
        nargs=2,
        type=Path,
        metavar=("ORIGEN", "DESTINO"),
        help="copia las imágenes de las preguntas publicadas (p. ej. a app/assets/imagenes)",
    )

    recolectar = comandos.add_parser("recolectar", help="baja del portal los PDF nuevos")
    recolectar.add_argument("--carpeta", type=Path, default=None)
    recolectar.add_argument("--limite", type=int, default=10)
    return parser


def _recolectar(args: argparse.Namespace) -> None:
    carpeta = args.carpeta or settings.examenes_pdf_dir
    r = recolectar_examenes(PortalFcyt(), carpeta, args.limite)
    sys.stdout.write(
        f"{r.encontrados} en el portal, {r.ya_descargados} ya descargados, "
        f"{len(r.nuevos)} nuevos, {len(r.descargados)} descargados ahora, "
        f"{r.pendientes} pendientes -> {carpeta}\n"
    )
    for nombre in r.descargados:
        sys.stdout.write(f"  + {nombre}\n")
    for error in r.errores:
        sys.stderr.write(f"  ! {error['archivo']}: {error['motivo']}\n")
    if r.errores:
        raise PortalNoDisponibleError(f"{len(r.errores)} descargas fallaron.")


def _extraer(args: argparse.Namespace) -> None:
    preguntas = extraer_preguntas(args.pdf, args.imagenes)
    escribir_borrador(preguntas, args.borrador)
    unicas = sum(1 for p in preguntas if not p.duplicada_de)
    con_imagen = sum(1 for p in preguntas if p.requiere_imagen)
    resumen = f"{len(preguntas)} preguntas ({unicas} únicas, {con_imagen} con imagen)"
    sys.stdout.write(f"{resumen} -> {args.borrador}\n")


def _exportar(args: argparse.Namespace) -> None:
    banco = exportar_banco(leer_borrador(args.borrador), args.examen, args.version)
    if args.copiar_imagenes:
        origen, destino = args.copiar_imagenes
        destino.mkdir(parents=True, exist_ok=True)
        for pregunta in banco["preguntas"]:
            if pregunta["rutaImagen"]:
                nombre = Path(pregunta["rutaImagen"]).name
                if not (origen / nombre).is_file():
                    raise BancoInvalidoError(f"Falta la imagen {nombre} en {origen}.")
                shutil.copy2(origen / nombre, destino / nombre)
    args.salida.parent.mkdir(parents=True, exist_ok=True)
    args.salida.write_text(json.dumps(banco, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    sys.stdout.write(f"{len(banco['preguntas'])} preguntas publicadas -> {args.salida}\n")


def main(argv: Sequence[str] | None = None) -> int:
    args = _crear_parser().parse_args(argv)
    try:
        if args.comando == "extraer":
            _extraer(args)
        elif args.comando == "recolectar":
            _recolectar(args)
        else:
            _exportar(args)
    except FileExistsError:
        sys.stderr.write(f"El borrador {args.borrador} ya existe; no se pisa tu trabajo.\n")
        return 1
    except (BancoInvalidoError, PortalNoDisponibleError, FileNotFoundError) as error:
        sys.stderr.write(f"{error}\n")
        return 1
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
