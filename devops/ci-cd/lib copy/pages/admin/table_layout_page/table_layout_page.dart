import 'package:flutter/material.dart';

class TableLayoutPage extends StatelessWidget {
  const TableLayoutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.table_chart, size: 64, color: Colors.blue),
          SizedBox(height: 16),
          Text(
            'Table Layout',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
} 