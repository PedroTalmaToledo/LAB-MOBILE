import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class RotaService {
  static const String baseUrl = 'http://10.0.2.2:8080/pedidos/rota'; // ajuste se necessário

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  Future<Map<String, dynamic>?> calcularRota({
    required double origemLat,
    required double origemLon,
    required double destinoLat,
    required double destinoLon,
  }) async {
    final token = await _getToken();
    final response = await http.get(
      Uri.parse('$baseUrl?origem=$origemLat,$origemLon&destino=$destinoLat,$destinoLon'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      print('Erro ao calcular rota: ${response.body}');
      return null;
    }
  }
}
