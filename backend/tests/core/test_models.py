from sqlmodel import SQLModel

import app.core.models  # noqa: F401  registra las tablas

TABLAS_ESPERADAS = {
    "banco_versiones",
    "examenes",
    "paquetes_conocimiento",
    "preguntas",
    "reportes",
    "respuestas",
    "temas",
    "usuarios",
}


def test_registra_todas_las_tablas_cuando_se_importan_los_modelos():
    assert set(SQLModel.metadata.tables) == TABLAS_ESPERADAS


def test_toda_tabla_tiene_marcas_de_tiempo_cuando_se_declara():
    for tabla in SQLModel.metadata.tables.values():
        assert {"creado_en", "actualizado_en"} <= set(tabla.columns.keys()), tabla.name


def test_usa_nombres_estables_cuando_se_genera_la_llave_primaria():
    tabla = SQLModel.metadata.tables["preguntas"]
    assert tabla.primary_key.name == "pk_preguntas"


def test_guarda_la_opcion_elegida_y_acepta_nulo_cuando_el_postulante_toca_no_se():
    columna = SQLModel.metadata.tables["respuestas"].columns["opcion_elegida"]

    assert columna.nullable
    assert columna.type.length == 1  # una letra, de A a E
