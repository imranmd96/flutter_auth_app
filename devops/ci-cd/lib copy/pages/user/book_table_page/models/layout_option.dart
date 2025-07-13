import 'package:flutter/material.dart';

class LayoutOption {
  final String title;
  final IconData icon;

  const LayoutOption({
    required this.title,
    required this.icon,
  });

  factory LayoutOption.fromMap(Map<String, dynamic> map) {
    return LayoutOption(
      title: map['title'] as String,
      icon: map['icon'] as IconData,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'icon': icon,
    };
  }
} 