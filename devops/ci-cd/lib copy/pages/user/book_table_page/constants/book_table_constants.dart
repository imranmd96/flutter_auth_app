import 'package:flutter/material.dart';

class BookTableConstants {
  static const Color primaryColor = Color(0xFF002366); // Deep blue for text
  static const Color accentBlue = Color(0xFF1769FF); // Button blue
  static const Color orange = Color(0xFFFF9000); // Orange chip
  static const Color pink = Color(0xFFFF6F91); // Pink chip
  static const Color backgroundColor = Color(0xFFF5F5F5);
  static const Color textColor = Color(0xFF333333);
  static const Color white = Colors.white;
  
  static const List<String> defaultDates = ['Today', 'Tomorrow', 'Wed', 'Thu', 'Fri'];
  static const List<String> defaultTimes = ['12:00', '13:00', '14:00', '19:00', '20:00'];
  static const List<int> defaultPeople = [2, 4, 6, 8];
  
  static const List<Map<String, dynamic>> layoutOptions = [
    {'title': '2D', 'icon': Icons.grid_on},
    {'title': '3D', 'icon': Icons.view_in_ar},
    {'title': 'VR', 'icon': Icons.vrpano},
  ];
  
  static const double defaultPadding = 16.0;
  static const double defaultSpacing = 24.0;
  static const double chipHeight = 56.0;
  static const double layoutCardHeight = 56.0;
  static const double previewHeight = 500.0;
  static const double buttonHeight = 64.0;
  static const double borderRadius = 16.0;
} 