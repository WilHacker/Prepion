"""Extrae preguntas de un PDF descargado y las publica en una nueva versión del banco."""

import copy
import re
import tempfile
import uuid
from pathlib import Path
from typing import Any

from pydantic import BaseModel, ConfigDict, Field
from pydantic.alias_generators import to_camel
from sqlmodel import Session

from app.features.examenes.domain.parseo_catalogo import inferir_gestion_y_tipo
from app.features.examenes.domain.pregunta_extraida import PreguntaExtraida
from app.features.examenes.infrastructure.adapters.extractor_pdf import extraer_preguntas
from app.features.preguntas.infrastructure.persistence.banco_repositorio import BancoRepositorioSql
from app.shared.domain.errores import RecursoNoEncontradoError, ReglaDeNegocioError

_NOMBRE_PDF = re.compile(r"^[A-Za-z0-9][A-Za-z0-9_.-]*\.pdf$")
_RESPUESTAS_VALIDAS = frozenset({"A", "B", "C", "D", "E"})
_ETIQUETA_TIPO = {
    "1op": "1.ª opción",
    "2op": "2.ª opción",
    "3op": "3.ª opción",
    "unica": "opción única",
    "preu": "curso preuniversitario",
    "propedeutico": "curso propedéutico",
}


class _Dto(BaseModel):
    model_config = ConfigDict(alias_generator=to_camel, populate_by_name=True)


class PreguntaExtraidaAdminDto(_Dto):
    codigo: str
    materia: str
    enunciado: str
    opciones: list[str]
    requiere_imagen: bool
    duplicada_de: str | None = None


class PreguntaCuradaEntradaDto(_Dto):
    codigo: str
    respuesta: str = Field(min_length=1, max_length=1)
    tema: str = Field(min_length=1, max_length=120)
    explicacion: str = Field(min_length=1, max_length=500)


class PublicarExamenRequestDto(_Dto):
    preguntas: list[PreguntaCuradaEntradaDto] = Field(min_length=1)


class ResultadoPublicacionExamenDto(_Dto):
    version: int
    agregadas: int
    total_banco: int


def _resolver_pdf(carpeta: Path, archivo: str) -> Path:
    if not _NOMBRE_PDF.fullmatch(archivo) or ".." in archivo:
        raise ReglaDeNegocioError(f"Nombre de archivo no permitido: {archivo}")
    ruta = carpeta / archivo
    if not ruta.is_file():
        raise RecursoNoEncontradoError(f"No se encontró el examen descargado {archivo}.")
    return ruta


def extraer_preguntas_de_pdf(carpeta: Path, archivo: str) -> list[PreguntaExtraida]:
    """Ejecuta PyMuPDF sobre el PDF descargado (sin escribir imágenes permanentes)."""
    ruta = _resolver_pdf(carpeta, archivo)
    with tempfile.TemporaryDirectory() as temporal:
        extraidas = extraer_preguntas(ruta, Path(temporal))
    unicas: dict[str, PreguntaExtraida] = {}
    for p in extraidas:
        if p.duplicada_de:
            continue
        anterior = unicas.get(p.codigo)
        if anterior is None or _contar_opciones(p) > _contar_opciones(anterior):
            unicas[p.codigo] = p
    return list(unicas.values())


def _contar_opciones(pregunta: PreguntaExtraida) -> int:
    return sum(1 for o in pregunta.opciones if o.strip())


def _id_estable(*partes: str) -> str:
    return str(uuid.uuid5(uuid.NAMESPACE_URL, "prepion:" + ":".join(partes)))


def _fuente_legible(gestion: str, tipo: str, codigo: str) -> str:
    etiqueta = _ETIQUETA_TIPO.get(tipo, tipo)
    return f"Examen de ingreso FCyT · {etiqueta} · {gestion} · pregunta {codigo}"


