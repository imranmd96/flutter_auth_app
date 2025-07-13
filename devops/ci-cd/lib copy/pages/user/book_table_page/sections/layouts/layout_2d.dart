import 'package:flutter/material.dart';
import '../../../book_table_page/constants/book_table_constants.dart';
import '../components/table_widget.dart';
import '../components/bar_widget.dart';
import '../components/entrance_widget.dart';

class Layout2D extends StatelessWidget {
  const Layout2D({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: BookTableConstants.previewHeight,
      decoration: BoxDecoration(
        color: const Color(0xFFFFD600),
        borderRadius: BorderRadius.circular(BookTableConstants.borderRadius),
      ),
      child: Stack(
        children: [
          // Tables (left)
          for (int i = 0; i < 4; i++)
            Positioned(
              left: 32,
              top: 32.0 + i * 70,
              child: TableWidget(type: 'circle', tableNumber: i + 1),
            ),
          // Tables (right)
          for (int i = 0; i < 2; i++)
            Positioned(
              right: 32,
              top: 32.0 + i * 120,
              child: TableWidget(type: 'circle', tableNumber: i + 5),
            ),
          // Large table area (right)
          const Positioned(
            right: 32,
            bottom: 32,
            child: TableWidget(type: 'large', tableNumber: 7),
          ),
          // BAR area (center)
          const Positioned(
            left: 120,
            top: 120,
            child: BarWidget(),
          ),
          // CUCINA area (center)
          const Positioned(
            left: 0,
            right: 0,
            top: 16,
            child: Center(
              child: BarWidget(label: 'CUCINA'),
            ),
          ),
          // Entrance
          const Positioned(
            left: 24,
            bottom: 18,
            child: EntranceWidget(),
          ),
        ],
      ),
    );
  }
} 