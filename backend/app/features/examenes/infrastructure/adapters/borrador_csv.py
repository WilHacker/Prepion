"""Borrador de curación en CSV: se rellena en Excel o Google Sheets."""

import csv
from pathlib import Path

from app.features.examenes.domain.pregunta_extraida import PreguntaExtraida

LETRAS_DE_OPCION = ("a", "b", "c", "d", "e")
COLUMNAS = (
    "codigo",
    "serie",
    "materia",
    "pagina",
    "enunciado",
    *(f"opcion_{letra}" for letra in LETRAS_DE_OPCION),
    "requiere_imagen",
    "ruta_imagen",
    "duplicada_de",
    # A partir de aquí las completa el equipo de curación.
    "respuesta",
    "tema",
    "explicacion",
    "estado",
)


def _fila(pregunta: PreguntaExtraida) -> dict[str, str]:
    fila = {
        "codigo": pregunta.codigo_completo,
        "serie": str(pregunta.serie),
        "materia": pregunta.materia,
        "pagina": str(pregunta.pagina),
        "enunciado": pregunta.enunciado,
        "requiere_imagen": "si" if pregunta.requiere_imagen else "no",
        "ruta_imagen": pregunta.ruta_imagen or "",
        "duplicada_de": pregunta.duplicada_de or "",
        "respuesta": "",
        "tema": "",
        "explicacion": "",
        "estado": "duplicada" if pregunta.duplicada_de else "borrador",
    }
    for indice, letra in enumerate(LETRAS_DE_OPCION):
        opcion = pregunta.opciones[indice] if indice < len(pregunta.opciones) else ""
        fila[f"opcion_{letra}"] = opcion
    return fila


def escribir_borrador(preguntas: list[PreguntaExtraida], ruta: Path) -> None:
    """Crea el CSV. Nunca pisa uno existente: ahí está el trabajo de curación."""
    ruta.parent.mkdir(parents=True, exist_ok=True)
    # utf-8-sig para que Excel reconozca las tildes.
    with ruta.open("x", newline="", encoding="utf-8-sig") as archivo:
        escritor = csv.DictWriter(archivo, fieldnames=COLUMNAS)
        escritor.writeheader()
        escritor.writerows(_fila(pregunta) for pregunta in preguntas)


def leer_borrador(ruta: Path) -> list[dict[str, str]]:
    texto = ruta.read_text(encoding="utf-8-sig")
    primera_linea = texto.splitlines()[0] if texto else ""
    # Excel en español guarda los CSV con punto y coma.
    delimitador = ";" if primera_linea.count(";") > primera_linea.count(",") else ","
    with ruta.open(newline="", encoding="utf-8-sig") as archivo:
        return [dict(fila) for fila in csv.DictReader(archivo, delimiter=delimitador)]
