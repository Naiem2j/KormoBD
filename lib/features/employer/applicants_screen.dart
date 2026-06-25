import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/services/job_service.dart';
import '../../core/services/profile_service.dart';

class ApplicantsScreen extends StatefulWidget {
  const ApplicantsScreen({super.key});

  @override
  State<ApplicantsScreen> createState() => _ApplicantsScreenState();
}

class _ApplicantsScreenState extends State<ApplicantsScreen> {
  @override
  Widget build(BuildContext context) {
    final profile = ProfileService().currentProfile;

    return Scaffold(
      appBar: AppBar(title: const Text('Applicants')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: StreamBuilder<QuerySnapshot>(
          // Fetch all applications and filter/sort locally to avoid Firestore
          // composite index issues or missing 'createdAt' fields.
          stream: FirebaseFirestore.instance
              .collection('applications')
              .snapshots(),
          builder: (context, snap) {
            if (snap.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (!snap.hasData || snap.data!.docs.isEmpty) {
              return Center(
                child: Text(
                  'No applicants yet',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              );
            }

            // Collect docs, filter by pending status and employer match
            final allDocs = snap.data!.docs.toList();
            final filteredDocs = <QueryDocumentSnapshot>[];
            for (final d in allDocs) {
              final m = d.data() as Map<String, dynamic>;
              if ((m['status'] ?? '') != 'pending') continue;
              // match by employerId when available; fall back to employerName/contact
              if ((m['employerId'] ?? '') != '') {
                if ((m['employerId'] ?? '') == (profile?.id ?? '')) {
                  filteredDocs.add(d);
                }
                continue;
              }
              final nameMatch =
                  (profile?.name ?? '') == (m['employerName'] ?? '');
              final contactMatch =
                  (profile?.contact ?? '') == (m['employerContact'] ?? '');
              if (nameMatch || contactMatch) filteredDocs.add(d);
            }

            if (filteredDocs.isEmpty) {
              return Center(
                child: Text(
                  'No applicants yet',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              );
            }

            // sort by createdAt descending if available
            filteredDocs.sort((a, b) {
              final ma = a.data() as Map<String, dynamic>;
              final mb = b.data() as Map<String, dynamic>;
              final ta = ma['createdAt'];
              final tb = mb['createdAt'];
              int vala = 0;
              int valb = 0;
              if (ta is Timestamp) vala = ta.millisecondsSinceEpoch;
              if (tb is Timestamp) valb = tb.millisecondsSinceEpoch;
              return valb.compareTo(vala);
            });

            return ListView.separated(
              itemCount: filteredDocs.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final d = filteredDocs[index];
                final m = d.data() as Map<String, dynamic>;
                final applicantName = m['applicantName'] ?? '';
                final contact = m['contact'] ?? '';
                final jobTitle = m['jobTitle'] ?? '';
                final profileSnapshot = m['profile'] as Map<String, dynamic>?;

                return Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 14,
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 26,
                          backgroundColor: Colors.grey.shade200,
                          child: Text(
                            applicantName.isNotEmpty ? applicantName[0] : '?',
                            style: const TextStyle(fontSize: 20),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                applicantName,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Job: $jobTitle\nContact: $contact',
                                style: const TextStyle(color: Colors.grey),
                              ),
                              const SizedBox(height: 6),
                              if (profileSnapshot != null) ...[
                                Text(
                                  'Experience: ${profileSnapshot['experienceYears'] ?? ''} years • Role: ${profileSnapshot['jobType'] ?? ''}',
                                  style: const TextStyle(
                                    color: Colors.grey,
                                    fontSize: 12,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                if ((profileSnapshot['address'] ?? '') != '')
                                  Text(
                                    'Address: ${profileSnapshot['address']}',
                                    style: const TextStyle(
                                      color: Colors.grey,
                                      fontSize: 12,
                                    ),
                                  ),
                              ],
                            ],
                          ),
                        ),
                        Column(
                          children: [
                            TextButton(
                              onPressed: () async {
                                await JobService.instance.rejectApplicationDoc(
                                  d.id,
                                );
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Rejected: $applicantName'),
                                  ),
                                );
                              },
                              style: TextButton.styleFrom(
                                foregroundColor: Colors.red,
                              ),
                              child: const Text('Reject'),
                            ),
                            const SizedBox(height: 8),
                            ElevatedButton(
                              onPressed: () async {
                                await JobService.instance.approveApplicationDoc(
                                  d.id,
                                );
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Approved: $applicantName'),
                                  ),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                              ),
                              child: const Text('Accept'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
