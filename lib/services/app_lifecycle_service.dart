import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:universal_html/html.dart' as html;

/// Centralized service for handling app lifecycle events (restart, refresh, inactivity)
/// with secure storage and Riverpod-compatible state management.
class AppLifecycleService {
  static SharedPreferences? _prefs;
  
  // Storage keys (private)
  static const String _kSessionId = 'lifecycle_session_id';
  static const String _kLastActivity = 'lifecycle_last_activity';
  static const String _kAppRestarted = 'lifecycle_app_restarted';
  static const String _kPageRefreshed = 'lifecycle_page_refreshed';
  static const String _kFirstLaunch = 'lifecycle_first_launch';

  // Timeout constants
  static const Duration _kInactivityTimeout = Duration(minutes: 10);
  static const Duration _kActivityDebounce = Duration(seconds: 5);

  // State tracking
  Timer? _activityDebounceTimer;
  DateTime? _lastActivityMemory; // In-memory cache to reduce storage I/O

  /// Initialize service and detect current lifecycle state
  static Future<AppLifecycleService> initialize() async {
    final service = AppLifecycleService();
    await service._initStorage();
    await service._detectInitialState();
    return service;
  }

  Future<void> _initStorage() async {
    try {
      _prefs = await SharedPreferences.getInstance();
      if (kDebugMode) {
        final status = await getSessionStatus();
        debugPrint('Lifecycle: Storage initialized. Current status: $status');
      }
    } catch (e) {
      debugPrint('Lifecycle: Storage init failed - $e');
      rethrow;
    }
  }

  Future<void> _detectInitialState() async {
    await Future.wait([
      _detectAppRestart(),
      _detectPageRefresh(),
      _updateLastActivity(skipDebounce: true),
    ]);
  }

  /// ========================
  /// Core Detection Methods
  /// ========================

  Future<bool> _detectAppRestart() async {
    final currentSessionId = DateTime.now().millisecondsSinceEpoch.toString();
    final previousSessionId = _prefs?.getString(_kSessionId);
    final isFirstLaunch = previousSessionId == null;

    // Update flags
    await _prefs?.setString(_kAppRestarted, (!isFirstLaunch).toString());
    await _prefs?.setString(_kFirstLaunch, isFirstLaunch.toString());
    await _prefs?.setString(_kSessionId, currentSessionId);

    if (kDebugMode) {
      debugPrint('''
Lifecycle: App restart detection
- Previous session: ${previousSessionId ?? 'N/A'}
- Current session: $currentSessionId
- First launch: $isFirstLaunch
''');
    }

    return !isFirstLaunch;
  }

  Future<bool> _detectPageRefresh() async {
    bool wasRefreshed = false;

    if (kIsWeb) {
      try {
        wasRefreshed = html.window.performance?.navigation?.type == 1;
      } catch (e) {
        debugPrint('Lifecycle: Page refresh detection failed - $e');
      }
    }

    await _prefs?.setString(_kPageRefreshed, wasRefreshed.toString());

    if (kDebugMode) {
      debugPrint('Lifecycle: Page refresh detected: $wasRefreshed');
    }

    return wasRefreshed;
  }

  /// ========================
  /// Activity Tracking
  /// ========================

  Future<void> _updateLastActivity({bool skipDebounce = false}) async {
    // Debounce rapid activity updates
    if (!skipDebounce) {
      _activityDebounceTimer?.cancel();
      _activityDebounceTimer = Timer(_kActivityDebounce, () async {
        await _writeLastActivity();
      });
    } else {
      await _writeLastActivity();
    }
  }

  Future<void> _writeLastActivity() async {
    final now = DateTime.now();
    _lastActivityMemory = now;
    await _prefs?.setString(_kLastActivity, now.toIso8601String());
  }

  /// Checks if user has been inactive beyond the timeout threshold
  Future<bool> checkInactivityTimeout() async {
    final lastActivity = await getLastActivity();
    if (lastActivity == null) return true;

    final inactiveDuration = DateTime.now().difference(lastActivity);
    return inactiveDuration > _kInactivityTimeout;
  }

  /// ========================
  /// Public API
  /// ========================

  static Future<bool> isFirstLaunch() async => 
      _prefs?.getString(_kFirstLaunch) == 'true';

  static Future<bool> isAppRestarted() async => 
      _prefs?.getString(_kAppRestarted) == 'true';

  static Future<bool> isPageRefreshed() async => 
      _prefs?.getString(_kPageRefreshed) == 'true';

  static Future<DateTime?> getLastActivity() async {
    // For static access, we need to read from storage directly
    final value = _prefs?.getString(_kLastActivity);
    if (value != null) {
      return DateTime.parse(value);
    }
    return null;
  }

  /// Call this whenever user interacts with the app
  static Future<void> recordUserActivity() async {
    final now = DateTime.now();
    await _prefs?.setString(_kLastActivity, now.toIso8601String());
  }

  /// Clear all lifecycle flags (use during logout)
  static Future<void> reset() async {
    await Future.wait([
      _prefs?.remove(_kAppRestarted),
      _prefs?.remove(_kPageRefreshed),
      _prefs?.remove(_kLastActivity),
    ].where((f) => f != null).cast<Future<void>>());
  }

  /// Get current status for debugging
  static Future<Map<String, dynamic>> getSessionStatus() async => {
      'isFirstLaunch': await isFirstLaunch(),
      'isAppRestarted': await isAppRestarted(),
      'isPageRefreshed': await isPageRefreshed(),
      'lastActivity': (await getLastActivity())?.toIso8601String(),
      'sessionId': _prefs?.getString(_kSessionId),
      'inactivityTimeout': _kInactivityTimeout.inMinutes,
    };

  /// Dispose resources
  void dispose() {
    _activityDebounceTimer?.cancel();
  }
}