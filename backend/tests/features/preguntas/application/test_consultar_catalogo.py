import uuid

import pytest
from sqlalchemy import Engine
from sqlmodel import Session

from app.features.preguntas.application.consultar_catalogo import (
    consultar_arbol_temas,
    consultar_preguntas_filtradas,
)
from app.features.preguntas.application.publicar_banco import publicar_banco
from app.features.preguntas.domain.errores import TemaNoEncontradoError
from app.features.preguntas.infrastructure.persistence.banco_repositorio import (
    BancoRepositorioSql,
)
from app.features.preguntas.infrastructure.persistence.catalogo_repositorio import (
    CatalogoRepositorioSql,
)


def _banco_con_temas() -> dict:
    t_algebra = str(uuid.uuid4())
    t_geom = str(uuid.uuid4())
    t_quim = str(uuid.uuid4())
    e1 = str(uuid.uuid4())
    return {
        "version": 1,
        "examenes": [
            {
                "id": e1,
                "gestion": "2-2026",
                "tipo": "1op",
                "archivo": "2026-2-1op.pdf",
                "url": "https://sagaa.fcyt.umss.edu.bo/examenes/1.pdf",
            }
        ],
        "temas": [
            {"id": t_algebra, "materia": "Aritmética-Álgebra", "nombre": "Ecuaciones"},
            {"id": t_geom, "materia": "Geometría-Trigonometría", "nombre": "Ángulos"},
            {"id": t_quim, "materia": "Química", "nombre": "Estequiometría"},
        ],
        "preguntas": [
            {
                "id": str(uuid.uuid4()),
                "examenId": e1,
                "codigo": "M1",
                "temaId": t_algebra,
                "enunciado": "Resolver 2x = 4",
                "opciones": ["1", "2", "3", "4"],
                "respuesta": "B",
                "explicacion": "x = 2",
                "estado": "publicada",
            },
            {
                "id": str(uuid.uuid4()),
                "examenId": e1,
                "codigo": "M2",
                "temaId": t_geom,
                "enunciado": "Triángulo rectángulo",
                "opciones": ["90°", "45°"],
                "respuesta": "A",
                "explicacion": "Tiene un ángulo recto",
                "estado": "publicada",
            },
            {
                "id": str(uuid.uuid4()),
                "examenId": e1,
                "codigo": "Q1",
                "temaId": t_quim,
                "enunciado": "Masa molar del agua",
                "opciones": ["18 g/mol", "20 g/mol"],
                "respuesta": "A",
                "explicacion": "H2O = 18",
                "estado": "publicada",
            },
            {
                "id": str(uuid.uuid4()),
                "examenId": e1,
                "codigo": "Q2_borrador",
                "temaId": t_quim,
                "enunciado": "Borrador de química",
                "opciones": ["A", "B"],
                "respuesta": "A",
                "explicacion": "Borrador",
                "estado": "borrador",
            },
        ],
    }


def test_consultar_arbol_temas_agrupa_matematicas(motor: Engine):
    banco = _banco_con_temas()
    with Session(motor) as sesion:
        publicar_banco(BancoRepositorioSql(sesion), banco)
        arbol = consultar_arbol_temas(CatalogoRepositorioSql(sesion))

    materias_dict = {m.materia: m for m in arbol}
    assert "Matemáticas" in materias_dict
    assert "Física" in materias_dict
    assert "Química" in materias_dict
    assert "Biología" in materias_dict

    mat = materias_dict["Matemáticas"]
    assert mat.cantidad_preguntas == 2
    assert len(mat.temas) == 2
    nombres_temas = [t.nombre for t in mat.temas]
    assert "Ecuaciones" in nombres_temas
    assert "Ángulos" in nombres_temas

    quim = materias_dict["Química"]
    assert quim.cantidad_preguntas == 1  # solo la publicada


def test_consultar_preguntas_filtradas_por_materia_y_tema(motor: Engine):
    banco = _banco_con_temas()
    with Session(motor) as sesion:
        publicar_banco(BancoRepositorioSql(sesion), banco)
        repo = CatalogoRepositorioSql(sesion)

        preguntas_mat = consultar_preguntas_filtradas(repo, materia="Matemáticas")
        assert len(preguntas_mat) == 2

        t_quim = uuid.UUID(banco["temas"][2]["id"])
        preguntas_quim_tema = consultar_preguntas_filtradas(repo, tema_id=t_quim)
        assert len(preguntas_quim_tema) == 1
        assert preguntas_quim_tema[0].codigo == "Q1"

        with pytest.raises(TemaNoEncontradoError):
            consultar_preguntas_filtradas(repo, tema_id=uuid.uuid4())
