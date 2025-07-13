import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_flutter_app/auth/login/providers/auth_provider.dart';
import 'package:my_flutter_app/routes/app_router.dart';
import 'package:my_flutter_app/services/app_lifecircle/app_lifecycle_service.dart';
import 'package:my_flutter_app/utils/theme.dart';
import 'package:url_strategy/url_strategy.dart';

void main() async {
  setPathUrlStrategy(); // Enables path-based URLs for Flutter web
  WidgetsFlutterBinding.ensureInitialized();
    await AppLifecycleService.initialize();
  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends ConsumerStatefulWidget {
  const MyApp({super.key});

  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> {
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    try {
      // Initialize auth state from storage
      await ref.read(authProvider.notifier).initialize();
    } catch (e) {
      // Optionally handle error
    } finally {
      if (mounted) {
        setState(() {
          _isInitialized = true;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(appRouterProvider);
    
    // Show loading screen while initializing auth
    if (!_isInitialized) {
      return MaterialApp(
        home: Scaffold(
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const CircularProgressIndicator(),
                const SizedBox(height: 16),
                Text(
                  'Initializing...',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
          ),
        ),
      );
    }
    
    return MaterialApp.router(
      title: 'Food Delivery App',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      routerConfig: router,
      debugShowCheckedModeBanner: false,
    );
  }
} 