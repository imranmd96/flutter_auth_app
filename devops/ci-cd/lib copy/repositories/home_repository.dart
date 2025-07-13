import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../config/api_config.dart';
import '../models/dashboard_models.dart';
import '../services/base_api_service.dart';
import '../services/restaurant_service.dart';

final homeRepositoryProvider = Provider((ref) => HomeRepository(ref));

class HomeRepository {
  final Ref ref;
  final BaseApiService _apiService;
  late final RestaurantService _restaurantService;

  HomeRepository(this.ref) : _apiService = BaseApiService(baseUrl: ApiConfig.userServiceUrl, ref: ref) {
    _restaurantService = RestaurantService(ref);
  }

  // Get dashboard data (mock for now)
  Future<DashboardResponse> getDashboardData() async {
    // Return mock data for dashboard
    final data = {
      'success': true,
      'data': {
        'message': 'Mock dashboard data',
        'stats': {
          'orders': 10,
          'bookings': 5,
          'favorites': 3,
        },
      },
    };
    return DashboardResponse.fromJson(data);
  }

  // Get featured restaurants
  Future<List<dynamic>> getFeaturedRestaurants() async {
    return await _restaurantService.getRestaurants();
  }

  // Get all restaurants
  Future<List<dynamic>> getRestaurants() async {
    final result = await _apiService.get('/restaurants');
    if (result is List) return result;
    if (result is Map && result['data'] is List) return result['data'] as List<dynamic>;
    return [];
  }

  // Get user orders
  Future<List<dynamic>> getOrders() async {
    final result = await _apiService.get('/orders');
    if (result is List) return result;
    if (result is Map && result['data'] is List) return result['data'] as List<dynamic>;
    return [];
  }

  // Get user profile
  Future<Map<String, dynamic>> getUserProfile() async {
    return await _apiService.get('/profile');
  }

  // Search restaurants
  Future<List<dynamic>> searchRestaurants(String query) async {
    final result = await _apiService.get('/restaurants/search?q=$query');
    if (result is List) return result;
    if (result is Map && result['data'] is List) return result['data'] as List<dynamic>;
    return [];
  }

  Future<List<dynamic>> getPopularRestaurants() async {
    final result = await _apiService.get('/restaurants/popular');
    if (result is List) return result;
    return [];
  }

  Future<List<dynamic>> getRecentOrders() async {
    final result = await _apiService.get('/orders/recent');
    if (result is List) return result;
    return [];
  }

  Future<List<dynamic>> getRecommendedItems() async {
    final result = await _apiService.get('/items/recommended');
    if (result is List) return result;
    return [];
  }
} 