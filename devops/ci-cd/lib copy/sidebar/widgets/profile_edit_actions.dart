import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../controllers/drawer_profile_image_controller.dart';

class ProfileEditActions extends ConsumerWidget {
  final DrawerProfileImageNotifier drawerProfileImageNotifier;

  const ProfileEditActions({
    required this.drawerProfileImageNotifier,
    super.key,
  });

  // Constants for styling
  static const _buttonSpacing = SizedBox(width: 8);
  static const _topPadding = EdgeInsets.only(top: 16);
  static const _buttonPadding = EdgeInsets.symmetric(horizontal: 16, vertical: 8);
  static const _primaryColor = Color(0xFF4B1EFF);
  static const _iconSize = 20.0;
  static const _loadingSize = 20.0;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isSaving = ref.watch(isSavingProvider);
    final selectedImage = ref.watch(selectedImageProvider);
    final webImageBytes = ref.watch(webImageBytesProvider);
    final hasSelectedImage = selectedImage != null || webImageBytes != null;

    if (!hasSelectedImage) return const SizedBox.shrink();

    return Padding(
      padding: _topPadding,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ElevatedButton.icon(
            onPressed: isSaving ? null : () => drawerProfileImageNotifier.saveImage(),
            icon: isSaving
                ? const SizedBox(
                    width: _loadingSize,
                    height: _loadingSize,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : const Icon(Icons.save, size: _iconSize),
            label: Text(isSaving ? 'Saving...' : 'Save'),
            style: ElevatedButton.styleFrom(
              backgroundColor: _primaryColor,
              foregroundColor: Colors.white,
              padding: _buttonPadding,
            ),
          ),
          _buttonSpacing,
          OutlinedButton.icon(
            onPressed: () => drawerProfileImageNotifier.cancelEdit(),
            icon: const Icon(Icons.close, size: _iconSize),
            label: const Text('Cancel'),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.white,
              side: const BorderSide(color: Colors.white),
              padding: _buttonPadding,
            ),
          ),
        ],
      ),
    );
  }
} 