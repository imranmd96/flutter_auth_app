import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../routes/app_router.dart';
import '../../login/data/models/auth_state.dart';
import '../../login/providers/auth_provider.dart';
import '../providers/logout_provider.dart';

/// Utility functions for logout operations
class LogoutUtils {
  /// Show logout confirmation dialog
  static Future<bool> showLogoutConfirmation(BuildContext context) async {
    return await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Logout'),
          content: const Text('Are you sure you want to logout?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Logout'),
            ),
          ],
        );
      },
    ) ?? false;
  }

  /// Perform logout with confirmation dialog
  static Future<void> logoutWithConfirmation(
    BuildContext context,
    WidgetRef ref,
  ) async {
    final confirmed = await showLogoutConfirmation(context);
    
    if (confirmed) {
      await performLogout(context, ref);
    }
  }

  /// Perform logout without confirmation
  static Future<void> performLogout(BuildContext context, WidgetRef ref) async {
    final logoutNotifier = ref.read(logoutProvider.notifier);
    final authNotifier = ref.read(authProvider.notifier);

    try {
      final success = await logoutNotifier.logout();
      
      if (success) {
        // Reset auth state
        authNotifier.state = const AuthState();
        
        // Navigate to login
        if (context.mounted) {
          context.go(AppRouteConstants.login);
        }
      } else {
        // Show error
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Logout failed'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Logout error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// Force logout (for token expiration scenarios)
  static Future<void> forceLogout(BuildContext context, WidgetRef ref) async {
    final logoutNotifier = ref.read(logoutProvider.notifier);
    final authNotifier = ref.read(authProvider.notifier);

    try {
      await logoutNotifier.forceLogout();
      
      // Reset auth state
      authNotifier.state = const AuthState();
      
      // Navigate to login
      if (context.mounted) {
        context.go(AppRouteConstants.login);
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Force logout error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// Check if user should be logged out (e.g., token expired)
  static bool shouldForceLogout(String? error) {
    if (error == null) return false;
    
    final lowerError = error.toLowerCase();
    return lowerError.contains('token expired') ||
           lowerError.contains('unauthorized') ||
           lowerError.contains('invalid token') ||
           lowerError.contains('authentication failed');
  }
}

/// Logout constants
class LogoutConstants {
  static const String logoutTitle = 'Logout';
  static const String logoutMessage = 'Are you sure you want to logout?';
  static const String logoutFailedMessage = 'Logout failed';
  static const String logoutSuccessMessage = 'Successfully logged out';
  
  static const Duration logoutTimeout = Duration(seconds: 30);
  static const int maxLogoutRetries = 3;
} 