def publicar_preguntas_al_banco(
    sesion: Session,
    carpeta: Path,
    archivo: str,
    entradas: list[PreguntaCuradaEntradaDto],
) -> ResultadoPublicacionExamenDto:
    """Agrega las preguntas curadas del PDF al banco publicado y sube su versión."""
    extraidas = extraer_preguntas_de_pdf(carpeta, archivo)
    por_codigo = {p.codigo: p for p in extraidas if not p.duplicada_de}
    gestion, tipo = inferir_gestion_y_tipo(archivo, "")

    repo = BancoRepositorioSql(sesion)
    actual = repo.obtener_actual()
    if actual is not None:
        base_cruda = repo.obtener_contenido(actual.version)
        contenido: dict[str, Any] = copy.deepcopy(base_cruda) if base_cruda else {}
        version_nueva = actual.version + 1
    else:
        contenido = {}
        version_nueva = 1

    examenes: list[dict[str, Any]] = list(contenido.get("examenes", []))
    temas: list[dict[str, Any]] = list(contenido.get("temas", []))
    preguntas: list[dict[str, Any]] = list(contenido.get("preguntas", []))

    examen_id = _id_estable("examen", archivo)
    if not any(e.get("archivo") == archivo for e in examenes):
        examenes.append({"id": examen_id, "gestion": gestion, "tipo": tipo, "archivo": archivo})
    else:
        existente_ex = next(e for e in examenes if e.get("archivo") == archivo)
        examen_id = str(existente_ex["id"])

    tema_por_clave = {
        (str(t.get("materia", "")), str(t.get("nombre", ""))): str(t["id"]) for t in temas
    }
    indice_pregunta = {
        (str(p.get("examenId", "")), str(p.get("codigo", ""))): i for i, p in enumerate(preguntas)
    }

    agregadas = 0
    for entrada in entradas:
        pregunta = por_codigo.get(entrada.codigo)
        if pregunta is None:
            raise ReglaDeNegocioError(f"La pregunta {entrada.codigo} no existe en {archivo}.")
        respuesta = entrada.respuesta.strip().upper()
        if respuesta not in _RESPUESTAS_VALIDAS:
            raise ReglaDeNegocioError(
                f"Respuesta inválida '{entrada.respuesta}' en {entrada.codigo}."
            )
        opciones = [o.strip() for o in pregunta.opciones if o.strip()]
        if len(opciones) < 2:
            raise ReglaDeNegocioError(
                f"La pregunta {entrada.codigo} no tiene al menos 2 opciones de texto."
            )

        nombre_tema = entrada.tema.strip()
        clave_tema = (pregunta.materia, nombre_tema)
        tema_id = tema_por_clave.get(clave_tema)
        if tema_id is None:
            tema_id = _id_estable("tema", pregunta.materia, nombre_tema)
            tema_por_clave[clave_tema] = tema_id
            temas.append({"id": tema_id, "materia": pregunta.materia, "nombre": nombre_tema})

        nueva_fila: dict[str, Any] = {
            "id": _id_estable("pregunta", archivo, pregunta.codigo),
            "examenId": examen_id,
            "codigo": pregunta.codigo,
            "temaId": tema_id,
            "enunciado": pregunta.enunciado.strip() or f"Pregunta {pregunta.codigo}",
            "opciones": opciones,
            "respuesta": respuesta,
            "explicacion": entrada.explicacion.strip(),
            "rutaImagen": None,
            "fuente": _fuente_legible(gestion, tipo, pregunta.codigo),
        }
        clave_preg = (examen_id, pregunta.codigo)
        if clave_preg in indice_pregunta:
            preguntas[indice_pregunta[clave_preg]] = nueva_fila
        else:
            indice_pregunta[clave_preg] = len(preguntas)
            preguntas.append(nueva_fila)
            agregadas += 1

    nuevo_contenido: dict[str, Any] = {
        "version": version_nueva,
        "examenes": examenes,
        "temas": temas,
        "preguntas": preguntas,
    }
    repo.guardar(version_nueva, len(preguntas), nuevo_contenido)
    return ResultadoPublicacionExamenDto(
        version=version_nueva,
        agregadas=agregadas,
        total_banco=len(preguntas),
    )
