import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../config/api_config.dart';
import '../services/base_api_service.dart';

class OrderRepository {
  final BaseApiService _apiService;

  OrderRepository(Ref ref) : _apiService = BaseApiService(baseUrl: ApiConfig.orderServiceUrl, ref: ref);

  // Create new order
  Future<Map<String, dynamic>> createOrder(Map<String, dynamic> orderData) async {
    return await _apiService.post('/orders', data: orderData);
  }

  // Get order details
  Future<Map<String, dynamic>> getOrderDetails(String orderId) async {
    return await _apiService.get('/orders/$orderId');
  }

  // Get order history
  Future<List<dynamic>> getOrderHistory() async {
    return await _apiService.get('/orders/history');
  }

  // Update order status
  Future<void> updateOrderStatus(String orderId, String status) async {
    await _apiService.put('/orders/$orderId', data: {'status': status});
  }

  // Cancel order
  Future<void> cancelOrder(String orderId) async {
    await _apiService.delete('/orders/$orderId');
  }
} 