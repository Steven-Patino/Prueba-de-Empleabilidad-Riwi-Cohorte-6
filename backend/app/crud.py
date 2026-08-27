from datetime import datetime

from sqlalchemy.orm import Session

from app.models import Pedido


def crear_pedido(db: Session, datos):
    pedido = Pedido(
        cliente=datos.cliente.strip(),
        zona=datos.zona,
        estado="pendiente",
        repartidor=datos.repartidor,
        metodo_pago=datos.metodo_pago,
        monto=datos.monto,
        fecha_creacion=datetime.utcnow(),
    )
    db.add(pedido)
    db.commit()
    db.refresh(pedido)
    return pedido


def listar_pedidos(db: Session, estado=None, zona=None):
    query = db.query(Pedido)
    if estado:
        query = query.filter(Pedido.estado == estado)
    if zona:
        query = query.filter(Pedido.zona == zona)
    return query.order_by(Pedido.id_pedido).all()


def obtener_pedido(db: Session, id_pedido):
    return db.query(Pedido).filter(Pedido.id_pedido == id_pedido).first()


def actualizar_estado(db: Session, pedido, nuevo_estado, repartidor=None):
    pedido.estado = nuevo_estado
    if repartidor:
        pedido.repartidor = repartidor
    if nuevo_estado == "entregado":
        pedido.fecha_entrega = datetime.utcnow()
    db.commit()
    db.refresh(pedido)
    return pedido
