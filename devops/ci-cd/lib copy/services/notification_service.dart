import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../config/api_config.dart';

class NotificationState {
  final List<Map<String, dynamic>> notifications;
  final bool isLoading;
  final String? error;

  NotificationState({
    this.notifications = const [],
    this.isLoading = false,
    this.error,
  });

  NotificationState copyWith({
    List<Map<String, dynamic>>? notifications,
    bool? isLoading,
    String? error,
  }) {
    return NotificationState(
      notifications: notifications ?? this.notifications,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class NotificationNotifier extends StateNotifier<NotificationState> {
  final Dio _dio;

  NotificationNotifier() : _dio = Dio(BaseOptions(
    baseUrl: ApiConfig.userServiceUrl,
    connectTimeout: const Duration(seconds: 5),
    receiveTimeout: const Duration(seconds: 3),
  )), super(NotificationState());

  Future<void> getNotifications() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final response = await _dio.get(ApiConfig.notifications);
      if (response.data is List) {
        final notifications = (response.data as List)
            .map((item) => item as Map<String, dynamic>)
            .toList();
        state = state.copyWith(notifications: notifications, isLoading: false);
      } else {
        state = state.copyWith(isLoading: false);
      }
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }

  Future<void> markAsRead(String notificationId) async {
    try {
      await _dio.put('${ApiConfig.notifications}/$notificationId/read');
      await getNotifications();
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> deleteNotification(String notificationId) async {
    try {
      await _dio.delete('${ApiConfig.notifications}/$notificationId');
      await getNotifications();
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> clearAllNotifications() async {
    try {
      await _dio.delete('${ApiConfig.notifications}/clear');
      state = state.copyWith(notifications: []);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }
}

final notificationProvider = StateNotifierProvider<NotificationNotifier, NotificationState>((ref) {
  return NotificationNotifier();
}); 