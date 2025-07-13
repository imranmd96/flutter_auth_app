import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Provider to access TokenService throughout the app
final tokenServiceProvider = Provider((ref) => TokenService());

// Service to handle token refresh operations
class TokenService {
  final _dio = Dio();

  // // Save auth state with tokens to local storage
  // Future<void> saveTokens(AuthState state) async {
  //   await state.save();
  // }

  // // Get saved auth state with tokens from local storage
  // Future<AuthState> getTokens() async {
  //   return await AuthState.load();
  // }

  // // Remove saved tokens from local storage (used in logout)
  // Future<void> clearTokens() async {
  //   await AuthState.clear();
  // }

  // // Check if valid tokens exist in local storage
  // Future<bool> hasTokens() async {
  //   return await AuthState.hasStoredState();
  // }

  // Get new access token using refresh token
  // Future<Map<String, dynamic>> refreshToken(String refreshToken) async {
  //   if (refreshToken.isEmpty) {
  //     throw Exception('Invalid refresh token');
  //   }
  //   try {
  //     final response = await _dio.post(
  //       '/auth/refresh',
  //       data: {'refreshToken': refreshToken},
  //     );
  //     if (response.data == null) {
  //       throw Exception('Invalid response from server');
  //     }
  //     return response.data;
  //   } catch (e) {
  //     throw Exception('Failed to refresh token: $e');
  //   }
  // }
} 