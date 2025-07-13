import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../auth/login/providers/auth_provider.dart';

final registerControllerProvider = StateNotifierProvider<RegisterController, RegisterState>((ref) {
  return RegisterController(ref);
});

class RegisterState {
  final bool isLoading;
  final String? error;

  RegisterState({
    this.isLoading = false,
    this.error,
  });

  RegisterState copyWith({
    bool? isLoading,
    String? error,
  }) {
    return RegisterState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class RegisterController extends StateNotifier<RegisterState> {
  final Ref ref;

  RegisterController(this.ref) : super(RegisterState());

  Future<bool> register({
    required String name,
    required String email,
    required String phone,
    required String password,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final success = await ref.read(authProvider.notifier).register({
        'name': name,
        'email': email,
        'phone': phone,
        'password': password,
      });

      state = state.copyWith(isLoading: false);
      return success;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      return false;
    }
  }
} 