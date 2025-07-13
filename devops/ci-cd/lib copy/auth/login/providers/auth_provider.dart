import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_flutter_app/config/api_config.dart';
import 'package:my_flutter_app/core/constants/storage_keys.dart';
import 'package:my_flutter_app/services/service_locator.dart';

import '../data/models/auth_state.dart';
import '../data/models/user_type.dart';

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(ref);
});

class AuthNotifier extends StateNotifier<AuthState> {
  final Ref ref;
  bool _isTesting = false; // Flag to prevent redirects during testing

  AuthNotifier(this.ref) : super(const AuthState());

  /// Set testing mode to prevent redirects
  void setTestingMode(bool isTesting) {
    _isTesting = isTesting;
  }

  /// Check if currently in testing mode
  bool get isTesting => _isTesting;

  Future<bool> login(String email, String password) async {
    final serviceLocator = ref.read(serviceLocatorProvider);
    state = state.copyWith(isLoading: true, error: '');
    
    try {
      final response = await serviceLocator.apiService.post(
        ApiConfig.login,
        data: {
          'email': email,
          'password': password,
        },
      );

      if (response == null || response['data'] == null) {
        throw Exception('Invalid response from server');
      }

      final responseData = response['data'] as Map<String, dynamic>;
      final user = responseData['user'] as Map<String, dynamic>?;
      final tokens = responseData['tokens'] as Map<String, dynamic>?;

      if (user == null || tokens == null) {
        throw Exception('Missing required data in server response');
      }

      final accessToken = tokens['accessToken'] as String?;
      final refreshToken = tokens['refreshToken'] as String?;

      if (accessToken == null || refreshToken == null) {
        throw Exception('Missing tokens in server response');
      }

      final newState = state.copyWith(
        isAuthenticated: true,
        isLoading: false,
        user: user,
        accessToken: accessToken,
        refreshToken: refreshToken,
        userName: user['name'] as String? ?? '',
        email: user['email'] as String? ?? '',
        userId: user['id'] as String? ?? '',
        profilePicture: user['profilePicture'] as String? ?? '',
        userType: UserType.validateType(user['role'] as String?),
      );

      await newState.save(storageKey: StorageKeys.authState.value);
      
      // Start session after successful login
      //await SessionManager.startSession();
      
      state = newState;
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      return false;
    }
  }

  
  Future<bool> register(Map<String, dynamic> userData) async {
    final serviceLocator = ref.read(serviceLocatorProvider);
    state = state.copyWith(isLoading: true, error: '');
    
    try {
      final response = await serviceLocator.apiService.post(
        ApiConfig.register,
        data: userData,
      );

      if (response == null || response['data'] == null) {
        throw Exception('Invalid response from server');
      }

      final responseData = response['data'] as Map<String, dynamic>;
      final accessToken = responseData['accessToken'] as String?;
      final refreshToken = responseData['refreshToken'] as String?;
      final user = responseData['user'] as Map<String, dynamic>?;

      if (accessToken == null || refreshToken == null || user == null) {
        throw Exception('Missing required data in server response');
      }

      final newState = state.copyWith(
        isAuthenticated: true,
        isLoading: false,
        user: user,
        accessToken: accessToken,
        refreshToken: refreshToken,
        userName: user['name'] as String? ?? '',
        email: user['email'] as String? ?? '',
        userId: user['id'] as String? ?? '',
        profilePicture: user['profilePicture'] as String? ?? '',
        userType: UserType.validateType(user['type'] as String?),
      );

      await newState.save(storageKey: StorageKeys.authState.value);
      state = newState;
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      return false;
    }
  }

