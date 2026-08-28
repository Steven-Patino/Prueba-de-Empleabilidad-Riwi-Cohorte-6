import "package:flutter/material.dart";

const List<String> zonasDisponibles = [
  "Norte",
  "Sur",
  "Centro",
  "Occidente",
  "Chapinero",
];

const List<String> estadosDisponibles = [
  "pendiente",
  "en_camino",
  "entregado",
  "cancelado",
];

const List<String> metodosPagoDisponibles = [
  "efectivo",
  "tarjeta",
  "app",
];

Color colorPorEstado(String estado) {
  switch (estado) {
    case "pendiente":
      return const Color(0xFFF08C00);
    case "en_camino":
      return const Color(0xFF1971C2);
    case "entregado":
      return const Color(0xFF2F9E44);
    case "cancelado":
      return const Color(0xFFE03131);
    default:
      return Colors.grey;
  }
}

IconData iconoPorEstado(String estado) {
  switch (estado) {
    case "pendiente":
      return Icons.schedule;
    case "en_camino":
      return Icons.pedal_bike;
    case "entregado":
      return Icons.check_circle;
    case "cancelado":
      return Icons.cancel;
    default:
      return Icons.help_outline;
  }
}

String etiquetaEstado(String estado) {
  switch (estado) {
    case "pendiente":
      return "Pendiente";
    case "en_camino":
      return "En camino";
    case "entregado":
      return "Entregado";
    case "cancelado":
      return "Cancelado";
    default:
      return estado;
  }
}

IconData iconoMetodoPago(String metodo) {
  switch (metodo) {
    case "efectivo":
      return Icons.payments;
    case "tarjeta":
      return Icons.credit_card;
    case "app":
      return Icons.phone_android;
    default:
      return Icons.attach_money;
  }
}

String etiquetaMetodoPago(String metodo) {
  switch (metodo) {
    case "efectivo":
      return "Efectivo";
    case "tarjeta":
      return "Tarjeta";
    case "app":
      return "App";
    default:
      return metodo;
  }
}

String? siguienteEstado(String estadoActual) {
  switch (estadoActual) {
    case "pendiente":
      return "en_camino";
    case "en_camino":
      return "entregado";
    default:
      return null;
  }
}

bool esEstadoFinal(String estado) {
  return estado == "entregado" || estado == "cancelado";
}

String formatoMoneda(double valor) {
  final entero = valor.round().toString();
  final buffer = StringBuffer();
  for (int i = 0; i < entero.length; i++) {
    if (i > 0 && (entero.length - i) % 3 == 0) {
      buffer.write(".");
    }
    buffer.write(entero[i]);
  }
  return "\$$buffer";
}

String formatoFecha(DateTime fecha) {
  final dia = fecha.day.toString().padLeft(2, "0");
  final mes = fecha.month.toString().padLeft(2, "0");
  final hora = fecha.hour.toString().padLeft(2, "0");
  final minuto = fecha.minute.toString().padLeft(2, "0");
  return "$dia/$mes/${fecha.year}  $hora:$minuto";
}
