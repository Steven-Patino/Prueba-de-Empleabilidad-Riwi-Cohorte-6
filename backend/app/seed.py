import csv
import os
from datetime import datetime

from app.config import settings
from app.database import SessionLocal
from app.models import Pedido


def parse_fecha(valor):
    if not valor:
        return None
    return datetime.strptime(valor, "%Y-%m-%d %H:%M:%S")


def seed_desde_csv():
    ruta = settings.seed_csv_path
    if not os.path.exists(ruta):
        print("No se encontro el CSV de semilla en:", ruta)
        return

    db = SessionLocal()
    try:
        ya_hay_datos = db.query(Pedido).first() is not None
        if ya_hay_datos:
            print("La tabla pedidos ya tiene datos, no se hace seed")
            return

        with open(ruta, newline="", encoding="utf-8") as f:
            lector = csv.DictReader(f)
            pedidos = []
            for fila in lector:
                pedidos.append(
                    Pedido(
                        cliente=fila["cliente"],
                        zona=fila["zona"],
                        fecha_creacion=parse_fecha(fila["fecha_creacion"]),
                        fecha_entrega=parse_fecha(fila["fecha_entrega"]),
                        estado=fila["estado"],
                        repartidor=fila["repartidor"] or None,
                        metodo_pago=fila["metodo_pago"],
                        monto=float(fila["monto"]),
                    )
                )
            db.add_all(pedidos)
            db.commit()
            print("Seed completado con", len(pedidos), "pedidos")
    finally:
        db.close()
