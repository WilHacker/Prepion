"""Reglas puras para interpretar filas del catálogo web de exámenes de la FCyT."""

import re

_PATRON_ONCLICK = re.compile(r"""window\.location\s*=\s*['"]([^'"]+)['"]""", re.IGNORECASE)
_PATRON_GESTION_SEMESTRE_ANIO = re.compile(r"(?<!\d)([12])[-_/](20\d{2})(?!\d)")
_PATRON_GESTION_ANIO_SEMESTRE = re.compile(r"(?<!\d)(20\d{2})[-_/]([12])(?!\d)")
_PATRON_TAMANO_KB = re.compile(r"(\d+)\s*KB", re.IGNORECASE)

_TIPOS: tuple[tuple[re.Pattern[str], str], ...] = (
    (re.compile(r"preu|prefacultativo", re.IGNORECASE), "preu"),
    (re.compile(r"proped[eé]utico", re.IGNORECASE), "propedeutico"),
    (re.compile(r"1op|primer[ao]?\s*(opci[oó]n|examen)", re.IGNORECASE), "1op"),
    (re.compile(r"2op|segund[ao]\s*(opci[oó]n|examen)", re.IGNORECASE), "2op"),
    (re.compile(r"3op|tercer[ao]?\s*(opci[oó]n|examen)", re.IGNORECASE), "3op"),
    (re.compile(r"uop|[uú]nica", re.IGNORECASE), "unica"),
)


def extraer_url_de_onclick(onclick: str) -> str | None:
    """Extrae la URL destino de un atributo `onclick=\"window.location='...'\"`."""
    coincidencia = _PATRON_ONCLICK.search(onclick)
    return coincidencia.group(1).strip() if coincidencia else None


def inferir_gestion_y_tipo(archivo: str, titulo: str = "") -> tuple[str, str]:
    """Infiere `(gestion, tipo)` a partir del nombre del PDF y su título en la tabla."""
    texto = f"{archivo} {titulo}"

    gestion = "desconocida"
    coincidencia = _PATRON_GESTION_SEMESTRE_ANIO.search(texto)
    if coincidencia:
        gestion = f"{coincidencia.group(1)}-{coincidencia.group(2)}"
    else:
        coincidencia_inv = _PATRON_GESTION_ANIO_SEMESTRE.search(texto)
        if coincidencia_inv:
            gestion = f"{coincidencia_inv.group(2)}-{coincidencia_inv.group(1)}"

    tipo = "otro"
    for patron, etiqueta in _TIPOS:
        if patron.search(texto):
            tipo = etiqueta
            break

    return gestion, tipo


def extraer_tamano_kb(texto: str) -> int | None:
    """Devuelve el tamaño en KB si aparece en el texto de la celda."""
    coincidencia = _PATRON_TAMANO_KB.search(texto)
    return int(coincidencia.group(1)) if coincidencia else None
