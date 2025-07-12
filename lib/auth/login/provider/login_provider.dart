import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

// 1. User Model
class AuthUser {
  final String id;
  final String type;
  final String name;
  final String email;
  final String? profilePicture;

  const AuthUser({
    required this.id,
    required this.type,
    required this.name,
    required this.email,
    this.profilePicture,
  });

  factory AuthUser.fromMap(Map<String, dynamic> map) => AuthUser(
    id: map['id'] ?? '',
    type: map['type'] ?? 'user',
    name: map['name'] ?? '',
    email: map['email'] ?? '',
    profilePicture: map['profilePicture'],
  );

  Map<String, dynamic> toMap() => {
    'id': id,
    'type': type,
    'name': name,
    'email': email,
    'profilePicture': profilePicture,
  };

  String toJson() => jsonEncode(toMap());

  factory AuthUser.fromJson(String source) => AuthUser.fromMap(jsonDecode(source));
}

// 2. State Model
class AuthState {
  final bool isLoading;
  final String? errorMessage;  
  final String? accessToken;
  final String? refreshToken;
  final DateTime? tokenExpiry;
  final AuthUser? user;

  const AuthState({
    this.isLoading = false,
    this.errorMessage,
    this.accessToken,
    this.refreshToken,
    this.tokenExpiry,
    this.user,
  });

  bool get isAuthenticated => accessToken != null;
  bool get hasValidToken => tokenExpiry != null && tokenExpiry!.isAfter(DateTime.now());
  bool get shouldRefresh => tokenExpiry != null && 
                         tokenExpiry!.subtract(const Duration(minutes: 5)).isBefore(DateTime.now());

  AuthState copyWith({
    bool? isLoading,
    String? errorMessage,
    String? accessToken,
    String? refreshToken,
    DateTime? tokenExpiry,
    AuthUser? user,
  }) => AuthState(
    isLoading: isLoading ?? this.isLoading,
    errorMessage: errorMessage ?? this.errorMessage,
    accessToken: accessToken ?? this.accessToken,
    refreshToken: refreshToken ?? this.refreshToken,
    tokenExpiry: tokenExpiry ?? this.tokenExpiry,
    user: user ?? this.user,
  );

  AuthState loading() => copyWith(isLoading: true, errorMessage: null);
  AuthState error(String message) => copyWith(isLoading: false, errorMessage: message);
  AuthState authenticated({
    required String accessToken,
    required String refreshToken,
    required DateTime expiry,
    required AuthUser user,
  }) => copyWith(
    isLoading: false,
    errorMessage: null,
    accessToken: accessToken,
    refreshToken: refreshToken,
    tokenExpiry: expiry,
    user: user,
  );
}

// 3. Token Service (Handles token storage)
abstract class TokenService {
  Future<void> saveAccessToken(String token);
  Future<void> saveRefreshToken(String token);
  Future<void> saveTokenExpiry(DateTime expiry);
  Future<void> saveUserData(AuthUser user);
  Future<String?> getAccessToken();
  Future<String?> getRefreshToken();
  Future<DateTime?> getTokenExpiry();
  Future<AuthUser?> getUserData();
  Future<void> clearTokens();
  Future<void> clearUserData();
  Future<void> clearAll();
}

class MobileTokenService implements TokenService {
  final _secureStorage = const FlutterSecureStorage();

  @override
  Future<void> saveAccessToken(String token) => 
      _secureStorage.write(key: 'access_token', value: token);

  @override
  Future<void> saveRefreshToken(String token) => 
      _secureStorage.write(key: 'refresh_token', value: token);

  @override
  Future<void> saveTokenExpiry(DateTime expiry) => 
      _secureStorage.write(key: 'token_expiry', value: expiry.toIso8601String());

  @override
  Future<void> saveUserData(AuthUser user) async {
    await _secureStorage.write(key: 'user_data', value: user.toJson());
  }

  @override
  Future<String?> getAccessToken() => _secureStorage.read(key: 'access_token');

  @override
  Future<String?> getRefreshToken() => _secureStorage.read(key: 'refresh_token');

