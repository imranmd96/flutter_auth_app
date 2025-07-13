import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/sidebar_provider.dart';
import 'drawer_menu_item.dart';

/// A widget that displays the list of menu items in the drawer.
/// This widget is responsible for rendering the list of menu items
/// and handling their selection state.
class DrawerMenuList extends ConsumerWidget {
  /// The theme to be used for styling the menu items
  final ThemeData theme;
  
  const DrawerMenuList(this.theme, {super.key});

  // Constants for styling
  static const _verticalPadding = EdgeInsets.symmetric(vertical: 16);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sidebarState = ref.watch(sidebarProvider);
    final notifier = ref.read(sidebarProvider.notifier);

    return ListView.builder(
      padding: _verticalPadding,
      itemCount: sidebarState.menuItems.length,
      itemBuilder: (context, index) {
        final menuItem = sidebarState.menuItems[index];
        final isSelected = sidebarState.selectedIndex == index;

        return DrawerMenuItem(
          context: context,
          notifier: notifier,
          index: index,
          theme: theme,
          isSelected: isSelected,
          menuItem: menuItem,
        );
      },
    );
  }
} 