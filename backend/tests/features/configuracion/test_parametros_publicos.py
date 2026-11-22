import uuid
from datetime import date

from fastapi.testclient import TestClient

from app.features.configuracion.application.use_cases.obtener_parametros_publicos import (
    ObtenerParametrosPublicos,
)
from app.main import app


def test_calcula_proximas_fechas_tentativas_cuando_se_consulta_parametros_publicos() -> None:
    # Preparar
    caso_de_uso = ObtenerParametrosPublicos()

    # Actuar
    parametros = caso_de_uso.ejecutar(hoy=date(2026, 11, 22))

    # Verificar
    assert len(parametros.fechas_tentativas_examen) == 3
    assert parametros.fechas_tentativas_examen[0].fecha == date(2027, 1, 25)
    assert parametros.fechas_tentativas_examen[0].es_recomendada is True
    assert parametros.fechas_tentativas_examen[1].es_recomendada is False
    assert parametros.metas_diarias_opciones == (5, 10, 20)
    assert parametros.meta_diaria_sugerida == 10
    assert parametros.hora_estudio_sugerida == "19:00"


def test_devuelve_parametros_publicos_en_camel_case_cuando_se_llama_al_endpoint() -> None:
    # Preparar
    cliente = TestClient(app)

    # Actuar
    respuesta = cliente.get("/api/configuracion/parametros-publicos")

    # Verificar
    assert respuesta.status_code == 200
    datos = respuesta.json()
    assert datos["metasDiariasOpciones"] == [5, 10, 20]
    assert datos["metaDiariaSugerida"] == 10
    assert datos["horaEstudioSugerida"] == "19:00"
    assert datos["minPreguntasDiarias"] == 5
    assert datos["maxPreguntasDiarias"] == 50
    assert len(datos["fechasTentativasExamen"]) == 3
    assert datos["fechasTentativasExamen"][0]["esRecomendada"] is True


def test_acepta_x_usuario_id_opcional_cuando_se_llama_parametros_publicos() -> None:
    # Preparar
    cliente = TestClient(app)

    # Actuar
    respuesta = cliente.get(
        "/api/configuracion/parametros-publicos",
        headers={"X-Usuario-Id": str(uuid.uuid4())},
    )

    # Verificar
    assert respuesta.status_code == 200


def test_rechaza_x_usuario_id_invalido_cuando_se_envia_a_parametros_publicos() -> None:
    # Preparar
    cliente = TestClient(app)

    # Actuar
    respuesta = cliente.get(
        "/api/configuracion/parametros-publicos",
        headers={"X-Usuario-Id": "invalido"},
    )

    # Verificar
    assert respuesta.status_code == 422
    assert respuesta.json()["codigo"] == "IdentidadUsuarioInvalidaError"
