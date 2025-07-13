import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Configuration for session management
class SessionConfig {
  static const Duration sessionTimeout = Duration(hours: 8);
  static const Duration activityTimeout = Duration(minutes: 30);
  static const Duration heartbeatInterval = Duration(seconds: 5);
  static const Duration heartbeatTimeout = Duration(seconds: 10);
  static const Duration minSessionTime = Duration(seconds: 30);
  static const Duration backgroundClearDelay = Duration(seconds: 5);
  
  // Storage keys
  static const String sessionKey = 'session_active';
  static const String lastActivityKey = 'last_activity';
  static const String heartbeatKey = 'session_heartbeat';
  static const String currentTabIdKey = 'current_tab_id';
}

/// Manages heartbeat mechanism for detecting active tabs
class HeartbeatManager {
  static Timer? _heartbeatTimer;
  static String? _currentTabId;
  static bool _debugMode = false;

  static void setDebugMode(bool enabled) => _debugMode = enabled;

  /// Set up heartbeat mechanism for current tab
  static void setupHeartbeat(String tabId) {
    _currentTabId = tabId;
    _heartbeatTimer?.cancel();
    _heartbeatTimer = Timer.periodic(SessionConfig.heartbeatInterval, (_) => _sendHeartbeat());
    
    if (_debugMode) {
      debugPrint('💓 HeartbeatManager: Heartbeat setup for tab $tabId');
    }
  }

  /// Send heartbeat for current tab
  static Future<void> _sendHeartbeat() async {
    if (_currentTabId == null) return;
    
    try {
      final prefs = await SharedPreferences.getInstance();
      final now = DateTime.now().millisecondsSinceEpoch;
      final heartbeat = '$_currentTabId|$now';
      
      final heartbeats = prefs.getStringList(SessionConfig.heartbeatKey) ?? [];
      
      // Remove old heartbeat for this tab
      heartbeats.removeWhere((h) => h.startsWith('$_currentTabId|'));
      
      // Add new heartbeat
      heartbeats.add(heartbeat);
      
      await prefs.setStringList(SessionConfig.heartbeatKey, heartbeats);
      
      if (_debugMode) {
        debugPrint('💓 HeartbeatManager: Sent heartbeat for tab $_currentTabId');
      }
    } catch (e) {
      if (_debugMode) {
        debugPrint('💓 HeartbeatManager: Error sending heartbeat: $e');
      }
    }
  }

  /// Remove current tab's heartbeat
  static Future<void> removeCurrentTabHeartbeat() async {
    if (_currentTabId == null) return;
    
    try {
      final prefs = await SharedPreferences.getInstance();
      final heartbeats = prefs.getStringList(SessionConfig.heartbeatKey) ?? [];
      
      heartbeats.removeWhere((h) => h.startsWith('$_currentTabId|'));
      await prefs.setStringList(SessionConfig.heartbeatKey, heartbeats);
      
      if (_debugMode) {
        debugPrint('💓 HeartbeatManager: Removed heartbeat for tab $_currentTabId');
      }
    } catch (e) {
      if (_debugMode) {
        debugPrint('💓 HeartbeatManager: Error removing heartbeat: $e');
      }
    }
  }

  /// Get count of active tabs
  static Future<int> getActiveTabsCount() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final heartbeats = prefs.getStringList(SessionConfig.heartbeatKey) ?? [];
      
      // Clean up stale heartbeats
      final now = DateTime.now().millisecondsSinceEpoch;
      final validHeartbeats = heartbeats.where((heartbeat) {
        try {
          final parts = heartbeat.split('|');
          if (parts.length != 2) return false;
          
          final timestamp = int.tryParse(parts[1]);
          if (timestamp == null) return false;
          
          final timeSince = now - timestamp;
          return timeSince < SessionConfig.heartbeatTimeout.inMilliseconds;
        } catch (e) {
          return false;
        }
      }).toList();
      
      // Update stored heartbeats if we cleaned up any
      if (validHeartbeats.length != heartbeats.length) {
        await prefs.setStringList(SessionConfig.heartbeatKey, validHeartbeats);
      }
      
      if (_debugMode) {
        debugPrint('💓 HeartbeatManager: Active tabs count: ${validHeartbeats.length}');
      }
      
