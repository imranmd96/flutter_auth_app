import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:my_flutter_app/auth/login/login_page.dart';
import 'package:my_flutter_app/pages/dashboard_page.dart';
import 'package:my_flutter_app/pages/home_page.dart';
import 'package:my_flutter_app/services/app_lifecycle_service.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AppLifecycleService.initialize();
  runApp(const ProviderScope(child: MyApp()));
}

final _router = GoRouter(
  initialLocation: '/login',
  routes: [
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginPage(),
    ),
    GoRoute(
      path: '/',
      builder: (context, state) => const MyHomePage(),
    ),
    GoRoute(
      path: '/home',
      builder: (context, state) => const DashboardPage(),
    ),
    GoRoute(
      path: '/dashboard',
      builder: (context, state) => const DashboardPage(),
    ),
    GoRoute(
      path: '/profile',
      builder: (context, state) => const DashboardPage(),
    ),
    GoRoute(
      path: '/settings',
      builder: (context, state) => const DashboardPage(),
    ),
  ],
);

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp.router(
        title: 'Flutter Demo',
        theme: ThemeData(useMaterial3: true),
        routerConfig: _router,
      );
} 