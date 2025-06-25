import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class TrackingService {
  static const String baseUrl = 'https://tracking-service-818291685347.southamerica-east1.run.app/rastreamento';

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  Future<bool> enviarLocalizacao({
    required String deliveryId,
    required String driverId,
    required double latitude,
    required double longitude,
  }) async {
    final token = await _getToken();
    final response = await http.post(
      Uri.parse('$baseUrl/$deliveryId/locations'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'driverId': driverId,
        'latitude': latitude,
        'longitude': longitude,
        'timestamp': DateTime.now().toIso8601String(),
      }),
    );

    if (response.statusCode != 201) {
      print('[ERRO rastreamento]');
      print('Status code: ${response.statusCode}');
      print('Body: ${response.body}');
    }

    return response.statusCode == 201;
  }

  Future<Map<String, dynamic>?> buscarUltimaLocalizacao(String deliveryId) async {
    final token = await _getToken();
    final response = await http.get(
      Uri.parse('$baseUrl/$deliveryId/locations/latest'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      print('Erro ao buscar localização: ${response.body}');
      return null;
    }
  }
}