      return validHeartbeats.length;
    } catch (e) {
      if (_debugMode) {
        debugPrint('💓 HeartbeatManager: Error getting active tabs count: $e');
      }
      return 0;
    }
  }

  /// Clean up stale heartbeats
  static Future<void> cleanupStaleHeartbeats() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final heartbeats = prefs.getStringList(SessionConfig.heartbeatKey) ?? [];
      
      final now = DateTime.now().millisecondsSinceEpoch;
      final validHeartbeats = heartbeats.where((heartbeat) {
        try {
          final parts = heartbeat.split('|');
          if (parts.length != 2) return false;
          
          final timestamp = int.tryParse(parts[1]);
          if (timestamp == null) return false;
          
          final timeSince = now - timestamp;
          return timeSince < SessionConfig.heartbeatTimeout.inMilliseconds;
        } catch (e) {
          return false;
        }
      }).toList();
      
      if (validHeartbeats.length != heartbeats.length) {
        await prefs.setStringList(SessionConfig.heartbeatKey, validHeartbeats);
        if (_debugMode) {
          debugPrint('💓 HeartbeatManager: Cleaned up ${heartbeats.length - validHeartbeats.length} stale heartbeats');
        }
      }
    } catch (e) {
      if (_debugMode) {
        debugPrint('💓 HeartbeatManager: Error cleaning stale heartbeats: $e');
      }
    }
  }

  /// Clear all heartbeat data
  static Future<void> clearAllHeartbeats() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(SessionConfig.heartbeatKey);
      
      if (_debugMode) {
        debugPrint('💓 HeartbeatManager: Cleared all heartbeats');
      }
    } catch (e) {
      if (_debugMode) {
        debugPrint('💓 HeartbeatManager: Error clearing heartbeats: $e');
      }
    }
  }

  /// Dispose heartbeat manager
  static void dispose() {
    _heartbeatTimer?.cancel();
    _heartbeatTimer = null;
    _currentTabId = null;
  }
}

/// Manages tab identification and persistence
class TabManager {
  static String? _currentTabId;
  static bool _debugMode = false;

  static void setDebugMode(bool enabled) => _debugMode = enabled;

  /// Get existing tab ID or create a new one
  static Future<String> getOrCreateTabId() async {
    if (_currentTabId != null) {
      return _currentTabId!;
    }
    
    try {
      final prefs = await SharedPreferences.getInstance();
      final existingTabId = prefs.getString(SessionConfig.currentTabIdKey);
      
      if (existingTabId != null && existingTabId.isNotEmpty) {
        _currentTabId = existingTabId;
        if (_debugMode) {
          debugPrint('🏷️ TabManager: Using existing tab ID: $_currentTabId');
        }
        return existingTabId;
      }
      
      // Create new tab ID
      final newTabId = 'tab_${DateTime.now().millisecondsSinceEpoch}_${(1000 + (DateTime.now().microsecond % 9000))}';
      _currentTabId = newTabId;
      
      await prefs.setString(SessionConfig.currentTabIdKey, newTabId);
      
      if (_debugMode) {
        debugPrint('🏷️ TabManager: Created new tab ID: $_currentTabId');
      }
      
      return newTabId;
    } catch (e) {
      if (_debugMode) {
        debugPrint('🏷️ TabManager: Error getting/creating tab ID: $e');
      }
      // Fallback to timestamp-based ID
      final fallbackId = 'tab_${DateTime.now().millisecondsSinceEpoch}';
      _currentTabId = fallbackId;
      return fallbackId;
    }
  }

  /// Get current tab ID
  static String? get currentTabId => _currentTabId;

  /// Clear current tab ID
  static Future<void> clearCurrentTabId() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(SessionConfig.currentTabIdKey);
      _currentTabId = null;
      
      if (_debugMode) {
        debugPrint('🏷️ TabManager: Cleared current tab ID');
      }
    } catch (e) {
      if (_debugMode) {
        debugPrint('🏷️ TabManager: Error clearing tab ID: $e');
      }
    }
  }
}

/// Manages activity tracking and timeouts
class ActivityManager {
  static Timer? _activityTimer;
  static bool _debugMode = false;

  static void setDebugMode(bool enabled) => _debugMode = enabled;

