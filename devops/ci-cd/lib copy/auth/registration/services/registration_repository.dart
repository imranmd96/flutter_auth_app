import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../config/api_config.dart';
import '../../../services/base_api_service.dart';
import '../../../services/user_service.dart';
import 'registration_service.dart';

final registrationRepositoryProvider = Provider((ref) => RegistrationRepository(ref));

class RegistrationRepository {
  final Ref ref;
  final BaseApiService _apiService;
  late final RegistrationService _registrationService;
  static const String _accessTokenKey = 'access_token';
  static const String _refreshTokenKey = 'refresh_token';
  late final UserService _userService;

  RegistrationRepository(this.ref) : _apiService = BaseApiService(baseUrl: ApiConfig.userServiceUrl, ref: ref) {
    _userService = UserService(ref);
    _registrationService = RegistrationService(ref);
  }

  // Register
  Future<void> register(Map<String, dynamic> data) async {
    try {
      print('==== REGISTER REQUEST ====');
      print('URL: [${ApiConfig.devBaseUrl}${ApiConfig.register}');
      print('Data: $data');
      final response = await _registrationService.register(
        name: data['name'],
        email: data['email'],
        phone: data['phone'],
        password: data['password'],
      );
      print('==== REGISTER RESPONSE ====');
      print('Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');
      if (response.statusCode == 201) {
        final responseData = jsonDecode(response.body);
        if (responseData['status'] == 'success') {
          return;
        }
      }
      throw Exception(jsonDecode(response.body)['message'] ?? 'Registration failed');
    } catch (e) {
      print('==== REGISTER ERROR ====');
      print('Error: $e');
      rethrow;
    }
  }

  // Logout
  Future<void> logout() async {
    try {
      await _apiService.post('/auth/logout');
      final prefs = await SharedPreferences.getInstance();
      final refreshToken = prefs.getString(_refreshTokenKey);
      if (refreshToken != null) {
        await _registrationService.logout(refreshToken);
      }
      // Clear stored tokens
      await prefs.remove(_accessTokenKey);
      await prefs.remove(_refreshTokenKey);
    } catch (e) {
      throw Exception('Logout failed: $e');
    }
  }
} 