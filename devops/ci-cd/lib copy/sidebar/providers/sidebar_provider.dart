import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/login/data/models/auth_state.dart';
import '../../auth/login/data/models/user_type.dart';
import '../../core/constants/storage_keys.dart';
import '../models/menu_item.dart';
import '../models/sidebar_state.dart';

/// Notifier class for managing sidebar state
class SidebarNotifier extends StateNotifier<SidebarState> {
  final Ref ref;
  
  SidebarNotifier(this.ref) : super(const SidebarState(menuItems: MenuItems.userMenuItems)) {
    _initializeMenuItems();
  }

  Future<void> _initializeMenuItems() async {
    final authState = await AuthState.load(storageKey: StorageKeys.authState.value);
    _updateMenuItems(authState.userType);
  }

  void _updateMenuItems(String userType) {
    if (userType == UserType.admin) {
      state = state.copyWith(menuItems: MenuItems.adminMenuItems);
    } else if (userType == UserType.user) {
      state = state.copyWith(menuItems: MenuItems.userMenuItems);
    }
  }

  /// Selects a menu item by index
  void selectItem(int index) {
    if (index >= 0 && index < state.menuItems.length) {
      state = state.copyWith(selectedIndex: index);
    }
  }

  /// Gets the current route for the selected menu item
  String getCurrentRoute() {
    return state.menuItems[state.selectedIndex].route;
  }

  /// Synchronizes the selected index with the current route
  /// This method should be called when the route changes or on page reload
  void syncWithCurrentRoute(String currentRoute) {
    final index = _findMenuItemIndexByRoute(currentRoute);
    
    if (index != -1 && index != state.selectedIndex) {
      state = state.copyWith(selectedIndex: index);
    }
  }

  /// Finds the index of a menu item by its route
  int _findMenuItemIndexByRoute(String route) {
    for (int i = 0; i < state.menuItems.length; i++) {
      if (state.menuItems[i].route == route) {
        return i;
      }
    }
    return -1; // Not found
  }

  /// Gets the menu item index for a given route
  int getMenuItemIndexForRoute(String route) {
    return _findMenuItemIndexByRoute(route);
  }
}

/// Provider for the sidebar state
final sidebarProvider = StateNotifierProvider<SidebarNotifier, SidebarState>((ref) {
  return SidebarNotifier(ref);
}); 