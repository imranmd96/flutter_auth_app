import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../utils/theme.dart';
import '../../models/menu_item.dart';
import '../../providers/sidebar_provider.dart';

/// A widget that represents a single menu item in the drawer.
/// This widget handles the visual representation and interaction
/// of individual menu items in the sidebar.
class DrawerMenuItem extends StatelessWidget {
  /// The build context for navigation
  final BuildContext context;
  
  /// The notifier for handling menu item selection
  final SidebarNotifier notifier;
  
  /// The index of this menu item in the list
  final int index;
  
  /// The theme to be used for styling
  final ThemeData theme;
  
  /// Whether this menu item is currently selected
  final bool isSelected;
  
  /// The menu item data to be displayed
  final MenuItem menuItem;

  const DrawerMenuItem({
    required this.context,
    required this.notifier,
    required this.index,
    required this.theme,
    required this.isSelected,
    required this.menuItem,
    super.key,
  });

  // Constants for styling
  static const _itemMargin = EdgeInsets.symmetric(horizontal: 8, vertical: 4);
  static const _borderRadius = 12.0;
  static const _titleFontSize = 13.0;
  static const _hoverOpacity = 0.05;
  static const _selectedOpacity = 0.1;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: _itemMargin,
      decoration: BoxDecoration(
        color: isSelected ? AppColors.primary.withAlpha((_selectedOpacity * 255).round()) : Colors.transparent,
        borderRadius: BorderRadius.circular(_borderRadius),
      ),
      child: ListTile(
        leading: Icon(
          menuItem.icon,
          color: isSelected ? AppColors.primary : AppColors.textLight,
        ),
        title: Text(
          menuItem.title,
          style: TextStyle(
            color: isSelected ? AppColors.primary : AppColors.textDark,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            fontSize: _titleFontSize,
          ),
        ),
        selected: isSelected,
        onTap: () {
          notifier.selectItem(index);
          context.go(menuItem.route);
          Navigator.pop(context);
        },
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(_borderRadius),
        ),
        hoverColor: AppColors.primary.withAlpha((_hoverOpacity * 255).round()),
      ),
    );
  }
} 