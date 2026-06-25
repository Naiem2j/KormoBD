class Applicant {
  final String name;
  final String contact;
  String status; // pending, approved, rejected
  final Map<String, dynamic>? profile; // optional snapshot of worker profile

  Applicant({
    required this.name,
    required this.contact,
    this.status = 'pending',
    this.profile,
  });

  Map<String, dynamic> toMap() => {
    'name': name,
    'contact': contact,
    'status': status,
    if (profile != null) 'profile': profile,
  };

  factory Applicant.fromMap(Map<String, dynamic>? m) {
    if (m == null)
      return Applicant(name: 'Unknown', contact: '', status: 'pending');
    return Applicant(
      name: (m['name'] ?? '') as String,
      contact: (m['contact'] ?? '') as String,
      status: (m['status'] ?? 'pending') as String,
      profile: m['profile'] is Map<String, dynamic>
          ? Map<String, dynamic>.from(m['profile'] as Map)
          : null,
    );
  }
}
