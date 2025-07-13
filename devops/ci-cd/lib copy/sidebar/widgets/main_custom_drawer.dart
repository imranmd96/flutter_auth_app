import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../controllers/drawer_profile_image_controller.dart';
import '../providers/sidebar_provider.dart';
import 'drawer_footer.dart';
import 'menu/drawer_menu_list.dart';
import 'user_profile_section.dart';

class CustomDrawer extends ConsumerWidget {
  const CustomDrawer({super.key});

  // Constants for styling
  static const _drawerBackgroundColor = Color(0xFFF6F7FB);
  static const _footerBackgroundColor = Colors.white;
  static const _footerShadowColor = Colors.black;
  static const _footerShadowOpacity = 0.05;
  static const _footerShadowBlurRadius = 10.0;
  static const _footerShadowOffset = Offset(0, -5);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final drawerController = ref.watch(drawerProfileImageNotifier);
    return Drawer(
      child: Container(
        color: _drawerBackgroundColor,
        child: Column(
          children: [
            UserProfileSection(drawerProfileImageNotifier: drawerController),
            Expanded(child: DrawerMenuList(Theme.of(context))),
            DrawerFooter(ref.read(sidebarProvider.notifier)),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuSection(BuildContext context) {
    return Expanded(
      child: DrawerMenuList(Theme.of(context)),
    );
  }

  Widget _buildFooterSection(WidgetRef ref) {
    return Container(
      decoration: BoxDecoration(
        color: _footerBackgroundColor,
        boxShadow: [
          BoxShadow(
            color: _footerShadowColor.withOpacity(_footerShadowOpacity),
            blurRadius: _footerShadowBlurRadius,
            offset: _footerShadowOffset,
          ),
        ],
      ),
      child: DrawerFooter(ref.read(sidebarProvider.notifier)),
    );
  }
} 