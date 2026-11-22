"""Comandos del equipo de curación (se corren en el contenedor `ml`).

    python -m app.features.examenes.infrastructure.cli listar --gestion 2-2026
    python -m app.features.examenes.infrastructure.cli descargar data/examenes_pdf --limite 3
    python -m app.features.examenes.infrastructure.cli extraer <pdf> <borrador.csv>
    python -m app.features.examenes.infrastructure.cli exportar <borrador.csv> <banco.json> \\
        --examen 2026-2-1op.pdf
"""

import argparse
import json
import shutil
import sys
from collections.abc import Sequence
from pathlib import Path

from app.features.examenes.application.descargar_examenes import (
    URL_CATALOGO_FCYT,
    descargar_examenes,
    filtrar_examenes,
)
from app.features.examenes.application.exportar_banco import exportar_banco
from app.features.examenes.domain.errores import BancoInvalidoError, DescargaExamenError
from app.features.examenes.infrastructure.adapters.borrador_csv import (
    escribir_borrador,
    leer_borrador,
)
from app.features.examenes.infrastructure.adapters.extractor_pdf import extraer_preguntas
from app.features.examenes.infrastructure.adapters.scraper_fcyt import ScraperFcyt


def _crear_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(description="Scraping, extracción y curación de la FCyT")
    comandos = parser.add_subparsers(dest="comando", required=True)

    listar = comandos.add_parser("listar", help="Lista exámenes disponibles en el portal FCyT")
    listar.add_argument("--url", default=URL_CATALOGO_FCYT)
    listar.add_argument("--gestion", default=None, help="Filtra por gestión, p. ej. 2-2026")
    listar.add_argument("--tipo", default=None, help="Filtra por tipo (1op, 2op, 3op, preu...)")
    listar.add_argument("--limite", type=int, default=None, help="Muestra los últimos N exámenes")

    descargar = comandos.add_parser("descargar", help="Descarga PDFs desde el portal FCyT")
    descargar.add_argument("destino", type=Path, help="Carpeta destino (p. ej. data/examenes_pdf)")
    descargar.add_argument("--url", default=URL_CATALOGO_FCYT)
    descargar.add_argument("--gestion", default=None, help="Filtra por gestión, p. ej. 2-2026")
    descargar.add_argument("--tipo", default=None, help="Filtra por tipo (1op, 2op, 3op, preu...)")
    descargar.add_argument("--limite", type=int, default=None, help="Descarga los últimos N")
    descargar.add_argument("--sobrescribir", action="store_true")

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
    return parser


def _listar(args: argparse.Namespace) -> None:
    scraper = ScraperFcyt()
    examenes = filtrar_examenes(
        scraper.listar_examenes(args.url),
        gestion=args.gestion,
        tipo=args.tipo,
        limite=args.limite,
    )
    for examen in examenes:
        sys.stdout.write(f"{examen.gestion}\t{examen.tipo}\t{examen.archivo}\t{examen.url}\n")
    sys.stdout.write(f"Total: {len(examenes)} exámenes\n")


def _descargar(args: argparse.Namespace) -> None:
    scraper = ScraperFcyt()
    descargados = descargar_examenes(
        scraper,
        args.destino,
        url_catalogo=args.url,
        gestion=args.gestion,
        tipo=args.tipo,
        limite=args.limite,
        sobrescribir=args.sobrescribir,
    )
    sys.stdout.write(f"{len(descargados)} PDFs descargados en {args.destino}\n")


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
        if args.comando == "listar":
            _listar(args)
        elif args.comando == "descargar":
            _descargar(args)
        elif args.comando == "extraer":
            _extraer(args)
        else:
            _exportar(args)
    except FileExistsError:
        sys.stderr.write(f"El borrador {args.borrador} ya existe; no se pisa tu trabajo.\n")
        return 1
    except (BancoInvalidoError, DescargaExamenError, FileNotFoundError) as error:
        sys.stderr.write(f"{error}\n")
        return 1
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
