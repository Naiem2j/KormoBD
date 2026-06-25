import 'package:flutter/material.dart';
import '../../models/worker_profile.dart';
import '../../core/services/profile_service.dart';
import 'map_picker.dart';

class ProfileEditScreen extends StatefulWidget {
  const ProfileEditScreen({super.key});

  @override
  State<ProfileEditScreen> createState() => _ProfileEditScreenState();
}

class _ProfileEditScreenState extends State<ProfileEditScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _expCtrl = TextEditingController();
  final _jobCtrl = TextEditingController();
  final _contactCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  final _photoCtrl = TextEditingController();
  double? _latitude;
  double? _longitude;

  @override
  void initState() {
    super.initState();
    final p = ProfileService().currentProfile;
    if (p != null) {
      _nameCtrl.text = p.name;
      _expCtrl.text = p.experienceYears.toString();
      _jobCtrl.text = p.jobType;
      _contactCtrl.text = p.contact;
      _addressCtrl.text = p.address;
      _photoCtrl.text = p.photoUrl ?? '';
      _latitude = p.latitude;
      _longitude = p.longitude;
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _expCtrl.dispose();
    _jobCtrl.dispose();
    _contactCtrl.dispose();
    _addressCtrl.dispose();
    _photoCtrl.dispose();
    super.dispose();
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    final profile = WorkerProfile(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: _nameCtrl.text.trim(),
      experienceYears: int.tryParse(_expCtrl.text.trim()) ?? 0,
      jobType: _jobCtrl.text.trim(),
      contact: _contactCtrl.text.trim(),
      address: _addressCtrl.text.trim(),
      photoUrl: _photoCtrl.text.trim().isEmpty ? null : _photoCtrl.text.trim(),
      latitude: _latitude,
      longitude: _longitude,
    );

    // persist profile to Firestore (and update in-memory)
    ProfileService().saveProfile(profile).then((ok) {
      if (ok) {
        Navigator.pop(context);
      } else {
        final err = ProfileService().lastError ?? 'Failed to save profile';
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(err)));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Profile')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _nameCtrl,
                decoration: const InputDecoration(labelText: 'Name'),
                validator: (v) => v!.trim().isEmpty ? 'Enter name' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _expCtrl,
                decoration: const InputDecoration(
                  labelText: 'Years of experience',
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _jobCtrl,
                decoration: const InputDecoration(
                  labelText: 'Job type (what you do)',
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _contactCtrl,
                decoration: const InputDecoration(labelText: 'Contact number'),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _addressCtrl,
                decoration: const InputDecoration(labelText: 'Address'),
              ),
              const SizedBox(height: 12),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      _latitude == null
                          ? 'No location picked'
                          : 'Lat: ${_latitude!.toStringAsFixed(6)}, Lng: ${_longitude!.toStringAsFixed(6)}',
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () async {
                      final res = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => MapPicker(
                            initialLatitude: _latitude,
                            initialLongitude: _longitude,
                          ),
                        ),
                      );
                      if (res is Map) {
                        setState(() {
                          _latitude = (res['latitude'] as num).toDouble();
                          _longitude = (res['longitude'] as num).toDouble();
                        });
                      }
                    },
                    child: const Text('Pick location'),
                  ),
                ],
              ),
              TextFormField(
                controller: _photoCtrl,
                decoration: const InputDecoration(
                  labelText: 'Photo URL (for now)',
                  hintText: 'http(s)://... or empty',
                ),
                keyboardType: TextInputType.url,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _save,
                child: const Text('Save Profile'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
