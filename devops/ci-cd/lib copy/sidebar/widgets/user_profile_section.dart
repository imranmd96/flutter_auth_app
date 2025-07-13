import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../controllers/drawer_profile_image_controller.dart';
import 'profile_avatar.dart';
import 'profile_edit_actions.dart';
import 'profile_title.dart';
import 'profile_welcome_text.dart';

class UserProfileSection extends ConsumerWidget {
  final DrawerProfileImageNotifier drawerProfileImageNotifier;
  
  const UserProfileSection({
    required this.drawerProfileImageNotifier,
    super.key,
  });

  // Constants for styling
  static const _padding = EdgeInsets.fromLTRB(16, 48, 16, 16);
  static const _avatarSpacing = SizedBox(height: 12);
  static const _titleSpacing = SizedBox(height: 4);
  static const _welcomeSpacing = SizedBox(height: 12);
  static const _backgroundColor = Color(0xFF4B1EFF);
  static const _borderRadius = BorderRadius.only(
    bottomLeft: Radius.circular(20),
    bottomRight: Radius.circular(20),
  );

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      width: double.infinity,
      padding: _padding,
      decoration: const BoxDecoration(
        color: _backgroundColor,
        borderRadius: _borderRadius,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const ProfileAvatar(),
          _avatarSpacing,
          const ProfileTitle(),
          _titleSpacing,
          const ProfileWelcomeText(),
          _welcomeSpacing,
          ProfileEditActions(drawerProfileImageNotifier: drawerProfileImageNotifier),
        ],
      ),
    );
  }
} 