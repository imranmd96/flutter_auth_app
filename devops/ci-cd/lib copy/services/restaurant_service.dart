import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_flutter_app/config/api_config.dart';

import 'base_api_service.dart';

class RestaurantService extends BaseApiService {
  RestaurantService(Ref ref) : super(baseUrl: ApiConfig.restaurantServiceUrl, ref: ref);

  Future<List<dynamic>> getRestaurants({
    String? search,
    String? cuisine,
    double? latitude,
    double? longitude,
    int? radius,
  }) async {
    final params = <String, dynamic>{};
    if (search != null) params['search'] = search;
    if (cuisine != null) params['cuisine_type'] = cuisine;
    if (latitude != null) params['lat'] = latitude;
    if (longitude != null) params['lng'] = longitude;
    if (radius != null) params['max_distance'] = radius;

    final result = await get(ApiConfig.restaurants, queryParameters: params);
    if (result is List) return result;
    if (result is Map && result['data'] is List) return result['data'];
    throw Exception('Unexpected response format for restaurants');
  }

  Future<Map<String, dynamic>> getRestaurantDetails(String id) async {
    return await get(ApiConfig.restaurantDetails.replaceAll('{id}', id));
  }

  Future<List<dynamic>> getRestaurantMenu(String id) async {
    final result = await get(ApiConfig.restaurantMenu.replaceAll('{id}', id));
    if (result is List) return result;
    if (result is Map && result['data'] is List) return result['data'];
    throw Exception('Unexpected response format for restaurant menu');
  }

  Future<List<dynamic>> getRestaurantReviews(String id) async {
    final result = await get(ApiConfig.restaurantReviews.replaceAll('{id}', id));
    if (result is List) return result;
    if (result is Map && result['data'] is List) return result['data'];
    throw Exception('Unexpected response format for restaurant reviews');
  }
} 