import 'package:flutter/material.dart';

class AdminPromotionsPage extends StatelessWidget {
  const AdminPromotionsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.local_offer, size: 64, color: Colors.orange),
          SizedBox(height: 16),
          Text(
            'Admin Promotions',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
} 