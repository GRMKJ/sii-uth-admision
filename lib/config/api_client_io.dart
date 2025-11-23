import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http/io_client.dart';

class ApiClient {
  static const String baseUrl = 'https://uthbackdev.cardomomo.icu/api/v1';

  static final http.Client _secureClient = _createSecureClient();

  static http.Client _createSecureClient() {
    final ioClient = HttpClient()
      ..badCertificateCallback = (X509Certificate cert, String host, int port) {
        if (host == '127.0.0.1' || host == 'localhost') {
          return true;
        }
        return false;
      };

    return IOClient(ioClient);
  }

  // 🔹 POST seguro con validación
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
    } on SocketException {
      throw Exception('Error de red: No hay conexión segura.');
    } on HandshakeException {
      throw Exception('Fallo en el handshake SSL/TLS. Certificado no válido.');
    } catch (e) {
      throw Exception('Error al conectar: $e');
    }
  }

  // 🔹 POST multipart (subida de archivo) con validación
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
      request.files.add(await http.MultipartFile.fromPath(fileField, filePath,
          filename: fileName));
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
    } on SocketException {
      throw Exception('Error de red: No hay conexión segura.');
    } on HandshakeException {
      throw Exception('Fallo en el handshake SSL/TLS. Certificado no válido.');
    } catch (e) {
      throw Exception('Error al conectar: $e');
    }
  }

  // 🔹 GET seguro con validación
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
    } on SocketException {
      throw Exception('Error de red: No hay conexión segura.');
    } on HandshakeException {
      throw Exception('Fallo SSL/TLS. Verifica el certificado del servidor.');
    } catch (e) {
      throw Exception('Error al conectar: $e');
    }
  }
}
