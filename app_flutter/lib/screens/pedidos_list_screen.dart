import "package:flutter/material.dart";
import "package:provider/provider.dart";

import "../estado_helpers.dart";
import "../models/pedido.dart";
import "../state/auth_provider.dart";
import "../state/pedidos_provider.dart";
import "crear_pedido_screen.dart";
import "pedido_detail_screen.dart";

class PedidosListScreen extends StatelessWidget {
  const PedidosListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<PedidosProvider>();
    final usuario = context.watch<AuthProvider>().usuario;

    return Scaffold(
      appBar: AppBar(
        title: Text("Pedidos - $usuario"),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: "Cerrar sesion",
            onPressed: () => context.read<AuthProvider>().logout(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const CrearPedidoScreen()),
          );
        },
        child: const Icon(Icons.add),
      ),
      body: Column(
        children: [
          _Filtros(provider: provider),
          Expanded(child: _Contenido(provider: provider)),
        ],
      ),
    );
  }
}

class _Filtros extends StatelessWidget {
  final PedidosProvider provider;

  const _Filtros({required this.provider});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          Expanded(
            child: DropdownButton<String>(
              isExpanded: true,
              value: provider.filtroEstado,
              hint: const Text("Estado"),
              items: [
                const DropdownMenuItem(value: null, child: Text("Todos los estados")),
                ...estadosDisponibles.map(
                  (e) => DropdownMenuItem(value: e, child: Text(e)),
                ),
              ],
              onChanged: provider.cambiarFiltroEstado,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: DropdownButton<String>(
              isExpanded: true,
              value: provider.filtroZona,
              hint: const Text("Zona"),
              items: [
                const DropdownMenuItem(value: null, child: Text("Todas las zonas")),
                ...zonasDisponibles.map(
                  (z) => DropdownMenuItem(value: z, child: Text(z)),
                ),
              ],
              onChanged: provider.cambiarFiltroZona,
            ),
          ),
        ],
      ),
    );
  }
}

class _Contenido extends StatelessWidget {
  final PedidosProvider provider;

  const _Contenido({required this.provider});

  @override
  Widget build(BuildContext context) {
    if (provider.estadoVista == ViewState.loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (provider.estadoVista == ViewState.error) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 8),
            Text(provider.mensajeError, textAlign: TextAlign.center),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: provider.cargarPedidos,
              child: const Text("Reintentar"),
            ),
          ],
        ),
      );
    }

    if (provider.pedidos.isEmpty) {
      return const Center(child: Text("No hay pedidos"));
    }

    return RefreshIndicator(
      onRefresh: provider.cargarPedidos,
      child: ListView.builder(
        itemCount: provider.pedidos.length,
        itemBuilder: (context, index) {
          final pedido = provider.pedidos[index];
          return _PedidoTile(pedido: pedido);
        },
      ),
    );
  }
}

class _PedidoTile extends StatelessWidget {
  final Pedido pedido;

  const _PedidoTile({required this.pedido});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(pedido.cliente),
      subtitle: Text("${pedido.zona}  -  \$${pedido.monto.toStringAsFixed(2)}"),
      trailing: Chip(
        label: Text(
          pedido.estado,
          style: const TextStyle(color: Colors.white, fontSize: 12),
        ),
        backgroundColor: colorPorEstado(pedido.estado),
      ),
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => PedidoDetailScreen(idPedido: pedido.idPedido),
          ),
        );
      },
    );
  }
}
