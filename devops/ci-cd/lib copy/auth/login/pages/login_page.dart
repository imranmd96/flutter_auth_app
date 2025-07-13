// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:my_flutter_app_test/auth/login/controllers/login_controller.dart';
// import 'package:my_flutter_app_test/widgets/form_widgets.dart';

// import '../../../utils/theme.dart';

// class LoginPage extends StatelessWidget {
//   const LoginPage({super.key});

//   @override
//   Widget build(BuildContext context) {
//     final controller = Get.find<LoginController>();
//     return Scaffold(
//       body: Container(
//         decoration: BoxDecoration(
//           gradient: LinearGradient(
//             begin: Alignment.topLeft,
//             end: Alignment.bottomRight,
//             colors: [
//               AppColors.primary,
//               AppColors.primary.withValues(alpha: 0.8),
//             ],
//           ),
//         ),
//         child: Center(
//           child: SingleChildScrollView(
//             padding: const EdgeInsets.all(24),
//             child: Form(
//               key: controller.formKey,
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   const Icon(
//                     Icons.restaurant,
//                     size: 80,
//                     color: Colors.white,
//                   ),
//                   const SizedBox(height: 24),
//                   const Text(
//                     'Food Delivery App',
//                     style: TextStyle(
//                       fontSize: 32,
//                       fontWeight: FontWeight.bold,
//                       color: Colors.white,
//                     ),
//                   ),
//                   const SizedBox(height: 48),
//                   ErrorDisplay(error: controller.error),
//                   const SizedBox(height: 16),
//                   AppTextFormField(
//                     controller: controller.emailController,
//                     label: 'Email',
//                     keyboardType: TextInputType.emailAddress,
//                     validator: controller.emailValidator,
//                   ),
//                   const SizedBox(height: 16),
//                   AppTextFormField(
//                     controller: controller.passwordController,
//                     label: 'Password',
//                     obscureText: true,
//                     validator: controller.passwordValidator,
//                   ),
//                   const SizedBox(height: 24),
//                   LoadingButton(
//                     isLoading: controller.isLoading,
//                     onPressed: controller.login,
//                     label: 'Login',
//                     backgroundColor: Colors.white,
//                     foregroundColor: AppColors.primary,
//                   ),
//                   const SizedBox(height: 16),
//                   TextButton(
//                     onPressed: () => Get.toNamed('/register'),
//                     child: const Text(
//                       'Don\'t have an account? Register',
//                       style: TextStyle(color: Colors.white),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// } 

