// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';

// import '../controllers/sidebar_controller.dart';

// class CustomBottomNav extends ConsumerWidget {
//   const CustomBottomNav({super.key});

//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     final sidebarState = ref.watch(sidebarControllerProvider);
//     final controller = ref.read(sidebarControllerProvider.notifier);

//     return BottomNavigationBar(
//       type: BottomNavigationBarType.fixed,
//       backgroundColor: Colors.white,
//       selectedItemColor: Colors.blue,
//       unselectedItemColor: Colors.grey,
//       currentIndex: sidebarState.selectedIndex,
//       onTap: controller.selectItem,
//       items: const <BottomNavigationBarItem>[
//         BottomNavigationBarItem(
//           icon: Icon(Icons.home),
//           label: 'Home',
//         ),
//         BottomNavigationBarItem(
//           icon: Icon(Icons.person),
//           label: 'User',
//         ),
//         BottomNavigationBarItem(
//           icon: Icon(Icons.admin_panel_settings),
//           label: 'Admin',
//         ),
//         BottomNavigationBarItem(
//           icon: Icon(Icons.settings),
//           label: 'Settings',
//         ),
//       ],
//     );
//   }
// } 