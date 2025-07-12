import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:my_flutter_app/pages/home_content_page.dart';
import 'package:my_flutter_app/pages/profile_page.dart';
import 'package:my_flutter_app/pages/settings_page.dart';


class DashboardPage extends ConsumerStatefulWidget {
  const DashboardPage({super.key});

  @override
  ConsumerState<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends ConsumerState<DashboardPage> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const HomeContentPage(),
    const ProfilePage(),
    const SettingsPage(),
  ];

  @override
  void initState() {
    super.initState();
    // Set initial tab based on current route
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final location = GoRouterState.of(context).uri.path;
      _updateIndexFromRoute(location);
    });
  }

  void _updateIndexFromRoute(String location) {
    int newIndex = 0;
    switch (location) {
      case '/home':
        newIndex = 0;
        break;
      case '/profile':
        newIndex = 1;
        break;
      case '/settings':
        newIndex = 2;
        break;
    }
    if (newIndex != _currentIndex) {
      setState(() => _currentIndex = newIndex);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        body: _pages[_currentIndex],
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() => _currentIndex = index);
            // Update URL based on selected tab
            switch (index) {
              case 0:
                context.go('/home');
                break;
              case 1:
                context.go('/profile');
                break;
              case 2:
                context.go('/settings');
                break;
            }
          },
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
            BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
            BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Settings'),
          ],
        ),
      );
} 