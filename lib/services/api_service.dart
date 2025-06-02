import 'package:http/http.dart' as http;
import 'dart:convert';

class ApiService {
  final String baseUrl;

  ApiService(this.baseUrl);

  // solicitud GET
  Future<dynamic> get(String endpoint) async {
    final response = await http.get(Uri.parse('$baseUrl/$endpoint'));

    if (response.statusCode == 200) {
      return jsonDecode(response.body); // Decodifica la respuesta JSON
    } else {
      throw Exception('Error al cargar los datos: ${response.statusCode}');
    }
  }

  // solicitud POST
  Future<dynamic> post(String endpoint, Map<String, dynamic> body) async {
    final response = await http.post(
      Uri.parse('$baseUrl/$endpoint'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Error al enviar los datos: ${response.statusCode}');
    }
  }
}