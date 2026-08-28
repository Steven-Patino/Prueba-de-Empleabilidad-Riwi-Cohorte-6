import "package:flutter/material.dart";
import "package:provider/provider.dart";

import "../state/auth_provider.dart";
import "../state/pedidos_provider.dart";
import "../theme.dart";

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final formKey = GlobalKey<FormState>();
  final usuarioController = TextEditingController();
  final apiKeyController = TextEditingController();

  bool entrando = false;

  @override
  void dispose() {
    usuarioController.dispose();
    apiKeyController.dispose();
    super.dispose();
  }

  Future<void> ingresar() async {
    if (!formKey.currentState!.validate()) return;

    setState(() => entrando = true);
    await Future.delayed(const Duration(milliseconds: 350));
    if (!mounted) return;

    context.read<AuthProvider>().login(
          usuarioController.text,
          apiKeyController.text,
        );
    context.read<PedidosProvider>().cargarPedidos();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [verdeEco, Color(0xFF1B4332)],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const _LogoAnimado(),
                  const SizedBox(height: 20),
                  const Text(
                    "EcoDelivery",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 30,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    "Domicilios ecológicos",
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.75),
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 32),
                  _TarjetaFormulario(
                    formKey: formKey,
                    usuarioController: usuarioController,
                    apiKeyController: apiKeyController,
                    entrando: entrando,
                    onIngresar: ingresar,
                  ),
                  const SizedBox(height: 20),
                  Text(
                    "EcoDelivery S.A.S.",
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.6),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _LogoAnimado extends StatefulWidget {
  const _LogoAnimado();

  @override
  State<_LogoAnimado> createState() => _LogoAnimadoState();
}

class _LogoAnimadoState extends State<_LogoAnimado>
    with SingleTickerProviderStateMixin {
  late final AnimationController controlador = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  )..forward();

  @override
  void dispose() {
    controlador.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final escala = CurvedAnimation(parent: controlador, curve: Curves.elasticOut);
    return ScaleTransition(
      scale: escala,
      child: Container(
        height: 96,
        width: 96,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.15),
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white.withValues(alpha: 0.3), width: 2),
        ),
        child: const Icon(Icons.eco, color: Colors.white, size: 48),
      ),
    );
  }
}

class _TarjetaFormulario extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController usuarioController;
  final TextEditingController apiKeyController;
  final bool entrando;
  final Future<void> Function() onIngresar;

  const _TarjetaFormulario({
    required this.formKey,
    required this.usuarioController,
    required this.apiKeyController,
    required this.entrando,
    required this.onIngresar,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeOutCubic,
      builder: (context, valor, child) {
        return Opacity(
          opacity: valor,
          child: Transform.translate(offset: Offset(0, 24 * (1 - valor)), child: child),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.15),
              blurRadius: 30,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Iniciar sesión",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: usuarioController,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(
                  labelText: "Usuario",
                  prefixIcon: Icon(Icons.person_outline),
                ),
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
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: "API key (opcional)",
                  prefixIcon: Icon(Icons.key_outlined),
                ),
              ),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: entrando ? null : onIngresar,
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 250),
                  child: entrando
                      ? const SizedBox(
                          key: ValueKey("cargando"),
                          height: 22,
                          width: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.4,
                            color: Colors.white,
                          ),
                        )
                      : const Row(
                          key: ValueKey("texto"),
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text("Ingresar"),
                            SizedBox(width: 8),
                            Icon(Icons.arrow_forward, size: 20),
                          ],
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
