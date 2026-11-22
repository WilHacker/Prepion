import uuid

import pytest
from sqlalchemy import Engine, func
from sqlmodel import Session, select

from app.features.examenes.infrastructure.persistence.tablas import ExamenTabla
from app.features.preguntas.application.volcar_banco import volcar_banco_publicado
from app.features.preguntas.domain.errores import BancoNoEncontradoError
from app.features.preguntas.infrastructure.cli import main
from app.features.preguntas.infrastructure.persistence.banco_repositorio import (
    BancoRepositorioSql,
)
from app.features.preguntas.infrastructure.persistence.tablas import (
    BancoVersionTabla,
    PreguntaTabla,
    TemaTabla,
)

EXAMEN = str(uuid.uuid4())
TEMA = str(uuid.uuid4())
PREGUNTA = str(uuid.uuid4())
BANCO = {
    "version": 1,
    "examenes": [{"id": EXAMEN, "gestion": "2-2026", "tipo": "2op", "archivo": "2026-2-2op.pdf"}],
    "temas": [{"id": TEMA, "materia": "Química", "nombre": "Estequiometría"}],
    "preguntas": [
        {
            "id": PREGUNTA,
            "examenId": EXAMEN,
            "codigo": "S1-Q17",
            "temaId": TEMA,
            "enunciado": "¿Cuántos gramos de hierro se obtienen?",
            "opciones": ["a", "b", "c"],
            "respuesta": "B",
            "explicacion": "Se aplica la estequiometría.",
            "rutaImagen": None,
            "fuente": "Examen de ingreso FCyT · 2.ª opción · 2-2026 · Q17 (serie 1)",
        }
    ],
}


def _publicar_sin_volcar(motor: Engine) -> None:
    """Simula un banco publicado antes de que existiera el volcado a las tablas."""
    with Session(motor) as sesion:
        sesion.add(BancoVersionTabla(version=1, cantidad=1, contenido=BANCO))
        sesion.commit()


def _contar(motor: Engine, tabla: type) -> int:
    with Session(motor) as sesion:
        return sesion.exec(select(func.count()).select_from(tabla)).one()


def test_vuelca_un_banco_ya_publicado_a_las_tablas_relacionales(motor: Engine) -> None:
    _publicar_sin_volcar(motor)

    with Session(motor) as sesion:
        version = volcar_banco_publicado(BancoRepositorioSql(sesion))

    assert version == 1
    assert _contar(motor, ExamenTabla) == 1
    assert _contar(motor, TemaTabla) == 1
    with Session(motor) as sesion:
        pregunta = sesion.get(PreguntaTabla, uuid.UUID(PREGUNTA))
        assert pregunta is not None
        assert pregunta.codigo == "S1-Q17"
        assert pregunta.estado == "publicada"
        assert pregunta.opciones == ["a", "b", "c"]
        assert "Q17" in (pregunta.fuente or "")


def test_volcar_dos_veces_no_duplica_filas(motor: Engine) -> None:
    _publicar_sin_volcar(motor)

    for _ in range(2):
        with Session(motor) as sesion:
            volcar_banco_publicado(BancoRepositorioSql(sesion))

    assert _contar(motor, ExamenTabla) == 1
    assert _contar(motor, TemaTabla) == 1
    assert _contar(motor, PreguntaTabla) == 1


def test_falla_con_un_mensaje_claro_cuando_no_hay_banco_publicado(motor: Engine) -> None:
    with Session(motor) as sesion, pytest.raises(BancoNoEncontradoError, match="Todavía no hay"):
        volcar_banco_publicado(BancoRepositorioSql(sesion))


def test_el_comando_volcar_llena_las_tablas_y_avisa_la_version(
    motor: Engine, capsys: pytest.CaptureFixture[str]
) -> None:
    _publicar_sin_volcar(motor)

    codigo = main(["volcar"], motor=motor)

    assert codigo == 0
    assert "versión 1" in capsys.readouterr().out
    assert _contar(motor, PreguntaTabla) == 1


def test_el_comando_volcar_sale_con_error_cuando_no_hay_banco(
    motor: Engine, capsys: pytest.CaptureFixture[str]
) -> None:
    codigo = main(["volcar"], motor=motor)

    assert codigo == 1
    assert "Todavía no hay" in capsys.readouterr().err
