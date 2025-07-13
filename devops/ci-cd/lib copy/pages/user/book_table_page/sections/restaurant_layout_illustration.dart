import 'package:flutter/material.dart';
import 'layouts/layout_2d.dart';
import 'layouts/layout_3d.dart';
import 'layouts/layout_vr.dart';

class RestaurantLayoutIllustration extends StatelessWidget {
  final String layoutType;
  const RestaurantLayoutIllustration({super.key, required this.layoutType});

  @override
  Widget build(BuildContext context) {
    switch (layoutType) {
      case '3D':
        return const Layout3D();
      case 'VR':
        return const LayoutVR();
      case '2D':
      default:
        return const Layout2D();
    }
  }
} 