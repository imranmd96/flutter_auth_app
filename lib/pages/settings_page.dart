import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_flutter_app/auth/login/provider/user_provider.dart';
import 'package:my_flutter_app/providers/app_lifecycle_provider.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lifecycleState = ref.watch(appLifecycleProvider);
    final userEmail = ref.watch(userEmailProvider);
    final userName = ref.watch(userNameProvider);
    final isAuthenticated = ref.watch(isAuthenticatedProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // User Info Section
            const Text(
              'User Information',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    _buildUserInfoItem('Authenticated', isAuthenticated ? 'Yes' : 'No'),
                    if (isAuthenticated) ...[
                      _buildUserInfoItem('Name', userName ?? 'Not available'),
                      _buildUserInfoItem('Email', userEmail ?? 'Not available'),
                    ] else
                      const Text('Please log in to see user information'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            
            // App Lifecycle Section
            const Text(
              'App Lifecycle Status',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            if (lifecycleState.isLoading)
              const Center(child: CircularProgressIndicator())
            else
              Column(
                children: [
                  _buildStatusItem('App Restarted', lifecycleState.isAppRestarted),
                  _buildStatusItem('Page Refreshed', lifecycleState.isPageRefreshed),
                  _buildStatusItem('First Launch', lifecycleState.isFirstLaunch),
                  if (lifecycleState.lastActivity != null)
                    _buildStatusItem('Last Activity', lifecycleState.lastActivity.toString()),
                  if (lifecycleState.inactiveDuration != null)
                    _buildStatusItem('Inactive Duration', '${lifecycleState.inactiveDuration!.inMinutes} minutes'),
                  if (lifecycleState.sessionId != null)
                    _buildStatusItem('Session ID', lifecycleState.sessionId!),
                  _buildStatusItem('Session Expired', lifecycleState.isSessionExpired),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => ref.read(appLifecycleProvider.notifier).recordUserActivity(),
                          child: const Text('Update Activity'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => ref.read(appLifecycleProvider.notifier).reset(),
                          child: const Text('Clear Flags'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => ref.read(appLifecycleProvider.notifier).refresh(),
                      child: const Text('Refresh Status'),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildUserInfoItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
          Text(value),
        ],
      ),
    );
  }

  Widget _buildStatusItem(String label, dynamic value) => Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: value == true ? Colors.green : Colors.grey,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              value.toString(),
              style: const TextStyle(color: Colors.white, fontSize: 12),
            ),
          ),
        ],
      ),
    );
} 