import os

os.environ["DATABASE_URL"] = "sqlite:///./test_ecodelivery.db"
os.environ["SEED_CSV_PATH"] = "no_existe.csv"

import pytest
from fastapi.testclient import TestClient

from app.database import Base, engine
from app.main import app


@pytest.fixture(autouse=True)
def limpiar_base():
    Base.metadata.drop_all(bind=engine)
    Base.metadata.create_all(bind=engine)
    yield
    Base.metadata.drop_all(bind=engine)


client = TestClient(app)


def pedido_valido():
    return {
        "cliente": "Ana Gomez",
        "zona": "Norte",
        "metodo_pago": "efectivo",
        "monto": 25000,
    }


def test_crear_pedido_ok():
    respuesta = client.post("/pedidos", json=pedido_valido())
    assert respuesta.status_code == 201
    cuerpo = respuesta.json()
    assert cuerpo["estado"] == "pendiente"
    assert cuerpo["fecha_entrega"] is None
    assert cuerpo["id_pedido"] > 0


def test_crear_pedido_sin_cliente_devuelve_422():
    datos = pedido_valido()
    datos.pop("cliente")
    respuesta = client.post("/pedidos", json=datos)
    assert respuesta.status_code == 422


def test_crear_pedido_zona_invalida_devuelve_422():
    datos = pedido_valido()
    datos["zona"] = "Este"
    respuesta = client.post("/pedidos", json=datos)
    assert respuesta.status_code == 422


def test_crear_pedido_monto_negativo_devuelve_422():
    datos = pedido_valido()
    datos["monto"] = -100
    respuesta = client.post("/pedidos", json=datos)
    assert respuesta.status_code == 422


def test_listar_con_filtros():
    client.post("/pedidos", json={**pedido_valido(), "zona": "Norte"})
    client.post("/pedidos", json={**pedido_valido(), "zona": "Sur"})

    solo_norte = client.get("/pedidos?zona=Norte").json()
    assert len(solo_norte) == 1
    assert solo_norte[0]["zona"] == "Norte"

    pendientes = client.get("/pedidos?estado=pendiente").json()
    assert len(pendientes) == 2


def test_listar_filtro_invalido_devuelve_400():
    respuesta = client.get("/pedidos?estado=volando")
    assert respuesta.status_code == 400


def test_detalle_no_encontrado_devuelve_404():
    respuesta = client.get("/pedidos/999")
    assert respuesta.status_code == 404


def test_flujo_estados_y_fecha_entrega():
    creado = client.post("/pedidos", json=pedido_valido()).json()
    id_pedido = creado["id_pedido"]

    r1 = client.patch(f"/pedidos/{id_pedido}/estado", json={"estado": "en_camino"})
    assert r1.status_code == 200
    assert r1.json()["estado"] == "en_camino"

    r2 = client.patch(f"/pedidos/{id_pedido}/estado", json={"estado": "entregado"})
    assert r2.status_code == 200
    assert r2.json()["fecha_entrega"] is not None


def test_transicion_invalida_devuelve_409():
    creado = client.post("/pedidos", json=pedido_valido()).json()
    id_pedido = creado["id_pedido"]

    respuesta = client.patch(f"/pedidos/{id_pedido}/estado", json={"estado": "entregado"})
    assert respuesta.status_code == 409


def test_cancelado_no_puede_pasar_a_entregado():
    creado = client.post("/pedidos", json=pedido_valido()).json()
    id_pedido = creado["id_pedido"]

    client.patch(f"/pedidos/{id_pedido}/estado", json={"estado": "cancelado"})
    respuesta = client.patch(f"/pedidos/{id_pedido}/estado", json={"estado": "entregado"})
    assert respuesta.status_code == 409
