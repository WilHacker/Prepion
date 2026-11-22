from uuid import UUID

from app.features.preguntas.domain.catalogo import (
    CatalogoRepositorio,
    MateriaCatalogo,
    PreguntaDetalle,
)


def consultar_arbol_temas(repositorio: CatalogoRepositorio) -> list[MateriaCatalogo]:
    return repositorio.listar_arbol_temas()


def consultar_preguntas_filtradas(
    repositorio: CatalogoRepositorio,
    materia: str | None = None,
    tema_id: UUID | None = None,
) -> list[PreguntaDetalle]:
    return repositorio.filtrar_preguntas(materia=materia, tema_id=tema_id)
