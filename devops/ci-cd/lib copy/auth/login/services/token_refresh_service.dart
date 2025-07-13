import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_flutter_app/services/service_locator.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../config/api_config.dart';
import '../../../core/constants/storage_keys.dart';
import '../../logout/providers/logout_provider.dart';
import '../data/models/auth_state.dart';
import '../providers/auth_provider.dart';
import 'auth_interceptor.dart';

/// Service to handle automatic token refresh and session management
class TokenRefreshService {
  Timer? _refreshTimer;
  final Dio _dio = Dio();
  static const String _lastRefreshKey = 'last_refresh_time';
  
  /// Token lifetime configuration
  static const int _accessTokenLifetimeMinutes = 25;
  static const int _refreshBeforeExpiryMinutes = 5;
  static const int _maxRefreshAttempts = 3;
  
  /// State management
  int _refreshAttempts = 0;
  bool _isRefreshing = false;
  Completer<bool>? _refreshCompleter;

  /// Initialize the token refresh service
  void initialize(Ref ref) {
    _scheduleTokenRefresh(ref);
  }

  /// Schedule automatic token refresh
  void _scheduleTokenRefresh(Ref ref) async {
    final authState = await AuthState.load(storageKey: StorageKeys.authState.value);
    
    if (authState.refreshToken.isEmpty) {
      return;
    }

    // Cancel existing timer
    _refreshTimer?.cancel();

    // Check if token needs refresh
    final shouldRefresh = await _shouldRefreshToken();
    
    if (shouldRefresh) {
      await _refreshToken(ref);
    } else {
      _scheduleNextRefresh(ref);
    }
  }

  /// Check if token should be refreshed
  Future<bool> _shouldRefreshToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final lastRefresh = prefs.getInt(_lastRefreshKey) ?? 0;
      final currentTime = DateTime.now().millisecondsSinceEpoch;
      
      // If no last refresh time, don't refresh immediately on app start
      if (lastRefresh == 0) {
        return false;
      }

      final timeSinceRefresh = (currentTime - lastRefresh) / (1000 * 60);
      final needsRefresh = timeSinceRefresh >= (_accessTokenLifetimeMinutes - _refreshBeforeExpiryMinutes);
      
