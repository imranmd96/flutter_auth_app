import 'package:flutter/material.dart';
import '../constants/book_table_constants.dart';

class DateTimeChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final Color color;

  const DateTimeChip({
    super.key,
    required this.label,
    required this.isSelected,
    required this.onTap,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: BookTableConstants.chipHeight,
        padding: const EdgeInsets.symmetric(horizontal: 28),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(BookTableConstants.borderRadius),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: const TextStyle(
            color: BookTableConstants.primaryColor,
            fontWeight: FontWeight.bold,
            fontSize: 26,
          ),
        ),
      ),
    );
  }
} 