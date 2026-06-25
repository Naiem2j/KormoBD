import 'package:flutter/material.dart';

class LocationHeader extends StatelessWidget {
  final String location;
  final String label;
  final IconData icon;

  const LocationHeader({
    super.key,
    required this.location,
    this.label = 'Your Location',
    this.icon = Icons.location_on,
  });

  bool get _isLoading => location.toLowerCase().contains('loading');

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
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
              child: Icon(icon, size: 20, color: Colors.redAccent),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: Theme.of(context).textTheme.bodySmall),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          location,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (_isLoading) ...[
                        const SizedBox(width: 8),
                        const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
