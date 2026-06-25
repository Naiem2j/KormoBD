import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../../models/job_model.dart';
import '../../models/applicant_model.dart';
import '../../models/worker_profile.dart';
import '../services/profile_service.dart';

class JobService {
  JobService._privateConstructor() {
    _init();
  }

  static final JobService instance = JobService._privateConstructor();

  final FirebaseFirestore _db = FirebaseFirestore.instance;

  final ValueNotifier<List<JobModel>> jobs = ValueNotifier<List<JobModel>>([]);

  void _init() {
    // listen to jobs collection and update ValueNotifier
    _db
        .collection('jobs')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .listen((snap) {
          final list = snap.docs.map((d) => JobModel.fromDoc(d)).toList();
          jobs.value = list;
        });
  }

  /// generate a new id locally
  String generateId() {
    return _db.collection('jobs').doc().id;
  }

  Future<void> addJob(JobModel job) async {
    final data = job.toMap();
    // ensure we set the document with the provided id so it's easy to reference
    await _db.collection('jobs').doc(job.id).set(data);
  }

  /// Worker applies to a job. Creates a top-level application document and also
  /// appends applicant to the job document's `applicants` array for quick listing.
  Future<void> applyToJob(
    String jobId,
    Applicant applicant, {
    WorkerProfile? profile,
    String? jobTitle,
    String? employerName,
  }) async {
    // try to retrieve job info if not provided
    final jobRef = _db.collection('jobs').doc(jobId);
    final jobSnap = await jobRef.get();
    String title = jobTitle ?? jobSnap.data()?['title'] ?? '';
    String employer = employerName ?? jobSnap.data()?['employerName'] ?? '';

    final appDoc = {
      'jobId': jobId,
      'jobTitle': title,
      'employerName': employer,
      'employerId': jobSnap.data()?['employerId'] ?? null,
      'employerContact': jobSnap.data()?['contact'] ?? '',
      'applicantName': applicant.name,
      'contact': applicant.contact,
      'status': applicant.status,
      if (profile != null) 'profile': profile.toMap(),
      'createdAt': FieldValue.serverTimestamp(),
    };

    // create an applications document for employer queries
    await _db.collection('applications').add(appDoc);

    // also append to the job's applicants array (store as map)
    final applicantMap = applicant.toMap();
    if (profile != null) applicantMap['profile'] = profile.toMap();

    // fetch latest job doc and rewrite applicants array including new applicant
    final current = jobSnap.data() as Map<String, dynamic>?;
    final existing = <Map<String, dynamic>>[];
    if (current != null && current['applicants'] is List) {
      for (final e in current['applicants'] as List) {
        if (e is Map) existing.add(Map<String, dynamic>.from(e));
      }
    }
    existing.add(applicantMap);

    // If job document doesn't exist yet (e.g., using local sample jobs), create it
    if (current == null) {
      await jobRef.set({
        'id': jobId,
        'title': title,
        'employerName': employer,
        'applicants': existing,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } else {
      await jobRef.update({'applicants': existing});
    }
  }

  /// Approve an application document by its id and update the job's applicants array.
  Future<void> approveApplicationDoc(String applicationId) async {
    final docRef = _db.collection('applications').doc(applicationId);
    final doc = await docRef.get();
    if (!doc.exists) return;
    final data = doc.data() as Map<String, dynamic>;
    final jobId = data['jobId'] as String? ?? '';
    final contact = data['contact'] as String? ?? '';

    await docRef.update({'status': 'approved'});

    final jobRef = _db.collection('jobs').doc(jobId);
    final jobSnap = await jobRef.get();
    final current = jobSnap.data() as Map<String, dynamic>? ?? {};
    final apps = <Map<String, dynamic>>[];
    if (current['applicants'] is List) {
      for (final e in current['applicants'] as List) {
        if (e is Map) apps.add(Map<String, dynamic>.from(e));
      }
    }
    for (final a in apps) {
      if ((a['contact'] ?? '') == contact) {
        a['status'] = 'approved';
      }
    }
    await jobRef.update({'applicants': apps});
  }

  Future<void> rejectApplicationDoc(String applicationId) async {
    final docRef = _db.collection('applications').doc(applicationId);
    final doc = await docRef.get();
    if (!doc.exists) return;
    final data = doc.data() as Map<String, dynamic>;
    final jobId = data['jobId'] as String? ?? '';
    final contact = data['contact'] as String? ?? '';

    await docRef.update({'status': 'rejected'});

    final jobRef = _db.collection('jobs').doc(jobId);
    final jobSnap = await jobRef.get();
    final current = jobSnap.data() as Map<String, dynamic>? ?? {};
    final apps = <Map<String, dynamic>>[];
    if (current['applicants'] is List) {
      for (final e in current['applicants'] as List) {
        if (e is Map) apps.add(Map<String, dynamic>.from(e));
      }
    }
    for (final a in apps) {
      if ((a['contact'] ?? '') == contact) {
        a['status'] = 'rejected';
      }
    }
    await jobRef.update({'applicants': apps});
  }

  /// Helper used by UI: return pending applicant entries for current employer
  List<Map<String, dynamic>> pendingApplicationsForEmployer() {
    final profile = ProfileService().currentProfile;
    final employerId = profile?.id ?? '';
    final out = <Map<String, dynamic>>[];
    for (final job in jobs.value) {
      // match by employerId when available; fall back to name/contact for older docs
      final jid = job.employerId ?? '';
      if (jid.isNotEmpty) {
        if (jid != employerId) continue;
      } else {
        final nameMatch = (profile?.name ?? '') == job.employerName;
        final contactMatch = (profile?.contact ?? '') == job.contact;
        if (!nameMatch && !contactMatch) continue;
      }
      for (final a in job.applicants) {
        if (a.status == 'pending') {
          out.add({'job': job, 'applicant': a});
        }
      }
    }
    return out;
  }

  /// Approve an applicant by modifying the job document's applicants array and
  /// updating matching application documents in `applications` collection.
  Future<void> approveApplicant(String jobId, int applicantIndex) async {
    final jobRef = _db.collection('jobs').doc(jobId);
    final jobSnap = await jobRef.get();
    final data = jobSnap.data() as Map<String, dynamic>? ?? {};
    final apps = <Map<String, dynamic>>[];
    if (data['applicants'] is List) {
      for (final e in data['applicants'] as List) {
        if (e is Map) apps.add(Map<String, dynamic>.from(e));
      }
    }
    if (applicantIndex < 0 || applicantIndex >= apps.length) return;
    apps[applicantIndex]['status'] = 'approved';
    await jobRef.update({'applicants': apps});

    // also update matching documents in applications collection
    final contact = apps[applicantIndex]['contact'] ?? '';
    final snap = await _db
        .collection('applications')
        .where('jobId', isEqualTo: jobId)
        .where('contact', isEqualTo: contact)
        .where('status', isEqualTo: 'pending')
        .get();
    for (final d in snap.docs) {
      await d.reference.update({'status': 'approved'});
    }
  }

  Future<void> rejectApplicant(String jobId, int applicantIndex) async {
    final jobRef = _db.collection('jobs').doc(jobId);
    final jobSnap = await jobRef.get();
    final data = jobSnap.data() as Map<String, dynamic>? ?? {};
    final apps = <Map<String, dynamic>>[];
    if (data['applicants'] is List) {
      for (final e in data['applicants'] as List) {
        if (e is Map) apps.add(Map<String, dynamic>.from(e));
      }
    }
    if (applicantIndex < 0 || applicantIndex >= apps.length) return;
    apps[applicantIndex]['status'] = 'rejected';
    await jobRef.update({'applicants': apps});

    final contact = apps[applicantIndex]['contact'] ?? '';
    final snap = await _db
        .collection('applications')
        .where('jobId', isEqualTo: jobId)
        .where('contact', isEqualTo: contact)
        .where('status', isEqualTo: 'pending')
        .get();
    for (final d in snap.docs) {
      await d.reference.update({'status': 'rejected'});
    }
  }

  // Admin job moderation removed: employers handle application approvals.
}
