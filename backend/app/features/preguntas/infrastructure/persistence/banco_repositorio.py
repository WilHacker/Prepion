import uuid
from typing import Any

from sqlmodel import Session, col, select

from app.features.examenes.infrastructure.persistence.tablas import ExamenTabla
from app.features.preguntas.domain.banco import BancoVersion
from app.features.preguntas.infrastructure.persistence.tablas import (
    BancoVersionTabla,
    PreguntaTabla,
    TemaTabla,
)


def _a_uuid(val: Any) -> uuid.UUID:
    if isinstance(val, uuid.UUID):
        return val
    try:
        return uuid.UUID(str(val))
    except (ValueError, TypeError):
        return uuid.uuid5(uuid.NAMESPACE_DNS, str(val))


class BancoRepositorioSql:
    def __init__(self, sesion: Session) -> None:
        self._sesion = sesion

    def obtener_actual(self) -> BancoVersion | None:
        consulta = (
            select(BancoVersionTabla).order_by(col(BancoVersionTabla.version).desc()).limit(1)
        )
        fila = self._sesion.exec(consulta).first()
        if fila is None:
            return None
        return BancoVersion(fila.version, fila.cantidad, fila.creado_en)

    def obtener_contenido(self, version: int) -> dict[str, Any] | None:
        consulta = select(BancoVersionTabla).where(BancoVersionTabla.version == version)
        fila = self._sesion.exec(consulta).first()
        return None if fila is None else fila.contenido

    def existe_version(self, version: int) -> bool:
        consulta = select(BancoVersionTabla.id).where(BancoVersionTabla.version == version)
        return self._sesion.exec(consulta).first() is not None

    def guardar(self, version: int, cantidad: int, contenido: dict[str, Any]) -> None:
        self._sesion.add(BancoVersionTabla(version=version, cantidad=cantidad, contenido=contenido))
        self._persistir_tablas_relacionales(contenido)
        self._sesion.commit()

    def _persistir_tablas_relacionales(self, contenido: dict[str, Any]) -> None:
        examenes = contenido.get("examenes")
        if isinstance(examenes, list):
            for e in examenes:
                if not isinstance(e, dict):
                    continue
                e_id = _a_uuid(e.get("id") or uuid.uuid4())
                archivo = str(e.get("archivo") or f"examen_{e_id}.pdf")
                existente_ex = self._sesion.get(ExamenTabla, e_id)
                if not existente_ex:
                    existente_ex = self._sesion.exec(
                        select(ExamenTabla).where(ExamenTabla.archivo == archivo)
                    ).first()
                if existente_ex:
                    existente_ex.archivo = archivo
                    existente_ex.gestion = str(e.get("gestion") or existente_ex.gestion)
                    existente_ex.tipo = str(e.get("tipo") or existente_ex.tipo)
                    existente_ex.url = str(e.get("url") or existente_ex.url or "")
                    self._sesion.add(existente_ex)
                else:
                    self._sesion.add(
                        ExamenTabla(
                            id=e_id,
                            archivo=archivo,
                            gestion=str(e.get("gestion") or ""),
                            tipo=str(e.get("tipo") or ""),
                            url=str(e.get("url") or ""),
                        )
                    )
            self._sesion.flush()

        temas = contenido.get("temas")
        if isinstance(temas, list):
            for t in temas:
                if not isinstance(t, dict):
                    continue
                t_id = _a_uuid(t.get("id") or uuid.uuid4())
                materia = str(t.get("materia") or "")
                nombre = str(t.get("nombre") or "")
                existente_tm = self._sesion.get(TemaTabla, t_id)
                if not existente_tm and materia and nombre:
                    existente_tm = self._sesion.exec(
                        select(TemaTabla).where(
                            TemaTabla.materia == materia, TemaTabla.nombre == nombre
                        )
                    ).first()
                if existente_tm:
                    existente_tm.materia = materia or existente_tm.materia
                    existente_tm.nombre = nombre or existente_tm.nombre
                    self._sesion.add(existente_tm)
                else:
                    self._sesion.add(TemaTabla(id=t_id, materia=materia, nombre=nombre))
            self._sesion.flush()

        preguntas = contenido.get("preguntas")
        if isinstance(preguntas, list):
            default_examen_id = uuid.uuid5(uuid.NAMESPACE_DNS, "default_examen")
            for idx, p in enumerate(preguntas):
                if not isinstance(p, dict):
                    continue
                p_id = _a_uuid(p.get("id") or uuid.uuid4())
                ex_id = _a_uuid(p["examenId"]) if p.get("examenId") else default_examen_id
                if not self._sesion.get(ExamenTabla, ex_id):
                    self._sesion.add(
                        ExamenTabla(
                            id=ex_id,
                            archivo=f"examen_{ex_id}.pdf",
                            gestion="2-2026",
                            tipo="1op",
                            url="",
                        )
                    )
                    self._sesion.flush()

                tm_id = _a_uuid(p["temaId"]) if p.get("temaId") else None
                if tm_id and not self._sesion.get(TemaTabla, tm_id):
                    self._sesion.add(TemaTabla(id=tm_id, materia="General", nombre="General"))
                    self._sesion.flush()

                codigo = str(p.get("codigo") or f"P{idx + 1}")
                existente_pr = self._sesion.get(PreguntaTabla, p_id)
                if not existente_pr:
                    existente_pr = self._sesion.exec(
                        select(PreguntaTabla).where(
                            PreguntaTabla.examen_id == ex_id, PreguntaTabla.codigo == codigo
                        )
                    ).first()

                enunciado = str(p.get("enunciado") or "")
                opciones = list(p.get("opciones") or [])
                imagen = p.get("rutaImagen") or p.get("imagen")
                respuesta = p.get("respuesta")
                explicacion = p.get("explicacion")
                fuente = p.get("fuente")
                estado = str(p.get("estado") or "publicada")

                if existente_pr:
                    existente_pr.examen_id = ex_id
                    existente_pr.codigo = codigo
                    existente_pr.tema_id = tm_id
                    existente_pr.enunciado = enunciado or existente_pr.enunciado
                    existente_pr.opciones = opciones if opciones else existente_pr.opciones
                    existente_pr.imagen = imagen or existente_pr.imagen
                    existente_pr.respuesta = respuesta or existente_pr.respuesta
                    existente_pr.explicacion = explicacion or existente_pr.explicacion
                    existente_pr.fuente = fuente or existente_pr.fuente
                    existente_pr.estado = estado
                    self._sesion.add(existente_pr)
                else:
                    self._sesion.add(
                        PreguntaTabla(
                            id=p_id,
                            examen_id=ex_id,
                            codigo=codigo,
                            tema_id=tm_id,
                            enunciado=enunciado,
                            opciones=opciones,
                            imagen=imagen,
                            respuesta=respuesta,
                            explicacion=explicacion,
                            fuente=fuente,
                            estado=estado,
                        )
                    )
            self._sesion.flush()
