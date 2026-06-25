import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
import '../../models/worker_profile.dart';
import 'auth_service.dart';
import '../../models/user_model.dart';
import '../../core/services/user_service.dart';

class ProfileService {
  static final ProfileService _instance = ProfileService._internal();
  factory ProfileService() => _instance;
  ProfileService._internal();

  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final AuthService _auth = AuthService();

  String? lastError;

  WorkerProfile? currentProfile;
  String? currentRole;

  /// Persist profile to Firestore (uses authenticated uid when available).
  /// [role] allows saving employer or worker profiles.
  Future<bool> saveProfile(WorkerProfile p, {String role = 'Worker'}) async {
    lastError = null;
    try {
      final uid = _auth.currentUser?.uid ?? p.id;
      await _db.collection('profiles').doc(uid).set({
        ...p.toMap(),
        'role': role,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      currentRole = role;
      currentProfile = p;
      return true;
    } catch (e) {
      lastError = e.toString();
      return false;
    }
  }

  Future<bool> registerCredential(
    String email,
    String password,
    String role,
    String name,
  ) async {
    lastError = null;
    try {
      final cred = await _auth.register(email, password);
      final uid = cred.user!.uid;
      final profile = WorkerProfile(
        id: uid,
        name: name,
        experienceYears: 0,
        jobType: '',
        contact: email,
        address: '',
        latitude: null,
        longitude: null,
        status: 'pending',
        verified: false,
      );
      try {
        await _db.collection('profiles').doc(uid).set({
          ...profile.toMap(),
          'role': role,
          'createdAt': FieldValue.serverTimestamp(),
        });
        currentRole = role;
      } catch (e) {
        // if Firestore write fails, remove created auth user to avoid orphaned auth accounts
        try {
          await cred.user?.delete();
        } catch (_) {}
        lastError = 'Failed to save profile: $e';
        return false;
      }
      currentProfile = profile;
      currentRole = role;
      // also inform admin UI via UserService
      try {
        final u = UserModel(
          id: uid,
          name: name,
          role: role,
          contact: email,
          status: 'pending',
        );
        UserService.instance.addUser(u);
      } catch (_) {}
      return true;
    } on fb_auth.FirebaseAuthException catch (e) {
      lastError = 'Auth error: ${e.message}';
      return false;
    } catch (e) {
      lastError = e.toString();
      return false;
    }
  }

  Future<bool> authenticate(String email, String password) async {
    lastError = null;
    try {
      final cred = await _auth.login(email, password);
      final uid = cred.user!.uid;
      final doc = await _db.collection('profiles').doc(uid).get();
      if (doc.exists) {
        final m = doc.data()!;
        currentProfile = WorkerProfile.fromMap(m);
        currentRole = (m['role'] as String?)?.trim();
      } else {
        // fallback minimal profile
        currentProfile = WorkerProfile(
          id: uid,
          name: email.split('@').first,
          experienceYears: 0,
          jobType: '',
          contact: email,
          address: '',
          latitude: null,
          longitude: null,
        );
        currentRole = null;
      }
      return true;
    } on fb_auth.FirebaseAuthException catch (e) {
      lastError = 'Auth error: ${e.message}';
      return false;
    } catch (e) {
      lastError = e.toString();
      return false;
    }
  }

  Future<String?> getRoleForEmail(String email) async {
    final snap = await _db
        .collection('profiles')
        .where('contact', isEqualTo: email)
        .limit(1)
        .get();
    if (snap.docs.isEmpty) return null;
    return snap.docs.first.data()['role'] as String?;
  }

  Future<void> addApplicant(WorkerProfile p, {String role = 'Worker'}) async {
    final uid = p.id;
    await _db.collection('profiles').doc(uid).set({
      ...p.toMap(),
      'role': role,
      'createdAt': FieldValue.serverTimestamp(),
    });
    currentRole = role;
  }

  /// Admin: verify or reject a user by id
  Future<void> verifyUserById(String uid, {required bool approved}) async {
    final docRef = _db.collection('profiles').doc(uid);
    final doc = await docRef.get();
    if (!doc.exists) return;
    await docRef.update({
      'verified': approved,
      'status': approved ? 'approved' : 'rejected',
      'verifiedAt': FieldValue.serverTimestamp(),
    });
  }

  void setProfile(WorkerProfile p) {
    currentProfile = p;
  }

  void clearApplicants() {}
}
