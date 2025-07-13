import 'package:flutter/material.dart';
import '../components/category_chip.dart';

class CategoryChipsList extends StatelessWidget {
  final List<Map<String, dynamic>> categories;
  const CategoryChipsList({super.key, required this.categories});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, i) {
          final cat = categories[i];
          return CategoryChip(
            label: cat['label'] as String,
            icon: cat['icon'] as IconData,
            color: cat['color'] as Color,
          );
        },
      ),
    );
  }
} 