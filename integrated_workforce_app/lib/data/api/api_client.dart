import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../core/config/app_config.dart';

class ApiClient {
  static String? token;

  static Uri _buildUri(String path, [Map<String, dynamic>? queryParams]) {
    final base = AppConfig.apiBaseUrl.replaceAll(RegExp(r'/+$'), '');
    final cleanPath = path.startsWith('/') ? path : '/$path';
    return Uri.parse('$base$cleanPath').replace(queryParameters: queryParams?.map((k, v) => MapEntry(k, v.toString())));
  }

  static Map<String, String> _headers() {
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    if (token != null && token!.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  static Future<dynamic> get(String path, {Map<String, dynamic>? queryParams}) async {
    final uri = _buildUri(path, queryParams);
    final response = await http.get(uri, headers: _headers());
    return _handleResponse(response);
  }

  static Future<dynamic> post(String path, {dynamic body}) async {
    final uri = _buildUri(path);
    final response = await http.post(
      uri,
      headers: _headers(),
      body: body != null ? jsonEncode(body) : null,
    );
    return _handleResponse(response);
  }

  static Future<dynamic> put(String path, {dynamic body}) async {
    final uri = _buildUri(path);
    final response = await http.put(
      uri,
      headers: _headers(),
      body: body != null ? jsonEncode(body) : null,
    );
    return _handleResponse(response);
  }

  static Future<dynamic> patch(String path, {dynamic body}) async {
    final uri = _buildUri(path);
    final response = await http.patch(
      uri,
      headers: _headers(),
      body: body != null ? jsonEncode(body) : null,
    );
    return _handleResponse(response);
  }

  static Future<dynamic> delete(String path) async {
    final uri = _buildUri(path);
    final response = await http.delete(uri, headers: _headers());
    return _handleResponse(response);
  }

  static dynamic _handleResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.isEmpty) return null;
      return jsonDecode(response.body);
    }

    String message = 'Server error (${response.statusCode})';
    try {
      final json = jsonDecode(response.body);
      if (json is Map && json.containsKey('message')) {
        message = json['message'].toString();
      }
    } catch (_) {}

    throw Exception(message);
  }
}
