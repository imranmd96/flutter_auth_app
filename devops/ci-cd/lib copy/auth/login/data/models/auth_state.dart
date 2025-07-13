import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'user_type.dart';

part 'auth_state.freezed.dart';
part 'auth_state.g.dart';

/// Represents the authentication state of the application.
/// This class handles both the state data and its persistence.
@freezed
class AuthState with _$AuthState {
  const AuthState._(); // Add private constructor for custom methods

  // Constants
  static const String _storageKey = 'auth_state';
  static const String _defaultProfilePicture = 'assets/images/default_avatar.png';
  static const Color _primaryColor = Color(0xFF4B1EFF);

  // Default avatar widget
  static Widget get defaultAvatarWidget => const Icon(
        Icons.person,
        size: 40,
        color: _primaryColor,
      );

  const factory AuthState({
    @Default(false) bool isAuthenticated,
    @Default(false) bool isLoading,
    @Default(false) bool isInitialized,
    @Default(UserType.user) String userType,
    @Default('') String error,
    @Default('') String userName,
    @Default('') String email,
    @Default('') String userId,
    @Default('') String accessToken,
    @Default('') String refreshToken,
    @Default('') String profilePicture,
    Map<String, dynamic>? user,
  }) = _AuthState;

  factory AuthState.fromJson(Map<String, dynamic> json) => _$AuthStateFromJson(json);

  /// Creates a new AuthState with updated user data
  AuthState updateUserData(Map<String, dynamic> userData) {
    final name = userData['name'] as String? ?? userName;
    final picture = _getProfilePicture(userData);
    
    return copyWith(
      userName: name,
      email: userData['email'] as String? ?? email,
      userId: userData['id'] as String? ?? userId,
      profilePicture: picture,
      userType: userData['type'] as String? ?? 'user',
      user: userData,
    );
  }

  /// Creates a new AuthState with updated tokens
  AuthState updateTokens({
    required String accessToken,
    required String refreshToken,
  }) {
    return copyWith(
      accessToken: accessToken,
      refreshToken: refreshToken,
      isAuthenticated: true,
    );
  }

  /// Creates a new AuthState with error
  AuthState withError(String errorMessage) {
    return copyWith(
      error: errorMessage,
      isLoading: false,
    );
  }

  /// Creates a new AuthState with loading state
  AuthState withLoading(bool isLoading) {
    return copyWith(isLoading: isLoading);
  }

  /// Saves the current state to SharedPreferences
  Future<void> save({String? storageKey}) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final stateJson = toJson();
      final jsonString = jsonEncode(stateJson);
      
      await prefs.setString(storageKey ?? _storageKey, jsonString);
    } catch (e) {
      throw Exception('Failed to save auth state: $e');
    }
  }

  /// Loads the saved state from SharedPreferences
  static Future<AuthState> load({String? storageKey}) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final stateJson = prefs.getString(storageKey ?? _storageKey);
      
      if (stateJson == null) {
        return const AuthState();
      }
      
      final Map<String, dynamic> decodedJson = jsonDecode(stateJson);
      final authState = AuthState.fromJson(decodedJson);
      
      return authState;
    } catch (e) {
      return const AuthState();
    }
  }

  /// Clears the saved state from SharedPreferences
  static Future<void> clear({String? storageKey}) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(storageKey ?? _storageKey);
    } catch (e) {
      throw Exception('Failed to clear auth state: $e');
    }
  }

  /// Checks if there is a valid stored state
  static Future<bool> hasStoredState({String? storageKey}) async {
    try {
      final state = await load(storageKey: storageKey);
      return state.hasValidTokens;
    } catch (e) {
      return false;
    }
  }

  /// Creates a new state with cleared error
  AuthState clearError() {
    return copyWith(error: '');
  }

  /// Creates a new state for logout
  static AuthState logout() {
    return const AuthState();
  }

  /// Checks if the current state has valid tokens
  bool get hasValidTokens => accessToken.isNotEmpty && refreshToken.isNotEmpty;

  /// Gets the user's display name
  String get displayName => userName.isNotEmpty ? userName : email;

  /// Gets the authorization header value
  String get authorizationHeader => 'Bearer $accessToken';

  /// Gets the profile picture URL, using default if none exists
  String get profilePictureUrl {
    return profilePicture.isEmpty ? _defaultProfilePicture : profilePicture;
  }

  /// Checks if the current profile picture is the default one
  bool get isDefaultProfilePicture => profilePicture.isEmpty || profilePicture == _defaultProfilePicture;

  /// Gets the profile picture from user data
  String _getProfilePicture(Map<String, dynamic> userData) {
    final picture = userData['profilePicture'] as String?;
    return (picture == null || picture.isEmpty) ? _defaultProfilePicture : picture;
  }
} 