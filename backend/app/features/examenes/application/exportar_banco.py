"""Convierte el borrador curado en el banco JSON que consume la app."""

import uuid
from collections.abc import Mapping, Sequence
from typing import Any

from pydantic import BaseModel, ConfigDict
from pydantic.alias_generators import to_camel

from app.features.examenes.domain.errores import BancoInvalidoError
from app.features.examenes.domain.parseo import describir_examen, etiqueta_de_tipo

LETRAS_VALIDAS = "ABCDE"
MINIMO_DE_OPCIONES = 2
# Identificadores estables: exportar dos veces el mismo borrador da los mismos UUID.
_ESPACIO = uuid.uuid5(uuid.NAMESPACE_URL, "https://prepion.local/banco")


class _Dto(BaseModel):
    model_config = ConfigDict(alias_generator=to_camel, populate_by_name=True)


class _ExamenDto(_Dto):
    id: str
    gestion: str
    tipo: str
    archivo: str


class _TemaDto(_Dto):
    id: str
    materia: str
    nombre: str


class _PreguntaDto(_Dto):
    id: str
    examen_id: str
    codigo: str
    tema_id: str
    enunciado: str
    opciones: list[str]
    respuesta: str
    explicacion: str
    ruta_imagen: str | None
    fuente: str


class _BancoDto(_Dto):
    version: int
    examenes: list[_ExamenDto]
    temas: list[_TemaDto]
    preguntas: list[_PreguntaDto]


def _id(clave: str) -> str:
    return str(uuid.uuid5(_ESPACIO, clave))


def _opciones(fila: Mapping[str, str]) -> list[str]:
    todas = (fila.get(f"opcion_{letra}", "").strip() for letra in "abcde")
    return [opcion for opcion in todas if opcion]


def _problemas(fila: Mapping[str, str]) -> list[str]:
    problemas = []
    if fila.get("respuesta", "").strip().upper() not in tuple(LETRAS_VALIDAS):
        problemas.append("la respuesta debe ser una letra de A a E")
    if not fila.get("tema", "").strip():
        problemas.append("falta el tema")
    if not fila.get("explicacion", "").strip():
        problemas.append("falta la explicación")
    if len(_opciones(fila)) < MINIMO_DE_OPCIONES:
        problemas.append("necesita al menos 2 opciones")
    requiere_imagen = fila.get("requiere_imagen", "").strip().lower() == "si"
    if requiere_imagen and not fila.get("ruta_imagen", "").strip():
        problemas.append("requiere imagen pero no tiene ruta_imagen")
    if not requiere_imagen and not fila.get("enunciado", "").strip():
        problemas.append("falta el enunciado")
    if fila.get("duplicada_de", "").strip():
        problemas.append(f"es repetida de {fila['duplicada_de']}; no se publica dos veces")
    return problemas


def _fuente(fila: Mapping[str, str], gestion: str, tipo: str) -> str:
    codigo = fila["codigo"].split("-", 1)[-1]
    return (
        f"Examen de ingreso FCyT · {etiqueta_de_tipo(tipo)} · {gestion} · {codigo} "
        f"(serie {fila['serie']})"
    )


def exportar_banco(
    filas: Sequence[Mapping[str, str]], archivo_examen: str, version: int
) -> dict[str, Any]:
    """Valida las filas con estado 'publicada' y arma el banco. Si algo falla, lista todo."""
    publicadas = [f for f in filas if f.get("estado", "").strip().lower() == "publicada"]
    if not publicadas:
        raise BancoInvalidoError("No hay ninguna pregunta con estado 'publicada'.")

    errores = [
        f"{fila.get('codigo', '?')}: {problema}"
        for fila in publicadas
        for problema in _problemas(fila)
    ]
    if errores:
        raise BancoInvalidoError("Hay preguntas publicadas con problemas:\n" + "\n".join(errores))

    gestion, tipo = describir_examen(archivo_examen)
    examen = _ExamenDto(
        id=_id(f"examen:{archivo_examen}"), gestion=gestion, tipo=tipo, archivo=archivo_examen
    )
    temas: dict[tuple[str, str], _TemaDto] = {}
    preguntas = []
    for fila in publicadas:
        clave = (fila["materia"].strip(), fila["tema"].strip())
        tema = temas.setdefault(
            clave,
            _TemaDto(id=_id(f"tema:{clave[0]}:{clave[1]}"), materia=clave[0], nombre=clave[1]),
        )
        preguntas.append(
            _PreguntaDto(
                id=_id(f"pregunta:{archivo_examen}:{fila['codigo']}"),
                examen_id=examen.id,
                codigo=fila["codigo"],
                tema_id=tema.id,
                enunciado=fila["enunciado"].strip(),
                opciones=_opciones(fila),
                respuesta=fila["respuesta"].strip().upper(),
                explicacion=fila["explicacion"].strip(),
                ruta_imagen=fila.get("ruta_imagen", "").strip() or None,
                fuente=_fuente(fila, gestion, tipo),
            )
        )
    banco = _BancoDto(
        version=version, examenes=[examen], temas=list(temas.values()), preguntas=preguntas
    )
    return banco.model_dump(by_alias=True)
