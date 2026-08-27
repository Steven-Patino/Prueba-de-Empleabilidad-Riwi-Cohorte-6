import "package:flutter/material.dart";
import "package:provider/provider.dart";

import "../estado_helpers.dart";
import "../state/pedidos_provider.dart";

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
      appBar: AppBar(title: const Text("Crear pedido")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: clienteController,
                decoration: const InputDecoration(labelText: "Cliente"),
                validator: (valor) {
                  if (valor == null || valor.trim().isEmpty) {
                    return "El cliente es obligatorio";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: zonaSeleccionada,
                decoration: const InputDecoration(labelText: "Zona"),
                items: zonasDisponibles
                    .map((z) => DropdownMenuItem(value: z, child: Text(z)))
                    .toList(),
                onChanged: (valor) {
                  setState(() => zonaSeleccionada = valor!);
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: metodoPagoSeleccionado,
                decoration: const InputDecoration(labelText: "Metodo de pago"),
                items: metodosPagoDisponibles
                    .map((m) => DropdownMenuItem(value: m, child: Text(m)))
                    .toList(),
                onChanged: (valor) {
                  setState(() => metodoPagoSeleccionado = valor!);
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: montoController,
                decoration: const InputDecoration(labelText: "Monto"),
                keyboardType: TextInputType.number,
                validator: (valor) {
                  if (valor == null || valor.trim().isEmpty) {
                    return "El monto es obligatorio";
                  }
                  final numero = double.tryParse(valor);
                  if (numero == null) {
                    return "El monto debe ser un numero";
                  }
                  if (numero <= 0) {
                    return "El monto debe ser mayor a 0";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: guardando ? null : guardar,
                child: guardando
                    ? const SizedBox(
                        height: 18,
                        width: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text("Guardar pedido"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
