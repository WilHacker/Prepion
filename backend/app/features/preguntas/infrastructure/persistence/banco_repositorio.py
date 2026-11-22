from typing import Any

from sqlmodel import Session, col, select

from app.features.preguntas.domain.banco import BancoVersion
from app.features.preguntas.infrastructure.persistence.tablas import BancoVersionTabla


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
        self._sesion.commit()