  /// Set up activity tracking
  static void setupActivityTracking() {
    if (_debugMode) {
      debugPrint('📊 ActivityManager: Setting up activity tracking');
    }
    updateLastActivity();
  }

  /// Update last activity timestamp
  static Future<void> updateLastActivity() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final now = DateTime.now().millisecondsSinceEpoch;
      await prefs.setInt(SessionConfig.lastActivityKey, now);
      
      if (_debugMode) {
        debugPrint('📊 ActivityManager: Updated last activity to ${DateTime.now()}');
      }
    } catch (e) {
      if (_debugMode) {
        debugPrint('📊 ActivityManager: Error updating activity: $e');
      }
    }
  }

  /// Check if session is inactive for too long
  static Future<bool> isSessionInactive() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final lastActivity = prefs.getInt(SessionConfig.lastActivityKey);
      
      if (lastActivity == null) {
        if (_debugMode) {
          debugPrint('📊 ActivityManager: No last activity found');
        }
        return true; // Inactive if no activity recorded
      }
      
      final now = DateTime.now().millisecondsSinceEpoch;
      final timeSinceActivity = now - lastActivity;
      final isInactive = timeSinceActivity > SessionConfig.activityTimeout.inMilliseconds;
      
      if (_debugMode) {
        debugPrint('📊 ActivityManager: Time since activity: ${timeSinceActivity}ms, inactive: $isInactive');
      }
      
      return isInactive;
    } catch (e) {
      if (_debugMode) {
        debugPrint('📊 ActivityManager: Error checking inactivity: $e');
      }
      return true; // Assume inactive on error
    }
  }

  /// Clear activity data
  static Future<void> clearActivityData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(SessionConfig.lastActivityKey);
      
      if (_debugMode) {
        debugPrint('📊 ActivityManager: Cleared activity data');
      }
    } catch (e) {
      if (_debugMode) {
        debugPrint('📊 ActivityManager: Error clearing activity data: $e');
      }
    }
  }

  /// Dispose activity manager
  static void dispose() {
    _activityTimer?.cancel();
    _activityTimer = null;
  }
}

/// Manages app lifecycle events
class LifecycleManager {
  static Timer? _backgroundTimer;
  static final List<String> _pendingEvents = [];
  static bool _debugMode = false;
  static DateTime? _sessionStartTime;

  static void setDebugMode(bool enabled) => _debugMode = enabled;
  static void setSessionStartTime(DateTime? time) => _sessionStartTime = time;

  /// Handle app lifecycle change
  static Future<void> handleLifecycleChange(String state, bool isInitialized) async {
    if (!isInitialized) {
      // Queue the event for later processing
      _pendingEvents.add(state);
      if (_debugMode) {
        debugPrint('🔄 LifecycleManager: Queued event "$state" (not initialized)');
      }
      return;
    }

    await _processLifecycleEvent(state);
  }

  /// Process lifecycle event
  static Future<void> _processLifecycleEvent(String state) async {
    if (_debugMode) {
      debugPrint('🔄 LifecycleManager: Processing lifecycle event: $state');
    }

    switch (state) {
      case 'paused':
      case 'inactive':
      case 'detached':
        await _handleBackgrounding();
        break;
      case 'resumed':
        await _handleAppResume();
        break;
      default:
        if (_debugMode) {
          debugPrint('🔄 LifecycleManager: Unknown lifecycle state: $state');
        }
    }
  }

  /// Handle app backgrounding
  static Future<void> _handleBackgrounding() async {
    if (_sessionStartTime == null) return;
    
    final sessionDuration = DateTime.now().difference(_sessionStartTime!);
    if (sessionDuration < SessionConfig.minSessionTime) {
      if (_debugMode) {
        debugPrint('🔄 LifecycleManager: Session too short (${sessionDuration.inSeconds}s), not clearing');
      }
      return;
    }

    // Start background timer
    _backgroundTimer?.cancel();
    _backgroundTimer = Timer(SessionConfig.backgroundClearDelay, () async {
      if (_debugMode) {
        debugPrint('🔄 LifecycleManager: Background timer expired, clearing session');
      }
      await SessionManager.clearSession();
    });

    if (_debugMode) {
      debugPrint('🔄 LifecycleManager: App backgrounding, started clear timer');
    }
  }

