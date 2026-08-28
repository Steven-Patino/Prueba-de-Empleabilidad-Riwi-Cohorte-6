import json
import os
from datetime import datetime

import pandas as pd
import requests
from airflow import DAG
from airflow.operators.python import PythonOperator

DATA_DIR = "/opt/airflow/data"
BACKEND_URL = os.environ.get("BACKEND_URL", "http://backend:8000")

STAGE_PEDIDOS = os.path.join(DATA_DIR, "_stage_pedidos.json")
STAGE_METRICAS = os.path.join(DATA_DIR, "_stage_metricas.csv")
REPORTE_FINAL = os.path.join(DATA_DIR, "reporte_pedidos.csv")
CSV_SEMILLA = "/opt/airflow/seed/dataset_pedidos_semilla.csv"


def extract():
    pedidos = None
    try:
        respuesta = requests.get(BACKEND_URL + "/pedidos", timeout=10)
        respuesta.raise_for_status()
        pedidos = respuesta.json()
        print("Datos obtenidos desde el backend:", len(pedidos), "pedidos")
    except Exception as error:
        print("No se pudo consultar el backend:", error)
        print("Usando el CSV de semilla como fuente")
        df_csv = pd.read_csv(CSV_SEMILLA)
        pedidos = df_csv.to_dict(orient="records")

    with open(STAGE_PEDIDOS, "w", encoding="utf-8") as f:
        json.dump(pedidos, f, default=str)

    return len(pedidos)


def transform():
    with open(STAGE_PEDIDOS, "r", encoding="utf-8") as f:
        pedidos = json.load(f)

    df = pd.DataFrame(pedidos)
    df["monto"] = pd.to_numeric(df["monto"], errors="coerce")
    df["fecha_creacion"] = pd.to_datetime(
        df["fecha_creacion"], format="ISO8601", errors="coerce"
    )
    df["fecha_entrega"] = pd.to_datetime(
        df["fecha_entrega"], format="ISO8601", errors="coerce"
    )

    entregados = df[df["estado"] == "entregado"].copy()
    entregados["minutos_entrega"] = (
        entregados["fecha_entrega"] - entregados["fecha_creacion"]
    ).dt.total_seconds() / 60.0

    tiempo_promedio = entregados.groupby("zona")["minutos_entrega"].mean().round(2)
    tiempo_promedio_filas = [
        {"metrica": "tiempo_promedio_entrega_min", "dimension": zona, "valor": valor}
        for zona, valor in tiempo_promedio.items()
    ]

    pedidos_por_estado = df.groupby("estado")["id_pedido"].count()
    pedidos_por_estado_filas = [
        {"metrica": "cantidad_pedidos", "dimension": estado, "valor": int(valor)}
        for estado, valor in pedidos_por_estado.items()
    ]

    ingresos_por_zona = df.groupby("zona")["monto"].sum().round(2)
    ingresos_por_zona_filas = [
        {"metrica": "ingresos_totales", "dimension": zona, "valor": valor}
        for zona, valor in ingresos_por_zona.items()
    ]

    todas_las_filas = (
        tiempo_promedio_filas + pedidos_por_estado_filas + ingresos_por_zona_filas
    )
    resultado = pd.DataFrame(todas_las_filas)
    resultado["fecha_reporte"] = datetime.utcnow().strftime("%Y-%m-%d")
    resultado.to_csv(STAGE_METRICAS, index=False, encoding="utf-8")

    print(resultado)
    return len(resultado)


def load():
    resultado = pd.read_csv(STAGE_METRICAS)
    resultado.to_csv(REPORTE_FINAL, index=False, encoding="utf-8")
    print("Reporte final escrito en:", REPORTE_FINAL)
    print(resultado.to_string(index=False))


default_args = {
    "owner": "ecodelivery",
    "retries": 1,
}

with DAG(
    dag_id="etl_pedidos_diario",
    description="Resumen diario de la operacion de pedidos de EcoDelivery",
    default_args=default_args,
    start_date=datetime(2024, 1, 1),
    schedule_interval=None,
    catchup=False,
    tags=["ecodelivery"],
) as dag:

    tarea_extract = PythonOperator(
        task_id="extract",
        python_callable=extract,
    )

    tarea_transform = PythonOperator(
        task_id="transform",
        python_callable=transform,
    )

    tarea_load = PythonOperator(
        task_id="load",
        python_callable=load,
    )

    tarea_extract >> tarea_transform >> tarea_load
