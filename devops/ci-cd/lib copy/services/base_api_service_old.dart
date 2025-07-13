import 'dart:convert';

import 'package:http/http.dart' as http;

class BaseApiService {
  final String baseUrl;
  final http.Client _client;
  String? _authToken;

  BaseApiService({required this.baseUrl}) : _client = http.Client();

  Map<String, String> get _headers {
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    if (_authToken != null) {
      headers['Authorization'] = 'Bearer $_authToken';
    }
    return headers;
  }

  void setAuthToken(String token) {
    _authToken = token;
  }

  void clearAuthToken() {
    _authToken = null;
  }

  Future<dynamic> get(String endpoint) async {
    try {
      final response = await _client.get(
        Uri.parse('$baseUrl$endpoint'),
        headers: _headers,
      );
      return _handleResponse(response);
    } catch (e) {
      throw Exception('Failed to make GET request: $e');
    }
  }

  Future<dynamic> post(String endpoint, {required dynamic data}) async {
    try {
      final response = await _client.post(
        Uri.parse('$baseUrl$endpoint'),
        headers: _headers,
        body: data is String ? data : jsonEncode(data),
      );
      return _handleResponse(response);
    } catch (e) {
      throw Exception('Failed to make POST request: $e');
    }
  }

  Future<dynamic> put(String endpoint, {required dynamic data}) async {
    try {
      final response = await _client.put(
        Uri.parse('$baseUrl$endpoint'),
        headers: _headers,
        body: data is String ? data : jsonEncode(data),
      );
      return _handleResponse(response);
    } catch (e) {
      throw Exception('Failed to make PUT request: $e');
    }
  }

  Future<dynamic> delete(String endpoint) async {
    try {
      final response = await _client.delete(
        Uri.parse('$baseUrl$endpoint'),
        headers: _headers,
      );
      return _handleResponse(response);
    } catch (e) {
      throw Exception('Failed to make DELETE request: $e');
    }
  }

  dynamic _handleResponse(http.Response response) {
    try {
      // Handle empty response
      if (response.body.isEmpty) {
        if (response.statusCode >= 200 && response.statusCode < 300) {
          return null;
        }
        throw ApiException(
          statusCode: response.statusCode,
          message: 'Empty response received',
        );
      }

      // Parse response body
      final dynamic data = jsonDecode(response.body);

      // Handle successful response
      if (response.statusCode >= 200 && response.statusCode < 300) {
        // Check if response has a data field
        if (data is Map<String, dynamic> && data.containsKey('data')) {
          return data['data'];
        }
        return data;
      }

      // Handle error response
      if (data is Map<String, dynamic>) {
        final errorMessage = data['message'] ?? 
                           data['error'] ?? 
                           data['errorMessage'] ?? 
                           'An error occurred';
        throw ApiException(
          statusCode: response.statusCode,
          message: errorMessage,
        );
      }

      throw ApiException(
        statusCode: response.statusCode,
        message: 'Unexpected response format',
      );
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(
        statusCode: response.statusCode,
        message: 'Failed to process response: $e',
      );
    }
  }

  void dispose() {
    _client.close();
  }
}

class ApiException implements Exception {
  final int statusCode;
  final String message;

  ApiException({required this.statusCode, required this.message});

  @override
  String toString() => 'ApiException: [$statusCode] $message';
} 