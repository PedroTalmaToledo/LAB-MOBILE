import 'dart:convert';
import 'package:http/http.dart' as http;

class SincronizacaoService {
  final String baseUrl;

  SincronizacaoService(this.baseUrl);

  // Envia uma nova entrega para o backend
  Future<bool> enviarEntrega(Map<String, dynamic> entrega) async {
    final url = Uri.parse('$baseUrl/entregas');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(entrega),
    );
    return response.statusCode == 201;
  }

  // Busca todas as entregas do backend
  Future<List<Map<String, dynamic>>> buscarEntregas() async {
    final url = Uri.parse('$baseUrl/entregas');
    final response = await http.get(url);
    if (response.statusCode == 200) {
      List<dynamic> data = jsonDecode(response.body);
      return List<Map<String, dynamic>>.from(data);
    } else {
      return [];
    }
  }
}
