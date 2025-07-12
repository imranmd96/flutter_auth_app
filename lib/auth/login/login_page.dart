import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:my_flutter_app/auth/login/provider/login_provider.dart';
import 'package:my_flutter_app/auth/login/utils/theme.dart';
import 'package:my_flutter_app/auth/login/widgets/form_widgets.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController(text: 'imran@com.com');
  final _passwordController = TextEditingController(text: '123456');

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (_formKey.currentState?.validate() ?? false) {
      try {
        await ref.read(authNotifierProvider.notifier).login(
          email: _emailController.text,
          password: _passwordController.text,
          context: context,
        );
        
        if (mounted) {
          context.go('/dashboard');
        }
      } catch (e) {
        // Error is already handled in the notifier
        if (kDebugMode) {
          print('Login error: $e');
        }
      }
    }
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your email';
    }
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
      return 'Please enter a valid email';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your password';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authNotifierProvider);

    return Scaffold(
      body: SafeArea(
        child: Container(
          decoration: AppDecorations.loginBackground,
          child: Center(
            child: SingleChildScrollView(
              padding: AppSizes.paddingHorizontal + AppSizes.paddingVertical,
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.restaurant,
                      size: AppSizes.iconSizeLarge,
                      color: AppColors.textWhite,
                    ),
                    const SizedBox(height: AppSizes.spacingM),
                    const Text(
                      'Food Delivery App',
                      style: AppTextStyles.loginTitle,
                    ),
                    const SizedBox(height: AppSizes.spacingXL),
                    if (authState.errorMessage != null)
                      ErrorDisplay(error: authState.errorMessage!),
                    const SizedBox(height: AppSizes.spacingM),
                    AppTextFormField(
                      controller: _emailController,
                      label: 'Email',
                      keyboardType: TextInputType.emailAddress,
                      validator: _validateEmail,
                    ),
                    const SizedBox(height: AppSizes.spacingM),
                    AppTextFormField(
                      controller: _passwordController,
                      label: 'Password',
                      obscureText: true,
                      validator: _validatePassword,
                    ),
                    const SizedBox(height: AppSizes.spacingL),
                    LoadingButton(
                      isLoading: authState.isLoading,
                      onPressed: _handleLogin,
                      label: 'Login',
                      backgroundColor: AppColors.loginFormBackground,
                      foregroundColor: AppColors.primary,
                    ),
                    const SizedBox(height: AppSizes.spacingM),
                    TextButton(
                      onPressed: () => context.go('/register'),
                      child: const Text(
                        'Don\'t have an account? Register',
                        style: AppTextStyles.loginLink,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}