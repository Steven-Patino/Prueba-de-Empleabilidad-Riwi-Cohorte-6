import "dart:convert";

import "package:http/http.dart" as http;

import "../config.dart";
import "../models/pedido.dart";

class ApiService {
  final String baseUrl = Config.apiBaseUrl;

  Map<String, String> _headers() {
    final headers = {"Content-Type": "application/json"};
    if (Config.apiKey.isNotEmpty) {
      headers["X-API-Key"] = Config.apiKey;
    }
    return headers;
  }

  Future<List<Pedido>> getPedidos({String? estado, String? zona}) async {
    final params = <String, String>{};
    if (estado != null) params["estado"] = estado;
    if (zona != null) params["zona"] = zona;

    var uri = Uri.parse("$baseUrl/pedidos");
    if (params.isNotEmpty) {
      uri = uri.replace(queryParameters: params);
    }
    final respuesta = await http.get(uri, headers: _headers());

    if (respuesta.statusCode != 200) {
      throw Exception("Error al cargar pedidos (${respuesta.statusCode})");
    }

    final List<dynamic> lista = jsonDecode(respuesta.body);
    return lista.map((item) => Pedido.fromJson(item)).toList();
  }

  Future<Pedido> getPedido(int id) async {
    final uri = Uri.parse("$baseUrl/pedidos/$id");
    final respuesta = await http.get(uri, headers: _headers());

    if (respuesta.statusCode != 200) {
      throw Exception("Error al cargar el pedido (${respuesta.statusCode})");
    }

    return Pedido.fromJson(jsonDecode(respuesta.body));
  }

  Future<Pedido> crearPedido({
    required String cliente,
    required String zona,
    required String metodoPago,
    required double monto,
  }) async {
    final uri = Uri.parse("$baseUrl/pedidos");
    final cuerpo = jsonEncode({
      "cliente": cliente,
      "zona": zona,
      "metodo_pago": metodoPago,
      "monto": monto,
    });

    final respuesta = await http.post(uri, headers: _headers(), body: cuerpo);

    if (respuesta.statusCode != 201) {
      throw Exception("No se pudo crear el pedido (${respuesta.statusCode})");
    }

    return Pedido.fromJson(jsonDecode(respuesta.body));
  }

  Future<Pedido> actualizarEstado(int id, String nuevoEstado) async {
    final uri = Uri.parse("$baseUrl/pedidos/$id/estado");
    final cuerpo = jsonEncode({"estado": nuevoEstado});

    final respuesta = await http.patch(uri, headers: _headers(), body: cuerpo);

    if (respuesta.statusCode != 200) {
      throw Exception("No se pudo actualizar el estado (${respuesta.statusCode})");
    }

    return Pedido.fromJson(jsonDecode(respuesta.body));
  }
}
