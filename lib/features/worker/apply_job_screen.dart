import 'package:flutter/material.dart';
import '../../widgets/custom_button.dart';

class ApplyJobScreen extends StatelessWidget {
  const ApplyJobScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Example job details - replace with real data when available
    const jobTitle = 'Construction Worker';
    const location = 'Dhaka, Bangladesh';
    const wage = '৳ 15,000 / month';

    return Scaffold(
      appBar: AppBar(title: const Text('Apply Job')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 500),
            child: Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 28,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      jobTitle,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(Icons.location_on, size: 18, color: Colors.grey),
                        SizedBox(width: 6),
                        Text(
                          'Dhaka, Bangladesh',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(Icons.attach_money, size: 18, color: Colors.grey),
                        SizedBox(width: 6),
                        Text(
                          '৳ 15,000 / month',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    CustomButton(
                      text: 'Apply Now',
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Applied successfully')),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
