/// LayoutSelector
///
/// A section widget for selecting the restaurant layout (2D, 3D, VR) using a segmented control.
/// Used in BookTablePage to let users choose their preferred table view.
///
/// Usage:
///   - Pass the selected layout and a callback for selection.
///   - Visually styled to match the app's design.

import 'package:flutter/material.dart';
import '../constants/book_table_constants.dart';

class LayoutSelector extends StatelessWidget {
  final String selectedLayout;
  final Function(String) onLayoutSelected;

  const LayoutSelector({
    super.key,
    required this.selectedLayout,
    required this.onLayoutSelected,
  });

  @override
  Widget build(BuildContext context) {
    final layouts = ['2D', '3D', 'VR'];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Restaurant Layout',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: BookTableConstants.primaryColor,
          ),
        ),
        const SizedBox(height: 20),
        Row(
          children: List.generate(layouts.length, (i) {
            final isSelected = selectedLayout == layouts[i];
            return Expanded(
              child: GestureDetector(
                onTap: () => onLayoutSelected(layouts[i]),
                child: Container(
                  height: BookTableConstants.layoutCardHeight,
                  decoration: BoxDecoration(
                    color: isSelected ? BookTableConstants.orange : BookTableConstants.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(i == 0 ? BookTableConstants.borderRadius : 0),
                      bottomLeft: Radius.circular(i == 0 ? BookTableConstants.borderRadius : 0),
                      topRight: Radius.circular(i == layouts.length - 1 ? BookTableConstants.borderRadius : 0),
                      bottomRight: Radius.circular(i == layouts.length - 1 ? BookTableConstants.borderRadius : 0),
                    ),
                    border: Border.all(color: BookTableConstants.white, width: 2),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    layouts[i],
                    style: TextStyle(
                      color: isSelected ? BookTableConstants.white : BookTableConstants.primaryColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 28,
                    ),
                  ),
                ),
              ),
            );
          }),
        ),
      ],
    );
  }
} 