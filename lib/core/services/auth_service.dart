import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  final FirebaseAuth _auth = FirebaseAuth.instance;

  User? get currentUser => _auth.currentUser;

  Future<UserCredential> register(String email, String password) async {
    final cred = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    return cred;
  }

  Future<UserCredential> login(String email, String password) async {
    final cred = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    return cred;
  }

  Future<void> logout() async {
    await _auth.signOut();
  }
}
