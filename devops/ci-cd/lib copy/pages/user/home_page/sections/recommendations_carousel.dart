import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';

import '../components/recommendation_card.dart';

class RecommendationsCarousel extends StatelessWidget {
  final List<Map<String, dynamic>> recommendations;
  const RecommendationsCarousel({super.key, required this.recommendations});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 180,
      constraints: const BoxConstraints(maxHeight: 180),
      child: CarouselSlider.builder(
        itemCount: recommendations.length,
        itemBuilder: (context, index, realIndex) {
          return RecommendationCard(recommendations[index]);
        },
        options: CarouselOptions(
          height: 180,
          enlargeCenterPage: true,
          enableInfiniteScroll: true,
          autoPlay: true,
          viewportFraction: 0.8,
          padEnds: false,
        ),
      ),
    );
  }
} 