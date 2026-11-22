"""Descarga los PDF nuevos del portal de la Facultad, de forma lenta y sin pisar nada."""

import time
from collections.abc import Callable
from dataclasses import dataclass, field
from pathlib import Path
from typing import Protocol

from pydantic import BaseModel, ConfigDict
from pydantic.alias_generators import to_camel

from app.features.examenes.domain.examen_publicado import ExamenPublicado

PAUSA_ENTRE_DESCARGAS = 1.0


class Portal(Protocol):
    def descargar_catalogo(self) -> list[ExamenPublicado]: ...

    def descargar_pdf(self, examen: ExamenPublicado) -> bytes: ...


@dataclass
class ResultadoRecoleccion:
    encontrados: int = 0
    ya_descargados: int = 0
    nuevos: list[str] = field(default_factory=list)
    descargados: list[str] = field(default_factory=list)
    errores: list[dict[str, str]] = field(default_factory=list)

    @property
    def pendientes(self) -> int:
        return len(self.nuevos) - len(self.descargados)


class ErrorRecoleccionDto(BaseModel):
    archivo: str
    motivo: str


class ResultadoRecoleccionDto(BaseModel):
    model_config = ConfigDict(alias_generator=to_camel, populate_by_name=True)

    encontrados: int
    ya_descargados: int
    nuevos: list[str]
    descargados: list[str]
    pendientes: int
    errores: list[ErrorRecoleccionDto]

    @classmethod
    def desde(cls, r: ResultadoRecoleccion) -> "ResultadoRecoleccionDto":
        return cls(
            encontrados=r.encontrados,
            ya_descargados=r.ya_descargados,
            nuevos=r.nuevos,
            descargados=r.descargados,
            pendientes=r.pendientes,
            errores=[ErrorRecoleccionDto(**e) for e in r.errores],
        )


def _guardar(destino: Path, contenido: bytes) -> None:
    parcial = destino.with_name(destino.name + ".part")
    parcial.write_bytes(contenido)
    try:
        if destino.exists():  # nunca se sobrescribe
            raise FileExistsError(f"{destino.name} ya existe.")
        parcial.rename(destino)
    finally:
        parcial.unlink(missing_ok=True)


def recolectar_examenes(
    portal: Portal,
    carpeta: Path,
    limite: int,
    esperar: Callable[[float], None] = time.sleep,
) -> ResultadoRecoleccion:
    catalogo = portal.descargar_catalogo()
    carpeta.mkdir(parents=True, exist_ok=True)
    existentes = {p.name for p in carpeta.glob("*.pdf")}
    # El catálogo viene del más antiguo al más reciente: se baja primero lo reciente.
    nuevos = [e for e in reversed(catalogo) if e.archivo not in existentes]
    resultado = ResultadoRecoleccion(
        encontrados=len(catalogo),
        ya_descargados=len(catalogo) - len(nuevos),
        nuevos=[e.archivo for e in nuevos],
    )
    for examen in nuevos[:limite]:
        if resultado.descargados or resultado.errores:
            esperar(PAUSA_ENTRE_DESCARGAS)
        try:
            _guardar(carpeta / examen.archivo, portal.descargar_pdf(examen))
        except Exception as error:  # un PDF malo no detiene a los demás
            resultado.errores.append({"archivo": examen.archivo, "motivo": str(error)})
        else:
            resultado.descargados.append(examen.archivo)
    return resultado
