import 'package:dio/dio.dart';
import 'package:my_flutter_app/config/api_config.dart';

class TokenService {
  static const String _accessTokenKey = 'access_token';
  static const String _refreshTokenKey = 'refresh_token';
  final Dio _dio = Dio();

  Future<Map<String, dynamic>> refreshToken(String refreshToken) async {
    try {
      final response = await _dio.post(
        '${ApiConfig.authServiceUrl}/refresh-token',
        data: {'refreshToken': refreshToken},
      );
      return response.data;
    } catch (e) {
      throw Exception('Failed to refresh token: $e');
    }
  }
} 