import 'package:flutter/material.dart';

class CustomSearchBar extends StatelessWidget {
  const CustomSearchBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Icon(Icons.search, color: Color(0xFFB0B0B0)),
          ),
          const Expanded(
            child: TextField(
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: 'Search restaurants, dishes, or cuisine',
                hintStyle: TextStyle(
                  color: Color(0xFFB0B0B0),
                  fontSize: 18,
                ),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.mic, color: Color(0xFFFF4B4B)),
            onPressed: () {},
          ),
        ],
      ),
    );
  }
} 