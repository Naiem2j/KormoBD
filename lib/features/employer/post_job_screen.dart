import 'package:flutter/material.dart';
import '../../widgets/custom_button.dart';
import '../../core/services/job_service.dart';
import '../../core/services/profile_service.dart';
import '../../models/job_model.dart';

class PostJobScreen extends StatefulWidget {
  const PostJobScreen({super.key});

  @override
  State<PostJobScreen> createState() => _PostJobScreenState();
}

class _PostJobScreenState extends State<PostJobScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _employerCtrl = TextEditingController();
  final _numWorkersCtrl = TextEditingController();
  final _neededByCtrl = TextEditingController();
  final _contactCtrl = TextEditingController();
  final _wageCtrl = TextEditingController();
  final _locationCtrl = TextEditingController();
  DateTime? _neededByDate;

  @override
  void dispose() {
    _titleCtrl.dispose();
    _employerCtrl.dispose();
    _numWorkersCtrl.dispose();
    _neededByCtrl.dispose();
    _contactCtrl.dispose();
    _wageCtrl.dispose();
    _locationCtrl.dispose();
    super.dispose();
  }

  int _parseWage(String s) {
    if (s.trim().isEmpty) return 0;
    String normalizeDigits(String str) {
      final map = <String, String>{
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
      for (var r in str.runes) {
        final c = String.fromCharCode(r);
        sb.write(map[c] ?? c);
      }
      return sb.toString();
    }

    final normalized = normalizeDigits(s);
    final cleaned = normalized.replaceAll(RegExp(r'[^0-9]'), '');
    return int.tryParse(cleaned) ?? 0;
  }

  void _submit() {
    if (_formKey.currentState?.validate() ?? false) {
      final prof = ProfileService().currentProfile;
      if (prof == null || !prof.verified) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Your account must be verified by admin before posting jobs',
            ),
          ),
        );
        return;
      }

      final job = JobModel(
        id: JobService.instance.generateId(),
        title: _titleCtrl.text.trim(),
        employerName: _employerCtrl.text.trim(),
        employerId: ProfileService().currentProfile?.id,
        jobType: 'Other',
        numWorkers: int.tryParse(_numWorkersCtrl.text.trim()) ?? 1,
        neededBy: _neededByCtrl.text.trim(),
        location: _locationCtrl.text.trim(),
        wage: _parseWage(_wageCtrl.text),
        contact: _contactCtrl.text.trim(),
        status: 'approved',
      );

      JobService.instance
          .addJob(job)
          .then((_) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Job posted successfully')),
            );
            Navigator.of(context).pop();
          })
          .catchError((e) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text('Failed to post job: $e')));
          });
    }
  }

  InputDecoration _inputDecoration({
    required String label,
    required IconData icon,
  }) {
    return InputDecoration(
      prefixIcon: Icon(icon, color: Colors.white70),
      labelText: label,
      labelStyle: const TextStyle(color: Colors.white70),
      hintStyle: const TextStyle(color: Colors.white54),
      filled: true,
      fillColor: Colors.green,
      contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B5E4D),
      appBar: AppBar(
        title: const Text('Post Job'),
        backgroundColor: const Color(0xFF0B5E4D),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Card(
              color: const Color(0xFF0F6F60),
              elevation: 6,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'Create Job Post',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _titleCtrl,
                        style: const TextStyle(color: Colors.white),
                        decoration: _inputDecoration(
                          label: 'Job Title',
                          icon: Icons.work,
                        ),
                        validator: (v) => (v == null || v.trim().isEmpty)
                            ? 'Please enter a job title'
                            : null,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _employerCtrl,
                        style: const TextStyle(color: Colors.white),
                        decoration: _inputDecoration(
                          label: 'Employer Name',
                          icon: Icons.person,
                        ),
                        validator: (v) => (v == null || v.trim().isEmpty)
                            ? 'Please enter employer name'
                            : null,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _wageCtrl,
                        style: const TextStyle(color: Colors.white),
                        decoration: _inputDecoration(
                          label: 'Taka',
                          icon: Icons.attach_money,
                        ),
                        keyboardType: TextInputType.number,
                        validator: (v) => (v == null || v.trim().isEmpty)
                            ? 'Please enter amount (৳)'
                            : null,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _numWorkersCtrl,
                        style: const TextStyle(color: Colors.white),
                        decoration: _inputDecoration(
                          label: 'Number of workers',
                          icon: Icons.people,
                        ),
                        keyboardType: TextInputType.number,
                        validator: (v) => (v == null || v.trim().isEmpty)
                            ? 'Please enter required workers'
                            : null,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _neededByCtrl,
                        readOnly: true,
                        style: const TextStyle(color: Colors.white),
                        decoration: _inputDecoration(
                          label: 'Needed by (date)',
                          icon: Icons.calendar_today,
                        ),
                        onTap: () async {
                          final now = DateTime.now();
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: _neededByDate ?? now,
                            firstDate: now,
                            lastDate: DateTime(now.year + 5),
                          );
                          if (picked != null) {
                            setState(() {
                              _neededByDate = picked;
                              _neededByCtrl.text =
                                  '${picked.year.toString().padLeft(4, '0')}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';
                            });
                          }
                        },
                        validator: (v) => (v == null || v.trim().isEmpty)
                            ? 'Please select needed by date'
                            : null,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _contactCtrl,
                        style: const TextStyle(color: Colors.white),
                        decoration: _inputDecoration(
                          label: 'Contact No.',
                          icon: Icons.phone,
                        ),
                        keyboardType: TextInputType.phone,
                        validator: (v) => (v == null || v.trim().isEmpty)
                            ? 'Please enter contact number'
                            : null,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _locationCtrl,
                        style: const TextStyle(color: Colors.white),
                        decoration: _inputDecoration(
                          label: 'Location',
                          icon: Icons.location_on,
                        ),
                        validator: (v) => (v == null || v.trim().isEmpty)
                            ? 'Please enter a location'
                            : null,
                      ),
                      const SizedBox(height: 20),
                      CustomButton(text: 'Post Job', onTap: _submit),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
