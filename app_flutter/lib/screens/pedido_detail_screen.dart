import "package:flutter/material.dart";
import "package:provider/provider.dart";

import "../estado_helpers.dart";
import "../models/pedido.dart";
import "../services/api_service.dart";
import "../state/pedidos_provider.dart";

class PedidoDetailScreen extends StatefulWidget {
  final int idPedido;

  const PedidoDetailScreen({super.key, required this.idPedido});

  @override
  State<PedidoDetailScreen> createState() => _PedidoDetailScreenState();
}

class _PedidoDetailScreenState extends State<PedidoDetailScreen> {
  final ApiService api = ApiService();

  bool cargando = true;
  bool error = false;
  bool actualizando = false;
  Pedido? pedido;

  @override
  void initState() {
    super.initState();
    cargarPedido();
  }

  Future<void> cargarPedido() async {
    setState(() {
      cargando = true;
      error = false;
    });
    try {
      final resultado = await api.getPedido(widget.idPedido);
      setState(() {
        pedido = resultado;
        cargando = false;
      });
    } catch (_) {
      setState(() {
        error = true;
        cargando = false;
      });
    }
  }

  Future<void> avanzarEstado() async {
    final actual = pedido;
    if (actual == null) return;

    final proximo = siguienteEstado(actual.estado);
    if (proximo == null) return;

    setState(() => actualizando = true);

    final provider = context.read<PedidosProvider>();
    final actualizado = await provider.avanzarEstado(actual.idPedido, proximo);

    setState(() => actualizando = false);

    if (!mounted) return;

    if (actualizado != null) {
      setState(() => pedido = actualizado);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Estado actualizado a $proximo")),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(provider.mensajeError)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Pedido #${widget.idPedido}")),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (cargando) {
      return const Center(child: CircularProgressIndicator());
    }

    if (error || pedido == null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("No se pudo cargar el pedido"),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: cargarPedido,
              child: const Text("Reintentar"),
            ),
          ],
        ),
      );
    }

    final p = pedido!;
    final proximo = siguienteEstado(p.estado);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _fila("Cliente", p.cliente),
        _fila("Zona", p.zona),
        _fila("Estado", p.estado),
        _fila("Monto", "\$${p.monto.toStringAsFixed(2)}"),
        _fila("Metodo de pago", p.metodoPago),
        _fila("Repartidor", p.repartidor ?? "Sin asignar"),
        _fila("Fecha creacion", p.fechaCreacion.toString()),
        _fila("Fecha entrega", p.fechaEntrega?.toString() ?? "Sin entregar"),
        const SizedBox(height: 24),
        if (proximo == null)
          const Text("Este pedido esta en un estado final")
        else
          ElevatedButton(
            onPressed: actualizando ? null : avanzarEstado,
            child: actualizando
                ? const SizedBox(
                    height: 18,
                    width: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text("Avanzar a $proximo"),
          ),
      ],
    );
  }

  Widget _fila(String etiqueta, String valor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              etiqueta,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: Text(valor)),
        ],
      ),
    );
  }
}
