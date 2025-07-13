import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../routes/app_router.dart';
import '../../login/data/models/auth_state.dart';
import '../../login/providers/auth_provider.dart';
import '../providers/logout_provider.dart';

/// A reusable logout button widget
class LogoutButton extends ConsumerWidget {
  final VoidCallback? onLogoutComplete;
  final bool showLoading;
  final String? customText;
  final IconData? customIcon;
  final Color? textColor;
  final Color? iconColor;

  const LogoutButton({
    super.key,
    this.onLogoutComplete,
    this.showLoading = true,
    this.customText,
    this.customIcon,
    this.textColor,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final logoutState = ref.watch(logoutProvider);
    final logoutNotifier = ref.read(logoutProvider.notifier);
    final authNotifier = ref.read(authProvider.notifier);

    return ListTile(
      leading: logoutState.isLoading && showLoading
          ? const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : Icon(
              customIcon ?? Icons.logout,
              color: iconColor,
            ),
      title: Text(
        customText ?? 'Logout',
        style: TextStyle(color: textColor),
      ),
      onTap: logoutState.isLoading
          ? null
          : () async {
              // Perform logout
              final success = await logoutNotifier.logout();
              
              if (success) {
                // Reset auth state
                authNotifier.state = const AuthState();
                
                // Navigate to login
                if (context.mounted) {
                  context.go(AppRouteConstants.login);
                }
                
                // Call completion callback if provided
                onLogoutComplete?.call();
              } else {
                // Show error if logout failed
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(logoutState.error ?? 'Logout failed'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
    );
  }
}

/// A simple logout button for use in app bars or other compact spaces
class CompactLogoutButton extends ConsumerWidget {
  final VoidCallback? onLogoutComplete;
  final Color? iconColor;
  final String? tooltip;

  const CompactLogoutButton({
    super.key,
    this.onLogoutComplete,
    this.iconColor,
    this.tooltip,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final logoutState = ref.watch(logoutProvider);
    final logoutNotifier = ref.read(logoutProvider.notifier);
    final authNotifier = ref.read(authProvider.notifier);

    return IconButton(
      icon: logoutState.isLoading
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : Icon(Icons.logout, color: iconColor),
      tooltip: tooltip ?? 'Logout',
      onPressed: logoutState.isLoading
          ? null
          : () async {
              // Perform logout
              final success = await logoutNotifier.logout();
              
              if (success) {
                // Reset auth state
                authNotifier.state = const AuthState();
                
                // Navigate to login
                if (context.mounted) {
                  context.go(AppRouteConstants.login);
                }
                
                // Call completion callback if provided
                onLogoutComplete?.call();
              } else {
                // Show error if logout failed
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(logoutState.error ?? 'Logout failed'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
    );
  }
} 