import 'package:flutter/material.dart';
import '../../routes/app_routes.dart';
import '../../core/language_controller.dart';
import '../../core/services/job_service.dart';
import '../../core/services/user_service.dart';
import '../../models/job_model.dart';
import '../../models/user_model.dart';
import 'verify_users_screen.dart';

class AdminDashboard extends StatelessWidget {
  const AdminDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushNamedAndRemoveUntil(
              context,
              AppRoutes.login,
              (route) => false,
            );
          },
          tooltip: 'Back to Login',
        ),
        title: const Text('Admin Dashboard'),
        actions: [
          PopupMenuButton<String>(
            onSelected: (v) {
              if (v == 'en') {
                LanguageController.of(context).setLocale(const Locale('en'));
              } else {
                LanguageController.of(context).setLocale(const Locale('bn'));
              }
            },
            itemBuilder: (_) => const [
              PopupMenuItem(value: 'en', child: Text('English')),
              PopupMenuItem(value: 'bn', child: Text('বাংলা')),
            ],
            icon: const Icon(Icons.language),
          ),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 700),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Admin Panel',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 16),

                // Summary row: total jobs and total users
                Row(
                  children: [
                    Expanded(
                      child: ValueListenableBuilder<List<JobModel>>(
                        valueListenable: JobService.instance.jobs,
                        builder: (context, jobs, _) {
                          return Card(
                            elevation: 2,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.work_outline, size: 28),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Jobs',
                                    style: Theme.of(
                                      context,
                                    ).textTheme.bodyLarge,
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    '${jobs.length}',
                                    style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ValueListenableBuilder<List<UserModel>>(
                        valueListenable: UserService.instance.users,
                        builder: (context, users, _) {
                          return Card(
                            elevation: 2,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.person, size: 28),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Users',
                                    style: Theme.of(
                                      context,
                                    ).textTheme.bodyLarge,
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    '${users.length}',
                                    style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // action cards (admin only verifies users now)
                Row(
                  children: [
                    Expanded(
                      child: Card(
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(12),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const VerifyUsersScreen(),
                              ),
                            );
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 18,
                              vertical: 20,
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  decoration: BoxDecoration(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.secondary.withOpacity(0.12),
                                    shape: BoxShape.circle,
                                  ),
                                  padding: const EdgeInsets.all(14),
                                  child: Icon(
                                    Icons.verified_user,
                                    size: 30,
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.secondary,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                const Text(
                                  'Verify Users',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                const Text(
                                  'Confirm user identities',
                                  style: TextStyle(color: Colors.grey),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => AppRoutes.navigateTo(context, AppRoutes.chat),
        child: const Icon(Icons.chat_bubble_outline),
        tooltip: 'Chatbot',
      ),
    );
  }
}
