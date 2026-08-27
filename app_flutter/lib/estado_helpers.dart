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
      return Colors.orange;
    case "en_camino":
      return Colors.blue;
    case "entregado":
      return Colors.green;
    case "cancelado":
      return Colors.red;
    default:
      return Colors.grey;
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
