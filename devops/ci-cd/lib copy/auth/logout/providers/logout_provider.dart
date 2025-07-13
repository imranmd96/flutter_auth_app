import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/logout_service.dart';

/// State for logout operations
class LogoutState {
  final bool isLoading;
  final String? error;
  final bool isLoggedOut;

  const LogoutState({
    this.isLoading = false,
    this.error,
    this.isLoggedOut = false,
  });

  LogoutState copyWith({
    bool? isLoading,
    String? error,
    bool? isLoggedOut,
  }) {
    return LogoutState(
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      isLoggedOut: isLoggedOut ?? this.isLoggedOut,
    );
  }
}

/// Notifier for logout state management
class LogoutNotifier extends StateNotifier<LogoutState> {
  final Ref ref;

  LogoutNotifier(this.ref) : super(const LogoutState());

  /// Perform logout with API call
  Future<bool> logout() async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      final logoutService = ref.read(logoutServiceProvider);
      final success = await logoutService.logout();
      
      if (success) {
        state = state.copyWith(
          isLoading: false,
          isLoggedOut: true,
        );
        return true;
      } else {
        // API failed but local state cleared
        state = state.copyWith(
          isLoading: false,
          isLoggedOut: true,
          error: 'Logout API failed, but local session cleared',
        );
        return true; // Still consider it successful since local state is cleared
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Logout failed: ${e.toString()}',
      );
      return false;
    }
  }

  /// Force logout without API call
  Future<void> forceLogout() async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      final logoutService = ref.read(logoutServiceProvider);
      await logoutService.forceLogout();
      
      state = state.copyWith(
        isLoading: false,
        isLoggedOut: true,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Force logout failed: ${e.toString()}',
      );
    }
  }

  /// Clear error state
  void clearError() {
    state = state.copyWith(error: null);
  }

  /// Reset logout state
  void reset() {
    state = const LogoutState();
  }
}

/// Provider for logout state management
final logoutProvider = StateNotifierProvider<LogoutNotifier, LogoutState>((ref) {
  return LogoutNotifier(ref);
}); 