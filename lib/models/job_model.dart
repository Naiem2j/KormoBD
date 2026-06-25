import 'package:cloud_firestore/cloud_firestore.dart';
import 'applicant_model.dart';

class JobModel {
  final String id;
  final String title;
  final String employerName;
  final String? employerId;
  final String jobType;
  final int numWorkers;
  final String neededBy;
  final String location;
  final int wage;
  final String contact;
  final String status;
  final DateTime? createdAt;
  final List<Applicant> applicants;

  JobModel({
    required this.id,
    required this.title,
    required this.employerName,
    this.employerId,
    required this.jobType,
    required this.numWorkers,
    required this.neededBy,
    required this.location,
    required this.wage,
    required this.contact,
    this.status = 'pending',
    this.createdAt,
    List<Applicant>? applicants,
  }) : applicants = applicants ?? [];

  Map<String, dynamic> toMap() => {
    'id': id,
    'title': title,
    'employerName': employerName,
    'employerId': employerId,
    'jobType': jobType,
    'numWorkers': numWorkers,
    'neededBy': neededBy,
    'location': location,
    'wage': wage,
    'contact': contact,
    'status': status,
    'createdAt': createdAt == null
        ? FieldValue.serverTimestamp()
        : Timestamp.fromDate(createdAt!),
    'applicants': applicants.map((a) => a.toMap()).toList(),
  };

  factory JobModel.fromDoc(QueryDocumentSnapshot d) {
    final m = d.data() as Map<String, dynamic>? ?? {};
    final ts = m['createdAt'];
    DateTime? created;
    if (ts is Timestamp) created = ts.toDate();
    final apps = <Applicant>[];
    if (m['applicants'] is List) {
      for (final e in (m['applicants'] as List)) {
        if (e is Map<String, dynamic>)
          apps.add(Applicant.fromMap(e));
        else if (e is Map)
          apps.add(Applicant.fromMap(Map<String, dynamic>.from(e)));
      }
    }
    return JobModel(
      id: (m['id'] ?? d.id) as String,
      title: (m['title'] ?? '') as String,
      employerName: (m['employerName'] ?? '') as String,
      employerId: (m['employerId'] ?? null) as String?,
      jobType: (m['jobType'] ?? '') as String,
      numWorkers: (m['numWorkers'] is num)
          ? (m['numWorkers'] as num).toInt()
          : (m['numWorkers'] ?? 1) as int,
      neededBy: (m['neededBy'] ?? '') as String,
      location: (m['location'] ?? '') as String,
      wage: _parseWageField(m['wage']),
      contact: (m['contact'] ?? '') as String,
      status: (m['status'] ?? 'pending') as String,
      createdAt: created,
      applicants: apps,
    );
  }

  static int _parseWageField(dynamic w) {
    if (w == null) return 0;
    if (w is num) return w.toInt();
    if (w is String) {
      // Normalize common non-ASCII digit sets (Bengali, Arabic-Indic, Persian) to ASCII
      String normalizeDigits(String s) {
        final map = <String, String>{
          // Bengali digits
          '০': '0',
          '১': '1',
          '২': '2',
          '৩': '3',
          '৪': '4',
          '৫': '5',
          '৬': '6',
          '৭': '7',
          '৮': '8',
          '৯': '9',
          // Arabic-Indic digits
          '٠': '0',
          '١': '1',
          '٢': '2',
          '٣': '3',
          '٤': '4',
          '٥': '5',
          '٦': '6',
          '٧': '7',
          '٨': '8',
          '٩': '9',
          // Extended Persian/Arabic-Indic
          '۰': '0',
          '۱': '1',
          '۲': '2',
          '۳': '3',
          '۴': '4',
          '۵': '5',
          '۶': '6',
          '۷': '7',
          '۸': '8',
          '۹': '9',
        };
        final sb = StringBuffer();
        for (var ch in s.runes) {
          final c = String.fromCharCode(ch);
          sb.write(map[c] ?? c);
        }
        return sb.toString();
      }

      final normalized = normalizeDigits(w);
      final cleaned = normalized.replaceAll(RegExp(r'[^0-9]'), '');
      return int.tryParse(cleaned) ?? 0;
    }
    return 0;
  }
}
