class Pedido {
  final int idPedido;
  final String cliente;
  final String zona;
  final DateTime fechaCreacion;
  final DateTime? fechaEntrega;
  final String estado;
  final String? repartidor;
  final String metodoPago;
  final double monto;

  Pedido({
    required this.idPedido,
    required this.cliente,
    required this.zona,
    required this.fechaCreacion,
    required this.fechaEntrega,
    required this.estado,
    required this.repartidor,
    required this.metodoPago,
    required this.monto,
  });

  factory Pedido.fromJson(Map<String, dynamic> json) {
    return Pedido(
      idPedido: json["id_pedido"],
      cliente: json["cliente"],
      zona: json["zona"],
      fechaCreacion: DateTime.parse(json["fecha_creacion"]),
      fechaEntrega: json["fecha_entrega"] == null
          ? null
          : DateTime.parse(json["fecha_entrega"]),
      estado: json["estado"],
      repartidor: json["repartidor"],
      metodoPago: json["metodo_pago"],
      monto: (json["monto"] as num).toDouble(),
    );
  }
}
