import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  static final FirestoreService _instance = FirestoreService._internal();
  factory FirestoreService() => _instance;
  FirestoreService._internal();

  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<void> addJob({
    required String title,
    required String location,
    required int wage,
    required String employerId,
  }) async {
    final doc = _db.collection('jobs').doc();
    await doc.set({
      'id': doc.id,
      'title': title,
      'location': location,
      'wage': wage,
      'employerId': employerId,
      'approved': false,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<List<Map<String, dynamic>>> getApprovedJobs() async {
    final snap = await _db
        .collection('jobs')
        .where('approved', isEqualTo: true)
        .orderBy('createdAt', descending: true)
        .get();
    return snap.docs.map((d) => d.data()).toList();
  }

  Future<List<Map<String, dynamic>>> getPendingJobs() async {
    final snap = await _db
        .collection('jobs')
        .where('approved', isEqualTo: false)
        .orderBy('createdAt', descending: true)
        .get();
    return snap.docs.map((d) => d.data()).toList();
  }

  Future<void> applyJob({
    required String jobId,
    required String workerId,
  }) async {
    final doc = _db.collection('applications').doc();
    await doc.set({
      'id': doc.id,
      'jobId': jobId,
      'workerId': workerId,
      'appliedAt': FieldValue.serverTimestamp(),
    });
  }
}
