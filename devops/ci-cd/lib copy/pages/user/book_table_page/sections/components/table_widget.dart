import 'package:flutter/material.dart';
import '../../constants/book_table_constants.dart';

class TableWidget extends StatelessWidget {
  final String type;
  final VoidCallback? onTap;
  final int tableNumber;

  const TableWidget({
    super.key,
    required this.type,
    this.onTap,
    required this.tableNumber,
  });

  @override
  Widget build(BuildContext context) {
    Widget tableWidget;
    switch (type) {
      case 'circle':
        tableWidget = _buildCircleTable();
      case '3d':
        tableWidget = _build3DTable();
      case 'vr':
        tableWidget = _buildVRTable();
      case 'large':
        tableWidget = _buildLargeTable();
      default:
        tableWidget = _buildCircleTable();
    }

    return Stack(
      children: [
        tableWidget,
        Positioned(
          right: 0,
          top: 0,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: BookTableConstants.accentBlue,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              '$tableNumber',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCircleTable() {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          color: BookTableConstants.orange,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.10),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Center(
          child: Icon(
            Icons.chair,
            color: BookTableConstants.accentBlue,
            size: 32,
            shadows: [
              Shadow(color: Colors.black.withOpacity(0.15), blurRadius: 6),
            ],
          ),
        ),
      ),
    );
  }

  Widget _build3DTable() {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 60,
        height: 40,
        decoration: BoxDecoration(
          color: BookTableConstants.orange,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: const Center(
          child: Icon(Icons.chair, color: BookTableConstants.accentBlue, size: 28),
        ),
      ),
    );
  }

  Widget _buildVRTable() {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: BookTableConstants.orange,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.blueAccent.withOpacity(0.25),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: const Center(
        child: Icon(Icons.chair, color: Colors.white, size: 24),
      ),
    );
  }

  Widget _buildLargeTable() {
    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        color: Colors.transparent,
        border: Border.all(color: BookTableConstants.accentBlue, width: 4),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.10),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildTableRect(),
              const SizedBox(width: 8),
              _buildTableRect(),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildTableRect(),
              const SizedBox(width: 8),
              _buildTableRect(),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTableRect() {
    return Container(
      width: 36,
      height: 28,
      decoration: BoxDecoration(
        color: BookTableConstants.orange,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.10),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
    );
  }
} 