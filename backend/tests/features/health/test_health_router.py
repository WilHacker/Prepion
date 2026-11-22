from fastapi.testclient import TestClient

from app.main import app


def test_devuelve_estado_ok_cuando_el_servicio_esta_vivo():
    # Preparar
    cliente = TestClient(app)

    # Actuar
    respuesta = cliente.get("/api/health")

    # Verificar
    assert respuesta.status_code == 200
    assert respuesta.json() == {"estado": "ok"}
