from datetime import datetime
from typing import Optional

from pydantic import BaseModel, field_validator

from app.enums import ESTADOS, METODOS_PAGO, ZONAS


class PedidoCreate(BaseModel):
    cliente: str
    zona: str
    metodo_pago: str
    monto: float
    repartidor: Optional[str] = None

    @field_validator("cliente")
    @classmethod
    def cliente_no_vacio(cls, value):
        if not value or not value.strip():
            raise ValueError("cliente no puede estar vacio")
        return value

    @field_validator("zona")
    @classmethod
    def zona_valida(cls, value):
        if value not in ZONAS:
            raise ValueError("zona debe ser una de: " + ", ".join(ZONAS))
        return value

    @field_validator("metodo_pago")
    @classmethod
    def metodo_pago_valido(cls, value):
        if value not in METODOS_PAGO:
            raise ValueError("metodo_pago debe ser uno de: " + ", ".join(METODOS_PAGO))
        return value

    @field_validator("monto")
    @classmethod
    def monto_positivo(cls, value):
        if value <= 0:
            raise ValueError("monto debe ser mayor a 0")
        return value


class EstadoUpdate(BaseModel):
    estado: str
    repartidor: Optional[str] = None

    @field_validator("estado")
    @classmethod
    def estado_valido(cls, value):
        if value not in ESTADOS:
            raise ValueError("estado debe ser uno de: " + ", ".join(ESTADOS))
        return value


class PedidoOut(BaseModel):
    id_pedido: int
    cliente: str
    zona: str
    fecha_creacion: datetime
    fecha_entrega: Optional[datetime]
    estado: str
    repartidor: Optional[str]
    metodo_pago: str
    monto: float

    class Config:
        from_attributes = True