  @override
  Future<DateTime?> getTokenExpiry() async {
    final expiry = await _secureStorage.read(key: 'token_expiry');
    return expiry != null ? DateTime.parse(expiry) : null;
  }

  @override
  Future<AuthUser?> getUserData() async {
    final userJson = await _secureStorage.read(key: 'user_data');
    if (userJson != null) {
      try {
        return AuthUser.fromJson(userJson);
      } catch (e) {
        debugPrint('Error parsing user data: $e');
        return null;
      }
    }
    return null;
  }

  @override
  Future<void> clearTokens() async {
    await Future.wait([
      _secureStorage.delete(key: 'access_token'),
      _secureStorage.delete(key: 'refresh_token'),
      _secureStorage.delete(key: 'token_expiry'),
    ]);
  }

  @override
  Future<void> clearUserData() async {
    await _secureStorage.delete(key: 'user_data');
  }

  @override
  Future<void> clearAll() async {
    await _secureStorage.deleteAll();
  }
}

class WebTokenService implements TokenService {
  @override
  Future<void> saveAccessToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('access_token', token);
  }

  @override
  Future<void> saveRefreshToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('refresh_token', token);
  }

  @override
  Future<void> saveTokenExpiry(DateTime expiry) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token_expiry', expiry.toIso8601String());
  }

  @override
  Future<void> saveUserData(AuthUser user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_data', user.toJson());
  }

  @override
  Future<String?> getAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('access_token');
  }

  @override
  Future<String?> getRefreshToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('refresh_token');
  }

  @override
  Future<DateTime?> getTokenExpiry() async {
    final prefs = await SharedPreferences.getInstance();
    final expiry = prefs.getString('token_expiry');
    return expiry != null ? DateTime.parse(expiry) : null;
  }

  @override
  Future<AuthUser?> getUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString('user_data');
    if (userJson != null) {
      try {
        return AuthUser.fromJson(userJson);
      } catch (e) {
        debugPrint('Error parsing user data: $e');
        return null;
      }
    }
    return null;
  }

  @override
  Future<void> clearTokens() async {
    final prefs = await SharedPreferences.getInstance();
    await Future.wait([
      prefs.remove('access_token'),
      prefs.remove('refresh_token'),
      prefs.remove('token_expiry'),
    ]);
  }

  @override
  Future<void> clearUserData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user_data');
  }

  @override
  Future<void> clearAll() async {
    await Future.wait([
      clearTokens(),
      clearUserData(),
    ]);
  }
}

// 4. Auth Repository (Handles storage and API calls)
abstract class AuthRepository {
  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
    required DateTime expiry,
  });
  Future<void> saveUserData(AuthUser user);
  Future<Map<String, String?>> getTokens();
  Future<AuthUser?> getUserData();
  Future<void> clearTokens();
  Future<void> clearUserData();
  Future<void> clearAll();
  Future<String> refreshToken(String refreshToken);
  Future<Map<String, dynamic>> login(String email, String password);
}

class AuthRepositoryImpl implements AuthRepository {
  final TokenService _tokenService;

  AuthRepositoryImpl(this._tokenService);

  @override
  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
    required DateTime expiry,
  }) async {
    await Future.wait([
      _tokenService.saveAccessToken(accessToken),
      _tokenService.saveRefreshToken(refreshToken),
      _tokenService.saveTokenExpiry(expiry),
    ]);
  }

  @override
  Future<void> saveUserData(AuthUser user) => _tokenService.saveUserData(user);

  @override
  Future<Map<String, String?>> getTokens() async {
    return {
      'accessToken': await _tokenService.getAccessToken(),
      'refreshToken': await _tokenService.getRefreshToken(),
      'expiry': (await _tokenService.getTokenExpiry())?.toIso8601String(),
    };
  }

  @override
  Future<AuthUser?> getUserData() => _tokenService.getUserData();

  @override
  Future<void> clearTokens() => _tokenService.clearTokens();

  @override
  Future<void> clearUserData() => _tokenService.clearUserData();

  @override
  Future<void> clearAll() => _tokenService.clearAll();

  @override
  Future<String> refreshToken(String refreshToken) async {
    // Implement actual API call here
    await Future.delayed(const Duration(milliseconds: 500));
    return 'new_access_token_${DateTime.now().millisecondsSinceEpoch}';
  }

  @override
  Future<Map<String, dynamic>> login(String email, String password) async {
    // Implement actual API call here
    await Future.delayed(const Duration(seconds: 1));
    return {
      'accessToken': 'access_token_${DateTime.now().millisecondsSinceEpoch}',
      'refreshToken': 'refresh_token_${DateTime.now().millisecondsSinceEpoch}',
      'expiry': DateTime.now().add(const Duration(hours: 1)).toIso8601String(),
      'user': {
        'id': 'user_123',
        'type': 'admin',
        'name': 'John Doe',
        'email': email,
        'profilePicture': null,
      },
    };
  }
}

