import "dart:convert";
import "package:aerosense/main.dart";
import "package:flutter/material.dart";
import "package:flutter_dotenv/flutter_dotenv.dart";
import "package:http/http.dart" as http;

class Api {
  Api._privateConstructor();
  static final Api instance = Api._privateConstructor();

  final String baseUrl = dotenv.env["API_URL"]!;
  String? _token;

  void setToken(String token) => _token = token;
  void clearToken() => _token = null;

  Map<String, String> _headers() {
    return {
      "Content-Type": "application/json",
      if (_token != null && _token!.isNotEmpty == true) "Authorization": _token!
    };
  }

  Uri _buildUri(String endpoint, [Map<String, dynamic>? queryParams]) {
    final uri = Uri.parse("$baseUrl$endpoint");
    
    if (queryParams != null && queryParams.isNotEmpty) {
      return uri.replace(
        queryParameters: queryParams.map((k, v) => MapEntry(k, v.toString())
      ));
    }

    return uri;
  }

  dynamic _handleResponse(http.Response response) {
    final statusCode = response.statusCode;

    if (statusCode >= 200 && statusCode < 300) {
      if (response.body.isEmpty) {
        return {};
      }

      return jsonDecode(response.body);
    } else {
      final errorMessage = jsonDecode(response.body)["error"];

      throw ApiException(errorMessage, statusCode);
    }
  }

  void _handleError(Object error) {
    final ctx = navigatorKey.currentContext;
    String message = "Unknown error occured.";
    
    if (error is ApiException) {
      message = error.message;
    } 

    if (ctx != null) {
      ScaffoldMessenger
        .of(ctx)
        .showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating
          ),
        );
    }
  }

  Future<dynamic> get(String endpoint, {Map<String, dynamic>? queryParams}) async {
    final url = _buildUri(endpoint, queryParams);

    try {
      final response = await http
        .get(
          url,
          headers: _headers()
        )
        .timeout(Duration(seconds: 30));

      return _handleResponse(response);
    } catch (e) {
      _handleError(e);
      rethrow;
    }
  }

  Future<dynamic> post(String endpoint, Map<String, dynamic> body, {Map<String, dynamic>? queryParams}) async {
    final url = _buildUri(endpoint, queryParams);

    try {
      final response = await http
        .post(
          url,
          headers: _headers(),
          body: json.encode(body),
        )
        .timeout(Duration(seconds: 30));

      return _handleResponse(response);
    } catch (e) {
      _handleError(e);
      rethrow;
    }
  }

  Future<dynamic> put(String endpoint, Map<String, dynamic> body, {Map<String, dynamic>? queryParams}) async {
    final url = _buildUri(endpoint, queryParams);

    try {
      final response = await http
        .put(
          url,
          headers: _headers(),
          body: json.encode(body),
        )
        .timeout(Duration(seconds: 30));

      return _handleResponse(response);
    } catch (e) {
      _handleError(e);
      rethrow;
    }
  }

  Future<dynamic> delete(String endpoint, {Map<String, dynamic>? queryParams}) async {
    final url = _buildUri(endpoint, queryParams);

    try {
      final response = await http
        .delete(
          url,
          headers: _headers()
        )
        .timeout(Duration(seconds: 30));

      return _handleResponse(response);
    } catch (e) {
      _handleError(e);
      rethrow;
    }
  }
}

class ApiException implements Exception {
  final String message;
  final int? statusCode;

  ApiException(this.message, [this.statusCode]);

  @override
  String toString() => 'ApiException($statusCode): $message';
}