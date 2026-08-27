import "package:flutter/material.dart";
import "package:provider/provider.dart";

import "screens/login_screen.dart";
import "screens/pedidos_list_screen.dart";
import "state/auth_provider.dart";
import "state/pedidos_provider.dart";

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
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
          useMaterial3: true,
        ),
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
    if (auth.isLoggedIn) {
      return const PedidosListScreen();
    }
    return const LoginScreen();
  }
}
