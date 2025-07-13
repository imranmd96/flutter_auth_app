import 'package:flutter/material.dart';

/// Model class for menu items in the sidebar
class MenuItem {
  final String title;
  final IconData icon;
  final String route;

  const MenuItem({
    required this.title,
    required this.icon,
    required this.route,
  });
}

/// Menu items data for different user roles
class MenuItems {
  static const List<MenuItem> adminMenuItems = [
    MenuItem(
      title: 'Users',
      icon: Icons.people,
      route: '/users',
    ),
    MenuItem(
      title: 'Restaurants',
      icon: Icons.restaurant,
      route: '/restaurants',
    ),
    MenuItem(
      title: 'Orders',
      icon: Icons.shopping_cart,
      route: '/orders',
    ),
    MenuItem(
      title: 'Settings',
      icon: Icons.settings,
      route: '/settings',
    ),
    MenuItem(
      title: 'Debug',
      icon: Icons.bug_report,
      route: '/debug',
    ),
  ];

  static const List<MenuItem> userMenuItems = [
    MenuItem(
      title: 'Dashboard',
      icon: Icons.dashboard,
      route: '/dashboard',
    ),
    MenuItem(
      title: 'Home',
      icon: Icons.home,
      route: '/home',
    ),
    MenuItem(
      title: 'Orders',
      icon: Icons.shopping_cart,
      route: '/orders',
    ),
    MenuItem(
      title: 'Favorites',
      icon: Icons.favorite,
      route: '/favorites',
    ),
    MenuItem(
      title: 'Profile',
      icon: Icons.person,
      route: '/profile',
    ),
    MenuItem(
      title: 'Settings',
      icon: Icons.settings,
      route: '/settings',
    ),
    MenuItem(
      title: 'Debug',
      icon: Icons.bug_report,
      route: '/debug',
    ),
  ];
} 