  /// Handle app resume
  static Future<void> _handleAppResume() async {
    // Cancel background timer if app is resumed
    _backgroundTimer?.cancel();
    _backgroundTimer = null;
    
    if (_debugMode) {
      debugPrint('🔄 LifecycleManager: App resumed, cancelled clear timer');
    }
  }

  /// Process pending events
  static Future<void> processPendingEvents() async {
    if (_pendingEvents.isEmpty) return;
    
    if (_debugMode) {
      debugPrint('🔄 LifecycleManager: Processing ${_pendingEvents.length} pending events');
    }
    
    final events = List<String>.from(_pendingEvents);
    _pendingEvents.clear();
    
    for (final event in events) {
      await _processLifecycleEvent(event);
    }
  }

  /// Get pending events for debugging
  static List<String> getPendingEvents() => List.from(_pendingEvents);

  /// Dispose lifecycle manager
  static void dispose() {
    _backgroundTimer?.cancel();
    _backgroundTimer = null;
    _pendingEvents.clear();
  }
}

/// Main session manager that orchestrates all components
class SessionManager {
  static bool _isSessionActive = false;
  static bool _debugMode = false;
  static bool _isInitialized = false;
  static Future<void>? _initializationPromise;
  static int _initializationCount = 0;
  static DateTime? _sessionStartTime;
  static bool _clearOnFreshStart = false; // Flag to clear session on fresh app start

  /// Enable debug mode for testing
  static void enableDebugMode() {
    _debugMode = true;
    HeartbeatManager.setDebugMode(true);
    TabManager.setDebugMode(true);
    ActivityManager.setDebugMode(true);
    LifecycleManager.setDebugMode(true);
    debugPrint('🚀 SessionManager: Debug mode enabled');
  }

  /// Enable clearing session on fresh app start (for development)
  static void enableClearOnFreshStart() {
    _clearOnFreshStart = true;
    debugPrint('🚀 SessionManager: Clear on fresh start enabled');
  }

  /// Disable clearing session on fresh app start
  static void disableClearOnFreshStart() {
    _clearOnFreshStart = false;
    debugPrint('🚀 SessionManager: Clear on fresh start disabled');
  }

  /// Disable debug mode
  static void disableDebugMode() {
    _debugMode = false;
    HeartbeatManager.setDebugMode(false);
    TabManager.setDebugMode(false);
    ActivityManager.setDebugMode(false);
    LifecycleManager.setDebugMode(false);
    debugPrint('🚀 SessionManager: Debug mode disabled');
  }

  /// Check if debug mode is enabled
  static bool get isDebugMode => _debugMode;

  /// Check if session manager is initialized
  static bool get isInitialized => _isInitialized;

  /// Get initialization count for debugging
  static int get initializationCount => _initializationCount;

  /// Check if session is currently active
  static bool get isSessionActive => _isSessionActive;

  /// Initialize session management
  static Future<void> initialize() async {
    if (_initializationPromise != null) {
      await _initializationPromise;
      return;
    }

    _initializationPromise = _performInitialization();
    await _initializationPromise;
  }

  /// Perform the actual initialization
  static Future<void> _performInitialization() async {
    _initializationCount++;
    
    if (_debugMode) {
      debugPrint('🚀 SessionManager: Initializing (count: $_initializationCount)');
    }

    try {
      // Set debug mode for all components
      HeartbeatManager.setDebugMode(_debugMode);
      TabManager.setDebugMode(_debugMode);
      ActivityManager.setDebugMode(_debugMode);
      LifecycleManager.setDebugMode(_debugMode);

      // Check for fresh app start
      await _checkForFreshAppStart();

      // Check for app restart
      await _checkForAppRestart();

      // Check if we have a valid session
      final isValid = await _checkSessionValidity();
      _isSessionActive = isValid;

      if (isValid) {
        // Set up activity tracking and heartbeat for existing session
        ActivityManager.setupActivityTracking();
        final tabId = await TabManager.getOrCreateTabId();
        HeartbeatManager.setupHeartbeat(tabId);
        
        if (_debugMode) {
          debugPrint('🚀 SessionManager: Existing session restored');
        }
      } else {
        if (_debugMode) {
          debugPrint('🚀 SessionManager: No valid session found');
        }
      }

      _isInitialized = true;
      
      if (_debugMode) {
        debugPrint('🚀 SessionManager: Initialization complete');
      }
    } catch (e) {
      if (_debugMode) {
        debugPrint('🚀 SessionManager: Error during initialization: $e');
      }
      _isSessionActive = false;
      _isInitialized = true;
    }
  }

