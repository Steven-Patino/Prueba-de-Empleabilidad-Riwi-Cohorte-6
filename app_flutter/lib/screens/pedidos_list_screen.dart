import "package:flutter/material.dart";
import "package:provider/provider.dart";

import "../estado_helpers.dart";
import "../models/pedido.dart";
import "../state/auth_provider.dart";
import "../state/pedidos_provider.dart";
import "../theme.dart";
import "../widgets/ui.dart";
import "crear_pedido_screen.dart";
import "pedido_detail_screen.dart";

class PedidosListScreen extends StatelessWidget {
  const PedidosListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<PedidosProvider>();
    final usuario = context.watch<AuthProvider>().usuario;

    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const CrearPedidoScreen()),
          );
        },
        icon: const Icon(Icons.add),
        label: const Text("Nuevo pedido"),
      ),
      body: RefreshIndicator(
        onRefresh: provider.cargarPedidos,
        child: CustomScrollView(
          slivers: [
            _Encabezado(usuario: usuario, pedidos: provider.pedidos),
            SliverToBoxAdapter(child: _Filtros(provider: provider)),
            _Contenido(provider: provider),
            const SliverToBoxAdapter(child: SizedBox(height: 90)),
          ],
        ),
      ),
    );
  }
}

class _Encabezado extends StatelessWidget {
  final String usuario;
  final List<Pedido> pedidos;

  const _Encabezado({required this.usuario, required this.pedidos});

  @override
  Widget build(BuildContext context) {
    final entregados = pedidos.where((p) => p.estado == "entregado").length;
    final enCamino = pedidos.where((p) => p.estado == "en_camino").length;

    return SliverAppBar(
      pinned: true,
      expandedHeight: 214,
      backgroundColor: verdeEco,
      foregroundColor: Colors.white,
      title: const Text(
        "Pedidos",
        style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.logout),
          tooltip: "Cerrar sesión",
          onPressed: () => context.read<AuthProvider>().logout(),
        ),
        const SizedBox(width: 4),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [verdeEco, Color(0xFF1B4332)],
            ),
          ),
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 54),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                "Hola, $usuario",
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 34,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    ChipDato(icono: Icons.receipt_long, texto: "${pedidos.length} pedidos"),
                    const SizedBox(width: 8),
                    ChipDato(icono: Icons.check_circle, texto: "$entregados entregados"),
                    const SizedBox(width: 8),
                    ChipDato(icono: Icons.pedal_bike, texto: "$enCamino en camino"),
                  ],
                ),
              ),
            ],
          ),
        ),
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
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _FilaChips(
            etiqueta: "Estado",
            opciones: const [null, ...estadosDisponibles],
            seleccion: provider.filtroEstado,
            textoDe: (valor) => valor == null ? "Todos" : etiquetaEstado(valor),
            colorDe: (valor) => valor == null ? verdeEco : colorPorEstado(valor),
            onSeleccion: provider.cambiarFiltroEstado,
          ),
          const SizedBox(height: 10),
          _FilaChips(
            etiqueta: "Zona",
            opciones: const [null, ...zonasDisponibles],
            seleccion: provider.filtroZona,
            textoDe: (valor) => valor ?? "Todas",
            colorDe: (_) => verdeEco,
            onSeleccion: provider.cambiarFiltroZona,
          ),
        ],
      ),
    );
  }
}

class _FilaChips extends StatelessWidget {
  final String etiqueta;
  final List<String?> opciones;
  final String? seleccion;
  final String Function(String?) textoDe;
  final Color Function(String?) colorDe;
  final void Function(String?) onSeleccion;

