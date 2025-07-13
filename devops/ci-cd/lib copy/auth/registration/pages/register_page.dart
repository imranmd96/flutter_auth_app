import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:form_validator/form_validator.dart';
import 'package:go_router/go_router.dart';

import '../../../routes/app_router.dart';
import '../../../utils/theme.dart';
import '../../../widgets/form_widgets.dart';
import '../controllers/register_controller.dart';

class RegisterPage extends ConsumerStatefulWidget {
  const RegisterPage({super.key});

  @override
  ConsumerState<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends ConsumerState<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    if (_formKey.currentState?.validate() ?? false) {
      final success = await ref.read(registerControllerProvider.notifier).register(
        name: _nameController.text,
        email: _emailController.text,
        phone: _phoneController.text,
        password: _passwordController.text,
      );

      if (success && mounted) {
        context.go(AppRouteConstants.dashboard);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(registerControllerProvider);

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.primary,
              AppColors.primary.withOpacity(0.8),
            ],
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.restaurant,
                    size: 80,
                    color: Colors.white,
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Create Account',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 48),
                  if (state.error != null)
                    ErrorDisplay(error: state.error!),
                  const SizedBox(height: 16),
                  AppTextFormField(
                    controller: _nameController,
                    label: 'Full Name',
                    validator: ValidationBuilder().required().minLength(2).build(),
                  ),
                  const SizedBox(height: 16),
                  AppTextFormField(
                    controller: _emailController,
                    label: 'Email',
                    keyboardType: TextInputType.emailAddress,
                    validator: ValidationBuilder().required().email().build(),
                  ),
                  const SizedBox(height: 16),
                  AppTextFormField(
                    controller: _phoneController,
                    label: 'Phone Number',
                    keyboardType: TextInputType.phone,
                    validator: ValidationBuilder().required().minLength(10).maxLength(15).build(),
                  ),
                  const SizedBox(height: 16),
                  AppTextFormField(
                    controller: _passwordController,
                    label: 'Password',
                    obscureText: true,
                    validator: ValidationBuilder().required().minLength(6).build(),
                  ),
                  const SizedBox(height: 24),
                  LoadingButton(
                    isLoading: state.isLoading,
                    onPressed: _handleRegister,
                    label: 'Register',
                    backgroundColor: Colors.white,
                    foregroundColor: AppColors.primary,
                  ),
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: () => context.go(AppRouteConstants.login),
                    child: const Text(
                      'Already have an account? Login',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
} 