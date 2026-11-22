"""Reglas puras para leer el texto de un examen de la FCyT (sin PyMuPDF)."""

import re
import unicodedata

_CABECERA = re.compile(r"^([A-Z])\s?(\d{1,2})\s?\.\s?-?\s*(.*)$")
_OPCION = re.compile(r"(?:^|(?<=\s))([a-eA-E])\)\s*")
# Letras matemáticas (𝑥, 𝑦…), raíces, sumatorias, integrales, comparadores y operadores.
_SIMBOLO_MATEMATICO = re.compile("[\U0001d400-\U0001d7ff√∑∫≤≥≠×÷⋅∞π]")
_MATERIAS_SIEMPRE_CON_FORMULA = {"Aritmética-Álgebra", "Geometría-Trigonometría"}
_ENCABEZADOS = {
    "ARITMETICA - ALGEBRA",
    "ARITMETICA-ALGEBRA",
    "GEOMETRIA - TRIGONOMETRIA",
    "GEOMETRIA-TRIGONOMETRIA",
    "FISICA",
    "QUIMICA",
    "BIOLOGIA",
}


def _sin_acentos(texto: str) -> str:
    descompuesto = unicodedata.normalize("NFD", texto)
    return "".join(c for c in descompuesto if unicodedata.category(c) != "Mn")


def _compactar(texto: str) -> str:
    return " ".join(texto.split())


def parsear_cabecera(linea: str) -> tuple[str, int, str] | None:
    """Devuelve (letra, número, resto) si la línea empieza una pregunta (A1., Q16.-)."""
    coincidencia = _CABECERA.match(linea.strip())
    if coincidencia is None:
        return None
    letra, numero, resto = coincidencia.groups()
    return letra, int(numero), resto.strip()


def es_encabezado_de_seccion(linea: str) -> bool:
    """True si la línea es solo el título de una materia (FISICA, QUÍMICA…)."""
    # Los guiones largos (–) y los espacios dobles varían entre PDFs.
    limpia = _compactar(_sin_acentos(linea).replace("–", "-").upper())
    limpia = re.sub(r"\s*-\s*", " - ", limpia)
    return limpia in _ENCABEZADOS


def separar_enunciado_y_opciones(texto: str) -> tuple[str, tuple[str, ...]]:
    """Separa el enunciado de las opciones a) b) c) d) e) (en mayúscula o minúscula)."""
    marcas = list(_OPCION.finditer(texto))
    for inicio in reversed([i for i, m in enumerate(marcas) if m.group(1).lower() == "a"]):
        secuencia = [marcas[inicio]]
        esperada = "b"
        for marca in marcas[inicio + 1 :]:
            if marca.group(1).lower() == esperada:
                secuencia.append(marca)
                esperada = chr(ord(esperada) + 1)
        if len(secuencia) < 2:
            continue
        limites = [m.end() for m in secuencia]
        finales = [m.start() for m in secuencia[1:]] + [len(texto)]
        opciones = tuple(_compactar(texto[a:b]) for a, b in zip(limites, finales, strict=True))
        return _compactar(texto[: secuencia[0].start()]), opciones
    return _compactar(texto), ()


def tiene_formula(texto: str, materia: str, *, hay_grafico: bool) -> bool:
    """Decide si la pregunta se muestra como imagen porque el texto sale roto."""
    return (
        materia in _MATERIAS_SIEMPRE_CON_FORMULA
        or hay_grafico
        or _SIMBOLO_MATEMATICO.search(texto) is not None
    )


_TIPOS_DE_EXAMEN = {
    "1op": "1.ª opción",
    "2op": "2.ª opción",
    "3op": "3.ª opción",
    "unica": "Opción única",
    "preu": "Preuniversitario",
}
_NOMBRE_DE_EXAMEN = re.compile(r"^(\d{4})-(\d)-(\w+?)(?:\.pdf)?$")


def describir_examen(archivo: str) -> tuple[str, str]:
    """De '2026-2-1op.pdf' saca la gestión ('2-2026') y el tipo ('1op')."""
    coincidencia = _NOMBRE_DE_EXAMEN.match(archivo)
    if coincidencia is None:
        nombre = archivo.removesuffix(".pdf")
        return nombre, nombre
    anio, semestre, tipo = coincidencia.groups()
    return f"{semestre}-{anio}", tipo


def etiqueta_de_tipo(tipo: str) -> str:
    """Texto para mostrar al usuario: '1op' -> '1.ª opción'."""
    return _TIPOS_DE_EXAMEN.get(tipo, tipo)


def normalizar_para_comparar(texto: str) -> str:
    """Forma canónica para detectar la misma pregunta escrita en dos series."""
    return _compactar(texto).lower()
