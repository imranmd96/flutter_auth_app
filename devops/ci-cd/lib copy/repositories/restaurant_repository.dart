import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../config/api_config.dart';
import '../services/base_api_service.dart';

class RestaurantRepository {
  final BaseApiService _apiService;

  RestaurantRepository(Ref ref) : _apiService = BaseApiService(baseUrl: ApiConfig.restaurantServiceUrl, ref: ref);

  // Get all restaurants
  Future<List<dynamic>> getAllRestaurants() async {
    return await _apiService.get('/restaurants');
  }

  // Get restaurant details
  Future<Map<String, dynamic>> getRestaurantDetails(String id) async {
    return await _apiService.get('/restaurants/$id');
  }

  // Get restaurant menu
  Future<List<dynamic>> getRestaurantMenu(String id) async {
    return await _apiService.get('/restaurants/$id/menu');
  }

  // Get restaurant reviews
  Future<List<dynamic>> getRestaurantReviews(String id) async {
    return await _apiService.get('/restaurants/$id/reviews');
  }

  // Place order
  Future<Map<String, dynamic>> placeOrder(String restaurantId, List<Map<String, dynamic>> items) async {
    return await _apiService.post(
      '/orders',
      data: {
        'restaurantId': restaurantId,
        'items': items,
      },
    );
  }

  // Rate restaurant
  Future<Map<String, dynamic>> rateRestaurant(String id, double rating, String review) async {
    return await _apiService.post(
      '/restaurants/$id/rate',
      data: {
        'rating': rating,
        'review': review,
      },
    );
  }
} 