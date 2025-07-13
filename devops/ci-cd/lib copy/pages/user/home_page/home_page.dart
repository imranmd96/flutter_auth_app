import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_flutter_app/sidebar/widgets/main_custom_drawer.dart';
import 'package:my_flutter_app/utils/theme.dart';

import '../../../auth/login/providers/auth_provider.dart';
import 'sections/action_buttons_row.dart';
import 'sections/category_chips_list.dart';
import 'sections/custom_search_bar.dart';
import 'sections/glass_top_bar.dart';
import 'sections/nearby_restaurants_list.dart';
import 'sections/recommendations_carousel.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final userName = authState.userName ?? '';
    const avatarUrl = 'https://randomuser.me/api/portraits/men/32.jpg';
    final categories = [
      {'label': 'Pizza', 'icon': Icons.local_pizza, 'color': const Color(0xFFFF4B8B)},
      {'label': 'Sushi', 'icon': Icons.rice_bowl, 'color': const Color(0xFF00CFFF)},
      {'label': 'Burgers', 'icon': Icons.lunch_dining, 'color': const Color(0xFF7B61FF)},
      {'label': 'Vegan', 'icon': Icons.eco, 'color': const Color(0xFFB6E900)},
      {'label': 'Dessert', 'icon': Icons.icecream, 'color': const Color(0xFFFFA800)},
    ];
    final recommendations = [
      {
        'image': 'https://images.pexels.com/photos/70497/pexels-photo-70497.jpeg',
        'name': 'Taco Fiesta',
        'desc': 'Best Tacos in Town',
        'rating': 4.8,
      },
      {
        'image': 'https://images.pexels.com/photos/461382/pexels-photo-461382.jpeg',
        'name': 'Pasta House',
        'desc': 'Authentic Italian Pasta',
        'rating': 4.7,
      },
      {
        'image': 'https://images.pexels.com/photos/461382/pexels-photo-461382.jpeg',
        'name': 'Vegan Delight',
        'desc': 'Fresh & Healthy',
        'rating': 4.9,
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Orders'),
        backgroundColor: AppTheme.lightTheme.colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      drawer: const CustomDrawer(),
      backgroundColor: const Color(0xFFF6F7FB),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Glassmorphism Top Bar
                GlassTopBar(userName: userName, avatarUrl: avatarUrl),
                const SizedBox(height: 24),
                // Search Bar
                const CustomSearchBar(),
                const SizedBox(height: 28),
                // Category Chips
                CategoryChipsList(categories: categories),
                const SizedBox(height: 32),
                // Nearby Restaurants
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Nearby Restaurants',
                      style: TextStyle(
                        color: Color(0xFF4B1EFF),
                        fontWeight: FontWeight.bold,
                        fontSize: 24,
                      ),
                    ),
                    TextButton(
                      onPressed: () {},
                      child: const Text('See All', style: TextStyle(color: Color(0xFF4B1EFF), fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                const NearbyRestaurantsList(),
                const SizedBox(height: 32),
                // Action Buttons
                const ActionButtonsRow(),
                const SizedBox(height: 36),
                // Recommendations Carousel
                const Text(
                  'You might like',
                  style: TextStyle(
                    color: Color(0xFF4B1EFF),
                    fontWeight: FontWeight.bold,
                    fontSize: 24,
                  ),
                ),
                const SizedBox(height: 18),
                RecommendationsCarousel(recommendations: recommendations),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }
} 