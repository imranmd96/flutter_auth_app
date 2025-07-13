import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../auth/login/providers/auth_provider.dart';
import '../sidebar/widgets/main_custom_drawer.dart';
import '../utils/theme.dart';

class DashboardPage extends ConsumerStatefulWidget {
  final String title;
  const DashboardPage({super.key, required this.title});

  @override
  ConsumerState<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends ConsumerState<DashboardPage> {
  // bool _isLoading = false;
  // String? _error;
  // DashboardData? _dashboardData;

  @override
  void initState() {
    super.initState();
   // _loadDashboardData();
  }

  // Future<void> _loadDashboardData() async {
  //   if (!mounted) return;
    
  //   setState(() {
  //     _isLoading = true;
  //     _error = null;
  //   });

  //   try {
  //     final isAdmin = widget.title.contains('Admin');
  //     final response = isAdmin
  //         ? await ref.read(adminRepositoryProvider).getDashboardData()
  //         : await ref.read(homeRepositoryProvider).getDashboardData();
      
  //     if (!mounted) return;
      
  //     setState(() {
  //       _dashboardData = response.data;
  //       _isLoading = false;
  //     });
  //   } catch (e) {
  //     if (!mounted) return;
      
  //     setState(() {
  //       _error = e.toString();
  //       _isLoading = false;
  //     });
      
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(
  //         content: Text('Failed to load dashboard data: ${e.toString()}'),
  //         backgroundColor: Colors.red,
  //       ),
  //     );
  //   }
  // }

  // Future<void> _logout() async {
  //   try {
  //     await ref.read(registrationRepositoryProvider).logout();
  //     if (!mounted) return;
  //     ref.read(routerProvider).go(AppRoutes.login);
  //   } catch (e) {
  //     if (!mounted) return;
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(
  //         content: Text('Logout failed: ${e.toString()}'),
  //         backgroundColor: Colors.red,
  //       ),
  //     );
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    // final sidebarState = ref.watch(sidebarProvider);
    // final isAdmin = widget.title.contains('Admin');
    
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        backgroundColor: AppTheme.lightTheme.colorScheme.primary,
        foregroundColor: Colors.white,
        actions: [
          // Debug logout button for testing
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              // Clear auth state for testing
              await ref.read(authProvider.notifier).forceClearSession();
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Logged out! You should be redirected to login page.'),
                    backgroundColor: Colors.green,
                  ),
                );
              }
            },
            tooltip: 'Logout (Debug)',
          ),
        ],
      ),
      drawer: const CustomDrawer(),
      body:const Text('Dashboard'),
      // body: RefreshIndicator(
      //   onRefresh: _loadDashboardData,
      //   child: _isLoading
      //       ? const Center(child: CircularProgressIndicator())
      //       : _error != null
      //           ? _buildErrorWidget()
      //           : sidebarState.menuItems.isEmpty
      //               ? const Center(child: Text('No menu items available'))
      //               : _buildDashboardContent(sidebarState, isAdmin),
      // ),
    );
  }

  // Widget _buildErrorWidget() {
  //   return Center(
  //     child: Column(
  //       mainAxisAlignment: MainAxisAlignment.center,
  //       children: [
  //         const Icon(
  //           Icons.error_outline,
  //           color: Colors.red,
  //           size: 48,
  //         ),
  //         const SizedBox(height: 16),
  //         Text(
  //           'Error loading dashboard',
  //           style: Theme.of(context).textTheme.titleLarge,
  //         ),
  //         const SizedBox(height: 8),
  //         Text(
  //           _error ?? 'Unknown error',
  //           style: Theme.of(context).textTheme.bodyMedium?.copyWith(
  //             color: Colors.red,
  //           ),
  //           textAlign: TextAlign.center,
  //         ),
  //         const SizedBox(height: 16),
  //         ElevatedButton.icon(
  //           onPressed: _loadDashboardData,
  //           icon: const Icon(Icons.refresh),
  //           label: const Text('Try Again'),
  //         ),
  //       ],
  //     ),
  //   );
  // }

  // Widget _buildDashboardContent(SidebarState sidebarState, bool isAdmin) {
  //   return SingleChildScrollView(
  //     physics: const AlwaysScrollableScrollPhysics(),
  //     padding: const EdgeInsets.all(16),
  //     child: Column(
  //       crossAxisAlignment: CrossAxisAlignment.start,
  //       children: [
  //         if (isAdmin && _dashboardData != null) ...[
  //           _buildWelcomeCard(),
  //           const SizedBox(height: 24),
  //           SizedBox(
  //             height: 180,
  //             child: _buildStatsGrid(),
  //           ),
  //           const SizedBox(height: 24),
  //         ],
  //         PageRouter.getPage(
  //           sidebarState.menuItems[sidebarState.selectedIndex].route,
  //         ),
  //       ],
  //     ),
  //   );
  // }

