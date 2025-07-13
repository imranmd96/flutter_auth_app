import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_flutter_app/auth/logout/widgets/logout_button.dart';

import '../providers/sidebar_provider.dart';

class DrawerFooter extends ConsumerWidget {
  final SidebarNotifier sidebarNotifier;
  const DrawerFooter(this.sidebarNotifier, {super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        children: [
          const Divider(),
          LogoutButton(
            onLogoutComplete: () {
              // Additional cleanup if needed
            },
          ),
        ],
      ),
    );
  }
} 