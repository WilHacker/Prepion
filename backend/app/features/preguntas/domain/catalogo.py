from dataclasses import dataclass
from typing import Protocol
from uuid import UUID

MATERIAS_OFICIALES = ("Matemáticas", "Física", "Química", "Biología")
# El examen de la FCyT separa Matemáticas en dos áreas; el catálogo las muestra juntas.
MATERIAS_DE_MATEMATICAS = ("Matemáticas", "Aritmética-Álgebra", "Geometría-Trigonometría")
_MATEMATICAS_EN_MINUSCULA = {
    *(materia.lower() for materia in MATERIAS_DE_MATEMATICAS),
    "matematicas",
    "aritmetica-algebra",
    "geometria-trigonometria",
}


def es_de_matematicas(materia: str) -> bool:
    return materia.strip().lower() in _MATEMATICAS_EN_MINUSCULA


def normalizar_materia(materia: str) -> str:
    """Nombre de la materia tal como se muestra en el catálogo."""
    limpia = materia.strip()
    if es_de_matematicas(limpia):
        return "Matemáticas"
    for oficial in MATERIAS_OFICIALES:
        if limpia.lower() == oficial.lower():
            return oficial
    return limpia


@dataclass(frozen=True)
class TemaCatalogo:
    id: UUID
    nombre: str
    cantidad_preguntas: int


@dataclass(frozen=True)
class MateriaCatalogo:
    materia: str
    cantidad_preguntas: int
    temas: list[TemaCatalogo]


@dataclass(frozen=True)
class PreguntaDetalle:
    id: UUID
    examen_id: UUID
    codigo: str
    tema_id: UUID | None
    enunciado: str
    opciones: list[str]
    ruta_imagen: str | None
    respuesta: str | None
    explicacion: str | None
    fuente: str | None
    estado: str


class CatalogoRepositorio(Protocol):
    """Puerto: materias, temas y preguntas publicadas para la práctica libre."""

    def listar_arbol_temas(self) -> list[MateriaCatalogo]: ...

    def filtrar_preguntas(
        self, materia: str | None = None, tema_id: UUID | None = None
    ) -> list[PreguntaDetalle]: ...
