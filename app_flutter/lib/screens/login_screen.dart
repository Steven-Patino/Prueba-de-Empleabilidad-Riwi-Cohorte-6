import "package:flutter/material.dart";
import "package:provider/provider.dart";

import "../state/auth_provider.dart";
import "../state/pedidos_provider.dart";

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final formKey = GlobalKey<FormState>();
  final usuarioController = TextEditingController();
  final apiKeyController = TextEditingController();

  @override
  void dispose() {
    usuarioController.dispose();
    apiKeyController.dispose();
    super.dispose();
  }

  void ingresar() {
    if (!formKey.currentState!.validate()) return;

    context.read<AuthProvider>().login(
          usuarioController.text,
          apiKeyController.text,
        );
    context.read<PedidosProvider>().cargarPedidos();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("EcoDelivery")),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                "Iniciar sesion",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: usuarioController,
                decoration: const InputDecoration(labelText: "Usuario"),
                validator: (valor) {
                  if (valor == null || valor.trim().isEmpty) {
                    return "El usuario es obligatorio";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: apiKeyController,
                decoration: const InputDecoration(
                  labelText: "API key (opcional)",
                ),
                obscureText: true,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: ingresar,
                child: const Text("Ingresar"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
