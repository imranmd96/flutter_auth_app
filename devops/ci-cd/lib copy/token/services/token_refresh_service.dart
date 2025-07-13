import 'dart:async';

import 'package:jwt_decoder/jwt_decoder.dart';

import 'token_service.dart';

class TokenRefreshService {
  Timer? _refreshTimer;
  static const int _refreshBufferMs = 2 * 60 * 1000;

  /// Schedules a token refresh before expiry.
  void scheduleTokenRefresh({
    required String refreshToken,
    required Future<void> Function(Map<String, dynamic>? tokens) onRefresh,
    required void Function() onSessionExpired,
  }) {
    _refreshTimer?.cancel();
    if (refreshToken.isEmpty) return;

    try {
      final decoded = JwtDecoder.decode(refreshToken);
      final exp = decoded['exp'] * 1000;
      final now = DateTime.now().millisecondsSinceEpoch;
      final delay = exp - now - _refreshBufferMs;
      if (delay > 0) {
        _refreshTimer = Timer(Duration(milliseconds: delay), () async {
          await _refreshCallback(refreshToken, onRefresh, onSessionExpired);
        });
      }
    } catch (e) {
      onSessionExpired();
    }
  }

  Future<void> _refreshCallback(
    String refreshToken,
    Future<void> Function(Map<String, dynamic>? tokens) onRefresh,
    void Function() onSessionExpired,
  ) async {
    try {
      final newTokens = await TokenService().refreshToken(refreshToken);
      final tokens = newTokens?['data']?['tokens'];
      if (tokens != null) {
        await onRefresh(tokens);
      } else {
        onSessionExpired();
      }
    } catch (e) {
      onSessionExpired();
    }
  }

  void dispose() {
    _refreshTimer?.cancel();
  }
} 