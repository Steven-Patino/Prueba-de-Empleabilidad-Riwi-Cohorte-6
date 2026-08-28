import "package:flutter/material.dart";
import "package:provider/provider.dart";

import "screens/login_screen.dart";
import "screens/pedidos_list_screen.dart";
import "state/auth_provider.dart";
import "state/pedidos_provider.dart";
import "theme.dart";

void main() {
  runApp(const EcoDeliveryApp());
}

class EcoDeliveryApp extends StatelessWidget {
  const EcoDeliveryApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => PedidosProvider()),
      ],
      child: MaterialApp(
        title: "EcoDelivery",
        debugShowCheckedModeBanner: false,
        theme: construirTema(),
        home: const RootScreen(),
      ),
    );
  }
}

class RootScreen extends StatelessWidget {
  const RootScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 450),
      switchInCurve: Curves.easeOutCubic,
      switchOutCurve: Curves.easeIn,
      transitionBuilder: (child, animation) {
        return FadeTransition(
          opacity: animation,
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.97, end: 1).animate(animation),
            child: child,
          ),
        );
      },
      child: auth.isLoggedIn
          ? const PedidosListScreen(key: ValueKey("lista"))
          : const LoginScreen(key: ValueKey("login")),
    );
  }
}
