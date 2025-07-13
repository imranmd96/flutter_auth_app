import 'package:flutter/material.dart';
import '../../constants/book_table_constants.dart';

class BarWidget extends StatelessWidget {
  final String label;

  const BarWidget({
    super.key,
    this.label = 'BAR',
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: label == 'BAR' ? 80 : 100,
      height: label == 'BAR' ? 40 : 48,
      decoration: BoxDecoration(
        color: BookTableConstants.orange,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.12),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Center(
        child: Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
      ),
    );
  }
} 