  const _FilaChips({
    required this.etiqueta,
    required this.opciones,
    required this.seleccion,
    required this.textoDe,
    required this.colorDe,
    required this.onSeleccion,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 6),
          child: Text(
            etiqueta,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: Colors.black54,
              letterSpacing: 0.3,
            ),
          ),
        ),
        SizedBox(
          height: 38,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: opciones.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              final valor = opciones[index];
              final activo = valor == seleccion;
              final color = colorDe(valor);
              return GestureDetector(
                onTap: () => onSeleccion(valor),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 220),
                  curve: Curves.easeOut,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: activo ? color : Colors.white,
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(
                      color: activo ? color : color.withValues(alpha: 0.25),
                    ),
                  ),
                  child: Text(
                    textoDe(valor),
                    style: TextStyle(
                      color: activo ? Colors.white : color,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _Contenido extends StatelessWidget {
  final PedidosProvider provider;

  const _Contenido({required this.provider});

  @override
  Widget build(BuildContext context) {
    if (provider.estadoVista == ViewState.loading) {
      return SliverList.builder(
        itemCount: 6,
        itemBuilder: (_, __) => const Padding(
          padding: EdgeInsets.fromLTRB(16, 8, 16, 0),
          child: _SkeletonCard(),
        ),
      );
    }

    if (provider.estadoVista == ViewState.error) {
      return SliverFillRemaining(
        hasScrollBody: false,
        child: _EstadoMensaje(
          icono: Icons.wifi_off,
          color: colorPorEstado("cancelado"),
          titulo: "No se pudieron cargar los pedidos",
          detalle: provider.mensajeError,
          textoBoton: "Reintentar",
          iconoBoton: Icons.refresh,
          onBoton: provider.cargarPedidos,
        ),
      );
    }

    if (provider.pedidos.isEmpty) {
      return SliverFillRemaining(
        hasScrollBody: false,
        child: _EstadoMensaje(
          icono: Icons.inbox_outlined,
          color: verdeEco,
          titulo: "No hay pedidos",
          detalle: "Crea el primero con el botón de abajo.",
          textoBoton: "Nuevo pedido",
          iconoBoton: Icons.add,
          onBoton: () => Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const CrearPedidoScreen()),
          ),
        ),
      );
    }

    return SliverList.builder(
      itemCount: provider.pedidos.length,
      itemBuilder: (context, index) {
        final pedido = provider.pedidos[index];
        return EntradaAnimada(
          delay: Duration(milliseconds: 30 * (index % 12)),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: _PedidoCard(pedido: pedido),
          ),
        );
      },
    );
  }
}

class _PedidoCard extends StatelessWidget {
  final Pedido pedido;

  const _PedidoCard({required this.pedido});

  @override
  Widget build(BuildContext context) {
    final color = colorPorEstado(pedido.estado);
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => PedidoDetailScreen(idPedido: pedido.idPedido),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Container(
                height: 48,
                width: 48,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(iconoPorEstado(pedido.estado), color: color),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      pedido.cliente,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.place_outlined, size: 14, color: Colors.black45),
                        const SizedBox(width: 3),
                        Text(
                          pedido.zona,
                          style: const TextStyle(fontSize: 13, color: Colors.black54),
                        ),
                        const Text("  ·  ", style: TextStyle(color: Colors.black26)),
                        Flexible(
                          child: Text(
                            "#${pedido.idPedido}",
                            style: const TextStyle(fontSize: 13, color: Colors.black45),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    formatoMoneda(pedido.monto),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 6),
                  EstadoPill(
                    estado: pedido.estado,
                    heroTag: "estado-${pedido.idPedido}",
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Pulso extends StatefulWidget {
  final Widget child;

  const _Pulso({required this.child});

  @override
  State<_Pulso> createState() => _PulsoState();
}

class _PulsoState extends State<_Pulso> with SingleTickerProviderStateMixin {
  late final AnimationController controlador = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  )..repeat(reverse: true);

  @override
  void dispose() {
    controlador.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: Tween<double>(begin: 0.45, end: 1).animate(controlador),
      child: widget.child,
    );
  }
}

class _SkeletonCard extends StatelessWidget {
  const _SkeletonCard();

  Widget _caja(double alto, double ancho) {
    return Container(
      height: alto,
      width: ancho,
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: _Pulso(
          child: Row(
            children: [
              Container(
                height: 48,
                width: 48,
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _caja(14, 160),
                    const SizedBox(height: 8),
                    _caja(11, 100),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  _caja(14, 70),
                  const SizedBox(height: 8),
                  _caja(22, 90),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EstadoMensaje extends StatelessWidget {
  final IconData icono;
  final Color color;
  final String titulo;
  final String detalle;
  final String textoBoton;
  final IconData iconoBoton;
  final VoidCallback onBoton;

  const _EstadoMensaje({
    required this.icono,
    required this.color,
    required this.titulo,
    required this.detalle,
    required this.textoBoton,
    required this.iconoBoton,
    required this.onBoton,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              height: 96,
              width: 96,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(icono, size: 44, color: color),
            ),
            const SizedBox(height: 20),
            Text(
              titulo,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            Text(
              detalle,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.black54, fontSize: 13),
            ),
            const SizedBox(height: 22),
            FilledButton.icon(
              onPressed: onBoton,
              icon: Icon(iconoBoton),
              label: Text(textoBoton),
              style: FilledButton.styleFrom(minimumSize: const Size(200, 48)),
            ),
          ],
        ),
      ),
    );
  }
}
