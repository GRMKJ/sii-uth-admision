import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiConfig {
  static const String baseUrl = 'https://127.0.0.1:8000/api'; // Ajusta tu dominio
  static Map<String, String> headers = {
    'Content-Type': 'application/json',
    // Agrega tokens si es necesario después de login
  };
}

class AspirantesService {
  static Future<List<dynamic>> fetchAspirantes() async {
    final url = Uri.parse('${ApiConfig.baseUrl}/aspirantes');
    final response = await http.get(url, headers: ApiConfig.headers);

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Error al cargar aspirantes');
    }
  }
}