class WorkerProfile {
  final String id;
  final String name;
  final int experienceYears;
  final String jobType;
  final String contact;
  final String address;
  final String? photoUrl;
  final double? latitude;
  final double? longitude;
  final String status; // 'pending', 'approved', 'rejected', etc.
  final bool verified;

  WorkerProfile({
    required this.id,
    required this.name,
    required this.experienceYears,
    required this.jobType,
    required this.contact,
    required this.address,
    this.photoUrl,
    this.latitude,
    this.longitude,
    this.status = 'active',
    this.verified = true,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'name': name,
    'experienceYears': experienceYears,
    'jobType': jobType,
    'contact': contact,
    'address': address,
    'photoUrl': photoUrl,
    'latitude': latitude,
    'longitude': longitude,
    'status': status,
    'verified': verified,
  };

  factory WorkerProfile.fromMap(Map<String, dynamic> m) => WorkerProfile(
    id: m['id'] as String,
    name: m['name'] as String,
    experienceYears: (m['experienceYears'] as num).toInt(),
    jobType: m['jobType'] as String,
    contact: m['contact'] as String,
    address: m['address'] as String,
    photoUrl: m['photoUrl'] as String?,
    latitude: (m['latitude'] as num?)?.toDouble(),
    longitude: (m['longitude'] as num?)?.toDouble(),
    status: (m['status'] ?? 'active') as String,
    verified: (m['verified'] ?? true) as bool,
  );
}
