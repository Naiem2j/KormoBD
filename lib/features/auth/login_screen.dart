import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../core/services/profile_service.dart';
import '../../models/worker_profile.dart';
import '../../routes/app_routes.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailCtrl = TextEditingController();
  final TextEditingController _passwordCtrl = TextEditingController();
  bool _loading = false;
  String _lang = 'EN';
  bool _obscurePassword = true;
  bool _rememberMe = false;
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  final List<Map<String, String>> _codes = [
    {'code': '+880', 'label': 'Bangladesh'},
    {'code': '+91', 'label': 'India'},
    {'code': '+1', 'label': 'USA'},
    {'code': '+44', 'label': 'UK'},
  ];

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _loadSavedCredentials();
  }

  Future<void> _loadSavedCredentials() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final remember = prefs.getBool('remember_me') ?? false;
      String? savedEmail = prefs.getString('saved_email');
      String? savedPassword;
      if (remember) {
        savedPassword = await _secureStorage.read(key: 'saved_password');
        // fallback: email may be stored in secure storage
        if (savedEmail == null) {
          final secEmail = await _secureStorage.read(key: 'saved_email');
          if (secEmail != null && secEmail.isNotEmpty) savedEmail = secEmail;
        }
      }
      setState(() {
        _rememberMe = remember;
        if (savedEmail != null) _emailCtrl.text = savedEmail;
        if (savedPassword != null) _passwordCtrl.text = savedPassword;
      });
    } catch (e) {
      // ignore storage errors
    }
  }

  void _sendOtp() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    final email = _emailCtrl.text.trim();
    final password = _passwordCtrl.text;
    final ok = await ProfileService().authenticate(email, password);
    if (!mounted) return;
    setState(() => _loading = false);
    if (ok) {
      // Save or clear credentials based on remember-me
      try {
        final prefs = await SharedPreferences.getInstance();
        if (_rememberMe) {
          await prefs.setString('saved_email', email);
          await prefs.setBool('remember_me', true);
          await _secureStorage.write(key: 'saved_email', value: email);
          await _secureStorage.write(key: 'saved_password', value: password);
        } else {
          await prefs.remove('saved_email');
          await prefs.setBool('remember_me', false);
          await _secureStorage.delete(key: 'saved_password');
          await _secureStorage.delete(key: 'saved_email');
        }
      } catch (e) {
        // ignore storage errors
      }
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Login successful')));
      final storedRoleRaw =
          ProfileService().currentRole ??
          await ProfileService().getRoleForEmail(email) ??
          'Worker';
      final storedRole = storedRoleRaw.toString().trim().toLowerCase();
      String route;
      if (storedRole == 'employer') {
        route = AppRoutes.employer;
      } else if (storedRole == 'admin') {
        route = AppRoutes.admin;
      } else {
        route = AppRoutes.worker;
      }
      Navigator.pushReplacementNamed(context, route);
    } else {
      final err = ProfileService().lastError ?? 'Invalid email or password';
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(err)));
    }
  }

  @override
  Widget build(BuildContext context) {
    String t(String en, String bn) => _lang == 'EN' ? en : bn;
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => setState(() => _lang = 'EN'),
                        child: Text(
                          'EN',
                          style: TextStyle(
                            fontWeight: _lang == 'EN'
                                ? FontWeight.bold
                                : FontWeight.normal,
                            color: _lang == 'EN'
                                ? Theme.of(context).primaryColor
                                : null,
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed: () => setState(() => _lang = 'BN'),
                        child: Text(
                          'BN',
                          style: TextStyle(
                            fontWeight: _lang == 'BN'
                                ? FontWeight.bold
                                : FontWeight.normal,
                            color: _lang == 'BN'
                                ? Theme.of(context).primaryColor
                                : null,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'KormoBD',
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.left,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Find Work, Easily',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white.withOpacity(0.85),
                    ),
                    textAlign: TextAlign.left,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    t(
                      'Sign in with your email to continue',
                      'চালিয়ে যেতে আপনার ইমেল দিয়ে সাইন ইন করুন',
                    ),
                    style: const TextStyle(fontSize: 14, color: Colors.black54),
                  ),
                  const SizedBox(height: 24),

                  Card(
                    color: Colors.purple[25],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 6,
                    child: Padding(
                      padding: const EdgeInsets.all(18),
                      child: AutofillGroup(
                        child: Form(
                          key: _formKey,
                          child: Column(
                            children: [
                              TextFormField(
                                controller: _emailCtrl,
                                keyboardType: TextInputType.emailAddress,
                                textInputAction: TextInputAction.next,
                                autofillHints: _rememberMe
                                    ? null
                                    : const [
                                        AutofillHints.username,
                                        AutofillHints.email,
                                      ],
                                decoration: InputDecoration(
                                  prefixIcon: const Icon(Icons.email_outlined),
                                  labelText: t('Email', 'ইমেল'),
                                  hintText: t(
                                    'Enter your email',
                                    'আপনার ইমেল দিন',
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                validator: (v) {
                                  if (v == null || v.trim().isEmpty)
                                    return 'Enter email';
                                  return null;
                                },
                              ),
                              const SizedBox(height: 12),
                              TextFormField(
                                controller: _passwordCtrl,
                                obscureText: _obscurePassword,
                                keyboardType: TextInputType.number,
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly,
                                ],
                                textInputAction: TextInputAction.done,
                                autofillHints: _rememberMe
                                    ? null
                                    : const [AutofillHints.password],
                                decoration: InputDecoration(
                                  prefixIcon: const Icon(Icons.lock_outline),
                                  labelText: t('Password', 'পাসওয়ার্ড'),
                                  hintText: t('6+ digits', '৬ অঙ্ক বা বেশি'),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      _obscurePassword
                                          ? Icons.visibility_off
                                          : Icons.visibility,
                                    ),
                                    onPressed: () => setState(
                                      () =>
                                          _obscurePassword = !_obscurePassword,
                                    ),
                                  ),
                                ),
                                validator: (v) {
                                  if (v == null || v.isEmpty) {
                                    return t(
                                      'Enter password',
                                      'পাসওয়ার্ড দিন',
                                    );
                                  }
                                  final reg = RegExp(r'^\d{6,}$');
                                  if (!reg.hasMatch(v)) {
                                    return _lang == 'EN'
                                        ? 'Password must be at least 6 digits'
                                        : 'পাসওয়ার্ড অবশ্যই কমপক্ষে ৬ অঙ্কের হতে হবে';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Checkbox(
                                    value: _rememberMe,
                                    onChanged: (v) => setState(() {
                                      _rememberMe = v ?? false;
                                    }),
                                  ),
                                  const SizedBox(width: 6),
                                  GestureDetector(
                                    onTap: () => setState(() {
                                      _rememberMe = !_rememberMe;
                                    }),
                                    child: Text(t('Remember me', 'মনে রাখুন')),
                                  ),
                                  const Spacer(),
                                  if (_rememberMe)
                                    TextButton(
                                      onPressed: () async {
                                        try {
                                          final prefs =
                                              await SharedPreferences.getInstance();
                                          await prefs.remove('saved_email');
                                          await prefs.setBool(
                                            'remember_me',
                                            false,
                                          );
                                          await _secureStorage.delete(
                                            key: 'saved_password',
                                          );
                                          await _secureStorage.delete(
                                            key: 'saved_email',
                                          );
                                          setState(() {
                                            _rememberMe = false;
                                            _emailCtrl.clear();
                                            _passwordCtrl.clear();
                                          });
                                        } catch (e) {}
                                      },
                                      child: Text(
                                        t('Clear saved', 'সংরক্ষিত মুছুন'),
                                      ),
                                    ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              const SizedBox.shrink(),
                              const SizedBox(height: 16),
                              SizedBox(
                                width: double.infinity,
                                height: 48,
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.purple[100],
                                    foregroundColor: Colors.deepPurple,
                                    disabledBackgroundColor: Colors.purple[50],
                                    disabledForegroundColor: Colors.deepPurple
                                        .withOpacity(0.6),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    elevation: 4,
                                  ),
                                  onPressed: _loading ? null : _sendOtp,
                                  child: _loading
                                      ? const SizedBox(
                                          width: 24,
                                          height: 24,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2.5,
                                            color: Colors.white,
                                          ),
                                        )
                                      : Text(t('Sign in', 'সাইন ইন')),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: () =>
                        Navigator.pushNamed(context, AppRoutes.register),
                    child: Text(t('Create account', 'উপরে নিবন্ধন করুন')),
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
