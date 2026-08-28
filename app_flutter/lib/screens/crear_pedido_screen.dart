import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:provider/provider.dart";

import "../estado_helpers.dart";
import "../state/pedidos_provider.dart";
import "../theme.dart";
import "../widgets/ui.dart";

class CrearPedidoScreen extends StatefulWidget {
  const CrearPedidoScreen({super.key});

  @override
  State<CrearPedidoScreen> createState() => _CrearPedidoScreenState();
}

class _CrearPedidoScreenState extends State<CrearPedidoScreen> {
  final formKey = GlobalKey<FormState>();
  final clienteController = TextEditingController();
  final montoController = TextEditingController();

  String zonaSeleccionada = zonasDisponibles.first;
  String metodoPagoSeleccionado = metodosPagoDisponibles.first;
  bool guardando = false;

  @override
  void dispose() {
    clienteController.dispose();
    montoController.dispose();
    super.dispose();
  }

  Future<void> guardar() async {
    if (!formKey.currentState!.validate()) return;

    setState(() => guardando = true);

    final provider = context.read<PedidosProvider>();
    final creado = await provider.crearPedido(
      cliente: clienteController.text.trim(),
      zona: zonaSeleccionada,
      metodoPago: metodoPagoSeleccionado,
      monto: double.parse(montoController.text),
    );

    setState(() => guardando = false);
    if (!mounted) return;

    if (creado) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Pedido creado"),
          backgroundColor: verdeEco,
        ),
      );
      Navigator.of(context).pop();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(provider.mensajeError)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Nuevo pedido"),
        backgroundColor: verdeEco,
        foregroundColor: Colors.white,
      ),
      body: Form(
        key: formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            EntradaAnimada(
              child: SeccionCard(
                titulo: "CLIENTE",
                child: TextFormField(
                  controller: clienteController,
                  textCapitalization: TextCapitalization.words,
                  decoration: const InputDecoration(
                    labelText: "Nombre del cliente",
                    prefixIcon: Icon(Icons.person_outline),
                  ),
                  validator: (valor) {
                    if (valor == null || valor.trim().isEmpty) {
                      return "El cliente es obligatorio";
                    }
                    return null;
                  },
                ),
              ),
            ),
            const SizedBox(height: 14),
            EntradaAnimada(
              delay: const Duration(milliseconds: 70),
              child: SeccionCard(
                titulo: "ZONA",
                child: _SelectorChips(
                  opciones: zonasDisponibles,
                  seleccion: zonaSeleccionada,
                  iconoDe: (_) => Icons.place_outlined,
                  etiquetaDe: (z) => z,
                  onSeleccion: (z) => setState(() => zonaSeleccionada = z),
                ),
              ),
            ),
            const SizedBox(height: 14),
            EntradaAnimada(
              delay: const Duration(milliseconds: 140),
              child: SeccionCard(
                titulo: "MÉTODO DE PAGO",
                child: _SelectorChips(
                  opciones: metodosPagoDisponibles,
                  seleccion: metodoPagoSeleccionado,
                  iconoDe: iconoMetodoPago,
                  etiquetaDe: etiquetaMetodoPago,
                  onSeleccion: (m) => setState(() => metodoPagoSeleccionado = m),
                ),
              ),
            ),
            const SizedBox(height: 14),
            EntradaAnimada(
              delay: const Duration(milliseconds: 210),
              child: SeccionCard(
                titulo: "MONTO",
                child: TextFormField(
                  controller: montoController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r"[0-9.]")),
                  ],
                  decoration: const InputDecoration(
                    labelText: "Valor del pedido",
                    prefixText: "\$ ",
                    prefixIcon: Icon(Icons.attach_money),
                  ),
                  validator: (valor) {
                    if (valor == null || valor.trim().isEmpty) {
                      return "El monto es obligatorio";
                    }
                    final numero = double.tryParse(valor);
                    if (numero == null) return "El monto debe ser un número";
                    if (numero <= 0) return "El monto debe ser mayor a 0";
                    return null;
                  },
                ),
              ),
            ),
            const SizedBox(height: 26),
            EntradaAnimada(
              delay: const Duration(milliseconds: 280),
              child: FilledButton.icon(
                onPressed: guardando ? null : guardar,
                icon: guardando
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.4,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.check),
                label: Text(guardando ? "Guardando..." : "Guardar pedido"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SelectorChips extends StatelessWidget {
  final List<String> opciones;
  final String seleccion;
  final IconData Function(String) iconoDe;
  final String Function(String) etiquetaDe;
  final void Function(String) onSeleccion;

  const _SelectorChips({
    required this.opciones,
    required this.seleccion,
    required this.iconoDe,
    required this.etiquetaDe,
    required this.onSeleccion,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: opciones.map((opcion) {
        final activo = opcion == seleccion;
        return GestureDetector(
          onTap: () => onSeleccion(opcion),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOut,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: activo ? verdeEco : Colors.white,
              borderRadius: BorderRadius.circular(999),
              border: Border.all(
                color: activo ? verdeEco : verdeEco.withValues(alpha: 0.25),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  iconoDe(opcion),
                  size: 16,
                  color: activo ? Colors.white : verdeEco,
                ),
                const SizedBox(width: 6),
                Text(
                  etiquetaDe(opcion),
                  style: TextStyle(
                    color: activo ? Colors.white : verdeEco,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}
