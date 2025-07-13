import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

import '../../../../config/api_config.dart';

final registrationServiceProvider = Provider((ref) => RegistrationService(ref));

class RegistrationService {
  final Ref ref;
  final _client = http.Client();

  RegistrationService(this.ref);

  Future<http.Response> register({
    required String name,
    required String email,
    required String phone,
    required String password,
  }) async {
    int retryCount = 0;
    const maxRetries = 3;
    while (retryCount < maxRetries) {
      try {
        final url = Uri.parse('${ApiConfig.devBaseUrl}${ApiConfig.register}');
        final response = await _client.post(
          url,
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
          body: jsonEncode({
            'name': name,
            'email': email,
            'phone': phone,
            'password': password,
          }),
        ).timeout(
          const Duration(seconds: 10),
          onTimeout: () {
            throw Exception('Connection timed out. Please check your internet connection.');
          },
        );
        return response;
      } catch (e) {
        if (e.toString().contains('Connection refused') || 
            e.toString().contains('Connection reset')) {
          retryCount++;
          if (retryCount < maxRetries) {
            await Future.delayed(const Duration(seconds: 2));
            continue;
          }
          throw Exception('Cannot connect to server. Please check your internet connection and try again.');
        }
        rethrow;
      }
    }
    throw Exception('Failed to connect after $maxRetries attempts');
  }

  Future<void> logout(String refreshToken) async {
    try {
      final response = await _client.post(
        Uri.parse('${ApiConfig.devBaseUrl}${ApiConfig.logout}'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'refreshToken': refreshToken,
        }),
      );
      if (response.statusCode != 200) {
        throw Exception(jsonDecode(response.body)['message'] ?? 'Logout failed');
      }
    } catch (e) {
      throw Exception('Failed to logout: $e');
    }
  }
} 