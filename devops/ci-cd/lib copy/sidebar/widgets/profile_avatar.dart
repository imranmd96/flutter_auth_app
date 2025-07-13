import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/login/data/models/auth_state.dart';
import '../../auth/login/providers/auth_provider.dart';
import '../controllers/drawer_profile_image_controller.dart';

class ProfileAvatar extends ConsumerWidget {
  const ProfileAvatar({super.key});

  static const double _avatarSize = 80.0;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final isEditing = ref.watch(isEditingProvider);
    final isSaving = ref.watch(isSavingProvider);
    final selectedImage = ref.watch(selectedImageProvider);
    final webImageBytes = ref.watch(webImageBytesProvider);
    final drawerController = ref.read(drawerProfileImageNotifier);

    if (isSaving) {
      return const CircleAvatar(
        radius: _avatarSize / 2,
        backgroundColor: Colors.grey,
        child: CircularProgressIndicator(
          color: Colors.white,
        ),
      );
    }

    if (isEditing) {
      return _buildEditingAvatar(selectedImage, webImageBytes);
    }

    return InkWell(
      onTap: () => drawerController.pickImage(),
      child: _buildProfileAvatar(authState),
    );
  }

  Widget _buildEditingAvatar(File? selectedImage, Uint8List? webImageBytes) {
    if (webImageBytes != null) {
      return CircleAvatar(
        radius: _avatarSize / 2,
        backgroundColor: Colors.grey[200],
        child: ClipOval(
          child: Image.memory(
            webImageBytes,
            width: _avatarSize,
            height: _avatarSize,
            fit: BoxFit.cover,
          ),
        ),
      );
    }
    if (selectedImage != null) {
      return CircleAvatar(
        radius: _avatarSize / 2,
        backgroundColor: Colors.grey[200],
        child: ClipOval(
          child: Image.file(
            selectedImage,
            width: _avatarSize,
            height: _avatarSize,
            fit: BoxFit.cover,
          ),
        ),
      );
    }
    return _buildDefaultAvatar();
  }

  Widget _buildProfileAvatar(AuthState authState) {
    if (authState.isDefaultProfilePicture) {
      return _buildDefaultAvatar();
    }
    return _buildNetworkAvatar(authState.profilePictureUrl);
  }

  Widget _buildDefaultAvatar() {
    return CircleAvatar(
      radius: _avatarSize / 2,
      backgroundColor: Colors.grey[200],
      child: ClipOval(
        child: Image.asset(
          'assets/default_avatar.png',
          width: _avatarSize,
          height: _avatarSize,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return const Icon(
              Icons.person,
              size: _avatarSize * 0.6,
              color: Colors.grey,
            );
          },
        ),
      ),
    );
  }

  Widget _buildNetworkAvatar(String url) {
    return CircleAvatar(
      radius: _avatarSize / 2,
      backgroundColor: Colors.grey[200],
      child: ClipOval(
        child: Image.network(
          url,
          width: _avatarSize,
          height: _avatarSize,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return _buildDefaultAvatar();
          },
        ),
      ),
    );
  }
} 