//   Widget _buildWelcomeCard() {
//     return Card(
//       elevation: 2,
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.circular(12),
//       ),
//       child: Padding(
//         padding: const EdgeInsets.all(20),
//         child: Row(
//           children: [
//             CircleAvatar(
//               radius: 30,
//               backgroundColor: AppColors.primary.withAlpha(25),
//               child: const Icon(
//                 Icons.admin_panel_settings,
//                 size: 30,
//                 color: AppColors.primary,
//               ),
//             ),
//             const SizedBox(width: 16),
//             const Expanded(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     'Welcome back,',
//                     style: TextStyle(
//                       fontSize: 16,
//                       color: AppColors.textLight,
//                     ),
//                   ),
//                   Text(
//                     'Admin',
//                     style: TextStyle(
//                       fontSize: 24,
//                       fontWeight: FontWeight.bold,
//                       color: AppColors.textDark,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildStatsGrid() {
//     if (_dashboardData == null || _dashboardData!.stats == null) {
//       return const SizedBox.shrink();
//     }

//     final stats = _dashboardData!.stats;
//     final statItems = [
//       StatItem(
//         title: 'Total Users',
//         value: (stats.users ?? 0).toString(),
//         icon: Icons.people,
//         color: AppColors.primary,
//       ),
//       StatItem(
//         title: 'Total Restaurants',
//         value: (stats.restaurants ?? 0).toString(),
//         icon: Icons.restaurant,
//         color: AppColors.success,
//       ),
//       StatItem(
//         title: 'Total Orders',
//         value: (stats.orders ?? 0).toString(),
//         icon: Icons.shopping_cart,
//         color: AppColors.warning,
//       ),
//     ];

//     return GridView.count(
//       shrinkWrap: true,
//       physics: const NeverScrollableScrollPhysics(),
//       crossAxisCount: 3,
//       crossAxisSpacing: 16,
//       mainAxisSpacing: 16,
//       childAspectRatio: 1.5,
//       children: statItems.map((item) => _buildStatCard(item)).toList(),
//     );
//   }

//   Widget _buildStatCard(StatItem item) {
//     return Card(
//       elevation: 2,
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.circular(12),
//       ),
//       child: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Icon(
//               item.icon,
//               color: item.color,
//               size: 32,
//             ),
//             const SizedBox(height: 8),
//             Text(
//               item.value,
//               style: Theme.of(context).textTheme.headlineSmall?.copyWith(
//                 color: item.color,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//             const SizedBox(height: 4),
//             Text(
//               item.title,
//               style: Theme.of(context).textTheme.bodyMedium?.copyWith(
//                 color: AppColors.textLight,
//               ),
//               textAlign: TextAlign.center,
//             ),
//           ],
//         ),
//       ),
//     );
//   }
}

// class StatItem {
//   final String title;
//   final String value;
//   final IconData icon;
//   final Color color;

//   const StatItem({
//     required this.title,
//     required this.value,
//     required this.icon,
//     required this.color,
//   });
// } 