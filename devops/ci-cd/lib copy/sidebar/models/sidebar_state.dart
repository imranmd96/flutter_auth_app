import 'menu_item.dart';

/// State class for the sidebar with immutable properties
class SidebarState {
  final int selectedIndex;
  final List<MenuItem> menuItems;

  const SidebarState({
    this.selectedIndex = 0,
    this.menuItems = const [],
  });

  SidebarState copyWith({
    int? selectedIndex,
    List<MenuItem>? menuItems,
  }) {
    return SidebarState(
      selectedIndex: selectedIndex ?? this.selectedIndex,
      menuItems: menuItems ?? this.menuItems,
    );
  }
} 