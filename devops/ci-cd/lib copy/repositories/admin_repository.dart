import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../config/api_config.dart';
import '../models/dashboard_models.dart';
import '../services/base_api_service.dart';

final adminRepositoryProvider = Provider((ref) => AdminRepository(ref));

class AdminRepository {
  final BaseApiService _apiService;

  AdminRepository(Ref ref) : _apiService = BaseApiService(baseUrl: ApiConfig.adminServiceUrl, ref: ref);

  // Get dashboard data (mock for now)
  Future<DashboardResponse> getDashboardData() async {
    // Return mock data for admin dashboard
    final data = {
      'success': true,
      'data': {
        'message': 'Mock admin dashboard data',
        'stats': {
          'users': 100,
          'restaurants': 20,
          'orders': 50,
        },
      },
    };
    return DashboardResponse.fromJson(data);
  }

  // Get all users
  Future<List<dynamic>> getUsers() async {
    final result = await _apiService.get('/users');
    if (result is List) return result;
    if (result is Map && result['data'] is List) return result['data'] as List<dynamic>;
    return [];
  }

  // Get all restaurants
  Future<List<dynamic>> getRestaurants() async {
    final result = await _apiService.get('/restaurants');
    if (result is List) return result;
    if (result is Map && result['data'] is List) return result['data'] as List<dynamic>;
    return [];
  }

  // Get all orders
  Future<List<dynamic>> getOrders() async {
    final result = await _apiService.get('/orders');
    if (result is List) return result;
    if (result is Map && result['data'] is List) return result['data'] as List<dynamic>;
    return [];
  }

  // Get reports (mock for now)
  Future<Map<String, dynamic>> getReports() async {
    // Return mock data for reports
    return {
      'success': true,
      'data': {
        'message': 'Mock admin reports data',
        'reports': [],
      },
    };
  }

  // Update user status
  Future<void> updateUserStatus(String userId, String status) async {
    await _apiService.put('/users/$userId', data: {'status': status});
  }

  // Update restaurant status
  Future<void> updateRestaurantStatus(String restaurantId, String status) async {
    await _apiService.put('/restaurants/$restaurantId', data: {'status': status});
  }
} 