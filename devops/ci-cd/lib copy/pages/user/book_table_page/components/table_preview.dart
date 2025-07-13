import 'package:flutter/material.dart';
import '../sections/restaurant_layout_illustration.dart';
import '../constants/book_table_constants.dart';

class TablePreview extends StatelessWidget {
  final String layoutType;

  const TablePreview({
    super.key,
    required this.layoutType,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: BookTableConstants.previewHeight,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: RestaurantLayoutIllustration(layoutType: layoutType),
      ),
    );
  }
} 