// import 'dart:convert';

// import 'package:http/http.dart' as http;

// class BaseApiService {
//   final String baseUrl;
//   final http.Client _client;

//   BaseApiService({required this.baseUrl}) : _client = http.Client();

//   Future<dynamic> get(String endpoint) async {
//     try {
//       final response = await _client.get(
//         Uri.parse('$baseUrl$endpoint'),
//         headers: {
//           'Content-Type': 'application/json',
//           'Accept': 'application/json',
//         },
//       );
//       return _handleResponse(response);
//     } catch (e) {
//       throw Exception('Failed to make GET request: $e');
//     }
//   }

//   Future<dynamic> post(String endpoint, {required dynamic data}) async {
//     try {
//       final response = await _client.post(
//         Uri.parse('$baseUrl$endpoint'),
//         headers: {
//           'Content-Type': 'application/json',
//           'Accept': 'application/json',
//         },
//         body: data is String ? data : jsonEncode(data),
//       );
//       return _handleResponse(response);
//     } catch (e) {
//       throw Exception('Failed to make POST request: $e');
//     }
//   }

//   Future<dynamic> put(String endpoint, {required dynamic data}) async {
//     try {
//       final response = await _client.put(
//         Uri.parse('$baseUrl$endpoint'),
//         headers: {
//           'Content-Type': 'application/json',
//           'Accept': 'application/json',
//         },
//         body: data is String ? data : jsonEncode(data),
//       );
//       return _handleResponse(response);
//     } catch (e) {
//       throw Exception('Failed to make PUT request: $e');
//     }
//   }

//   Future<dynamic> delete(String endpoint) async {
//     try {
//       final response = await _client.delete(
//         Uri.parse('$baseUrl$endpoint'),
//         headers: {
//           'Content-Type': 'application/json',
//           'Accept': 'application/json',
//         },
//       );
//       return _handleResponse(response);
//     } catch (e) {
//       throw Exception('Failed to make DELETE request: $e');
//     }
//   }

//   dynamic _handleResponse(http.Response response) {
//     if (response.statusCode >= 200 && response.statusCode < 300) {
//       if (response.body.isEmpty) return null;
//       return jsonDecode(response.body);
//     } else {
//       final error = jsonDecode(response.body);
//       throw Exception(error['message'] ?? 'An error occurred');
//     }
//   }

//   void dispose() {
//     _client.close();
//   }
// }  

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../auth/login/services/auth_interceptor.dart';

class BaseApiService {
  final String baseUrl;
  final Ref ref;
  late final Dio _dio;

  BaseApiService({required this.baseUrl, required this.ref}) {
    _dio = Dio(BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      sendTimeout: const Duration(seconds: 30),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      validateStatus: (status) {
        return status != null && status < 500;
      },
    ));

    // Add AuthInterceptor for automatic token management
    _dio.interceptors.add(ref.read(authInterceptorProvider));

    // Add response interceptor for error handling and retries
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        print('Request: ${options.method} ${options.path}');
        return handler.next(options);
      },
      onResponse: (response, handler) {
        print('Response: ${response.statusCode} ${response.requestOptions.path}');
        if (response.data == null) {
          return handler.reject(
            DioException(
              requestOptions: response.requestOptions,
              error: 'Response data is null',
            ),
          );
        }
        return handler.next(response);
      },
      onError: (DioException e, handler) async {
        print('API Error: ${e.message}');
        if (e.response?.data != null) {
          print('Error Response: ${e.response?.data}');
        }

        // Retry logic for connection errors
        if (e.type == DioExceptionType.connectionTimeout ||
            e.type == DioExceptionType.receiveTimeout ||
            e.type == DioExceptionType.sendTimeout) {
          final options = e.requestOptions;
          try {
            final response = await _dio.request(
              options.path,
              data: options.data,
              queryParameters: options.queryParameters,
              options: Options(
                method: options.method,
                headers: options.headers,
              ),
            );
            return handler.resolve(response);
          } catch (e) {
            return handler.next(e as DioException);
          }
        }
        return handler.next(e);
      },
    ));
  }

  Future<dynamic> get(String path, {Map<String, dynamic>? queryParameters}) async {
    try {
      final response = await _dio.get(path, queryParameters: queryParameters);
      if (response.data == null) {
        throw Exception('Response data is null');
      }
      return response.data;
    } on DioException catch (e) {
      print('GET Error: ${e.message}');
      if (e.response?.data != null) {
        print('Error Response: ${e.response?.data}');
      }
      rethrow;
    } catch (e) {
      print('Unexpected Error: $e');
      rethrow;
    }
  }

  Future<dynamic> post(String path, {dynamic data, Map<String, dynamic>? queryParameters}) async {
    try {
      final response = await _dio.post(path, data: data, queryParameters: queryParameters);
      if (response.data == null) {
        throw Exception('Response data is null');
      }
      return response.data;
    } on DioException catch (e) {
      print('POST Error: ${e.message}');
      if (e.response?.data != null) {
        print('Error Response: ${e.response?.data}');
      }
      rethrow;
    } catch (e) {
      print('Unexpected Error: $e');
      rethrow;
    }
  }

  Future<dynamic> put(String path, {dynamic data, Map<String, dynamic>? queryParameters}) async {
    try {
      final response = await _dio.put(path, data: data, queryParameters: queryParameters);
      if (response.data == null) {
        throw Exception('Response data is null');
      }
      return response.data;
    } on DioException catch (e) {
      print('PUT Error: ${e.message}');
      if (e.response?.data != null) {
        print('Error Response: ${e.response?.data}');
      }
      rethrow;
    } catch (e) {
      print('Unexpected Error: $e');
      rethrow;
    }
  }

  Future<dynamic> delete(String path, {Map<String, dynamic>? queryParameters}) async {
    try {
      final response = await _dio.delete(path, queryParameters: queryParameters);
      if (response.data == null) {
        throw Exception('Response data is null');
      }
      return response.data;
    } on DioException catch (e) {
      print('DELETE Error: ${e.message}');
      if (e.response?.data != null) {
        print('Error Response: ${e.response?.data}');
      }
      rethrow;
    } catch (e) {
      print('Unexpected Error: $e');
      rethrow;
    }
  }

  void setAuthToken(String token) {
    if (token.isEmpty) {
      throw Exception('Invalid auth token');
    }
    _dio.options.headers['Authorization'] = 'Bearer $token';
  }

  void clearAuthToken() {
    _dio.options.headers.remove('Authorization');
  }
}  