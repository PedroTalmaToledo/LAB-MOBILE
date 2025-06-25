import 'dart:convert';
import 'dart:ffi';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../models/pedido.dart';

class DeliveryService {
  static const String baseUrl = 'http://10.0.2.2:8080/pedidos';
  static const String rotaUrl = 'http://10.0.2.2:5001/rota'; // ajuste conforme o serviço real

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    print('[TOKEN] Usando token: $token');
    return token;
  }

  Future<List<Pedido>> listarPedidos() async {
    final token = await _getToken();
    final response = await http.get(
      Uri.parse(baseUrl),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    print('[GET] Status code: ${response.statusCode}');
    print('[GET] Response body: ${response.body}');

    if (response.statusCode == 200) {
      final List<dynamic> body = jsonDecode(response.body);
      return body.map((json) => Pedido.fromJson(json)).toList();
    } else if (response.statusCode == 401) {
      throw Exception('Token inválido ou expirado.');
    } else {
      throw Exception('Erro ao listar pedidos: ${response.body}');
    }
  }

  Future<bool> criarPedido(Pedido pedido) async {
    final token = await _getToken();
    final body = jsonEncode(pedido.toJson());

    print('[POST] Criando pedido com body: $body');

    final response = await http.post(
      Uri.parse(baseUrl),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: body,
    );

    print('[POST] Status code: ${response.statusCode}');
    print('[POST] Response body: ${response.body}');

    if (response.statusCode == 401) {
      print('Token inválido ou expirado.');
      return false;
    }

    return response.statusCode == 200 || response.statusCode == 201;
  }

  Future<bool> atualizarStatus(int id, String status) async {
    final token = await _getToken();
    final url = '$baseUrl/$id/status?status=$status';

    print('[PUT] Atualizando status para $status no pedido $id');

    final response = await http.put(
      Uri.parse(url),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    print('[PUT] Status code: ${response.statusCode}');
    print('[PUT] Response body: ${response.body}');

    if (response.statusCode == 401) {
      print('Token inválido ou expirado.');
      return false;
    }

    return response.statusCode == 200;
  }

  /// 🚚 NOVO MÉTODO: Obter rota otimizada do microserviço
  Future<List<LatLng>> obterRota(String origem, String destino, int idPedido) async {
    final token = await _getToken();
    final String rotaUrl = 'http://10.0.2.2:8080/pedidos/$idPedido/rota';
    final url = Uri.parse(rotaUrl);

    print('[GET] Buscando rota de $origem para $destino');

    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List pontos = data['rota'];
      return pontos.map<LatLng>((p) => LatLng(p['lat'], p['lng'])).toList();
    } else {
      print('Erro ao buscar rota: ${response.statusCode}');
      return [];
    }
  }
}
