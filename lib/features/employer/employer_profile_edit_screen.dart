import 'package:flutter/material.dart';
import '../../models/worker_profile.dart';
import '../../core/services/profile_service.dart';

class EmployerProfileEditScreen extends StatefulWidget {
  const EmployerProfileEditScreen({super.key});

  @override
  State<EmployerProfileEditScreen> createState() =>
      _EmployerProfileEditScreenState();
}

class _EmployerProfileEditScreenState extends State<EmployerProfileEditScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  final _contactCtrl = TextEditingController();
  final _locationCtrl = TextEditingController();
  final _photoCtrl = TextEditingController();
  String? _previewUrl;

  @override
  void initState() {
    super.initState();
    final p = ProfileService().currentProfile;
    if (p != null) {
      _nameCtrl.text = p.name;
      _addressCtrl.text = p.address;
      _contactCtrl.text = p.contact;
      _locationCtrl.text =
          p.jobType; // reuse jobType for "location" slot if present
      _photoCtrl.text = p.photoUrl ?? '';
      _previewUrl = _resolveImageUrl(_photoCtrl.text);
    }
    _photoCtrl.addListener(() {
      setState(() {
        _previewUrl = _resolveImageUrl(_photoCtrl.text);
      });
    });
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _addressCtrl.dispose();
    _contactCtrl.dispose();
    _locationCtrl.dispose();
    _photoCtrl.dispose();
    super.dispose();
  }

  String? _resolveImageUrl(String? input) {
    if (input == null) return null;
    final s = input.trim();
    if (s.isEmpty) return null;
    // Handle Unsplash photo page URLs like
    // https://unsplash.com/photos/<slug>-<id>
    final m = RegExp(
      r'unsplash\.com\/photos\/([^\/?#]+)',
      caseSensitive: false,
    ).firstMatch(s);
    if (m != null) {
      var seg = m.group(1)!;
      final id = seg.contains('-') ? seg.split('-').last : seg;
      return 'https://images.unsplash.com/photo-$id?auto=format&fit=crop&w=800&q=80';
    }
    // Otherwise return as-is (may be a direct CDN URL)
    return s;
  }

  void _save() async {
    if (!_formKey.currentState!.validate()) return;
    final profile = WorkerProfile(
      id:
          ProfileService().currentProfile?.id ??
          DateTime.now().millisecondsSinceEpoch.toString(),
      name: _nameCtrl.text.trim(),
      experienceYears: 0,
      jobType: _locationCtrl.text.trim(),
      contact: _contactCtrl.text.trim(),
      address: _addressCtrl.text.trim(),
      photoUrl: _photoCtrl.text.trim().isEmpty ? null : _photoCtrl.text.trim(),
    );

    final ok = await ProfileService().saveProfile(profile, role: 'employer');
    if (ok) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Profile saved')));
      Navigator.pop(context);
    } else {
      final err = ProfileService().lastError ?? 'Failed to save profile';
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(err)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Employer Profile')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: CircleAvatar(
                    radius: 48,
                    backgroundColor: Colors.green[900],
                    child: ClipOval(
                      child: SizedBox(
                        width: 92,
                        height: 92,
                        child: _previewUrl == null || _previewUrl!.isEmpty
                            ? const Icon(Icons.person, size: 48)
                            : Image.network(
                                _previewUrl!,
                                fit: BoxFit.cover,
                                errorBuilder: (c, e, s) =>
                                    const Icon(Icons.broken_image, size: 48),
                                loadingBuilder: (c, w, progress) {
                                  if (progress == null) return w;
                                  return const Center(
                                    child: CircularProgressIndicator(),
                                  );
                                },
                              ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _photoCtrl,
                decoration: const InputDecoration(
                  labelText: 'Profile image URL (Supabase or CDN)',
                ),
                keyboardType: TextInputType.url,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _nameCtrl,
                decoration: const InputDecoration(labelText: 'Employer Name'),
                validator: (v) =>
                    v!.trim().isEmpty ? 'Enter employer name' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _addressCtrl,
                decoration: const InputDecoration(labelText: 'Address'),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _contactCtrl,
                decoration: const InputDecoration(labelText: 'Contact number'),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _locationCtrl,
                decoration: const InputDecoration(labelText: 'Location (city)'),
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
