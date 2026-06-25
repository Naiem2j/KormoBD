import 'package:flutter/material.dart';
import '../../core/services/profile_service.dart';
import '../../models/worker_profile.dart';
import 'login_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameCtrl = TextEditingController();
  final TextEditingController _emailCtrl = TextEditingController();
  final TextEditingController _passwordCtrl = TextEditingController();
  String _role = 'Worker';
  bool _loading = false;

  final List<String> _roles = ['Worker', 'Employer', 'Admin'];
  // include Admin role so admins can be created from UI
  // (login screen already supports Admin routing)

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    final email = _emailCtrl.text.trim();
    final password = _passwordCtrl.text;
    if (!mounted) return;
    final ok = await ProfileService().registerCredential(
      email,
      password,
      _role,
      _nameCtrl.text.trim(),
    );
    setState(() => _loading = false);
    if (!ok) {
      final err =
          ProfileService().lastError ?? 'Email already registered or error';
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(err)));
      return;
    }
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Registered successfully')));
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 8),
                  const Text(
                    'Create account',
                    style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Register with email and password to get started',
                    style: TextStyle(fontSize: 14, color: Colors.black54),
                  ),
                  const SizedBox(height: 20),

                  Card(
                    color: Colors.purple[25],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 6,
                    child: Padding(
                      padding: const EdgeInsets.all(18),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            TextFormField(
                              controller: _nameCtrl,
                              decoration: InputDecoration(
                                prefixIcon: const Icon(Icons.person_outline),
                                labelText: 'Full name',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              validator: (v) {
                                if (v == null || v.trim().isEmpty) {
                                  return 'Enter your name';
                                }
                                if (v.trim().length < 2) {
                                  return 'Name too short';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 12),

                            TextFormField(
                              controller: _emailCtrl,
                              keyboardType: TextInputType.emailAddress,
                              decoration: InputDecoration(
                                prefixIcon: const Icon(Icons.email_outlined),
                                labelText: 'Email',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              validator: (v) {
                                if (v == null || v.trim().isEmpty) {
                                  return 'Enter email';
                                }
                                // simple, reliable email pattern
                                if (!RegExp(
                                  r'^[^@\s]+@[^@\s]+\.[^@\s]+',
                                ).hasMatch(v.trim())) {
                                  return 'Enter valid email';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 12),
                            TextFormField(
                              controller: _passwordCtrl,
                              obscureText: true,
                              decoration: InputDecoration(
                                prefixIcon: const Icon(Icons.lock_outline),
                                labelText: 'Password',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              validator: (v) {
                                if (v == null || v.isEmpty)
                                  return 'Enter password';
                                if (v.length < 6) return 'Password too short';
                                return null;
                              },
                            ),
                            const SizedBox(height: 12),

                            DropdownButtonFormField<String>(
                              initialValue: _role,
                              items: _roles
                                  .map(
                                    (r) => DropdownMenuItem(
                                      value: r,
                                      child: Text(r),
                                    ),
                                  )
                                  .toList(),
                              decoration: InputDecoration(
                                prefixIcon: const Icon(Icons.badge_outlined),
                                labelText: 'Role',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              onChanged: (v) {
                                setState(() {
                                  _role = v!;
                                });
                              },
                            ),
                            const SizedBox(height: 16),

                            SizedBox(
                              width: double.infinity,
                              height: 48,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.deepPurple,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  elevation: 4,
                                ),
                                onPressed: _loading ? null : _submit,
                                child: _loading
                                    ? const SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                          color: Colors.white,
                                          strokeWidth: 2.5,
                                        ),
                                      )
                                    : const Text('Register'),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
