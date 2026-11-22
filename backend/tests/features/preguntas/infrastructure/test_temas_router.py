import uuid

from fastapi.testclient import TestClient
from sqlalchemy import Engine
from sqlmodel import Session

from app.features.preguntas.application.publicar_banco import publicar_banco
from app.features.preguntas.infrastructure.persistence.banco_repositorio import (
    BancoRepositorioSql,
)


def _banco_de_prueba() -> dict:
    t_id = str(uuid.uuid4())
    e_id = str(uuid.uuid4())
    return {
        "version": 1,
        "examenes": [
            {
                "id": e_id,
                "gestion": "2-2026",
                "tipo": "2op",
                "archivo": "2026-2-2op.pdf",
            }
        ],
        "temas": [
            {"id": t_id, "materia": "Física", "nombre": "Cinemática"},
        ],
        "preguntas": [
            {
                "id": str(uuid.uuid4()),
                "examenId": e_id,
                "codigo": "F1",
                "temaId": t_id,
                "enunciado": "Calcular la velocidad v = d/t",
                "opciones": ["10 m/s", "20 m/s"],
                "respuesta": "A",
                "explicacion": "100m / 10s = 10m/s",
                "fuente": "Examen de ingreso FCyT · 2.ª opción · 2-2026 · F1 (serie 1)",
                "estado": "publicada",
            }
        ],
    }


def test_obtiene_arbol_temas_con_materias_oficiales(cliente: TestClient):
    respuesta = cliente.get("/api/temas")
    assert respuesta.status_code == 200
    cuerpo = respuesta.json()
    assert isinstance(cuerpo, list)
    materias = [m["materia"] for m in cuerpo]
    assert "Matemáticas" in materias
    assert "Física" in materias
    assert "Química" in materias
    assert "Biología" in materias


def test_obtiene_arbol_temas_con_datos_poblados(cliente: TestClient, motor: Engine):
    banco = _banco_de_prueba()
    with Session(motor) as sesion:
        publicar_banco(BancoRepositorioSql(sesion), banco)

    respuesta = cliente.get("/api/temas")
    assert respuesta.status_code == 200
    cuerpo = respuesta.json()
    fisica = next(m for m in cuerpo if m["materia"] == "Física")
    assert fisica["cantidadPreguntas"] == 1
    assert len(fisica["temas"]) == 1
    assert fisica["temas"][0]["nombre"] == "Cinemática"
    assert fisica["temas"][0]["cantidadPreguntas"] == 1


def test_listar_preguntas_sin_filtros(cliente: TestClient, motor: Engine):
    banco = _banco_de_prueba()
    with Session(motor) as sesion:
        publicar_banco(BancoRepositorioSql(sesion), banco)

    respuesta = cliente.get("/api/preguntas")
    assert respuesta.status_code == 200
    cuerpo = respuesta.json()
    assert len(cuerpo) == 1
    assert cuerpo[0]["codigo"] == "F1"
    assert cuerpo[0]["fuente"] == "Examen de ingreso FCyT · 2.ª opción · 2-2026 · F1 (serie 1)"


def test_usa_una_fuente_generica_cuando_la_pregunta_no_trae_fuente(
    cliente: TestClient, motor: Engine
):
    banco = _banco_de_prueba()
    del banco["preguntas"][0]["fuente"]
    with Session(motor) as sesion:
        publicar_banco(BancoRepositorioSql(sesion), banco)

    respuesta = cliente.get("/api/preguntas")

    assert respuesta.json()[0]["fuente"] == "Examen de ingreso FCyT · F1"


def test_listar_preguntas_filtradas_por_materia(cliente: TestClient, motor: Engine):
    banco = _banco_de_prueba()
    with Session(motor) as sesion:
        publicar_banco(BancoRepositorioSql(sesion), banco)

    respuesta = cliente.get("/api/preguntas?materia=Física")
    assert respuesta.status_code == 200
    assert len(respuesta.json()) == 1

    respuesta_vacia = cliente.get("/api/preguntas?materia=Química")
    assert respuesta_vacia.status_code == 200
    assert len(respuesta_vacia.json()) == 0


def test_listar_preguntas_filtradas_por_tema_id(cliente: TestClient, motor: Engine):
    banco = _banco_de_prueba()
    with Session(motor) as sesion:
        publicar_banco(BancoRepositorioSql(sesion), banco)

    tema_id = banco["temas"][0]["id"]
    respuesta = cliente.get(f"/api/preguntas?temaId={tema_id}")
    assert respuesta.status_code == 200
    assert len(respuesta.json()) == 1


def test_listar_preguntas_retorna_404_cuando_tema_no_existe(cliente: TestClient):
    tema_inexistente = str(uuid.uuid4())
    respuesta = cliente.get(f"/api/preguntas?temaId={tema_inexistente}")
    assert respuesta.status_code == 404
    assert respuesta.headers["content-type"] == "application/problem+json"
    assert "No existe el tema" in respuesta.json()["detail"]


def test_listar_preguntas_retorna_422_cuando_tema_es_uuid_invalido(cliente: TestClient):
    respuesta = cliente.get("/api/preguntas?temaId=invalido")
    assert respuesta.status_code == 422
