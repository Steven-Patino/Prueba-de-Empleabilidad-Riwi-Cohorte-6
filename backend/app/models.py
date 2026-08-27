from datetime import datetime

from sqlalchemy import Column, DateTime, Integer, Numeric, String

from app.database import Base


class Pedido(Base):
    __tablename__ = "pedidos"

    id_pedido = Column(Integer, primary_key=True, index=True)
    cliente = Column(String, nullable=False)
    zona = Column(String, nullable=False)
    fecha_creacion = Column(DateTime, default=datetime.utcnow, nullable=False)
    fecha_entrega = Column(DateTime, nullable=True)
    estado = Column(String, nullable=False, default="pendiente")
    repartidor = Column(String, nullable=True)
    metodo_pago = Column(String, nullable=False)
    monto = Column(Numeric(10, 2), nullable=False)
