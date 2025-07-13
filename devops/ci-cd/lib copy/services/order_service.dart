import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../config/api_config.dart';

class OrderState {
  final List<Map<String, dynamic>> orders;
  final bool isLoading;
  final String? error;

  OrderState({
    this.orders = const [],
    this.isLoading = false,
    this.error,
  });

  OrderState copyWith({
    List<Map<String, dynamic>>? orders,
    bool? isLoading,
    String? error,
  }) {
    return OrderState(
      orders: orders ?? this.orders,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class OrderNotifier extends StateNotifier<OrderState> {
  final Dio _dio;

  OrderNotifier() : _dio = Dio(BaseOptions(
    baseUrl: ApiConfig.userServiceUrl,
    connectTimeout: const Duration(seconds: 5),
    receiveTimeout: const Duration(seconds: 3),
  )), super(OrderState());

  Future<void> getOrders() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final response = await _dio.get(ApiConfig.orderServiceUrl);
      if (response.data is List) {
        final orders = (response.data as List)
            .map((item) => item as Map<String, dynamic>)
            .toList();
        state = state.copyWith(orders: orders, isLoading: false);
      } else {
        state = state.copyWith(isLoading: false);
      }
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }

  Future<Map<String, dynamic>?> getOrderDetails(String orderId) async {
    try {
      final response = await _dio.get('${ApiConfig.orderServiceUrl}/$orderId');
      if (response.data is Map<String, dynamic>) {
        return response.data as Map<String, dynamic>;
      }
      return null;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return null;
    }
  }

  Future<bool> createOrder(Map<String, dynamic> orderData) async {
    try {
      final response = await _dio.post(ApiConfig.orderServiceUrl, data: orderData);
      if (response.statusCode == 201) {
        await getOrders(); // Refresh orders list
        return true;
      }
      return false;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return false;
    }
  }

  Future<bool> updateOrderStatus(String orderId, String status) async {
    try {
      final response = await _dio.put(
        '${ApiConfig.orderServiceUrl}/$orderId/status',
        data: {'status': status},
      );
      if (response.statusCode == 200) {
        await getOrders(); // Refresh orders list
        return true;
      }
      return false;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return false;
    }
  }

  Future<bool> cancelOrder(String orderId) async {
    try {
      final response = await _dio.put(
        '${ApiConfig.orderServiceUrl}/$orderId/cancel',
      );
      if (response.statusCode == 200) {
        await getOrders(); // Refresh orders list
        return true;
      }
      return false;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return false;
    }
  }

  Future<List<Map<String, dynamic>>> getOrderHistory() async {
    try {
      final response = await _dio.get('${ApiConfig.orderServiceUrl}/history');
      if (response.data is List) {
        return (response.data as List)
            .map((item) => item as Map<String, dynamic>)
            .toList();
      }
      return [];
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return [];
    }
  }
}

final orderProvider = StateNotifierProvider<OrderNotifier, OrderState>((ref) {
  return OrderNotifier();
}); 