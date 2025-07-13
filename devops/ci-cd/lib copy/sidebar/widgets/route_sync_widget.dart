import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/sidebar_provider.dart';

/// A widget that listens to route changes and synchronizes the sidebar
/// This widget should be placed high in the widget tree to ensure it catches all route changes
class RouteSyncWidget extends ConsumerStatefulWidget {
  final Widget child;

  const RouteSyncWidget({
    super.key,
    required this.child,
  });

  @override
  ConsumerState<RouteSyncWidget> createState() => _RouteSyncWidgetState();
}

class _RouteSyncWidgetState extends ConsumerState<RouteSyncWidget> {
  String? _lastRoute;
  bool _isInitialized = false;
  int _syncAttempts = 0;
  static const int _maxSyncAttempts = 5;

  @override
  void initState() {
    super.initState();
    // Delay the initial sync to ensure router is fully initialized
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scheduleInitialSync();
    });
  }

  void _scheduleInitialSync() {
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        setState(() {
          _isInitialized = true;
        });
        _syncWithCurrentRoute();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Only sync if we're initialized to avoid early access issues
    if (_isInitialized) {
      _syncWithCurrentRoute();
    }
  }

  void _syncWithCurrentRoute() {
    if (_syncAttempts >= _maxSyncAttempts) {
      return;
    }

    _syncAttempts++;

    try {
      // Try to get the current route from the router state
      final routerState = GoRouterState.of(context);
      if (routerState == null) {
        _syncWithAlternativeMethod();
        return;
      }

      final currentRoute = routerState.matchedLocation;
      
      // Skip syncing if we're on the root route (/) as it's likely temporary
      if (currentRoute == '/' && _syncAttempts < _maxSyncAttempts) {
        Future.delayed(const Duration(milliseconds: 100), () {
          if (mounted) {
            _syncWithCurrentRoute();
          }
        });
        return;
      }
      
      // Only sync if the route has actually changed
      if (_lastRoute != currentRoute) {
        _lastRoute = currentRoute;
        _syncAttempts = 0; // Reset attempts on successful sync
        
        // Get the sidebar notifier and sync with current route
        final sidebarNotifier = ref.read(sidebarProvider.notifier);
        sidebarNotifier.syncWithCurrentRoute(currentRoute);
      }
    } catch (e) {
      // If GoRouterState.of(context) fails, try alternative approach
      _syncWithAlternativeMethod();
    }
  }

  void _syncWithAlternativeMethod() {
    try {
      // Alternative method: try to get route from window location (web only)
      if (identical(0, 0.0)) { // Check if running on web
        // For web, we can try to get the route from the browser
        final currentPath = Uri.base.path;
        
        // Skip syncing if we're on the root route (/) as it's likely temporary
        if (currentPath == '/' && _syncAttempts < _maxSyncAttempts) {
          Future.delayed(const Duration(milliseconds: 100), () {
            if (mounted) {
              _syncWithCurrentRoute();
            }
          });
          return;
        }
        
        if (currentPath.isNotEmpty && _lastRoute != currentPath) {
          _lastRoute = currentPath;
          _syncAttempts = 0; // Reset attempts on successful sync
          
          // Get the sidebar notifier and sync with current route
          final sidebarNotifier = ref.read(sidebarProvider.notifier);
          sidebarNotifier.syncWithCurrentRoute(currentPath);
        }
      }
    } catch (e) {
      // Schedule another attempt if we haven't reached max attempts
      if (_syncAttempts < _maxSyncAttempts) {
        Future.delayed(const Duration(milliseconds: 100), () {
          if (mounted) {
            _syncWithCurrentRoute();
          }
        });
      }
    }
  }
} 