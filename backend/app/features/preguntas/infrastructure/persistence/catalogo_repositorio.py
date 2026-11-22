from uuid import UUID

from sqlalchemy import func
from sqlmodel import Session, col, select

from app.features.preguntas.domain.catalogo import (
    MATERIAS_DE_MATEMATICAS,
    MATERIAS_OFICIALES,
    MateriaCatalogo,
    PreguntaDetalle,
    TemaCatalogo,
    es_de_matematicas,
    normalizar_materia,
)
from app.features.preguntas.domain.errores import TemaNoEncontradoError
from app.features.preguntas.infrastructure.persistence.tablas import PreguntaTabla, TemaTabla


class CatalogoRepositorioSql:
    def __init__(self, sesion: Session) -> None:
        self._sesion = sesion

    def listar_arbol_temas(self) -> list[MateriaCatalogo]:
        temas = list(
            self._sesion.exec(select(TemaTabla).order_by(col(TemaTabla.nombre).asc())).all()
        )
        conteo = (
            select(PreguntaTabla.tema_id, func.count(col(PreguntaTabla.id)))
            .where(PreguntaTabla.estado == "publicada")
            .group_by(col(PreguntaTabla.tema_id))
        )
        conteo_por_tema: dict[UUID | None, int] = {
            tema_id: int(cantidad) for tema_id, cantidad in self._sesion.exec(conteo).all()
        }

        agrupados: dict[str, list[TemaCatalogo]] = {materia: [] for materia in MATERIAS_OFICIALES}
        for tema in temas:
            agrupados.setdefault(normalizar_materia(tema.materia), []).append(
                TemaCatalogo(
                    id=tema.id,
                    nombre=tema.nombre,
                    cantidad_preguntas=conteo_por_tema.get(tema.id, 0),
                )
            )

        resultado: list[MateriaCatalogo] = []
        for materia, lista_temas in agrupados.items():
            lista_temas.sort(key=lambda t: t.nombre)
            total_preguntas = sum(t.cantidad_preguntas for t in lista_temas)
            resultado.append(
                MateriaCatalogo(
                    materia=materia,
                    cantidad_preguntas=total_preguntas,
                    temas=lista_temas,
                )
            )
        return resultado

    def filtrar_preguntas(
        self,
        materia: str | None = None,
        tema_id: UUID | None = None,
    ) -> list[PreguntaDetalle]:
        if tema_id is not None:
            tema = self._sesion.get(TemaTabla, tema_id)
            if tema is None:
                raise TemaNoEncontradoError(f"No existe el tema con id {tema_id}.")

        consulta = select(PreguntaTabla).where(PreguntaTabla.estado == "publicada")
        if tema_id is not None:
            consulta = consulta.where(PreguntaTabla.tema_id == tema_id)
        elif materia is not None and materia.strip():
            if es_de_matematicas(materia):
                subconsulta = select(TemaTabla.id).where(
                    col(TemaTabla.materia).in_(MATERIAS_DE_MATEMATICAS)
                )
            else:
                subconsulta = select(TemaTabla.id).where(
                    func.lower(col(TemaTabla.materia)) == materia.strip().lower()
                )
            consulta = consulta.where(col(PreguntaTabla.tema_id).in_(subconsulta))

        filas = list(self._sesion.exec(consulta.order_by(col(PreguntaTabla.codigo).asc())).all())

        resultado: list[PreguntaDetalle] = []
        for p in filas:
            resultado.append(
                PreguntaDetalle(
                    id=p.id,
                    examen_id=p.examen_id,
                    codigo=p.codigo,
                    tema_id=p.tema_id,
                    enunciado=p.enunciado,
                    opciones=list(p.opciones),
                    ruta_imagen=p.imagen,
                    respuesta=p.respuesta,
                    explicacion=p.explicacion,
                    fuente=p.fuente or f"Examen de ingreso FCyT · {p.codigo}",
                    estado=p.estado,
                )
            )
        return resultado
