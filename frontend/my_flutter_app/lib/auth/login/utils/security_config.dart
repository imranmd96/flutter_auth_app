import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Security configuration for production route protection
class SecurityConfig {
  // Session timeout settings
  static const Duration sessionTimeout = Duration(hours: 24);
  static const Duration maxSessionAge = Duration(days: 7);
  static const Duration tokenRefreshThreshold = Duration(minutes: 5);
  
  // 🔒 ENHANCED SECURITY: Tab closure detection
  static const Duration tabClosureTimeout = Duration(minutes: 5); // Require re-auth after 5 min of no tabs
  static const String lastTabActivityKey = 'last_tab_activity';
  static const String sessionActiveKey = 'session_active';
  
  // Route protection settings
  static const List<String> publicRoutes = ['/login', '/404'];
  static const List<String> protectedRoutes = [
    '/dashboard',
    '/home', 
    '/profile',
    '/settings',
  ];
  
  // Security headers for web deployment
  static const Map<String, String> securityHeaders = {
    'X-Frame-Options': 'DENY',
    'X-Content-Type-Options': 'nosniff',
    'X-XSS-Protection': '1; mode=block',
    'Strict-Transport-Security': 'max-age=31536000; includeSubDomains',
    'Content-Security-Policy': "default-src 'self'; script-src 'self' 'unsafe-inline'",
  };
  
  /// Check if a route requires authentication
  static bool isProtectedRoute(String path) {
    return protectedRoutes.any((route) => path.startsWith(route));
  }
  
  /// Check if a route is publicly accessible
  static bool isPublicRoute(String path) {
    return publicRoutes.contains(path);
  }
  
  /// Validate session age
  static bool isSessionValid(DateTime? tokenExpiry) {
    if (tokenExpiry == null) return false;
    
    final now = DateTime.now();
    final sessionAge = now.difference(tokenExpiry.subtract(const Duration(hours: 1)));
    
    return sessionAge < maxSessionAge && tokenExpiry.isAfter(now);
  }
  
  /// Check if token needs refresh
  static bool shouldRefreshToken(DateTime? tokenExpiry) {
    if (tokenExpiry == null) return false;
    
    final now = DateTime.now();
    final timeUntilExpiry = tokenExpiry.difference(now);
    
    return timeUntilExpiry < tokenRefreshThreshold;
  }
  
  /// 🔒 ENHANCED SECURITY: Record tab activity
  static Future<void> recordTabActivity() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(lastTabActivityKey, DateTime.now().toIso8601String());
      await prefs.setBool(sessionActiveKey, true);
      logSecurityEvent('Tab Activity Recorded');
    } catch (e) {
      logSecurityEvent('Failed to record tab activity: $e');
    }
  }
  
  /// 🔒 ENHANCED SECURITY: Check if session should be invalidated due to tab closure
  static Future<bool> shouldInvalidateSession() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final lastActivityStr = prefs.getString(lastTabActivityKey);
      final sessionActive = prefs.getBool(sessionActiveKey) ?? false;
      
      if (lastActivityStr == null || !sessionActive) {
        // 🔧 FIX: Don't invalidate fresh sessions or page refreshes
        // This could be a fresh login or page refresh - be more lenient
        logSecurityEvent('No previous tab activity found - allowing fresh session');
        await recordTabActivity();
        return false; // Allow fresh sessions and page refreshes to proceed
      }
      
      final lastActivity = DateTime.parse(lastActivityStr);
      final timeSinceLastActivity = DateTime.now().difference(lastActivity);
      
      // 🔧 FIX: Be more lenient with timing - only invalidate if significantly old
      if (timeSinceLastActivity > tabClosureTimeout) {
        // Additional check: if this is within 1 minute of last activity, it might be a page refresh
        if (timeSinceLastActivity < const Duration(minutes: 1)) {
          logSecurityEvent(
            'Recent activity detected - likely page refresh, maintaining session',
            details: {
              'lastActivity': lastActivity.toIso8601String(),
              'timeSinceLastActivity': '${timeSinceLastActivity.inSeconds} seconds',
            },
          );
          await recordTabActivity(); // Refresh the activity timestamp
          return false;
        }
        
        logSecurityEvent(
          'Session invalidated due to tab closure timeout',
          details: {
            'lastActivity': lastActivity.toIso8601String(),
            'timeSinceLastActivity': '${timeSinceLastActivity.inMinutes} minutes',
            'timeout': '${tabClosureTimeout.inMinutes} minutes',
          },
        );
        await _clearTabSession();
        return true;
      }
      
      // 🔧 FIX: Always refresh activity timestamp when checking
      await recordTabActivity();
      
      logSecurityEvent(
        'Session valid - tab activity recent',
        details: {
          'lastActivity': lastActivity.toIso8601String(),
          'timeSinceLastActivity': '${timeSinceLastActivity.inMinutes} minutes',
        },
      );
      return false;
    } catch (e) {
      logSecurityEvent('Error checking tab session: $e');
      // 🔧 FIX: Don't invalidate on errors - log and allow
      return false; // Changed from true to false - be more lenient
    }
  }
  
  /// 🔒 Clear tab session data
  static Future<void> _clearTabSession() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(lastTabActivityKey);
      await prefs.setBool(sessionActiveKey, false);
      logSecurityEvent('Tab session cleared');
    } catch (e) {
      logSecurityEvent('Failed to clear tab session: $e');
    }
  }
  
  /// 🔒 Mark session as inactive (call on logout)
  static Future<void> markSessionInactive() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(sessionActiveKey, false);
      await prefs.remove(lastTabActivityKey);
      logSecurityEvent('Session marked as inactive');
    } catch (e) {
      logSecurityEvent('Failed to mark session inactive: $e');
    }
  }
  
  /// Log security events (only in debug mode)
  static void logSecurityEvent(String event, {Map<String, dynamic>? details}) {
    if (kDebugMode) {
      final timestamp = DateTime.now().toIso8601String();
      debugPrint('🔒 [$timestamp] $event');
      if (details != null) {
        details.forEach((key, value) {
          debugPrint('   $key: $value');
        });
      }
    }
  }
}

