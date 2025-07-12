import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class HomeContentPage extends ConsumerWidget {
  const HomeContentPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) => Scaffold(
        appBar: AppBar(title: const Text('Home')),
        body: const Center(
          child: Text('Welcome to Home Page!'),
        ),
      );
} 