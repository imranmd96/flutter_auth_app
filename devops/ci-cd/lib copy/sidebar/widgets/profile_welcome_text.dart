import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/login/providers/auth_provider.dart';
import '../../utils/theme.dart';

class ProfileWelcomeText extends ConsumerWidget {
  const ProfileWelcomeText({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    return Text(
      'Welcome, ${authState.userName}!',
      style: const TextStyle(
        fontSize: 16,
        color: AppColors.textLight,
      ),
    );
  }
} 