  /// Check for fresh app start and clear session if needed
  static Future<void> _checkForFreshAppStart() async {
    if (!_clearOnFreshStart) return;

    try {
      final prefs = await SharedPreferences.getInstance();
      final lastActivity = prefs.getInt(SessionConfig.lastActivityKey);
      
      if (lastActivity == null) {
        // No previous activity, this is a fresh start
        await clearSession();
        if (_debugMode) {
          debugPrint('🚀 SessionManager: Fresh app start detected, cleared session');
        }
      }
    } catch (e) {
      if (_debugMode) {
        debugPrint('🚀 SessionManager: Error checking fresh start: $e');
      }
    }
  }

  /// Check for app restart
  static Future<void> _checkForAppRestart() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final lastActivity = prefs.getInt(SessionConfig.lastActivityKey);
      
      if (lastActivity != null) {
        final now = DateTime.now().millisecondsSinceEpoch;
        final timeSince = now - lastActivity;
        
        // If more than 1 hour has passed, consider it an app restart
        if (timeSince > const Duration(hours: 1).inMilliseconds) {
          await clearSession();
          if (_debugMode) {
            debugPrint('🚀 SessionManager: App restart detected, cleared session');
          }
        }
      }
    } catch (e) {
      if (_debugMode) {
        debugPrint('🚀 SessionManager: Error checking app restart: $e');
      }
    }
  }

  /// Check if current session is valid
  static Future<bool> _checkSessionValidity() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final hasAuthState = prefs.containsKey('auth_state');
      
      if (!hasAuthState) {
        return false;
      }

      // Check for activity timeout
      final isInactive = await ActivityManager.isSessionInactive();
      if (isInactive) {
        return false;
      }

      // Check for active tabs
      final activeTabsCount = await HeartbeatManager.getActiveTabsCount();
      return activeTabsCount > 0;
    } catch (e) {
      if (_debugMode) {
        debugPrint('🚀 SessionManager: Error checking session validity: $e');
      }
      return false;
    }
  }

  /// Check if session is valid
  static Future<bool> isSessionValid() async {
    if (!_isInitialized) {
      if (_debugMode) {
        debugPrint('🔍 SessionManager: Not initialized, session invalid');
      }
      return false;
    }

    try {
      // Check if session is marked as active
      if (!_isSessionActive) {
        if (_debugMode) {
          debugPrint('🔍 SessionManager: Session not active');
        }
        return false;
      }

      // Check if we have stored auth state
      final prefs = await SharedPreferences.getInstance();
      final hasAuthState = prefs.containsKey('auth_state');
      
      if (!hasAuthState) {
        if (_debugMode) {
          debugPrint('🔍 SessionManager: No auth state found');
        }
        return false;
      }

      // Check for activity timeout
      final isInactive = await ActivityManager.isSessionInactive();
      if (isInactive) {
        if (_debugMode) {
          debugPrint('🔍 SessionManager: Session inactive due to timeout');
        }
        return false;
      }

      // Check for active tabs (heartbeat mechanism)
      final activeTabsCount = await HeartbeatManager.getActiveTabsCount();
      if (activeTabsCount == 0) {
        if (_debugMode) {
          debugPrint('🔍 SessionManager: No active tabs detected');
        }
        return false;
      }

      if (_debugMode) {
        debugPrint('🔍 SessionManager: Session is valid');
      }
      return true;
    } catch (e) {
      if (_debugMode) {
        debugPrint('🔍 SessionManager: Error checking session validity: $e');
      }
      return false;
    }
  }

  /// Start a new session
  static Future<void> startSession() async {
    try {
      _isSessionActive = true;
      _sessionStartTime = DateTime.now();
      
      // Set up activity tracking
      ActivityManager.setupActivityTracking();
      
      // Set up heartbeat for current tab
      final tabId = await TabManager.getOrCreateTabId();
      HeartbeatManager.setupHeartbeat(tabId);
      
      // Mark session as active
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(SessionConfig.sessionKey, true);
      
      if (_debugMode) {
        debugPrint('🚀 SessionManager: Session started');
      }
    } catch (e) {
      if (_debugMode) {
        debugPrint('🚀 SessionManager: Error starting session: $e');
      }
    }
  }

  /// Clear session and all stored data
  static Future<void> clearSession() async {
    try {
      _isSessionActive = false;
      _sessionStartTime = null;
      
      // Clear all stored data
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(SessionConfig.sessionKey);
      await prefs.remove(SessionConfig.lastActivityKey);
      await prefs.remove(SessionConfig.heartbeatKey);
      await prefs.remove(SessionConfig.currentTabIdKey);
      await prefs.remove('auth_state');
      
      // Clean up components
      ActivityManager.clearActivityData();
      HeartbeatManager.removeCurrentTabHeartbeat();
      TabManager.clearCurrentTabId();
      
      if (_debugMode) {
        debugPrint('🚀 SessionManager: Session cleared');
      }
    } catch (e) {
      if (_debugMode) {
        debugPrint('🚀 SessionManager: Error clearing session: $e');
      }
    }
  }

  /// Get session info for debugging
  static Future<Map<String, dynamic>> getSessionInfo() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final lastActivity = prefs.getInt(SessionConfig.lastActivityKey);
      final now = DateTime.now().millisecondsSinceEpoch;
      final timeSinceActivity = lastActivity != null ? now - lastActivity : 0;
      
      final activeTabsCount = await HeartbeatManager.getActiveTabsCount();
      final isInactive = await ActivityManager.isSessionInactive();
      
      return {
        'sessionActive': _isSessionActive,
        'isInitialized': _isInitialized,
        'timeSinceActivity': timeSinceActivity,
        'activeTabsCount': activeTabsCount,
        'isInactive': isInactive,
        'currentTabId': TabManager.currentTabId,
        'hasAuthState': prefs.containsKey('auth_state'),
      };
    } catch (e) {
      return {
        'error': e.toString(),
        'sessionActive': _isSessionActive,
        'isInitialized': _isInitialized,
      };
    }
  }

  /// Handle app lifecycle events
  static Future<void> handleAppLifecycleChange(String state) async {
    if (!_isInitialized) {
      LifecycleManager.handleLifecycleChange(state, false);
      return;
    }
    
    LifecycleManager.handleLifecycleChange(state, true);
  }

  /// Force clear session on app restart
  static Future<void> clearSessionOnAppRestart() async {
    await clearSession();
    if (_debugMode) {
      debugPrint('🚀 SessionManager: Session cleared on app restart');
    }
  }

  /// Force reinitialize session manager for testing
  static Future<void> forceReinitialize() async {
    _isInitialized = false;
    _initializationPromise = null;
    await initialize();
  }

  /// Manually clear session for testing purposes
  static Future<void> clearSessionForTesting() async {
    await clearSession();
    if (_debugMode) {
      debugPrint('🚀 SessionManager: Session cleared for testing');
    }
  }

  /// Get pending lifecycle events for debugging
  static List<String> getPendingLifecycleEvents() {
    return LifecycleManager.getPendingEvents();
  }

  /// Get active tabs count (convenience method for debugging)
  static Future<int> getActiveTabsCount() async {
    return await HeartbeatManager.getActiveTabsCount();
  }

  /// Get current tab ID (convenience method for debugging)
  static String? get currentTabId => TabManager.currentTabId;

  /// Clear all heartbeats (convenience method for debugging)
  static Future<void> clearAllHeartbeats() async {
    await HeartbeatManager.clearAllHeartbeats();
  }

  /// Clean up stale heartbeats (convenience method for debugging)
  static Future<void> cleanupStaleHeartbeats() async {
    await HeartbeatManager.cleanupStaleHeartbeats();
  }

  /// Dispose session manager
  static void dispose() {
    HeartbeatManager.dispose();
    ActivityManager.dispose();
    LifecycleManager.dispose();
    _isSessionActive = false;
    _isInitialized = false;
    _initializationPromise = null;
  }
} 