// 5. Auth Notifier
class AuthNotifier extends StateNotifier<AuthState> {
  final AuthRepository _repository;
  final Ref _ref;

  AuthNotifier(this._ref, this._repository) : super(const AuthState()) {
    _initialize();
  }

  Future<void> _initialize() async {
    try {
      state = state.loading();
      final tokens = await _repository.getTokens();
      final user = await _repository.getUserData();
      
      if (tokens['accessToken'] != null && tokens['refreshToken'] != null) {
        final expiry = tokens['expiry'] != null 
            ? DateTime.parse(tokens['expiry']!) 
            : null;
            
        if (expiry != null && expiry.isAfter(DateTime.now())) {
          state = state.copyWith(
            accessToken: tokens['accessToken'],
            refreshToken: tokens['refreshToken'],
            tokenExpiry: expiry,
            user: user,
          );
        } else if (tokens['refreshToken'] != null) {
          await _refreshToken(tokens['refreshToken']!);
        }
      }
    } catch (e) {
      debugPrint('Auth initialization error: $e');
      state = state.error(e.toString());
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }

  Future<void> login({
    required String email,
    required String password,
    BuildContext? context,
  }) async {
    try {
      state = state.loading();
      final response = await _repository.login(email, password);
      
      final user = AuthUser.fromMap(response['user']);
      
      // Save both tokens and user data
      await Future.wait([
        _repository.saveTokens(
          accessToken: response['accessToken'],
          refreshToken: response['refreshToken'],
          expiry: DateTime.parse(response['expiry']),
        ),
        _repository.saveUserData(user),
      ]);
      
      state = state.authenticated(
        accessToken: response['accessToken'],
        refreshToken: response['refreshToken'],
        expiry: DateTime.parse(response['expiry']),
        user: user,
      );

      if (context != null && context.mounted) {
        context.go('/home');
      }
    } catch (e) {
      state = state.error(e.toString());
      rethrow;
    }
  }

  Future<void> _refreshToken(String refreshToken) async {
    try {
      final newAccessToken = await _repository.refreshToken(refreshToken);
      final newExpiry = DateTime.now().add(const Duration(hours: 1));
      await _repository.saveTokens(
        accessToken: newAccessToken,
        refreshToken: refreshToken,
        expiry: newExpiry,
      );
      
      state = state.copyWith(
        accessToken: newAccessToken,
        tokenExpiry: newExpiry,
      );
    } catch (e) {
      await logout();
      rethrow;
    }
  }

  Future<void> logout() async {
    try {
      state = state.loading();
      await _repository.clearAll();
      state = const AuthState();
    } catch (e) {
      state = state.error('Logout failed: $e');
      rethrow;
    }
  }

  Future<String?> getValidToken() async {
    if (!state.isAuthenticated) return null;
    if (state.shouldRefresh && state.refreshToken != null) {
      await _refreshToken(state.refreshToken!);
    }
    return state.accessToken;
  }
}

// 6. Provider Setup
final tokenServiceProvider = Provider<TokenService>((ref) {
  return kIsWeb ? WebTokenService() : MobileTokenService();
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl(ref.read(tokenServiceProvider));
});

final authNotifierProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(
    ref,
    ref.read(authRepositoryProvider),
  );
});