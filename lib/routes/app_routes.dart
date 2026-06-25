import 'package:flutter/material.dart';

import '../features/auth/login_screen.dart';
import '../features/auth/register_screen.dart';
import '../features/worker/worker_dashboard.dart';
import '../features/employer/employer_dashboard.dart';
import '../features/admin/admin_dashboard.dart';
import '../features/chat/chatbot_screen.dart';
import '../features/job/job_details_screen.dart';

class AppRoutes {
  static const login = '/';
  static const splash = '/splash';
  static const register = '/register';
  static const worker = '/worker';
  static const employer = '/employer';
  static const admin = '/admin';
  static const chat = '/chat';
  static const jobDetails = '/job_details';

  static Map<String, WidgetBuilder> routes = {
    login: (context) => const LoginScreen(),
    register: (context) => const RegisterScreen(),
    worker: (context) => const WorkerDashboard(),
    employer: (context) => const EmployerDashboard(),
    admin: (context) => const AdminDashboard(),
    chat: (context) => const ChatbotScreen(),
    jobDetails: (context) => const JobDetailsScreen(),
  };

  // Use this with MaterialApp(onGenerateRoute: AppRoutes.onGenerateRoute)
  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    final name = settings.name;
    final builder = routes[name];
    if (builder != null) {
      return MaterialPageRoute(
        builder: (ctx) => builder(ctx),
        settings: settings,
      );
    }
    // fallback for unknown routes
    return MaterialPageRoute(
      builder: (_) => Scaffold(
        appBar: AppBar(title: const Text('Not Found')),
        body: Center(child: Text('No route defined for "$name"')),
      ),
      settings: settings,
    );
  }

  // Helper to navigate using named routes
  static Future<T?> navigateTo<T>(
    BuildContext context,
    String routeName, {
    Object? arguments,
  }) {
    return Navigator.pushNamed<T?>(context, routeName, arguments: arguments);
  }
}
