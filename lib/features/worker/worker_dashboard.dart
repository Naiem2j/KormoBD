import 'package:flutter/material.dart';
import '../../core/services/location_service.dart';
import '../../core/services/job_service.dart';
import '../../models/job_model.dart';
import '../../widgets/location_header.dart';
import '../../routes/app_routes.dart';
import '../../core/language_controller.dart';
import '../../core/services/profile_service.dart';
import '../../models/applicant_model.dart';
import '../../models/worker_profile.dart';
import 'profile_edit_screen.dart';
import '../../core/localization/app_localizations.dart';
import '../../core/constants/strings.dart';

class WorkerDashboard extends StatefulWidget {
  const WorkerDashboard({super.key});

  @override
  State<WorkerDashboard> createState() => _WorkerDashboardState();
}

class _WorkerDashboardState extends State<WorkerDashboard> {
  final TextEditingController _searchCtrl = TextEditingController();
  String _selectedLocation = 'All';
  double _minWage = 0;
  String _currentLocation = 'Loading...';

  final List<JobModel> _sampleJobs = [
    JobModel(
      id: 's1',
      title: 'Rajmistri Needed',
      employerName: 'Sample',
      jobType: 'Construction',
      numWorkers: 2,
      neededBy: 'ASAP',
      location: 'Dhaka',
      wage: 1200,
      contact: '',
    ),
    JobModel(
      id: 's2',
      title: 'Cleaner / Helper',
      employerName: 'Sample',
      jobType: 'Cleaning',
      numWorkers: 1,
      neededBy: 'ASAP',
      location: 'Chittagong',
      wage: 600,
      contact: '',
    ),
    JobModel(
      id: 's3',
      title: 'Electrician',
      employerName: 'Sample',
      jobType: 'Electric',
      numWorkers: 1,
      neededBy: 'ASAP',
      location: 'Dhaka',
      wage: 1500,
      contact: '',
    ),
    JobModel(
      id: 's4',
      title: 'Painter',
      employerName: 'Sample',
      jobType: 'Painting',
      numWorkers: 1,
      neededBy: 'ASAP',
      location: 'Sylhet',
      wage: 800,
      contact: '',
    ),
    JobModel(
      id: 's5',
      title: 'Carpenter',
      employerName: 'Sample',
      jobType: 'Carpentry',
      numWorkers: 2,
      neededBy: 'ASAP',
      location: 'Khulna',
      wage: 1100,
      contact: '',
    ),
    JobModel(
      id: 's6',
      title: 'Delivery Assistant',
      employerName: 'Sample',
      jobType: 'Delivery',
      numWorkers: 1,
      neededBy: 'ASAP',
      location: 'Dhaka',
      wage: 700,
      contact: '',
    ),
  ];

  List<JobModel> _filterJobs(List<JobModel> source) {
    final q = _searchCtrl.text.trim().toLowerCase();
    return source.where((j) {
      if (_selectedLocation != 'All' && j.location != _selectedLocation)
        return false;
      if (j.wage < _minWage) return false;
      if (q.isEmpty) return true;
      return j.title.toLowerCase().contains(q) ||
          j.location.toLowerCase().contains(q);
    }).toList();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    // Prefer profile address if available, fall back to LocationService
    final prof = ProfileService().currentProfile;
    if (prof != null && prof.address.trim().isNotEmpty) {
      _currentLocation = prof.address;
    } else {
      LocationService()
          .getCurrentLocation()
          .then((loc) {
            if (!mounted) return;
            setState(() => _currentLocation = loc);
          })
          .catchError((_) {
            if (!mounted) return;
            setState(() => _currentLocation = 'Unknown');
          });
    }
  }

