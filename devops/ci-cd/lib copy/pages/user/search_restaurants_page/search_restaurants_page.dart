import 'package:flutter/material.dart';

class SearchRestaurantsPage extends StatelessWidget {
  const SearchRestaurantsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search, size: 64, color: Colors.blue),
          SizedBox(height: 16),
          Text(
            'Search Restaurants',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
} 