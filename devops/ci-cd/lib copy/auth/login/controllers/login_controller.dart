// import 'package:flutter/material.dart';
// import 'package:form_validator/form_validator.dart';
// import 'package:get/get.dart';
// import 'package:get_storage/get_storage.dart';
// import 'package:my_flutter_app_test/sidebar/controllers/sidebar_controller.dart';

// import '../../../token/services/token_refresh_service.dart';
// import '../services/auth_service.dart';

// class LoginController extends GetxController {
//   // Auth state
//   final RxBool isAdmin = false.obs;
//   final RxString userName = ''.obs;
//   final RxString profilePicture = ''.obs;
//   final RxString accessToken = ''.obs;
//   final RxString refreshToken = ''.obs;
//   final TokenRefreshService _tokenRefreshService = TokenRefreshService();

//   // Login form state
//   final AuthService _authService = AuthService();
//   final emailController = TextEditingController();
//   final passwordController = TextEditingController();
//   final formKey = GlobalKey<FormState>();
//   final RxBool isLoading = false.obs;
//   final RxString error = ''.obs;
//   final box = GetStorage();

//   // Form validation
//   final emailValidator = ValidationBuilder()
//     .required('Email is required')
//     .email('Please enter a valid email')
//     .build();

//   final passwordValidator = ValidationBuilder()
//     .required('Password is required')
//     .minLength(6, 'Password must be at least 6 characters')
//     .build();

//   // Setters for user/session state
//   void setUserType(bool admin) => isAdmin.value = admin;
//   void setUserName(String name) => userName.value = name;
//   void setProfilePicture(String url) => profilePicture.value = url;
//   void setAccessToken(String token) => accessToken.value = token;

//   void setRefreshToken(String token) {
//     refreshToken.value = token;
//     _tokenRefreshService.scheduleTokenRefresh(
//       refreshToken: token,
//       onRefresh: (tokens) async {
//         if (tokens != null) {
//           accessToken.value = tokens['accessToken'];
//           setRefreshToken(tokens['refreshToken']);
//         }
//       },
//       onSessionExpired: _handleSessionExpiry,
//     );
//   }

//   void _handleSessionExpiry() {
//     accessToken.value = '';
//     refreshToken.value = '';
//     // Optionally: trigger logout UI or callback
//   }

//   // Main login method
//   Future<void> login() async {
//     if (!formKey.currentState!.validate()) return;
//     isLoading.value = true;
//     error.value = '';
//     try {
//       final response = await _authService.login(
//         email: emailController.text.trim(),
//         password: passwordController.text,
//       );
//       if (response['tokens'] != null && response['user'] != null) {
//         final tokens = response['tokens'];
//         final user = response['user'];
//         // Persist tokens and user info as JSON
//         box.write('tokens', tokens);
//         box.write('user', user);
//         setUserType(user['role'] == 'admin');
//         setUserName(user['name'] ?? '');
//         setAccessToken(tokens['accessToken']);
//         setRefreshToken(tokens['refreshToken']);
//         final sidebarController = Get.find<SidebarController>();
//         sidebarController.updateMenuItems(user['role'] == 'admin');
//         Get.offAllNamed('/dashboard');
//       } else {
//         error.value = 'Invalid response from server';
//       }
//     } catch (e) {
//       error.value = e.toString();
//     } finally {
//       isLoading.value = false;
//     }
//   }

//   // Restore session from storage
//   void restoreSession() {
//     final tokens = box.read('tokens');
//     final user = box.read('user');
//     if (tokens != null && user != null) {
//       setUserType(user['role'] == 'admin');
//       setUserName(user['name'] ?? '');
//       setAccessToken(tokens['accessToken']);
//       setRefreshToken(tokens['refreshToken']);
//       final sidebarController = Get.find<SidebarController>();
//       sidebarController.updateMenuItems(user['role'] == 'admin');
//     }
//   }

//   @override
//   void onClose() {
//     emailController.dispose();
//     passwordController.dispose();
//     _tokenRefreshService.dispose();
//     super.onClose();
//   }
// } 