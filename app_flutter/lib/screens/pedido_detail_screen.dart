import "package:flutter/material.dart";
import "package:provider/provider.dart";

import "../estado_helpers.dart";
import "../models/pedido.dart";
import "../services/api_service.dart";
import "../state/pedidos_provider.dart";
import "../widgets/ui.dart";

const List<String> _flujo = ["pendiente", "en_camino", "entregado"];

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
        SnackBar(
          content: Text("Estado actualizado a ${etiquetaEstado(proximo)}"),
          backgroundColor: colorPorEstado(proximo),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(provider.mensajeError)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = pedido;
    final color = p != null ? colorPorEstado(p.estado) : Colors.grey;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            expandedHeight: 150,
            backgroundColor: color,
            foregroundColor: Colors.white,
            flexibleSpace: FlexibleSpaceBar(
              title: Text("Pedido #${widget.idPedido}"),
              background: AnimatedContainer(
                duration: const Duration(milliseconds: 400),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [color, Color.lerp(color, Colors.black, 0.28)!],
                  ),
                ),
                alignment: Alignment.center,
                child: p == null
                    ? null
                    : Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Icon(
                          iconoPorEstado(p.estado),
                          color: Colors.white.withValues(alpha: 0.9),
                          size: 44,
                        ),
                      ),
              ),
            ),
          ),
          SliverToBoxAdapter(child: _cuerpo()),
        ],
      ),
    );
  }

  Widget _cuerpo() {
    if (cargando) {
      return const Padding(
        padding: EdgeInsets.only(top: 80),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (error || pedido == null) {
      return Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.redAccent),
            const SizedBox(height: 12),
            const Text("No se pudo cargar el pedido"),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: cargarPedido,
              icon: const Icon(Icons.refresh),
              label: const Text("Reintentar"),
            ),
          ],
        ),
      );
    }

    final p = pedido!;
    final proximo = siguienteEstado(p.estado);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
      child: Column(
        children: [
          EntradaAnimada(
            child: SeccionCard(
              titulo: "SEGUIMIENTO",
              child: _Timeline(estado: p.estado),
            ),
          ),
          const SizedBox(height: 14),
          EntradaAnimada(
            delay: const Duration(milliseconds: 80),
            child: SeccionCard(
              titulo: "DETALLE",
              child: Column(
                children: [
                  _InfoRow(icono: Icons.person_outline, etiqueta: "Cliente", valor: p.cliente),
                  _InfoRow(icono: Icons.place_outlined, etiqueta: "Zona", valor: p.zona),
                  _InfoRow(
                    icono: iconoMetodoPago(p.metodoPago),
                    etiqueta: "Método de pago",
                    valor: etiquetaMetodoPago(p.metodoPago),
                  ),
                  _InfoRow(
                    icono: Icons.pedal_bike,
                    etiqueta: "Repartidor",
                    valor: p.repartidor ?? "Sin asignar",
                  ),
                  _InfoRow(
                    icono: Icons.event_outlined,
                    etiqueta: "Creación",
                    valor: formatoFecha(p.fechaCreacion),
                  ),
                  _InfoRow(
                    icono: Icons.event_available_outlined,
                    etiqueta: "Entrega",
                    valor: p.fechaEntrega != null
                        ? formatoFecha(p.fechaEntrega!)
                        : "Sin entregar",
                    ultimo: true,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 14),
          EntradaAnimada(
            delay: const Duration(milliseconds: 160),
            child: SeccionCard(
              child: Row(
                children: [
                  const Text(
                    "Monto",
                    style: TextStyle(fontSize: 15, color: Colors.black54),
                  ),
                  const Spacer(),
                  Text(
                    formatoMoneda(p.monto),
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 22),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: proximo == null
                ? Container(
                    key: const ValueKey("final"),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: colorPorEstado(p.estado).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        Icon(iconoPorEstado(p.estado), color: colorPorEstado(p.estado)),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            "Este pedido está en un estado final (${etiquetaEstado(p.estado)}).",
                            style: TextStyle(color: colorPorEstado(p.estado)),
                          ),
                        ),
                      ],
                    ),
                  )
                : FilledButton.icon(
                    key: ValueKey("avanzar-$proximo"),
                    onPressed: actualizando ? null : avanzarEstado,
                    icon: actualizando
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.4,
                              color: Colors.white,
                            ),
                          )
                        : Icon(iconoPorEstado(proximo)),
                    label: Text(
                      actualizando ? "Actualizando..." : "Avanzar a ${etiquetaEstado(proximo)}",
                    ),
                    style: FilledButton.styleFrom(
                      backgroundColor: colorPorEstado(proximo),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

class _Timeline extends StatelessWidget {
  final String estado;

  const _Timeline({required this.estado});

  @override
  Widget build(BuildContext context) {
    final cancelado = estado == "cancelado";
    final indiceActual = _flujo.indexOf(estado);

    return Row(
      children: List.generate(_flujo.length * 2 - 1, (i) {
        if (i.isOdd) {
          final antes = (i - 1) ~/ 2;
          final hecho = !cancelado && antes < indiceActual;
          return Expanded(
            child: Container(
              height: 3,
              margin: const EdgeInsets.symmetric(horizontal: 4),
              color: hecho ? colorPorEstado("entregado") : Colors.black12,
            ),
          );
        }

        final paso = i ~/ 2;
        final estadoPaso = _flujo[paso];
        final activo = !cancelado && paso <= indiceActual;
        final color = activo ? colorPorEstado(estadoPaso) : Colors.black26;

        return Column(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 350),
              height: 34,
              width: 34,
              decoration: BoxDecoration(
                color: activo ? color.withValues(alpha: 0.15) : Colors.black.withValues(alpha: 0.04),
                shape: BoxShape.circle,
                border: Border.all(color: color, width: 2),
              ),
              child: Icon(iconoPorEstado(estadoPaso), size: 17, color: color),
            ),
            const SizedBox(height: 6),
            Text(
              etiquetaEstado(estadoPaso),
              style: TextStyle(
                fontSize: 11,
                fontWeight: activo ? FontWeight.w700 : FontWeight.w500,
                color: color,
              ),
            ),
          ],
        );
      }),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icono;
  final String etiqueta;
  final String valor;
  final bool ultimo;

  const _InfoRow({
    required this.icono,
    required this.etiqueta,
    required this.valor,
    this.ultimo = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Row(
            children: [
              Icon(icono, size: 20, color: Colors.black45),
              const SizedBox(width: 14),
              Text(
                etiqueta,
                style: const TextStyle(color: Colors.black54, fontSize: 14),
              ),
              const Spacer(),
              Flexible(
                child: Text(
                  valor,
                  textAlign: TextAlign.right,
                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                ),
              ),
            ],
          ),
        ),
        if (!ultimo) const Divider(height: 1),
      ],
    );
  }
}
