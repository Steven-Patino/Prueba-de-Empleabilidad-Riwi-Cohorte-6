from typing import Optional

from fastapi import Depends, FastAPI, HTTPException, Query
from fastapi.middleware.cors import CORSMiddleware
from sqlalchemy.orm import Session

from app import crud
from app.database import Base, engine, get_db
from app.enums import ESTADOS, ZONAS, transicion_permitida
from app.schemas import EstadoUpdate, PedidoCreate, PedidoOut
from app.security import require_api_key
from app.seed import seed_desde_csv

Base.metadata.create_all(bind=engine)

app = FastAPI(title="EcoDelivery API", version="1.0.0")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_methods=["*"],
    allow_headers=["*"],
)


@app.on_event("startup")
def on_startup():
    seed_desde_csv()


@app.get("/health")
def health():
    return {"status": "ok"}


@app.post("/pedidos", response_model=PedidoOut, status_code=201, dependencies=[Depends(require_api_key)])
def crear_pedido(datos: PedidoCreate, db: Session = Depends(get_db)):
    return crud.crear_pedido(db, datos)


@app.get("/pedidos", response_model=list[PedidoOut])
def listar_pedidos(
    estado: Optional[str] = Query(default=None),
    zona: Optional[str] = Query(default=None),
    db: Session = Depends(get_db),
):
    if estado is not None and estado not in ESTADOS:
        raise HTTPException(status_code=400, detail="estado invalido")
    if zona is not None and zona not in ZONAS:
        raise HTTPException(status_code=400, detail="zona invalida")
    return crud.listar_pedidos(db, estado=estado, zona=zona)


@app.get("/pedidos/{id_pedido}", response_model=PedidoOut)
def detalle_pedido(id_pedido: int, db: Session = Depends(get_db)):
    pedido = crud.obtener_pedido(db, id_pedido)
    if pedido is None:
        raise HTTPException(status_code=404, detail="Pedido no encontrado")
    return pedido


@app.patch("/pedidos/{id_pedido}/estado", response_model=PedidoOut, dependencies=[Depends(require_api_key)])
def actualizar_estado(id_pedido: int, datos: EstadoUpdate, db: Session = Depends(get_db)):
    pedido = crud.obtener_pedido(db, id_pedido)
    if pedido is None:
        raise HTTPException(status_code=404, detail="Pedido no encontrado")

    if datos.estado == pedido.estado:
        raise HTTPException(status_code=409, detail="El pedido ya esta en ese estado")

    if not transicion_permitida(pedido.estado, datos.estado):
        raise HTTPException(
            status_code=409,
            detail="Transicion no permitida de " + pedido.estado + " a " + datos.estado,
        )

    return crud.actualizar_estado(db, pedido, datos.estado, datos.repartidor)
