import 'package:flutter/material.dart';

class ManageDishesPage extends StatelessWidget {
  const ManageDishesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.restaurant_menu, size: 64, color: Colors.blue),
          SizedBox(height: 16),
          Text(
            'Manage Dishes',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
} 