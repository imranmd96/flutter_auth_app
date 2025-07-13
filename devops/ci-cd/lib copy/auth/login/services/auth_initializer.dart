import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/storage_keys.dart';
import '../data/models/auth_state.dart';
import '../providers/auth_provider.dart';
import 'token_refresh_service.dart';

/// Service to initialize authentication state and token refresh on app startup
class AuthInitializer {
  final Ref ref;

  AuthInitializer(this.ref);

  /// Initialize authentication state and token refresh
  Future<void> initialize() async {
    try {
      // Load stored auth state and initialize provider
      await ref.read(authProvider.notifier).initialize();
      
      // Get current state to check if we have valid tokens
      final currentState = ref.read(authProvider);
      
      if (currentState.hasValidTokens) {
        // Initialize token refresh service
        final tokenRefreshService = ref.read(tokenRefreshServiceProvider);
        tokenRefreshService.initialize(ref);
      }
    } catch (e) {
      // Clear invalid state on error
      await AuthState.clear(storageKey: StorageKeys.authState.value);
      ref.read(authProvider.notifier).state = const AuthState(isInitialized: true);
    }
  }

  /// Check if user should be redirected to login
  Future<bool> shouldShowLogin() async {
    try {
      final authState = await AuthState.load(storageKey: StorageKeys.authState.value);
      return !authState.isAuthenticated || authState.accessToken.isEmpty;
    } catch (e) {
      return true;
    }
  }

  /// Get initial route based on authentication status
  Future<String> getInitialRoute() async {
    final shouldLogin = await shouldShowLogin();
    return shouldLogin ? '/auth/login' : '/dashboard';
  }
}

/// Provider for AuthInitializer
final authInitializerProvider = Provider<AuthInitializer>((ref) {
  return AuthInitializer(ref);
}); 