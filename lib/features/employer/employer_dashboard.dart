import 'package:flutter/material.dart';
import '../../routes/app_routes.dart';
import '../../core/language_controller.dart';
import '../../core/localization/app_localizations.dart';
import 'post_job_screen.dart';
import 'applicants_screen.dart';
import 'employer_profile_edit_screen.dart';

class EmployerDashboard extends StatelessWidget {
  const EmployerDashboard({super.key});

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
        title: const Text('Employer Dashboard'),
        actions: [
          IconButton(
            tooltip: 'Edit Profile',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const EmployerProfileEditScreen(),
                ),
              );
            },
            icon: const Icon(Icons.person),
          ),
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
            constraints: const BoxConstraints(maxWidth: 600),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Welcome, Employer',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 20),
                Card(
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
                          builder: (_) => const PostJobScreen(),
                        ),
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 18,
                      ),
                      child: Row(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              color: Theme.of(
                                context,
                              ).colorScheme.primary.withOpacity(0.12),
                              shape: BoxShape.circle,
                            ),
                            padding: const EdgeInsets.all(12),
                            child: Icon(
                              Icons.post_add,
                              size: 28,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: const [
                                Text(
                                  'Post Job',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  'Create a new job posting',
                                  style: TextStyle(color: Colors.grey),
                                ),
                              ],
                            ),
                          ),
                          const Icon(
                            Icons.arrow_forward_ios,
                            size: 16,
                            color: Colors.grey,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                Card(
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
                          builder: (_) => const ApplicantsScreen(),
                        ),
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 18,
                      ),
                      child: Row(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              color: Theme.of(
                                context,
                              ).colorScheme.secondary.withOpacity(0.12),
                              shape: BoxShape.circle,
                            ),
                            padding: const EdgeInsets.all(12),
                            child: Icon(
                              Icons.people,
                              size: 28,
                              color: Theme.of(context).colorScheme.secondary,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: const [
                                Text(
                                  'View Applicants',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  'See applicants for your jobs',
                                  style: TextStyle(color: Colors.grey),
                                ),
                              ],
                            ),
                          ),
                          const Icon(
                            Icons.arrow_forward_ios,
                            size: 16,
                            color: Colors.grey,
                          ),
                        ],
                      ),
                    ),
                  ),
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
