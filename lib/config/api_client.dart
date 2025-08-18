import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiClient {
  static const String baseUrl = 'http://127.0.0.1:8000/api/v1'; // TODO: cambia a tu URL

  static Future<Map<String, dynamic>> postJson(
    String path, {
    Map<String, dynamic>? body,
    String? token,
  }) async {
    final uri = Uri.parse('$baseUrl$path');

    final headers = <String, String>{
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };

    final res = await http
        .post(uri, headers: headers, body: jsonEncode(body ?? {}))
        .timeout(const Duration(seconds: 15));

    if (res.statusCode >= 200 && res.statusCode < 300) {
      return jsonDecode(res.body.isEmpty ? '{}' : res.body) as Map<String, dynamic>;
    }

    try {
      final payload = jsonDecode(res.body) as Map<String, dynamic>;
      final msg = payload['message'] ?? payload['error'] ?? 'Error ${res.statusCode}';
      throw Exception(msg);
    } catch (_) {
      throw Exception('Error ${res.statusCode}: ${res.body}');
    }
  }

  /// 🔹 Nuevo método GET
static Future<Map<String, dynamic>> getJson(
  String path, {
  String? token,
}) async {
  final uri = Uri.parse('$baseUrl$path');

  final headers = <String, String>{
    'Content-Type': 'application/json',
    if (token != null) 'Authorization': 'Bearer $token',
  };

  final res = await http
      .get(uri, headers: headers)
      .timeout(const Duration(seconds: 15));

  if (res.statusCode >= 200 && res.statusCode < 300) {
    return jsonDecode(res.body.isEmpty ? '{}' : res.body) as Map<String, dynamic>;
  }

  try {
    final payload = jsonDecode(res.body) as Map<String, dynamic>;
    final msg = payload['message'] ?? payload['error'] ?? 'Error ${res.statusCode}';
    throw Exception(msg);
  } catch (_) {
    throw Exception('Error ${res.statusCode}: ${res.body}');
  }
}

}
