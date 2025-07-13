import 'package:flutter/material.dart';

class BookingsManagementPage extends StatelessWidget {
  const BookingsManagementPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.calendar_today, size: 64, color: Colors.blue),
          SizedBox(height: 16),
          Text(
            'Bookings Management',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
} 