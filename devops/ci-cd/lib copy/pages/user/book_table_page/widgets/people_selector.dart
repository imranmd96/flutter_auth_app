/// PeopleSelector
///
/// A section widget for selecting the number of people for a reservation.
/// Used in BookTablePage to let users specify party size.
///
/// Usage:
///   - Pass the selected count and a callback for selection.
///   - Horizontally scrollable for easy selection.

import 'package:flutter/material.dart';
import '../components/people_count_chip.dart';

class PeopleSelector extends StatelessWidget {
  final int selectedCount;
  final Function(int) onCountSelected;

  const PeopleSelector({
    super.key,
    required this.selectedCount,
    required this.onCountSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Number of People',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF4B1EFF),
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 48,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: 8,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final count = index + 1;
              return PeopleCountChip(
                count: count,
                isSelected: count == selectedCount,
                onTap: () => onCountSelected(count),
              );
            },
          ),
        ),
      ],
    );
  }
} 