      return needsRefresh;
    } catch (e) {
      return false;
    }
  }

  /// Schedule the next token refresh
  void _scheduleNextRefresh(Ref ref) {
    _refreshTimer?.cancel();
    
    // Schedule refresh 20 minutes from now (5 minutes before access token expires)
    _refreshTimer = Timer(const Duration(minutes: 20), () {
      _refreshToken(ref);
    });
  }

  /// Refresh the access token using refresh token
  Future<void> _refreshToken(Ref ref) async {
    // Prevent multiple simultaneous refresh attempts
    if (_isRefreshing) {
      if (_refreshCompleter != null) {
        await _refreshCompleter!.future;
      }
      return;
    }

    _isRefreshing = true;
    _refreshCompleter = Completer<bool>();

    try {
      final authState = await AuthState.load(storageKey: StorageKeys.authState.value);
      if (authState.refreshToken.isEmpty) {
        await _handleRefreshFailure(ref, 'No refresh token available');
        return;
      }
      
      final serviceLocator = ref.read(serviceLocatorProvider);
      final response = await serviceLocator.apiService.post(
        '${ApiConfig.authServiceUrl}${ApiConfig.refreshToken}',
        data: { 'refreshToken': authState.refreshToken },
      );
      
      if (_isValidRefreshResponse(response)) {
        final tokens = _extractTokens(response);
        if (tokens != null) {
          await _updateTokens(ref, tokens['accessToken']!, tokens['refreshToken']!);
          _refreshAttempts = 0;
          _scheduleNextRefresh(ref);
          _refreshCompleter?.complete(true);
          return;
        }
      }

      await _handleRefreshFailure(ref, 'Invalid refresh response');
    } catch (e) {
      if (_isTokenExpiredError(e)) {
        await _handleRefreshTokenExpired(ref);
      } else {
        await _handleRefreshFailure(ref, 'Refresh failed: ${e.toString()}');
      }
    } finally {
      _isRefreshing = false;
      _refreshCompleter?.complete(false);
    }
  }

  /// Check if refresh response is valid
  bool _isValidRefreshResponse(dynamic response) {
    return response != null && 
           response['status'] == 'success' && 
           response['data'] != null;
  }

  /// Extract tokens from response
  Map<String, String>? _extractTokens(dynamic response) {
    try {
      final data = response['data'] as Map<String, dynamic>;
      final responseData = data['data'] as Map<String, dynamic>;
      final tokens = responseData['tokens'] as Map<String, dynamic>?;
      
      if (tokens != null) {
        final accessToken = tokens['accessToken'] as String?;
        final refreshToken = tokens['refreshToken'] as String?;
        
        if (accessToken != null && refreshToken != null) {
          return {
            'accessToken': accessToken,
            'refreshToken': refreshToken,
          };
        }
      }
    } catch (e) {
      // Ignore errors when extracting tokens
    }
    return null;
  }

  /// Check if error indicates expired token
  bool _isTokenExpiredError(dynamic error) {
    final errorString = error.toString().toLowerCase();
    return errorString.contains('401') || 
           errorString.contains('unauthorized') ||
           errorString.contains('expired');
  }

  /// Handle expired refresh token
  Future<void> _handleRefreshTokenExpired(Ref ref) async {
    await clearTokens();
    
    // Add a small delay to prevent navigation conflicts
    await Future.delayed(const Duration(milliseconds: 100));
    
    // Use the new logout service instead of auth provider
    await ref.read(logoutProvider.notifier).forceLogout();
    _refreshAttempts = 0;
  }

  /// Update tokens in auth state
  Future<void> _updateTokens(Ref ref, String accessToken, String refreshToken) async {
    try {
      final authState = await AuthState.load(storageKey: StorageKeys.authState.value);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_lastRefreshKey, DateTime.now().millisecondsSinceEpoch);
      
      // Update stored state
      final newState = authState.copyWith(
        accessToken: accessToken,
        refreshToken: refreshToken,
        isAuthenticated: true,
      );
      await newState.save(storageKey: StorageKeys.authState.value);
      
      // Update provider state
      await ref.read(authProvider.notifier).updateTokens(accessToken, refreshToken);
      
      // Refresh AuthInterceptor cache
      final authInterceptor = ref.read(authInterceptorProvider);
      await authInterceptor.refreshCache();
    } catch (e) {
      throw Exception('Failed to update tokens: $e');
    }
  }

  /// Handle refresh token failure
  Future<void> _handleRefreshFailure(Ref ref, String error) async {
    _refreshAttempts++;
    
    if (_refreshAttempts >= _maxRefreshAttempts) {
      await clearTokens();
      
      // Add a small delay to prevent navigation conflicts
      await Future.delayed(const Duration(milliseconds: 100));
      
      // Use the new logout service instead of auth provider
      await ref.read(logoutProvider.notifier).forceLogout();
      return;
    }

    // Retry after delay with exponential backoff
    final delay = Duration(minutes: _refreshAttempts);
    Timer(delay, () {
      _refreshToken(ref);
    });
  }

  /// Force manual token refresh
  Future<bool> forceRefresh(Ref ref) async {
    try {
      await _refreshToken(ref);
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Check if token needs refresh and refresh if needed
  Future<bool> checkAndRefreshIfNeeded(Ref ref) async {
    if (_isRefreshing) {
      if (_refreshCompleter != null) {
        return await _refreshCompleter!.future;
      }
      return false;
    }

    final shouldRefresh = await _shouldRefreshToken();
    if (shouldRefresh) {
      await _refreshToken(ref);
      return true;
    }
    return false;
  }

  /// Check if user is authenticated
  Future<bool> isAuthenticated() async {
    try {
      final authState = await AuthState.load(storageKey: StorageKeys.authState.value);
      return authState.isAuthenticated && authState.accessToken.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  /// Get current access token
  Future<String> getAccessToken() async {
    try {
      final authState = await AuthState.load(storageKey: StorageKeys.authState.value);
      return authState.accessToken;
    } catch (e) {
      return '';
    }
  }

  /// Clear all tokens and stop refresh timer
  Future<void> clearTokens() async {
    _refreshTimer?.cancel();
    _refreshAttempts = 0;
    _isRefreshing = false;
    _refreshCompleter?.complete(false);
    
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_lastRefreshKey);
    } catch (e) {
      // Ignore errors when clearing
    }
  }

  /// Dispose the service
  void dispose() {
    _refreshTimer?.cancel();
    _refreshCompleter?.complete(false);
  }
}

/// Provider for TokenRefreshService
final tokenRefreshServiceProvider = Provider<TokenRefreshService>((ref) {
  final service = TokenRefreshService();
  ref.onDispose(() => service.dispose());
  return service;
}); 