// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:my_flutter_app/config/api_config.dart';
// import 'package:my_flutter_app/services/base_api_service.dart';

// import '../../../../shared/exceptions/api_exception.dart';

// class AuthService extends BaseApiService {
//   AuthService(Ref ref) : super(baseUrl: ApiConfig.devBaseUrl, ref: ref);

//   /// Logs in the user using the provided email and password.
//   /// Uses BaseApiService's post method and _handleResponse for error handling.
//   Future<Map<String, dynamic>> login({required String email, required String password}) async {
//     final response = await post(
//       ApiConfig.login,
//       data: {
//         'email': email,
//         'password': password,
//       },
//     );
//     // _handleResponse is already called inside post, so just check the result
//     if (response != null && response['status'] == 'success' && response['data'] != null) {
//       return response['data'];
//     } else {
//       throw ApiException(
//         statusCode: response?['statusCode'] ?? 500,
//         message: response?['message'] ?? 'Invalid response format from server',
//       );
//     }
//   }
// } 