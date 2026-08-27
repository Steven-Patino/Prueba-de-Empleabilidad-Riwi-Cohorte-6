ZONAS = ["Norte", "Sur", "Centro", "Occidente", "Chapinero"]
ESTADOS = ["pendiente", "en_camino", "entregado", "cancelado"]
METODOS_PAGO = ["efectivo", "tarjeta", "app"]

TRANSICIONES_VALIDAS = {
    "pendiente": ["en_camino", "cancelado"],
    "en_camino": ["entregado", "cancelado"],
    "entregado": [],
    "cancelado": [],
}


def transicion_permitida(estado_actual, estado_nuevo):
    return estado_nuevo in TRANSICIONES_VALIDAS.get(estado_actual, [])
