import 'package:flutter/material.dart';
import '../../models/job_model.dart';

class JobDetailsScreen extends StatelessWidget {
  const JobDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments;
    final JobModel? job = args is JobModel ? args : null;

    if (job == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Job Details')),
        body: const Center(child: Text('No job data')),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Job Details')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    job.title,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text('Employer: ${job.employerName}'),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.location_on, size: 16),
                      const SizedBox(width: 6),
                      Text(job.location),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.attach_money, size: 16),
                      const SizedBox(width: 6),
                      Text('${job.wage}৳'),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text('Job type: ${job.jobType}'),
                  const SizedBox(height: 8),
                  Text('Needed by: ${job.neededBy}'),
                  const SizedBox(height: 8),
                  Text('Number of workers: ${job.numWorkers}'),
                  const SizedBox(height: 12),
                  const Divider(),
                  const SizedBox(height: 12),
                  Text('Contact: ${job.contact}'),
                  const SizedBox(height: 12),
                  if (job.applicants.isNotEmpty) ...[
                    const Text(
                      'Applicants',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    ...job.applicants.map(
                      (a) => ListTile(
                        leading: CircleAvatar(
                          child: Text(a.name.isNotEmpty ? a.name[0] : '?'),
                        ),
                        title: Text(a.name),
                        subtitle: Text(
                          'Contact: ${a.contact} • Status: ${a.status}',
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
