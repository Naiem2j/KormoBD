import 'package:flutter/material.dart';
import '../../models/job_model.dart';
import '../../core/services/job_service.dart';
import '../../models/applicant_model.dart';
import '../../core/services/location_service.dart';
import '../../core/services/profile_service.dart';
import '../../widgets/location_header.dart';
import '../../routes/app_routes.dart';

class JobListScreen extends StatefulWidget {
  const JobListScreen({super.key});

  // Sample job data. Replace with real data source as needed.
  List<JobModel> _sampleJobs() => [
    JobModel(
      id: 's1',
      title: 'Rajmistri Needed',
      employerName: 'Local Builder',
      jobType: 'Construction',
      numWorkers: 2,
      neededBy: 'ASAP',
      location: 'Dhaka',
      wage: 1000,
      contact: '017XXXXXXXX',
      status: 'approved',
    ),
    JobModel(
      id: 's2',
      title: 'Electrician',
      employerName: 'Home Fix',
      jobType: 'Electric',
      numWorkers: 1,
      neededBy: '2026-05-01',
      location: 'Chittagong',
      wage: 1200,
      contact: '018XXXXXXXX',
      status: 'approved',
    ),
    JobModel(
      id: 's3',
      title: 'Plumber',
      employerName: 'QuickPlumb',
      jobType: 'Plumbing',
      numWorkers: 1,
      neededBy: '2026-04-20',
      location: 'Sylhet',
      wage: 900,
      contact: '019XXXXXXXX',
      status: 'approved',
    ),
    JobModel(
      id: 's4',
      title: 'Carpenter',
      employerName: 'WoodWorks',
      jobType: 'Carpentry',
      numWorkers: 3,
      neededBy: '2026-04-25',
      location: 'Khulna',
      wage: 1100,
      contact: '016XXXXXXXX',
      status: 'approved',
    ),
  ];

  @override
  State<JobListScreen> createState() => _JobListScreenState();
}

class _JobListScreenState extends State<JobListScreen> {
  String _currentLocation = 'Loading...';
  late final List<JobModel> _jobs;

  @override
  void initState() {
    super.initState();
    _jobs = widget._sampleJobs();
    _loadLocation();
  }

  Future<void> _loadLocation() async {
    try {
      final loc = await LocationService().getCurrentLocation();
      if (!mounted) return;
      setState(() => _currentLocation = loc);
    } catch (_) {
      if (!mounted) return;
      setState(() => _currentLocation = 'Unknown');
    }
  }

  List<JobModel> get _filteredJobs {
    if (_currentLocation == 'Loading...' || _currentLocation == 'Unknown')
      return _jobs;
    final city = _currentLocation.split(',').first.trim().toLowerCase();
    final matches = _jobs
        .where((j) => j.location.toLowerCase() == city)
        .toList();
    return matches;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Job List'), elevation: 2),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Location display
            LocationHeader(location: _currentLocation),
            const SizedBox(height: 12),
            Expanded(
              child: ValueListenableBuilder<List<JobModel>>(
                valueListenable: JobService.instance.jobs,
                builder: (context, jobs, _) {
                  final allJobs = (jobs.isEmpty) ? _jobs : jobs;
                  final filtered = allJobs
                      .where((j) => j.status == 'approved')
                      .toList();
                  if (filtered.isEmpty) {
                    return Center(
                      child: Text(
                        'No jobs found in your area',
                        style: TextStyle(color: Colors.grey[700]),
                      ),
                    );
                  }

                  return ListView.builder(
                    itemCount: filtered.length,
                    physics: const BouncingScrollPhysics(),
                    itemBuilder: (context, index) {
                      final job = filtered[index];

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 6,
                          shadowColor: Colors.black26,
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            child: Row(
                              children: [
                                Container(
                                  width: 56,
                                  height: 56,
                                  decoration: BoxDecoration(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.primary.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Icon(
                                    Icons.work_outline,
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.primary,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        job.title,
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        '${job.location} • ${job.wage}৳',
                                        style: TextStyle(
                                          color: Colors.grey[700],
                                          fontSize: 13,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'Employer: ${job.employerName} • Need: ${job.numWorkers}',
                                        style: TextStyle(
                                          color: Colors.grey[600],
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Column(
                                  children: [
                                    ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                        elevation: 2,
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 16,
                                          vertical: 10,
                                        ),
                                      ),
                                      onPressed: () async {
                                        final profile =
                                            ProfileService().currentProfile;
                                        if (profile != null) {
                                          if (!profile.verified) {
                                            ScaffoldMessenger.of(
                                              context,
                                            ).showSnackBar(
                                              const SnackBar(
                                                content: Text(
                                                  'Your account is pending verification by admin',
                                                ),
                                              ),
                                            );
                                            return;
                                          }
                                          final applicant = Applicant(
                                            name: profile.name,
                                            contact: profile.contact,
                                          );
                                          JobService.instance.applyToJob(
                                            job.id,
                                            applicant,
                                            profile: profile,
                                          );
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            SnackBar(
                                              content: Text(
                                                'Applied to "${job.title}"',
                                              ),
                                            ),
                                          );
                                          return;
                                        }

                                        final result =
                                            await showDialog<
                                              Map<String, String>
                                            >(
                                              context: context,
                                              builder: (_) {
                                                final nameCtrl =
                                                    TextEditingController();
                                                final contactCtrl =
                                                    TextEditingController();
                                                return AlertDialog(
                                                  title: const Text(
                                                    'Apply for job',
                                                  ),
                                                  content: Column(
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    children: [
                                                      TextField(
                                                        controller: nameCtrl,
                                                        decoration:
                                                            const InputDecoration(
                                                              labelText:
                                                                  'Your name',
                                                            ),
                                                      ),
                                                      TextField(
                                                        controller: contactCtrl,
                                                        decoration:
                                                            const InputDecoration(
                                                              labelText:
                                                                  'Contact',
                                                            ),
                                                        keyboardType:
                                                            TextInputType.phone,
                                                      ),
                                                    ],
                                                  ),
                                                  actions: [
                                                    TextButton(
                                                      onPressed: () =>
                                                          Navigator.pop(
                                                            context,
                                                          ),
                                                      child: const Text(
                                                        'Cancel',
                                                      ),
                                                    ),
                                                    ElevatedButton(
                                                      onPressed: () {
                                                        if (nameCtrl.text
                                                            .trim()
                                                            .isEmpty)
                                                          return;
                                                        Navigator.pop(context, {
                                                          'name': nameCtrl.text
                                                              .trim(),
                                                          'contact': contactCtrl
                                                              .text
                                                              .trim(),
                                                        });
                                                      },
                                                      child: const Text(
                                                        'Apply',
                                                      ),
                                                    ),
                                                  ],
                                                );
                                              },
                                            );

                                        if (result != null) {
                                          JobService.instance.applyToJob(
                                            job.id,
                                            Applicant(
                                              name:
                                                  result['name'] ?? 'Anonymous',
                                              contact: result['contact'] ?? '',
                                            ),
                                          );
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            SnackBar(
                                              content: Text(
                                                'Applied to "${job.title}"',
                                              ),
                                            ),
                                          );
                                        }
                                      },
                                      child: const Text('Apply'),
                                    ),
                                    const SizedBox(height: 6),
                                    TextButton(
                                      onPressed: () => AppRoutes.navigateTo(
                                        context,
                                        AppRoutes.jobDetails,
                                        arguments: job,
                                      ),
                                      child: const Text('Details'),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
