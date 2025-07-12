import 'package:flutter/material.dart';
import 'package:my_flutter_app/auth/login/utils/theme.dart';

class AppTextFormField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final bool obscureText;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;

  const AppTextFormField({
    super.key,
    required this.controller,
    required this.label,
    this.obscureText = false,
    this.keyboardType,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      validator: validator,
      style: AppTextStyles.formInput,
      decoration: AppDecorations.formInputDecoration.copyWith(
        labelText: label,
        labelStyle: AppTextStyles.formLabel,
      ),
    );
  }
}

class LoadingButton extends StatelessWidget {
  final bool isLoading;
  final VoidCallback onPressed;
  final String label;
  final Color backgroundColor;
  final Color foregroundColor;

  const LoadingButton({
    super.key,
    required this.isLoading,
    required this.onPressed,
    required this.label,
    required this.backgroundColor,
    required this.foregroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: AppSizes.buttonHeight,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          foregroundColor: foregroundColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSizes.borderRadius),
          ),
        ),
        child: isLoading
            ? const SizedBox(
                width: AppSizes.iconSizeSmall,
                height: AppSizes.iconSizeSmall,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                ),
              )
            : Text(
                label,
                style: AppTextStyles.loginButton,
              ),
      ),
    );
  }
}

class ErrorDisplay extends StatelessWidget {
  final String error;

  const ErrorDisplay({
    super.key,
    required this.error,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: AppSizes.paddingSmall,
      decoration: AppDecorations.loginErrorContainer,
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: AppColors.error),
          const SizedBox(width: AppSizes.spacingS),
          Expanded(
            child: Text(
              error,
              style: AppTextStyles.formError,
            ),
          ),
        ],
      ),
    );
  }
}


