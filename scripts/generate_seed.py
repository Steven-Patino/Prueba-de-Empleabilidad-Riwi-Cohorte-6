import csv
import random
from datetime import datetime, timedelta

random.seed(42)

ZONAS = ["Norte", "Sur", "Centro", "Occidente", "Chapinero"]
ESTADOS = ["pendiente", "en_camino", "entregado", "cancelado"]
METODOS_PAGO = ["efectivo", "tarjeta", "app"]

NOMBRES = [
    "Ana Gomez", "Carlos Ruiz", "Diana Torres", "Esteban Lopez", "Fernanda Diaz",
    "Gabriel Mora", "Helena Castro", "Ivan Rojas", "Julia Pena", "Kevin Silva",
    "Laura Vega", "Mateo Nunez", "Natalia Rios", "Oscar Parra", "Paula Leon",
    "Ricardo Salas", "Sofia Marin", "Tomas Beltran", "Valentina Cano", "Wilson Prieto",
]

REPARTIDORES = [
    "Bici-01 Andres", "Bici-02 Camila", "Moto-01 Felipe", "Moto-02 Sara",
    "Bici-03 Nicolas", "Moto-03 Daniela",
]

NUM_PEDIDOS = 260
DIAS_ATRAS = 35

filas = []
inicio = datetime.now() - timedelta(days=DIAS_ATRAS)

for i in range(1, NUM_PEDIDOS + 1):
    minutos_random = random.randint(0, DIAS_ATRAS * 24 * 60)
    fecha_creacion = inicio + timedelta(minutes=minutos_random)

    estado = random.choices(ESTADOS, weights=[15, 15, 60, 10])[0]
    zona = random.choice(ZONAS)
    cliente = random.choice(NOMBRES)
    metodo_pago = random.choice(METODOS_PAGO)
    monto = round(random.uniform(12000, 95000), 2)

    repartidor = ""
    fecha_entrega = ""

    if estado in ("en_camino", "entregado"):
        repartidor = random.choice(REPARTIDORES)

    if estado == "entregado":
        minutos_entrega = random.randint(15, 90)
        fecha_entrega = fecha_creacion + timedelta(minutes=minutos_entrega)

    filas.append(
        {
            "id_pedido": i,
            "cliente": cliente,
            "zona": zona,
            "fecha_creacion": fecha_creacion.strftime("%Y-%m-%d %H:%M:%S"),
            "fecha_entrega": fecha_entrega.strftime("%Y-%m-%d %H:%M:%S") if fecha_entrega else "",
            "estado": estado,
            "repartidor": repartidor,
            "metodo_pago": metodo_pago,
            "monto": monto,
        }
    )

columnas = [
    "id_pedido",
    "cliente",
    "zona",
    "fecha_creacion",
    "fecha_entrega",
    "estado",
    "repartidor",
    "metodo_pago",
    "monto",
]

with open("dataset_pedidos_semilla.csv", "w", newline="", encoding="utf-8") as f:
    writer = csv.DictWriter(f, fieldnames=columnas)
    writer.writeheader()
    writer.writerows(filas)

print("dataset_pedidos_semilla.csv generado con", len(filas), "filas")