  void _openFilter() async {
    final result = await showModalBottomSheet<Map<String, dynamic>>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        String loc = _selectedLocation;
        double min = _minWage;
        return StatefulBuilder(
          builder: (c, s) {
            return Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'Filters',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: loc,
                    items: ['All', 'Dhaka', 'Chittagong', 'Sylhet', 'Khulna']
                        .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                        .toList(),
                    onChanged: (v) => s(() => loc = v!),
                    decoration: const InputDecoration(labelText: 'Location'),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Minimum wage: ৳${min.toInt()}',
                    style: const TextStyle(fontSize: 14),
                  ),
                  Slider(
                    value: min,
                    min: 0,
                    max: 2000,
                    divisions: 20,
                    onChanged: (v) => s(() => min = v),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(ctx, {'reset': true}),
                          child: const Text('Reset'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => Navigator.pop(ctx, {
                            'location': loc,
                            'minWage': min,
                          }),
                          child: const Text('Apply'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );

    if (result == null) return;
    if (result['reset'] == true) {
      setState(() {
        _selectedLocation = 'All';
        _minWage = 0;
      });
      return;
    }
    setState(() {
      _selectedLocation = result['location'] as String? ?? 'All';
      _minWage = (result['minWage'] as double?) ?? 0;
    });
  }

  void _openProfileSheet() {
    final p = ProfileService().currentProfile;
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) {
        return SizedBox(
          height: 260,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundColor: Colors.grey.shade200,
                      foregroundImage: p?.photoUrl != null
                          ? NetworkImage(p!.photoUrl!)
                          : null,
                      child: p == null || p.photoUrl == null
                          ? Text(p?.name.isNotEmpty == true ? p!.name[0] : 'W')
                          : null,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            p?.name ?? 'No name',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            p?.jobType ?? '',
                            style: const TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const ProfileEditScreen(),
                          ),
                        );
                      },
                      child: const Text('Edit'),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text('Experience: ${p?.experienceYears ?? '-'} years'),
                const SizedBox(height: 6),
                Text('Contact: ${p?.contact ?? '-'}'),
                const SizedBox(height: 6),
                Text('Address: ${p?.address ?? '-'}'),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentLang = LanguageController.of(context).locale.languageCode;
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
        title: Text(AppText.getText('worker', currentLang)),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => FocusScope.of(context).requestFocus(FocusNode()),
          ),
          // Language selector
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
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: GestureDetector(
              onTap: _openProfileSheet,
              child: StreamBuilder<void>(
                stream: null,
                builder: (_, __) {
                  final p = ProfileService().currentProfile;
                  if (p == null || p.photoUrl == null) {
                    final initials = p == null || p.name.isEmpty
                        ? 'W'
                        : p.name[0];
                    return CircleAvatar(
                      backgroundColor: Colors.white24,
                      child: Text(
                        initials,
                        style: const TextStyle(color: Colors.white),
                      ),
                    );
                  }
                  return CircleAvatar(
                    backgroundColor: Colors.white24,
                    foregroundImage: NetworkImage(p.photoUrl!),
                  );
                },
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Current location display
              LocationHeader(location: _currentLocation),
              // Debug: show current job count from JobService
              Padding(
                padding: const EdgeInsets.only(top: 8, bottom: 8),
                child: ValueListenableBuilder<List<JobModel>>(
                  valueListenable: JobService.instance.jobs,
                  builder: (_, list, __) => Text(
                    'Jobs available: ${list.length}',
                    style: TextStyle(color: Colors.grey[700]),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _searchCtrl,
                      decoration: InputDecoration(
                        hintText: 'Search jobs, locations...',
                        prefixIcon: const Icon(Icons.search),
                        filled: true,
                        fillColor: Colors.grey[100],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      onChanged: (_) => setState(() {}),
                    ),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton.icon(
                    onPressed: _openFilter,
                    icon: const Icon(Icons.filter_list),
                    label: const Text('Filter'),
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Expanded(
                child: ScrollConfiguration(
                  behavior: const ScrollBehavior().copyWith(overscroll: false),
                  child: ValueListenableBuilder<List<JobModel>>(
                    valueListenable: JobService.instance.jobs,
                    builder: (_, postedJobs, __) {
                      final source = postedJobs.isEmpty
                          ? _sampleJobs
                          : postedJobs;
                      final visible = _filterJobs(source);

                      if (visible.isEmpty) {
                        return Center(
                          child: Text(
                            'No jobs found',
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                        );
                      }

                      return ListView.builder(
                        physics: const BouncingScrollPhysics(),
                        itemCount: visible.length,
                        itemBuilder: (ctx, i) {
                          final job = visible[i];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: Card(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                              elevation: 3,
                              child: Padding(
                                padding: const EdgeInsets.all(12),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 56,
                                      height: 56,
                                      decoration: BoxDecoration(
                                        color: Colors.deepPurple.shade50,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: const Icon(
                                        Icons.work_outline,
                                        color: Colors.deepPurple,
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
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          const SizedBox(height: 6),
                                          Row(
                                            children: [
                                              const Icon(
                                                Icons.location_on,
                                                size: 14,
                                                color: Colors.grey,
                                              ),
                                              const SizedBox(width: 4),
                                              Text(
                                                job.location,
                                                style: const TextStyle(
                                                  color: Colors.grey,
                                                ),
                                              ),
                                              const SizedBox(width: 12),
                                              const Icon(
                                                Icons.monetization_on,
                                                size: 14,
                                                color: Colors.grey,
                                              ),
                                              const SizedBox(width: 4),
                                              Text(
                                                '৳${job.wage}',
                                                style: const TextStyle(
                                                  color: Colors.grey,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                    Column(
                                      children: [
                                        ElevatedButton(
                                          onPressed: () {
                                            final p =
                                                ProfileService().currentProfile;
                                            if (p == null) {
                                              ScaffoldMessenger.of(
                                                context,
                                              ).showSnackBar(
                                                SnackBar(
                                                  content: Text(
                                                    'Please complete your profile before applying',
                                                  ),
                                                ),
                                              );
                                              return;
                                            }

                                            final applicant = Applicant(
                                              name: p.name,
                                              contact: p.contact,
                                            );
                                            // prevent duplicate apply by contact
                                            final already = job.applicants.any(
                                              (a) =>
                                                  a.contact ==
                                                  applicant.contact,
                                            );
                                            if (already) {
                                              ScaffoldMessenger.of(
                                                context,
                                              ).showSnackBar(
                                                SnackBar(
                                                  content: Text(
                                                    'You have already applied to this job',
                                                  ),
                                                ),
                                              );
                                              return;
                                            }

                                            if (!p.verified) {
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

                                            JobService.instance.applyToJob(
                                              job.id,
                                              applicant,
                                              profile: p,
                                            );
                                            ScaffoldMessenger.of(
                                              context,
                                            ).showSnackBar(
                                              SnackBar(
                                                content: Text(
                                                  '${AppText.getText('apply_job', currentLang)} sent',
                                                ),
                                              ),
                                            );
                                          },
                                          style: ElevatedButton.styleFrom(
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                          ),
                                          child: Text(
                                            AppText.getText(
                                              'apply_job',
                                              currentLang,
                                            ),
                                          ),
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
              ),
            ],
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

class _Job {
  final String title;
  final String location;
  final int wage;
  _Job(this.title, this.location, this.wage);
}
