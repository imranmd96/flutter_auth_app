import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../auth/login/providers/auth_provider.dart';
import '../../services/user_service.dart';

final selectedImageProvider = StateProvider<File?>((ref) => null);
final webImageBytesProvider = StateProvider<Uint8List?>((ref) => null);
final webImageNameProvider = StateProvider<String>((ref) => '');
final isEditingProvider = StateProvider<bool>((ref) => false);
final isSavingProvider = StateProvider<bool>((ref) => false);

final drawerProfileImageNotifier = Provider((ref) => DrawerProfileImageNotifier(ref));

class DrawerProfileImageNotifier {
  final Ref ref;
  final ImagePicker _picker = ImagePicker();

  DrawerProfileImageNotifier(this.ref);

  @override
  Widget build(BuildContext context) {
    return Container(); // Placeholder widget
  }

  Future<void> pickImage() async {
    try {
      if (kIsWeb) {
        final result = await FilePicker.platform.pickFiles(
          type: FileType.image,
          allowMultiple: false,
        );
        
        if (result != null && result.files.single.bytes != null) {
          ref.read(selectedImageProvider.notifier).state = null;
          ref.read(isEditingProvider.notifier).state = true;
          ref.read(webImageBytesProvider.notifier).state = result.files.single.bytes;
          ref.read(webImageNameProvider.notifier).state = result.files.single.name;
        }
      } else {
        final pickedFile = await _picker.pickImage(
          source: ImageSource.gallery,
          imageQuality: 80,
        );
        
        if (pickedFile != null) {
          ref.read(selectedImageProvider.notifier).state = File(pickedFile.path);
          ref.read(isEditingProvider.notifier).state = true;
          ref.read(webImageBytesProvider.notifier).state = null;
          ref.read(webImageNameProvider.notifier).state = '';
        }
      }
    } catch (e) {
      debugPrint('Error picking image: $e');
    }
  }

  void cancelEdit() {
    ref.read(selectedImageProvider.notifier).state = null;
    ref.read(isEditingProvider.notifier).state = false;
    ref.read(webImageBytesProvider.notifier).state = null;
    ref.read(webImageNameProvider.notifier).state = '';
  }

  Future<void> saveImage() async {
    final selectedImage = ref.read(selectedImageProvider);
    final webImageBytes = ref.read(webImageBytesProvider);
    
    if (selectedImage == null && webImageBytes == null) return;

    ref.read(isSavingProvider.notifier).state = true;
    try {
      final authState = ref.read(authProvider);
      final userService = ref.read(userServiceProvider);
      
      String? imageUrl;
      if (kIsWeb && webImageBytes != null) {
        imageUrl = await userService.uploadAvatar(
          imageFileOrBytes: webImageBytes,
          accessToken: authState.accessToken,
          fileName: ref.read(webImageNameProvider),
          isWeb: true,
        );
      } else if (selectedImage != null) {
        imageUrl = await userService.uploadAvatar(
          imageFileOrBytes: selectedImage,
          accessToken: authState.accessToken,
          isWeb: false,
        );
      }

      if (imageUrl != null) {
        await ref.read(authProvider.notifier).updateProfilePicture(imageUrl);
        ref.read(isEditingProvider.notifier).state = false;
        ref.read(selectedImageProvider.notifier).state = null;
        ref.read(webImageBytesProvider.notifier).state = null;
        ref.read(webImageNameProvider.notifier).state = '';
      }
    } catch (e) {
      debugPrint('Error saving image: $e');
    } finally {
      ref.read(isSavingProvider.notifier).state = false;
    }
  }
} 
