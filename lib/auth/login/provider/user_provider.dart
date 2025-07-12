import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'login_provider.dart';

// Utility providers for easy access to user data across the app

/// Provider to get the current user's email
/// Returns null if user is not authenticated
final userEmailProvider = Provider<String?>((ref) {
  final authState = ref.watch(authNotifierProvider);
  return authState.user?.email;
});

/// Provider to get the current user's name
/// Returns null if user is not authenticated
final userNameProvider = Provider<String?>((ref) {
  final authState = ref.watch(authNotifierProvider);
  return authState.user?.name;
});

/// Provider to get the current user object
/// Returns null if user is not authenticated
final currentUserProvider = Provider<AuthUser?>((ref) {
  final authState = ref.watch(authNotifierProvider);
  return authState.user;
});

/// Provider to check if user is authenticated
final isAuthenticatedProvider = Provider<bool>((ref) {
  final authState = ref.watch(authNotifierProvider);
  return authState.isAuthenticated;
}); 