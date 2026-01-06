import 'dart:convert';
import 'package:aerosense/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class Api {
  Api._privateConstructor();
  static final Api instance = Api._privateConstructor();

  final String baseUrl = dotenv.env['API_URL']!;
  String? _token;

  set token(String value) => _token = value;
  String get token => _token ?? '';

  void clearToken() => _token = null;

  Map<String, String> _headers() {
    return <String, String>{
      'Content-Type': 'application/json',
      if (_token != null && _token!.isNotEmpty) 'Authorization': _token!
    };
  }

  Uri _buildUri(String endpoint, [Map<String, dynamic>? queryParams]) {
    final Uri uri = Uri.parse('$baseUrl$endpoint');
    
    if (queryParams != null && queryParams.isNotEmpty) {
      return uri.replace(
        queryParameters: queryParams.map((String k, dynamic v) => MapEntry<String, String>(k, v.toString())
      ));
    }

    return uri;
  }

  dynamic _handleResponse(http.Response response) {
    final int statusCode = response.statusCode;

    if (statusCode >= 200 && statusCode < 300) {
      if (response.body.isEmpty) {
        return <dynamic>{};
      }

      return jsonDecode(response.body);
    } 
    else {
      final Map<String, dynamic> decodedResponse = jsonDecode(response.body) as Map<String, dynamic>;
      final String errorMessage = decodedResponse['error'] as String;

      throw ApiException(errorMessage, statusCode);
    }
  }

  void _handleError(Object error) {
    final BuildContext? ctx = navigatorKey.currentContext;
    String message = 'Unknown error occured.';
    
    if (error is ApiException) {
      message = error.message;
    } 

    if (ctx != null) {
      _showGlobalError(message);
    }
  }

  void _showGlobalError(String message) {
    final NavigatorState? navigator = navigatorKey.currentState;
    final OverlayState? overlay = navigator?.overlay;

    if (overlay == null) {
      return;
    }

    final OverlayEntry entry = OverlayEntry(
      builder: (_) => Positioned(
        bottom: MediaQuery.of(overlay.context).padding.bottom + 12,
        left: 16,
        right: 16,
        child: Material(
          color: Colors.red,
          elevation: 12,
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Text(
              message,
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ),
      ),
    );

    overlay.insert(entry);

    Future<void>.delayed(
      const Duration(seconds: 3),
      entry.remove
    );
  }

  Future<dynamic> get(String endpoint, {Map<String, dynamic>? queryParams}) async {
    final Uri url = _buildUri(endpoint, queryParams);

    try {
      final http.Response response = await http
        .get(
          url,
          headers: _headers()
        )
        .timeout(const Duration(seconds: 30));

      return _handleResponse(response);
    } catch (e) {
      _handleError(e);
      rethrow;
    }
  }

  Future<dynamic> post(String endpoint, Map<String, dynamic> body, {Map<String, dynamic>? queryParams}) async {
    final Uri url = _buildUri(endpoint, queryParams);

    try {
      final http.Response response = await http
        .post(
          url,
          headers: _headers(),
          body: json.encode(body),
        )
        .timeout(const Duration(seconds: 30));

      return _handleResponse(response);
    } catch (e) {
      _handleError(e);
      rethrow;
    }
  }

  Future<dynamic> put(String endpoint, Map<String, dynamic> body, {Map<String, dynamic>? queryParams}) async {
    final Uri url = _buildUri(endpoint, queryParams);

    try {
      final http.Response response = await http
        .put(
          url,
          headers: _headers(),
          body: json.encode(body),
        )
        .timeout(const Duration(seconds: 30));

      return _handleResponse(response);
    } catch (e) {
      _handleError(e);
      rethrow;
    }
  }

  Future<dynamic> delete(String endpoint, {Map<String, dynamic>? queryParams}) async {
    final Uri url = _buildUri(endpoint, queryParams);

    try {
      final http.Response response = await http
        .delete(
          url,
          headers: _headers()
        )
        .timeout(const Duration(seconds: 30));

      return _handleResponse(response);
    } catch (e) {
      _handleError(e);
      rethrow;
    }
  }
}

class ApiException implements Exception {
  ApiException(this.message, [this.statusCode]);

  final String message;
  final int? statusCode;

  @override
  String toString() => 'ApiException($statusCode): $message';
}
