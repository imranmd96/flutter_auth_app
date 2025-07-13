import 'package:flutter/material.dart';
import 'components/welcome_card.dart';
import 'widgets/stat_card.dart';
import 'constants/admin_dashboard_constants.dart';

class AdminDashboardPage extends StatelessWidget {
  const AdminDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const WelcomeCard(),
          const SizedBox(height: 24),
          Text(
            'Quick Stats',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 1.3,
            children: [
              for (final stat in adminDashboardStats)
                StatCard(
                  title: stat['title']!,
                  value: stat['value']!,
                  icon: stat['icon'] as IconData,
                  color: stat['color'] as Color,
                ),
            ],
          ),
        ],
      ),
    );
  }
} 