import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/storage_keys.dart';
import '../../logout/providers/logout_provider.dart';
import '../data/models/auth_state.dart';
import 'token_refresh_service.dart';

/// Interceptor to handle automatic token refresh on API calls
/// Optimized to minimize SharedPreferences access
class AuthInterceptor extends Interceptor {
  final Ref ref;
  final TokenRefreshService _tokenRefreshService;
  bool _isRefreshing = false;
  
  // Cache auth state to avoid SharedPreferences access on every request
  AuthState? _cachedAuthState;
  DateTime? _lastCacheUpdate;

  AuthInterceptor(this.ref) : _tokenRefreshService = ref.read(tokenRefreshServiceProvider);

  /// Get cached auth state or load from storage if needed
  Future<AuthState> _getAuthState() async {
    final now = DateTime.now();
    
    // Use cached state if it's recent (less than 10 milliseconds old)
    if (_cachedAuthState != null && _lastCacheUpdate != null) {
      final timeDiff = now.difference(_lastCacheUpdate!);
      if (timeDiff.inMilliseconds < 10) {
        return _cachedAuthState!;
      }
    }
    
    // Load fresh state from storage using consistent key
    _cachedAuthState = await AuthState.load(storageKey: StorageKeys.authState.value);
    _lastCacheUpdate = now;
    return _cachedAuthState!;
  }

  /// Update cached auth state (called when tokens are refreshed)
  void _updateCachedState(AuthState newState) {
    _cachedAuthState = newState;
    _lastCacheUpdate = DateTime.now();
  }

  /// Clear cached auth state (called when tokens are updated externally)
  void clearCache() {
    _cachedAuthState = null;
    _lastCacheUpdate = null;
  }

  /// Force refresh cache with latest auth state from storage
  Future<void> refreshCache() async {
    _cachedAuthState = await AuthState.load(storageKey: StorageKeys.authState.value);
    _lastCacheUpdate = DateTime.now();
  }

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    // Skip token injection for public endpoints
    if (_isPublicEndpoint(options.path)) {
      return handler.next(options);
    }
    
    // Check if token needs refresh before making the request
    await _tokenRefreshService.checkAndRefreshIfNeeded(ref);
    
    // Add auth token to requests (using cached state)
    final authState = await _getAuthState();
    if (authState.accessToken.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer ${authState.accessToken}';
    }
    
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 401 && !_isRefreshing) {
      // Token expired, try to refresh
      _isRefreshing = true;
      
      try {
        final success = await _tokenRefreshService.forceRefresh(ref);
        
        if (success) {
          // Get the updated auth state after successful refresh
          final newAuthState = await AuthState.load(storageKey: StorageKeys.authState.value);
          _updateCachedState(newAuthState); // Update cache with new tokens
          
          // Retry the original request with new token
          final newOptions = err.requestOptions;
          newOptions.headers['Authorization'] = 'Bearer ${newAuthState.accessToken}';
          
          final dio = Dio();
          final response = await dio.fetch(newOptions);
          handler.resolve(response);
          return;
        } else {
          // Refresh failed, logout user
          await ref.read(logoutProvider.notifier).forceLogout();
          _cachedAuthState = null; // Clear cache
        }
      } catch (e) {
        // Refresh failed, logout user
        await ref.read(logoutProvider.notifier).forceLogout();
        _cachedAuthState = null; // Clear cache
      } finally {
        _isRefreshing = false;
      }
    }
    
    handler.next(err);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    handler.next(response);
  }

  /// Check if endpoint is public (doesn't need authentication)
  bool _isPublicEndpoint(String path) {
    final publicEndpoints = [
      '/auth/login',
      '/auth/register',
      '/auth/refresh-token',
      '/auth/refresh-token/',  // Add trailing slash variant
      'auth/login',
      'auth/register',
      'auth/refresh-token',
      'auth/refresh-token/',   // Add without leading slash

    ];
    
    // Check if any public endpoint matches the path
    final isPublic = publicEndpoints.any((endpoint) => 
      path.contains(endpoint) || 
      path.endsWith(endpoint) ||
      path == endpoint
    );
    
    return isPublic;
  }
}

/// Provider for AuthInterceptor
final authInterceptorProvider = Provider<AuthInterceptor>((ref) {
  return AuthInterceptor(ref);
}); 