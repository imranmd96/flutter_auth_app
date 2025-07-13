import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class OrderDetailsPage extends ConsumerWidget {
  final String id;
  const OrderDetailsPage({super.key, required this.id});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Center(
      child: Text('Order Details Page - ID: $id'),
    );
  }
} 