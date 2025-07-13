import 'package:flutter/material.dart';
import '../../../book_table_page/constants/book_table_constants.dart';
import '../components/table_widget.dart';
import '../components/bar_widget.dart';
import '../components/entrance_widget.dart';

class Layout3D extends StatelessWidget {
  const Layout3D({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: BookTableConstants.previewHeight,
      decoration: BoxDecoration(
        color: const Color(0xFFFFA726),
        borderRadius: BorderRadius.circular(BookTableConstants.borderRadius),
      ),
      child: Stack(
        children: [
          // Tables (left)
          for (int i = 0; i < 4; i++)
            Positioned(
              left: 32,
              top: 32.0 + i * 70,
              child: TableWidget(type: '3d', tableNumber: i + 1),
            ),
          // Tables (right)
          for (int i = 0; i < 2; i++)
            Positioned(
              right: 32,
              top: 32.0 + i * 120,
              child: TableWidget(type: '3d', tableNumber: i + 5),
            ),
          // Large table area (right)
          const Positioned(
            right: 32,
            bottom: 32,
            child: TableWidget(type: '3d', tableNumber: 7),
          ),
          // BAR area (center)
          const Positioned(
            left: 120,
            top: 120,
            child: BarWidget(),
          ),
          // CUCINA area (top right)
          const Positioned(
            right: 130,
            top: 16,
            child: BarWidget(label: 'CUCINA'),
          ),
          // Entrance
          const Positioned(
            left: 100,
            bottom: 0,
            child: EntranceWidget(),
          ),
          // 3D effect shadow
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              height: 24,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    Colors.black.withOpacity(0.08),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
} 