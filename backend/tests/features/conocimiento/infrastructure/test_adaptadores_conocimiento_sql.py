import uuid
from datetime import UTC, datetime

from sqlmodel import Session

from app.features.conocimiento.infrastructure.persistence.adaptadores_sql import (
    BancoPublicadoSql,
    PaquetesConocimientoSql,
    RespuestasRealesSql,
)
from app.features.preguntas.infrastructure.persistence.tablas import BancoVersionTabla
from app.features.sincronizacion.infrastructure.persistence.tablas import RespuestaTabla


def test_banco_publicado_devuelve_el_contenido_de_la_version_mas_alta(sesion: Session) -> None:
    sesion.add(BancoVersionTabla(version=1, cantidad=1, contenido={"v": 1}))
    sesion.add(BancoVersionTabla(version=2, cantidad=1, contenido={"v": 2}))
    sesion.commit()

    assert BancoPublicadoSql(sesion).obtener_ultimo() == {"v": 2}


def test_banco_publicado_sin_filas_devuelve_none(sesion: Session) -> None:
    assert BancoPublicadoSql(sesion).obtener_ultimo() is None


def test_respuestas_reales_lista_usuario_pregunta_y_acierto(sesion: Session) -> None:
    usuario, pregunta = uuid.uuid4(), uuid.uuid4()
    sesion.add(
        RespuestaTabla(
            id_evento=uuid.uuid4(),
            usuario_id=usuario,
            pregunta_id=pregunta,
            es_correcta=True,
            tiempo_ms=900,
            respondida_en=datetime(2026, 11, 1, tzinfo=UTC),
        )
    )
    sesion.commit()

    respuestas = RespuestasRealesSql(sesion).listar()

    assert [(r.usuario_id, r.pregunta_id, r.es_correcta) for r in respuestas] == [
        (str(usuario), str(pregunta), True)
    ]


def test_paquetes_sin_filas_no_hay_actual_y_la_ultima_version_es_cero(sesion: Session) -> None:
    repo = PaquetesConocimientoSql(sesion)

    assert repo.obtener_actual() is None
    assert repo.ultima_version() == 0


def test_paquetes_guarda_y_devuelve_la_version_mas_alta(sesion: Session) -> None:
    repo = PaquetesConocimientoSql(sesion)

    repo.guardar(1, {"a": 1})
    repo.guardar(2, {"a": 2})

    assert repo.ultima_version() == 2
    assert repo.obtener_actual() == {"a": 2}
