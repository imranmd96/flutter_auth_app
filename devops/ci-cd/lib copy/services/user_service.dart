import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:my_flutter_app/config/api_config.dart';

import 'base_api_service.dart';

final userServiceProvider = Provider((ref) => UserService(ref));

class UserService extends BaseApiService {
  UserService(Ref ref) : super(baseUrl: ApiConfig.userServiceUrl, ref: ref);

  Future<Map<String, dynamic>> getProfile() async {
    return await get(ApiConfig.profile);
  }

  Future<void> updateProfile({
    String? name,
    String? email,
    String? phone,
    String? address,
    String? profilePicture,
  }) async {
    final data = <String, dynamic>{};
    if (name != null) data['name'] = name;
    if (email != null) data['email'] = email;
    if (phone != null) data['phone'] = phone;
    if (address != null) data['address'] = address;
    if (profilePicture != null) data['profilePicture'] = profilePicture;

    await put(ApiConfig.updateProfile, data: data);
  }

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    await put(ApiConfig.changePassword, data: {
      'currentPassword': currentPassword,
      'newPassword': newPassword,
    });
  }

  Future<List<dynamic>> getFavorites() async {
    final result = await get('${ApiConfig.userServiceUrl}/favorites');
    if (result is List) return result;
    if (result is Map<String, dynamic>) {
      final data = result['data'];
      if (data is List) return List<dynamic>.from(data);
    }
    return <dynamic>[];
  }

  Future<void> addToFavorites(String restaurantId) async {
    await post('${ApiConfig.userServiceUrl}/favorites', data: {
      'restaurantId': restaurantId,
    });
  }

  Future<void> removeFromFavorites(String restaurantId) async {
    await delete('${ApiConfig.userServiceUrl}/favorites/$restaurantId');
  }

  Future<Map<String, dynamic>> getLoyaltyPoints() async {
    return await get('${ApiConfig.userServiceUrl}/loyalty/points');
  }

  Future<List<dynamic>> getLoyaltyHistory() async {
    final result = await get('${ApiConfig.userServiceUrl}/loyalty/history');
    if (result is List) return result;
    if (result is Map<String, dynamic>) {
      final data = result['data'];
      if (data is List) return List<dynamic>.from(data);
    }
    return <dynamic>[];
  }

  // Upload avatar (web and mobile)
  Future<String?> uploadAvatar({
    required dynamic imageFileOrBytes,
    required String accessToken,
    String? fileName,
    required bool isWeb,
  }) async {
    try {
      final uri = Uri.parse('${ApiConfig.userServiceUrl}/profile/avatar');
      final request = http.MultipartRequest('POST', uri);
      
      // Add authorization header
      request.headers['Authorization'] = 'Bearer $accessToken';
      
      // Add file to request
      if (isWeb) {
        // Web: imageFileOrBytes is Uint8List
        request.files.add(
          http.MultipartFile.fromBytes(
            'avatar',
            imageFileOrBytes,
            filename: fileName ?? 'avatar.png',
          ),
        );
      } else {
        // Mobile: imageFileOrBytes is File
        request.files.add(
          await http.MultipartFile.fromPath(
            'avatar',
            (imageFileOrBytes as File).path,
          ),
        );
      }

      // Send request
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data is Map<String, dynamic> && data['url'] != null) {
          return data['url'] as String;
        }
      }
      
      debugPrint('Upload failed: ${response.body}');
      return null;
    } catch (e) {
      debugPrint('Error uploading avatar: $e');
      return null;
    }
  }
} 