"""Adaptador de PyMuPDF: lee un examen de la FCyT y recorta las preguntas con fórmulas."""

from dataclasses import dataclass, replace
from pathlib import Path

import pymupdf

from app.features.examenes.domain.parseo import (
    es_encabezado_de_seccion,
    normalizar_para_comparar,
    parsear_cabecera,
    separar_enunciado_y_opciones,
    tiene_formula,
)
from app.features.examenes.domain.pregunta_extraida import MATERIA_POR_LETRA, PreguntaExtraida

ZOOM_IMAGEN = 2  # 2x para que las fórmulas se lean bien en el celular
MARGEN_IMAGEN = 20.0
TAMANO_MINIMO_GRAFICO = 10.0  # ignora subrayados y líneas finas


@dataclass(frozen=True)
class _Linea:
    y0: float
    y1: float
    texto: str


@dataclass(frozen=True)
class _Marca:
    """Línea del PDF que delimita una pregunta (o el fin de ella por una materia nueva)."""

    y: float
    letra: str | None = None
    numero: int | None = None


def _lineas_de_la_pagina(pagina: pymupdf.Page) -> list[_Linea]:
    """Líneas de texto en el orden de lectura que da el PDF."""
    return [
        _Linea(linea["bbox"][1], linea["bbox"][3], "".join(span["text"] for span in linea["spans"]))
        for bloque in pagina.get_text("dict")["blocks"]
        for linea in bloque.get("lines", [])
    ]


def _marcas_de_las_lineas(lineas: list[_Linea]) -> list[_Marca]:
    marcas: list[_Marca] = []
    for linea in lineas:
        cabecera = parsear_cabecera(linea.texto)
        if cabecera is not None:
            marcas.append(_Marca(linea.y0, cabecera[0], cabecera[1]))
        elif es_encabezado_de_seccion(linea.texto):
            marcas.append(_Marca(linea.y0))
    return sorted(marcas, key=lambda marca: marca.y)


def _hay_grafico(pagina: pymupdf.Page, region: pymupdf.Rect) -> bool:
    imagenes = (pymupdf.Rect(info["bbox"]) for info in pagina.get_image_info())
    dibujos = (
        rect
        for rect in (pymupdf.Rect(d["rect"]) for d in pagina.get_drawings())
        if rect.width > TAMANO_MINIMO_GRAFICO and rect.height > TAMANO_MINIMO_GRAFICO
    )
    return any(region.intersects(rect) for rect in (*imagenes, *dibujos))


def _texto_de_la_region(lineas: list[_Linea], inicio: float, fin: float) -> str:
    # Se usa el inicio de cada línea: así no se pegan los restos de la pregunta anterior
    # (fracciones, letras con cola) que solo rozan la zona.
    textos = [linea.texto for linea in lineas if inicio <= linea.y0 < fin and linea.texto.strip()]
    primera, *resto = textos or [""]
    cabecera = parsear_cabecera(primera)
    return "\n".join([cabecera[2] if cabecera is not None else primera, *resto])


def _recortar_imagen(pagina: pymupdf.Page, region: pymupdf.Rect, destino: Path) -> None:
    zona = pymupdf.Rect(MARGEN_IMAGEN, region.y0 - 4, pagina.rect.x1 - MARGEN_IMAGEN, region.y1)
    destino.parent.mkdir(parents=True, exist_ok=True)
    pagina.get_pixmap(
        matrix=pymupdf.Matrix(ZOOM_IMAGEN, ZOOM_IMAGEN), clip=zona & pagina.rect
    ).save(destino)


def _marcar_repetidas(preguntas: list[PreguntaExtraida]) -> list[PreguntaExtraida]:
    primera_aparicion: dict[str, str] = {}
    resultado = []
    for pregunta in preguntas:
        clave = normalizar_para_comparar(pregunta.enunciado + "|" + "|".join(pregunta.opciones))
        original = primera_aparicion.setdefault(clave, pregunta.codigo_completo)
        repetida = original != pregunta.codigo_completo
        resultado.append(replace(pregunta, duplicada_de=original) if repetida else pregunta)
    return resultado


def extraer_preguntas(ruta_pdf: Path, carpeta_imagenes: Path) -> list[PreguntaExtraida]:
    """Extrae las preguntas del PDF; las que tienen fórmula o gráfico se guardan como PNG.

    Un mismo PDF puede traer varias series que reinician la numeración (A1 aparece dos
    veces): cada vez que el número no sube se abre una serie nueva.
    """
    if not ruta_pdf.is_file():
        raise FileNotFoundError(f"No existe el examen: {ruta_pdf}")

    preguntas: list[PreguntaExtraida] = []
    serie, ultimo_numero = 1, 0
    with pymupdf.open(ruta_pdf) as documento:
        for indice, pagina in enumerate(documento, start=1):
            lineas = _lineas_de_la_pagina(pagina)
            marcas = _marcas_de_las_lineas(lineas)
            fondo = max((linea.y1 for linea in lineas), default=0.0)
            for posicion, marca in enumerate(marcas):
                if marca.letra is None or marca.numero is None:
                    continue
                if marca.letra not in MATERIA_POR_LETRA:
                    continue
                if marca.numero <= ultimo_numero:
                    serie += 1
                ultimo_numero = marca.numero

                fin = marcas[posicion + 1].y if posicion + 1 < len(marcas) else fondo + 2
                region = pymupdf.Rect(0, marca.y - 0.5, pagina.rect.x1, fin - 0.5)
                texto = _texto_de_la_region(lineas, marca.y - 0.5, fin - 0.5)
                enunciado, opciones = separar_enunciado_y_opciones(texto)
                codigo = f"{marca.letra}{marca.numero}"
                materia = MATERIA_POR_LETRA[marca.letra]
                requiere_imagen = tiene_formula(
                    texto, materia, hay_grafico=_hay_grafico(pagina, region)
                )

                ruta_imagen = None
                if requiere_imagen:
                    # Plano (sin subcarpetas): Flutter no incluye las subcarpetas de un assets/.
                    nombre = f"{ruta_pdf.stem}_S{serie}-{codigo}.png"
                    _recortar_imagen(pagina, region, carpeta_imagenes / nombre)
                    ruta_imagen = f"assets/imagenes/{nombre}"
                preguntas.append(
                    PreguntaExtraida(
                        serie=serie,
                        codigo=codigo,
                        pagina=indice,
                        enunciado=enunciado,
                        opciones=opciones,
                        requiere_imagen=requiere_imagen,
                        ruta_imagen=ruta_imagen,
                    )
                )
    return _marcar_repetidas(preguntas)
