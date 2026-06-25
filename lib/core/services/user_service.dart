import 'package:flutter/foundation.dart';
import '../../models/user_model.dart';
import '../../core/services/job_service.dart';
import '../../models/job_model.dart';
import 'dart:math';
import 'profile_service.dart';

class UserService {
  UserService._privateConstructor() {
    // no local dummy users; rely on backend or explicit adds
  }

  static final UserService instance = UserService._privateConstructor();

  final ValueNotifier<List<UserModel>> users = ValueNotifier<List<UserModel>>(
    [],
  );

  void addUser(UserModel u) {
    final list = List<UserModel>.from(users.value);
    // avoid duplicate by contact
    final exists = list.any((x) => x.contact == u.contact && x.name == u.name);
    if (!exists) {
      list.insert(0, u);
      users.value = list;
    }
  }

  void approveUser(String userId) {
    final list = List<UserModel>.from(users.value);
    final idx = list.indexWhere((u) => u.id == userId);
    if (idx == -1) return;
    final u = list[idx];
    list[idx] = UserModel(
      id: u.id,
      name: u.name,
      role: u.role,
      contact: u.contact,
      status: 'approved',
    );
    users.value = list;

    // mark any matching applicants as admin-approved so employers can see them
    final jobs = JobService.instance.jobs.value;
    final jlist = List<JobModel>.from(jobs);
    var changed = false;
    for (final job in jlist) {
      for (final a in job.applicants) {
        if (a.contact == u.contact && a.status == 'pending') {
          a.status = 'admin_approved';
          changed = true;
        }
      }
    }
    if (changed) JobService.instance.jobs.value = jlist;
    // persist verification to Firestore as well
    try {
      ProfileService().verifyUserById(userId, approved: true);
    } catch (_) {}
  }

  void rejectUser(String userId) {
    final list = List<UserModel>.from(users.value);
    final idx = list.indexWhere((u) => u.id == userId);
    if (idx == -1) return;
    final u = list[idx];
    list[idx] = UserModel(
      id: u.id,
      name: u.name,
      role: u.role,
      contact: u.contact,
      status: 'rejected',
    );
    users.value = list;
    try {
      ProfileService().verifyUserById(userId, approved: false);
    } catch (_) {}
  }

  List<UserModel> pendingUsers() =>
      users.value.where((u) => u.status == 'pending').toList();

  String generateId() =>
      DateTime.now().millisecondsSinceEpoch.toString() +
      Random().nextInt(999).toString();
}
