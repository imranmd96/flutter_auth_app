import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_flutter_app/services/app_lifecycle_service.dart';

class AppLifecycleState {
  final bool isFirstLaunch;
  final bool isAppRestarted;
  final bool isPageRefreshed;
  final DateTime? lastActivity;
  final String? sessionId;
  final bool isLoading;
  final bool hasError;
  final Duration? inactiveDuration;

  const AppLifecycleState({
    this.isFirstLaunch = false,
    this.isAppRestarted = false,
    this.isPageRefreshed = false,
    this.lastActivity,
    this.sessionId,
    this.isLoading = true,
    this.hasError = false,
    this.inactiveDuration,
  });

  bool get isSessionExpired {
    if (inactiveDuration == null) return false;
    return inactiveDuration! > const Duration(minutes: 10);
  }

  AppLifecycleState copyWith({
    bool? isFirstLaunch,
    bool? isAppRestarted,
    bool? isPageRefreshed,
    DateTime? lastActivity,
    String? sessionId,
    bool? isLoading,
    bool? hasError,
    Duration? inactiveDuration,
  }) => AppLifecycleState(
    isFirstLaunch: isFirstLaunch ?? this.isFirstLaunch,
    isAppRestarted: isAppRestarted ?? this.isAppRestarted,
    isPageRefreshed: isPageRefreshed ?? this.isPageRefreshed,
    lastActivity: lastActivity ?? this.lastActivity,
    sessionId: sessionId ?? this.sessionId,
    isLoading: isLoading ?? this.isLoading,
    hasError: hasError ?? this.hasError,
    inactiveDuration: inactiveDuration ?? this.inactiveDuration,
  );
}

class AppLifecycleNotifier extends StateNotifier<AppLifecycleState> {
  AppLifecycleNotifier() : super(const AppLifecycleState()) {
    _initialize();
  }

  Future<void> _initialize() async {
    try {
      state = state.copyWith(isLoading: true);
      await AppLifecycleService.initialize();
      
      final status = await AppLifecycleService.getSessionStatus();
      final lastActivity = await AppLifecycleService.getLastActivity();
      final inactiveDuration = lastActivity != null 
          ? DateTime.now().difference(lastActivity) 
          : null;

      state = AppLifecycleState(
        isFirstLaunch: status['isFirstLaunch'] ?? false,
        isAppRestarted: status['isAppRestarted'] ?? false,
        isPageRefreshed: status['isPageRefreshed'] ?? false,
        lastActivity: lastActivity,
        sessionId: status['sessionId'],
        inactiveDuration: inactiveDuration,
        isLoading: false,
      );

      if (kDebugMode) {
        debugPrint('''
Lifecycle State Initialized:
- First launch: ${state.isFirstLaunch}
- Restarted: ${state.isAppRestarted}
- Refreshed: ${state.isPageRefreshed}
- Last activity: ${state.lastActivity}
- Inactive for: ${state.inactiveDuration?.inMinutes} minutes
''');
      }
    } catch (e, stack) {
      debugPrint('Lifecycle initialization failed: $e\n$stack');
      state = state.copyWith(
        isLoading: false,
        hasError: true,
      );
    }
  }

  /// Records user activity and updates state
  Future<void> recordUserActivity() async {
    try {
      await AppLifecycleService.recordUserActivity();
      final lastActivity = await AppLifecycleService.getLastActivity();
      state = state.copyWith(
        lastActivity: lastActivity,
        inactiveDuration: Duration.zero,
      );
    } catch (e) {
      debugPrint('Failed to record activity: $e');
    }
  }

  /// Checks and updates inactivity status
  Future<void> checkInactivity() async {
    try {
      final lastActivity = await AppLifecycleService.getLastActivity();
      if (lastActivity == null) return;

      final duration = DateTime.now().difference(lastActivity);
      state = state.copyWith(inactiveDuration: duration);
      
      final isExpired = duration > const Duration(minutes: 10);
      if (isExpired) {
        debugPrint('Session expired: inactive for ${duration.inMinutes} minutes');
      }
    } catch (e) {
      debugPrint('Inactivity check failed: $e');
    }
  }

  /// Resets all lifecycle flags (call during logout)
  Future<void> reset() async {
    try {
      await AppLifecycleService.reset();
      state = state.copyWith(
        isFirstLaunch: false,
        isAppRestarted: false,
        isPageRefreshed: false,
        lastActivity: null,
        inactiveDuration: null,
      );
    } catch (e) {
      debugPrint('Lifecycle reset failed: $e');
    }
  }

  /// Force refresh the lifecycle state
  Future<void> refresh() async {
    state = state.copyWith(isLoading: true);
    await _initialize();
  }
}

final appLifecycleProvider = StateNotifierProvider<AppLifecycleNotifier, AppLifecycleState>((ref) {
  return AppLifecycleNotifier();
});

/// Helper provider to check session expiration
final sessionExpiredProvider = Provider<bool>((ref) {
  return ref.watch(appLifecycleProvider.select((state) => state.isSessionExpired));
});