  Future<void> logout() async {
    final serviceLocator = ref.read(serviceLocatorProvider);
    state = state.copyWith(isLoading: true, error: '');
    
    try {
      await serviceLocator.apiService.post(ApiConfig.logout);
      await AuthState.clear(storageKey: StorageKeys.authState.value);
      state = const AuthState();
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Logout failed: ${e.toString()}',
      );
    }
  }

  // Future<void> checkAuthStatus() async {
  //   final serviceLocator = ref.read(serviceLocatorProvider);
  //   state = state.copyWith(isLoading: true, error: '');
    
  //   try {
  //     final hasTokens = await AuthState.hasStoredState(storageKey: StorageKeys.authState.value);
  //     if (!hasTokens) {
  //       state = const AuthState(isInitialized: true);
  //       return;
  //     }

  //     final tokenState = await AuthState.load(storageKey: StorageKeys.authState.value);
  //     if (tokenState.accessToken.isEmpty) {
  //       state = const AuthState(isInitialized: true);
  //       return;
  //     }

  //     serviceLocator.apiService.setAuthToken(tokenState.accessToken);
  //     final response = await serviceLocator.apiService.get(ApiConfig.me);

  //     if (response == null || response['data'] == null) {
  //       throw Exception('Invalid response from server');
  //     }

  //     final user = response['data'] as Map<String, dynamic>;
  //     state = state.copyWith(
  //       isAuthenticated: true,
  //       isLoading: false,
  //       isInitialized: true,
  //       user: user,
  //       accessToken: tokenState.accessToken,
  //       refreshToken: tokenState.refreshToken,
  //       userName: user['name'] as String? ?? '',
  //       email: user['email'] as String? ?? '',
  //       userId: user['id'] as String? ?? '',
  //       profilePicture: user['profilePicture'] as String? ?? '',
  //       userType: UserType.validateType(user['type'] as String?),
  //     );
  //   } catch (e) {
  //     state = const AuthState(isInitialized: true);
  //   }
  // }

  Future<bool> updateProfile(Map<String, dynamic> profileData) async {
    final serviceLocator = ref.read(serviceLocatorProvider);
    state = state.copyWith(isLoading: true, error: '');
    
    try {
      if (state.accessToken.isEmpty) {
        throw Exception('Not authenticated');
      }

      serviceLocator.apiService.setAuthToken(state.accessToken);
      final response = await serviceLocator.apiService.put(
        ApiConfig.updateProfile,
        data: profileData,
      );

      if (response == null || response['data'] == null) {
        throw Exception('Invalid response from server');
      }

      final user = response['data'] as Map<String, dynamic>;
      state = state.copyWith(
        isLoading: false,
        user: user,
        userName: user['name'] as String? ?? '',
        email: user['email'] as String? ?? '',
        profilePicture: user['profilePicture'] as String? ?? '',
        userType: UserType.validateType(user['type'] as String?),
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      return false;
    }
  }

  Future<bool> updateProfilePicture(String imageUrl) async {
    final serviceLocator = ref.read(serviceLocatorProvider);
    state = state.copyWith(isLoading: true, error: '');
    
    try {
      if (state.accessToken.isEmpty) {
        throw Exception('Not authenticated');
      }

      serviceLocator.apiService.setAuthToken(state.accessToken);
      final response = await serviceLocator.apiService.put(
        ApiConfig.updateProfilePicture,
        data: {'profilePicture': imageUrl},
      );

      if (response == null || response['data'] == null) {
        throw Exception('Invalid response from server');
      }

      final user = response['data'] as Map<String, dynamic>;
      state = state.copyWith(
        isLoading: false,
        user: user,
        profilePicture: imageUrl,
        userType: UserType.validateType(user['type'] as String?),
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      return false;
    }
  }

  /// Update tokens without making API call (used by token refresh service)
  Future<void> updateTokens(String accessToken, String refreshToken) async {
    final newState = state.copyWith(
      accessToken: accessToken,
      refreshToken: refreshToken,
      isAuthenticated: true,
    );
    
    // Save to storage
    await newState.save(storageKey: StorageKeys.authState.value);
    
    // Update provider state
    state = newState;
  }

  /// Load auth state from storage (used for initialization)
  Future<void> loadFromStorage() async {
    try {
      final storedState = await AuthState.load(storageKey: StorageKeys.authState.value);
      state = storedState;
    } catch (e) {
      state = const AuthState();
    }
  }

  /// Initialize auth state (load from storage and set as initialized)
  Future<void> initialize() async {
    try {
      print('🔄 AuthProvider: Initializing...');
      
      // Load stored auth state
      final storedState = await AuthState.load(storageKey: StorageKeys.authState.value);
      
      // Check if we have valid tokens
      if (storedState.accessToken.isEmpty || storedState.refreshToken.isEmpty) {
        print('❌ AuthProvider: No valid tokens found');
        await AuthState.clear(storageKey: StorageKeys.authState.value);
        state = const AuthState(isInitialized: true);
        return;
      }
      
      // Basic token validation
      if (storedState.accessToken.length < 10 || storedState.refreshToken.length < 10) {
        print('❌ AuthProvider: Tokens appear invalid');
        await AuthState.clear(storageKey: StorageKeys.authState.value);
        state = const AuthState(isInitialized: true);
        return;
      }
      
      // Set as authenticated with stored state
      final initializedState = storedState.copyWith(isInitialized: true);
      state = initializedState;
      
      print('✅ AuthProvider: Initialized successfully');
      print('  - isAuthenticated: ${initializedState.isAuthenticated}');
      print('  - userType: ${initializedState.userType}');
      print('  - hasValidTokens: ${initializedState.hasValidTokens}');
    } catch (e) {
      print('❌ AuthProvider: Error during initialization: $e');
      // Clear auth state and set as unauthenticated
      await AuthState.clear(storageKey: StorageKeys.authState.value);
      state = const AuthState(isInitialized: true);
    }
  }

  /// Force clear session for testing purposes
  Future<void> forceClearSession() async {
    // Since session manager is commented out, just clear auth state
    await AuthState.clear(storageKey: StorageKeys.authState.value);
    state = const AuthState(isInitialized: true);
  }

  // Validation methods
  String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
      return 'Please enter a valid email';
    }
    return null;
  }

  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }
} 