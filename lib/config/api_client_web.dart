import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiClient {
  static const String baseUrl = 'http://127.0.0.1:8000/api/v1';

  // Browser-friendly client (no dart:io)
  static final http.Client _secureClient = http.Client();

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

    try {
      final res = await _secureClient
          .post(uri, headers: headers, body: jsonEncode(body ?? {}))
          .timeout(const Duration(seconds: 15));

      if (res.statusCode >= 200 && res.statusCode < 300) {
        return jsonDecode(res.body.isEmpty ? '{}' : res.body)
            as Map<String, dynamic>;
      }

      final payload = jsonDecode(res.body) as Map<String, dynamic>;
      final msg = payload['message'] ?? payload['error'] ?? 'Error ${res.statusCode}';
      throw Exception(msg);
    } on http.ClientException catch (e) {
      throw Exception('Error de red: ${e.message}');
    } catch (e) {
      throw Exception('Error al conectar: $e');
    }
  }

  static Future<Map<String, dynamic>> getJson(
    String path, {
    String? token,
  }) async {
    final uri = Uri.parse('$baseUrl$path');

    final headers = <String, String>{
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };

    try {
      final res = await _secureClient
          .get(uri, headers: headers)
          .timeout(const Duration(seconds: 15));

      if (res.statusCode >= 200 && res.statusCode < 300) {
        return jsonDecode(res.body.isEmpty ? '{}' : res.body)
            as Map<String, dynamic>;
      }

      final payload = jsonDecode(res.body) as Map<String, dynamic>;
      final msg = payload['message'] ?? payload['error'] ?? 'Error ${res.statusCode}';
      throw Exception(msg);
    } on http.ClientException catch (e) {
      throw Exception('Error de red: ${e.message}');
    } catch (e) {
      throw Exception('Error al conectar: $e');
    }
  }

  // 🔹 POST multipart (subida de archivo) para Web
  static Future<Map<String, dynamic>> postMultipart(
    String path, {
    required String fileField,
    String? filePath,
    List<int>? fileBytes,
    String? fileName,
    Map<String, String>? fields,
    String? token,
  }) async {
    final uri = Uri.parse('$baseUrl$path');
    final request = http.MultipartRequest('POST', uri);
    if (fields != null) {
      request.fields.addAll(fields);
    }
    if (token != null) {
      request.headers['Authorization'] = 'Bearer $token';
    }
    if (fileBytes != null) {
      request.files.add(http.MultipartFile.fromBytes(
        fileField,
        fileBytes,
        filename: fileName ?? 'upload.bin',
      ));
    } else if (filePath != null) {
      // fromPath is not supported on web (no filesystem access).
      throw Exception('postMultipart en web requiere fileBytes');
    } else {
      throw Exception('postMultipart requiere fileBytes o filePath');
    }

    try {
      final streamed = await _secureClient.send(request);
      final res = await http.Response.fromStream(streamed);

      if (res.statusCode >= 200 && res.statusCode < 300) {
        return jsonDecode(res.body.isEmpty ? '{}' : res.body)
            as Map<String, dynamic>;
      }

      final payload = jsonDecode(res.body) as Map<String, dynamic>;
      final msg = payload['message'] ?? payload['error'] ?? 'Error ${res.statusCode}';
      throw Exception(msg);
    } on http.ClientException catch (e) {
      throw Exception('Error de red: ${e.message}');
    } catch (e) {
      throw Exception('Error al conectar: $e');
    }
  }
}
