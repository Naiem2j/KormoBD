import 'package:flutter/material.dart';

class JobCard extends StatelessWidget {
  final String title;
  final String location;
  final String wage;
  final VoidCallback? onApply;

  const JobCard({
    super.key,
    required this.title,
    required this.location,
    required this.wage,
    this.onApply,
  });

  void _handleApply(BuildContext context) {
    if (onApply != null) {
      onApply!();
      return;
    }
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Applied successfully')));
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.03),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Icon(
                Icons.work_outline,
                size: 30,
                color: Colors.black54,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '$location • $wage',
                    style: const TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            ),
            ElevatedButton(
              onPressed: () => _handleApply(context),
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('Apply'),
            ),
          ],
        ),
      ),
    );
  }
}
