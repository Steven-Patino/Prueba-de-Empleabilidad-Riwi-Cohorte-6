import "package:flutter/material.dart";
import "package:provider/provider.dart";

import "screens/pedidos_list_screen.dart";
import "state/pedidos_provider.dart";

void main() {
  runApp(const EcoDeliveryApp());
}

class EcoDeliveryApp extends StatelessWidget {
  const EcoDeliveryApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => PedidosProvider()..cargarPedidos(),
      child: MaterialApp(
        title: "EcoDelivery",
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
          useMaterial3: true,
        ),
        home: const PedidosListScreen(),
      ),
    );
  }
}
