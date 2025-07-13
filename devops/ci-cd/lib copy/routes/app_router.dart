import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../auth/login/data/models/auth_state.dart';
import '../auth/login/presentation/pages/login_page.dart';
import '../auth/login/providers/auth_provider.dart';
import '../auth/registration/pages/register_page.dart';
import '../debug/debug_page.dart';
import '../pages/admin/admin_dashboard_page/admin_dashboard_page.dart';
import '../pages/admin/admin_orders_page/admin_orders_page.dart';
import '../pages/admin/admin_promotions_page/admin_promotions_page.dart';
import '../pages/admin/admin_settings_page/admin_settings_page.dart';
import '../pages/admin/analytics_page/analytics_page.dart';
import '../pages/admin/bookings_management_page/bookings_management_page.dart';
import '../pages/admin/customer_management_page/customer_management_page.dart';
import '../pages/admin/manage_dishes_page/manage_dishes_page.dart';
import '../pages/admin/staff_scheduling_page/staff_scheduling_page.dart';
import '../pages/admin/table_layout_page/table_layout_page.dart';
import '../pages/dashboard_page.dart';
import '../pages/order_details_page.dart';
import '../pages/orders_page.dart';
import '../pages/profile_page.dart';
import '../pages/restaurant_details_page.dart';
import '../pages/restaurants_page.dart';
import '../pages/settings_page.dart';
import '../pages/user/home_page/home_page.dart';

// 1. Route Enum (matching user_route pattern)
enum AppRoute {
  // Auth routes
  login('/auth/login'),
  register('/auth/register'),
  
  // Customer routes
  dashboard('/dashboard'),
  home('/home'),
  profile('/profile'),
  settings('/settings'),
  restaurants('/restaurants'),
  orders('/orders'),
  debug('/debug'),
  
  // Admin routes
  adminDashboard('/admin/dashboard'),
  manageDishes('/admin/dishes'),
  adminOrders('/admin/orders'),
  bookingsManagement('/admin/bookings'),
  tableLayout('/admin/tables'),
  staffScheduling('/admin/staff'),
  adminPromotions('/admin/promotions'),
  customerManagement('/admin/customers'),
  analytics('/admin/analytics'),
  adminSettings('/admin/settings');

  final String path;
  const AppRoute(this.path);
}

// 2. GoRouter Refresh Stream (matching user_route pattern)
class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<AuthState> stream) {
    notifyListeners();
    _subscription = stream.asBroadcastStream().listen(
      (dynamic _) => notifyListeners(),
    );
  }

  late final StreamSubscription<dynamic> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}

// 3. Route Observer (matching user_route pattern)
class _RouteObserver extends NavigatorObserver {
  final Ref _ref;

  _RouteObserver(this._ref);

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    _persistRoute(route);
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    if (newRoute != null) _persistRoute(newRoute);
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    if (previousRoute != null) _persistRoute(previousRoute);
  }

  void _persistRoute(Route<dynamic> route) {
    final routeSettings = route.settings;
    if (routeSettings.name != null) {
      _persistRouteToStorage(routeSettings.name!);
    }
  }

  Future<void> _persistRouteToStorage(String route) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('last_route', route);
    } catch (e) {
      debugPrint('Failed to persist route: $e');
    }
  }
}

// 4. Route Helper Functions
bool _isPublicRoute(String route) {
  const publicRoutes = [
    '/auth/login',
    '/auth/register',
    '/debug',
  ];
  return publicRoutes.contains(route);
}

