// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:my_flutter_app/auth/login/provider/login_provider.dart';

// class MyHomePage extends ConsumerWidget {
//   const MyHomePage({super.key});

//   @override
//   Widget build(BuildContext context, WidgetRef ref) => Scaffold(
//         appBar: AppBar(title: const Text('Flutter Demo')),
//         body: Center(
//           child: ElevatedButton(
//             onPressed: () => ref.read(loginProvider.notifier).login(context),
//             child: const Text('Login'),
//           ),
//         ),
//       );
// } 


import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_flutter_app/auth/login/provider/login_provider.dart';

class MyHomePage extends ConsumerWidget {
  const MyHomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authNotifierProvider);
    final authNotifier = ref.read(authNotifierProvider.notifier);

    return Scaffold(
      appBar: AppBar(title: const Text('Flutter Demo')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (authState.isLoading)
              const CircularProgressIndicator(),
            if (authState.errorMessage != null)
              Text(
                authState.errorMessage!,
                style: const TextStyle(color: Colors.red),
              ),
            if (authState.isAuthenticated) ...[
              Text('Welcome ${authState.user?.name ?? ''}!'),
              const SizedBox(height: 8),
              Text('Email: ${authState.user?.email ?? 'No email'}'),
              const SizedBox(height: 8),
              Text('User Type: ${authState.user?.type ?? 'Unknown'}'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => authNotifier.logout(),
                child: const Text('Logout'),
              ),
            ] else ...[
              ElevatedButton(
                onPressed: () => authNotifier.login(
                  email: 'imran@com.com',
                  password: '123456',
                  context: context,
                ),
                child: const Text('Login'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}