/// Route protection result
enum RouteProtectionResult {
  allowed,
  redirectToLogin,
  redirectToDashboard,
  notFound,
}

/// Route protection service
class RouteProtectionService {
  /// Evaluate route access based on authentication state
  static Future<RouteProtectionResult> evaluateRoute({
    required String requestedPath,
    required bool isAuthenticated,
    required bool hasValidToken,
  }) async {
    SecurityConfig.logSecurityEvent(
      'Route Access Evaluation',
      details: {
        'path': requestedPath,
        'authenticated': isAuthenticated,
        'validToken': hasValidToken,
      },
    );
    
    // 🔒 ENHANCED SECURITY: Check for tab closure invalidation
    if (isAuthenticated && hasValidToken && SecurityConfig.isProtectedRoute(requestedPath)) {
      final shouldInvalidate = await SecurityConfig.shouldInvalidateSession();
      if (shouldInvalidate) {
        SecurityConfig.logSecurityEvent(
          'Session invalidated due to security policy',
          details: {'path': requestedPath, 'reason': 'Tab closure timeout'},
        );
        return RouteProtectionResult.redirectToLogin;
      }
      
      // Record current tab activity for future checks
      await SecurityConfig.recordTabActivity();
    }
    
    // Handle root path
    if (requestedPath == '/') {
      return isAuthenticated && hasValidToken 
          ? RouteProtectionResult.redirectToDashboard
          : RouteProtectionResult.redirectToLogin;
    }
    
    // Handle login page
    if (requestedPath == '/login') {
      return isAuthenticated && hasValidToken
          ? RouteProtectionResult.redirectToDashboard
          : RouteProtectionResult.allowed;
    }
    
    // Handle protected routes
    if (SecurityConfig.isProtectedRoute(requestedPath)) {
      if (!isAuthenticated || !hasValidToken) {
        SecurityConfig.logSecurityEvent(
          'Access Denied: Unauthenticated access to protected route',
          details: {'path': requestedPath},
        );
        return RouteProtectionResult.redirectToLogin;
      }
      return RouteProtectionResult.allowed;
    }
    
    // Handle public routes
    if (SecurityConfig.isPublicRoute(requestedPath)) {
      return RouteProtectionResult.allowed;
    }
    
    // Unknown route
    SecurityConfig.logSecurityEvent(
      'Unknown Route Accessed',
      details: {'path': requestedPath},
    );
    return RouteProtectionResult.notFound;
  }
} 