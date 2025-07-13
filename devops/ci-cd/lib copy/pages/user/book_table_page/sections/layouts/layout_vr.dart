import 'package:flutter/material.dart';
import '../../../book_table_page/constants/book_table_constants.dart';
import '../components/table_widget.dart';

class LayoutVR extends StatelessWidget {
  const LayoutVR({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: BookTableConstants.previewHeight,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF6A82FB), Color(0xFFFC5C7D)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(BookTableConstants.borderRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.blueAccent.withOpacity(0.3),
            blurRadius: 32,
            spreadRadius: 8,
          ),
        ],
      ),
      child: Stack(
        children: [
          // Subtle background pattern (dots)
          Positioned.fill(
            child: CustomPaint(
              painter: _DotsPatternPainter(),
            ),
          ),
          // VR tables
          for (int i = 0; i < 3; i++)
            Positioned(
              left: 60.0 + i * 80,
              top: 120,
              child: TableWidget(type: 'vr', tableNumber: i + 1),
            ),
          // VR Walkway
          Positioned(
            left: 40,
            bottom: 32,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF6A82FB), Color(0xFFFC5C7D)],
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.blueAccent.withOpacity(0.15),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Text(
                'WALKWAY',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
            ),
          ),
          // Virtual overlay
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(BookTableConstants.borderRadius),
                color: Colors.white.withOpacity(0.08),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DotsPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.08)
      ..style = PaintingStyle.fill;
    for (double y = 0; y < size.height; y += 32) {
      for (double x = 0; x < size.width; x += 32) {
        canvas.drawCircle(Offset(x, y), 3, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
} 