// 5. Main Router Provider (matching user_route pattern)
final appRouterProvider = Provider<GoRouter>((ref) {
  final authNotifier = ref.read(authProvider.notifier);
  final authState = ref.watch(authProvider);

  return GoRouter(
    debugLogDiagnostics: true,
    initialLocation: AppRoute.login.path,
    redirect: (context, state) async {
      final currentLocation = state.matchedLocation;
      final isAuthenticated = authState.isAuthenticated;
      final isLoggingIn = currentLocation == AppRoute.login.path;
      final isRegistering = currentLocation == AppRoute.register.path;

      // Handle unauthenticated users trying to access protected routes
      if (!isAuthenticated && !_isPublicRoute(currentLocation)) {
        return AppRoute.login.path;
      }

      // Handle authenticated users trying to access auth pages
      if (isAuthenticated && (isLoggingIn || isRegistering)) {
        return AppRoute.dashboard.path;
      }

      return null;
    },
    routes: [
      // Authentication routes
      GoRoute(
        path: AppRoute.login.path,
        name: AppRoute.login.name,
        pageBuilder: (context, state) => MaterialPage(
          key: state.pageKey,
          child: const LoginPage(),
        ),
      ),
      GoRoute(
        path: AppRoute.register.path,
        name: AppRoute.register.name,
        pageBuilder: (context, state) => MaterialPage(
          key: state.pageKey,
          child: const RegisterPage(),
        ),
      ),
      
      // Customer routes
      GoRoute(
        path: AppRoute.dashboard.path,
        name: AppRoute.dashboard.name,
        pageBuilder: (context, state) => const NoTransitionPage(
          child: DashboardPage(title: 'Dashboard'),
        ),
      ),
      GoRoute(
        path: AppRoute.home.path,
        name: AppRoute.home.name,
        pageBuilder: (context, state) => const NoTransitionPage(
          child: HomePage(),
        ),
      ),
      GoRoute(
        path: AppRoute.profile.path,
        name: AppRoute.profile.name,
        pageBuilder: (context, state) => const NoTransitionPage(
          child: ProfilePage(),
        ),
      ),
      GoRoute(
        path: AppRoute.settings.path,
        name: AppRoute.settings.name,
        pageBuilder: (context, state) => const NoTransitionPage(
          child: SettingsPage(),
        ),
      ),
      GoRoute(
        path: AppRoute.restaurants.path,
        name: AppRoute.restaurants.name,
        pageBuilder: (context, state) => const NoTransitionPage(
          child: RestaurantsPage(),
        ),
      ),
      GoRoute(
        path: '/restaurants/:id',
        pageBuilder: (context, state) => MaterialPage(
          key: state.pageKey,
          child: RestaurantDetailsPage(id: state.pathParameters['id'] ?? ''),
        ),
      ),
      GoRoute(
        path: AppRoute.orders.path,
        name: AppRoute.orders.name,
        pageBuilder: (context, state) => const NoTransitionPage(
          child: OrdersPage(),
        ),
      ),
      GoRoute(
        path: '/orders/:id',
        pageBuilder: (context, state) => MaterialPage(
          key: state.pageKey,
          child: OrderDetailsPage(id: state.pathParameters['id'] ?? ''),
        ),
      ),
      GoRoute(
        path: AppRoute.debug.path,
        name: AppRoute.debug.name,
        pageBuilder: (context, state) => MaterialPage(
          key: state.pageKey,
          child: const DebugPage(),
        ),
      ),
      
      // Admin routes
      GoRoute(
        path: AppRoute.adminDashboard.path,
        name: AppRoute.adminDashboard.name,
        pageBuilder: (context, state) => const NoTransitionPage(
          child: AdminDashboardPage(),
        ),
      ),
      GoRoute(
        path: AppRoute.manageDishes.path,
        name: AppRoute.manageDishes.name,
        pageBuilder: (context, state) => const NoTransitionPage(
          child: ManageDishesPage(),
        ),
      ),
      GoRoute(
        path: AppRoute.adminOrders.path,
        name: AppRoute.adminOrders.name,
        pageBuilder: (context, state) => const NoTransitionPage(
          child: AdminOrdersPage(),
        ),
      ),
      GoRoute(
        path: AppRoute.bookingsManagement.path,
        name: AppRoute.bookingsManagement.name,
        pageBuilder: (context, state) => const NoTransitionPage(
          child: BookingsManagementPage(),
        ),
      ),
      GoRoute(
        path: AppRoute.tableLayout.path,
        name: AppRoute.tableLayout.name,
        pageBuilder: (context, state) => const NoTransitionPage(
          child: TableLayoutPage(),
        ),
      ),
      GoRoute(
        path: AppRoute.staffScheduling.path,
        name: AppRoute.staffScheduling.name,
        pageBuilder: (context, state) => const NoTransitionPage(
          child: StaffSchedulingPage(),
        ),
      ),
      GoRoute(
        path: AppRoute.adminPromotions.path,
        name: AppRoute.adminPromotions.name,
        pageBuilder: (context, state) => const NoTransitionPage(
          child: AdminPromotionsPage(),
        ),
      ),
      GoRoute(
        path: AppRoute.customerManagement.path,
        name: AppRoute.customerManagement.name,
        pageBuilder: (context, state) => const NoTransitionPage(
          child: CustomerManagementPage(),
        ),
      ),
      GoRoute(
        path: AppRoute.analytics.path,
        name: AppRoute.analytics.name,
        pageBuilder: (context, state) => const NoTransitionPage(
          child: AnalyticsPage(),
        ),
      ),
      GoRoute(
        path: AppRoute.adminSettings.path,
        name: AppRoute.adminSettings.name,
        pageBuilder: (context, state) => const NoTransitionPage(
          child: AdminSettingsPage(),
        ),
      ),
    ],
    refreshListenable: GoRouterRefreshStream(authNotifier.stream),
    observers: [
      _RouteObserver(ref),
    ],
    errorBuilder: (context, state) => const Scaffold(
      body: Center(child: Icon(Icons.error_outline, size: 64, color: Colors.red)),
    ),
  );
});

// 6. Route Constants (for backward compatibility)
class AppRouteConstants {
  // Base routes
  static const String root = '/';
  static const String login = '/auth/login';
  static const String register = '/auth/register';
  
  // User routes
  static const String dashboard = '/dashboard';
  static const String home = '/home';
  static const String profile = '/profile';
  static const String settings = '/settings';
  static const String restaurants = '/restaurants';
  static const String orders = '/orders';
  static const String debug = '/debug';
  
  // Admin routes
  static const String admin = '/admin';
  static const String adminDashboard = '/admin/dashboard';
  static const String manageDishes = '/admin/dishes';
  static const String adminOrders = '/admin/orders';
  static const String bookingsManagement = '/admin/bookings';
  static const String tableLayout = '/admin/tables';
  static const String staffScheduling = '/admin/staff';
  static const String adminPromotions = '/admin/promotions';
  static const String customerManagement = '/admin/customers';
  static const String analytics = '/admin/analytics';
  static const String adminSettings = '/admin/settings';
} 