import 'package:flutter/material.dart';
import '../components/restaurant_card.dart';

class NearbyRestaurantsList extends StatelessWidget {
  const NearbyRestaurantsList({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 240,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: const [
          RestaurantCard(
            image: 'https://images.pexels.com/photos/315755/pexels-photo-315755.jpeg',
            name: 'La Pizzeria',
            distance: '400m',
            tag: 'Table Available',
            tagColor: Color(0xFF7ED957),
            cardColor: Color(0xFFFF4B4B),
            rating: 4.7,
            isFavorite: true,
          ),
          RestaurantCard(
            image: 'https://images.pexels.com/photos/357756/pexels-photo-357756.jpeg',
            name: 'Sushi Place',
            distance: '350m',
            tag: 'Vegan',
            tagColor: Color(0xFF7ED957),
            cardColor: Color(0xFF4B1EFF),
            rating: 4.9,
            isFavorite: false,
          ),
          RestaurantCard(
            image: 'https://images.pexels.com/photos/1639566/pexels-photo-1639566.jpeg',
            name: 'Burger Spot',
            distance: '500m',
            tag: 'Vegan',
            tagColor: Color(0xFF7ED957),
            cardColor: Color(0xFF2D2D2D),
            textColor: Color(0xFFFFF200),
            rating: 4.5,
            isFavorite: true,
          ),
        ],
      ),
    );
  }
} 