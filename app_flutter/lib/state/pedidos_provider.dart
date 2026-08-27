import "package:flutter/material.dart";

import "../models/pedido.dart";
import "../services/api_service.dart";

enum ViewState { idle, loading, error, loaded }

class PedidosProvider extends ChangeNotifier {
  final ApiService api = ApiService();

  ViewState estadoVista = ViewState.idle;
  String mensajeError = "";
  List<Pedido> pedidos = [];

  String? filtroEstado;
  String? filtroZona;

  Future<void> cargarPedidos() async {
    estadoVista = ViewState.loading;
    notifyListeners();

    try {
      pedidos = await api.getPedidos(estado: filtroEstado, zona: filtroZona);
      estadoVista = ViewState.loaded;
    } catch (error) {
      mensajeError = error.toString();
      estadoVista = ViewState.error;
    }

    notifyListeners();
  }

  void cambiarFiltroEstado(String? valor) {
    filtroEstado = valor;
    cargarPedidos();
  }

  void cambiarFiltroZona(String? valor) {
    filtroZona = valor;
    cargarPedidos();
  }

  Future<bool> crearPedido({
    required String cliente,
    required String zona,
    required String metodoPago,
    required double monto,
  }) async {
    try {
      await api.crearPedido(
        cliente: cliente,
        zona: zona,
        metodoPago: metodoPago,
        monto: monto,
      );
      await cargarPedidos();
      return true;
    } catch (error) {
      mensajeError = error.toString();
      return false;
    }
  }

  Future<Pedido?> avanzarEstado(int id, String nuevoEstado) async {
    try {
      final actualizado = await api.actualizarEstado(id, nuevoEstado);
      await cargarPedidos();
      return actualizado;
    } catch (error) {
      mensajeError = error.toString();
      return null;
    }
  }
}
