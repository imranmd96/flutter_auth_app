// import 'package:shared_preferences/shared_preferences.dart';

// class TokenStorageService {
//   static const String accessTokenKey = 'access_token';
//   static const String refreshTokenKey = 'refresh_token';

//   Future<String?> getToken(String key) async {
//     final prefs = await SharedPreferences.getInstance();
//     return prefs.getString(key);
//   }

//   Future<void> setToken(String key, String value) async {
//     final prefs = await SharedPreferences.getInstance();
//     await prefs.setString(key, value);
//   }

// } 