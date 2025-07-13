import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_flutter_app/config/api_config.dart';
import 'package:my_flutter_app/core/constants/storage_keys.dart';
import 'package:my_flutter_app/services/service_locator.dart';

import '../../login/data/models/auth_state.dart';
// import '../../login/services/session_manager.dart';

/// Service to handle logout functionality
class LogoutService {
  final Ref ref;

  LogoutService(this.ref);

  /// Perform logout by calling API and clearing local state
  Future<bool> logout() async {
    try {
      final serviceLocator = ref.read(serviceLocatorProvider);
      
      // Call logout API endpoint
      await serviceLocator.apiService.post(ApiConfig.logout);
      
      // Clear auth state (session management disabled)
      await AuthState.clear(storageKey: StorageKeys.authState.value);
      
      return true;
    } catch (e) {
      // Even if API call fails, clear auth state for security
      try {
        await AuthState.clear(storageKey: StorageKeys.authState.value);
      } catch (clearError) {
        // Ignore clear errors
      }
      
      // Return false to indicate API failure, but auth state is cleared
      return false;
    }
  }

  /// Force logout without API call (for token expiration scenarios)
  Future<void> forceLogout() async {
    try {
      await AuthState.clear(storageKey: StorageKeys.authState.value);
    } catch (e) {
      // Ignore errors during force logout
    }
  }

  /// Check if user is currently logged in
  Future<bool> isLoggedIn() async {
    try {
      // Since session management is disabled, just check auth state
      final authState = await AuthState.load(storageKey: StorageKeys.authState.value);
      return authState.isAuthenticated && authState.hasValidTokens;
    } catch (e) {
      return false;
    }
  }
}

/// Provider for LogoutService
final logoutServiceProvider = Provider<LogoutService>((ref) {
  return LogoutService(ref);
}); 