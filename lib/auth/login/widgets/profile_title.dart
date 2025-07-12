import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_flutter_app/auth/login/provider/login_provider.dart';
import 'package:my_flutter_app/auth/login/utils/theme.dart';

class ProfileTitle extends ConsumerWidget {
  const ProfileTitle({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authNotifierProvider);
    final user = authState.user;

    return Column(
      children: [
        CircleAvatar(
          radius: AppSizes.avatarRadius,
          backgroundColor: AppColors.profileAvatarBackground,
          child: user?.profilePicture != null
              ? ClipOval(
                  child: Image.network(
                    user!.profilePicture!,
                    width: AppSizes.avatarRadius * 2,
                    height: AppSizes.avatarRadius * 2,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return const Icon(
                        Icons.person,
                        size: AppSizes.iconSizeMedium,
                        color: AppColors.textWhite,
                      );
                    },
                  ),
                )
              : const Icon(
                  Icons.person,
                  size: AppSizes.iconSizeMedium,
                  color: AppColors.textWhite,
                ),
        ),
        const SizedBox(height: AppSizes.spacingM),
        Text(
          user?.name ?? 'User',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: AppTextStyles.profileName.fontWeight,
              ),
        ),
        if (user?.email != null) ...[
          const SizedBox(height: AppSizes.spacingXS),
          Text(
            user!.email,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.profileTextSecondary,
                ),
          ),
        ],
      ],
    );
  }
}