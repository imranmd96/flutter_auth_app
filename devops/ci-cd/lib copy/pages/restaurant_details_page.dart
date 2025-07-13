import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class RestaurantDetailsPage extends ConsumerWidget {
  final String id;
  const RestaurantDetailsPage({super.key, required this.id});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Center(
      child: Text('Restaurant Details Page - ID: $id'),
    );
  }
} 