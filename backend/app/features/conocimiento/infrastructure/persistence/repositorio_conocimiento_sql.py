from sqlmodel import Session, select

from app.features.conocimiento.domain.paquete import PaqueteConocimiento
from app.features.conocimiento.domain.puertos import RepositorioConocimiento
from app.features.conocimiento.infrastructure.persistence.tablas import PaqueteConocimientoTabla


class RepositorioConocimientoSql(RepositorioConocimiento):
    def __init__(self, sesion: Session) -> None:
        self._sesion = sesion

    def obtener_paquete_actual(self) -> PaqueteConocimiento | None:
        query = (
            select(PaqueteConocimientoTabla)
            .order_by(PaqueteConocimientoTabla.version.desc())  # type: ignore[attr-defined]
            .limit(1)
        )
        registro = self._sesion.exec(query).first()
        if registro is None:
            return None

        return PaqueteConocimiento(
            id=registro.id,
            version=registro.version,
            contenido=registro.contenido,
            actualizado_en=registro.actualizado_en,
        )
