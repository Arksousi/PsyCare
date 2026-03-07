import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/enums.dart';

class AuthService {
  AuthService({
    FirebaseAuth? auth,
    FirebaseFirestore? db,
  })  : _auth = auth ?? FirebaseAuth.instance,
        _db = db ?? FirebaseFirestore.instance;

  final FirebaseAuth _auth;
  final FirebaseFirestore _db;

  User? get currentUser => _auth.currentUser;

  Stream<User?> authStateChanges() => _auth.authStateChanges();

  /// Sign up + create/overwrite users/{uid}
  Future<UserCredential> signUpEmailPassword({
    required String email,
    required String password,
    required String fullName,
    required UserRole role,
  }) async {
    final cred = await _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );

    final uid = cred.user!.uid;

    await _db.collection('users').doc(uid).set({
      'email': email.trim(),
      'fullName': fullName.trim(),
      'role': role.value,
      'createdAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
    if (role == UserRole.therapist) {
      await _db.collection('therapists').doc(uid).set({
        'fullName': fullName.trim(),
        'createdAt': FieldValue.serverTimestamp(),
        'ratingAvg': 0.0,
        'ratingCount': 0,
        'locationText': '',
        'locationUrl': '',
        'bio': '',
        'specialties': <String>[],
        'therapiesCount': 0,
      }, SetOptions(merge: true));
    }
    Future<String?> getCurrentUserFullName() async {
      final u = currentUser;
      if (u == null) return null;
      final snap = await _db.collection('users').doc(u.uid).get();
      return snap.data()?['fullName'] as String?;
    }

    return cred;
  }

  Future<UserCredential> loginEmailPassword({
    required String email,
    required String password,
  }) {
    return _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
  }

  Future<void> logout() => _auth.signOut();

  /// Read the role from users/{uid}
  Future<UserRole?> getCurrentUserRole() async {
    final u = currentUser;
    if (u == null) return null;

    final snap = await _db.collection('users').doc(u.uid).get();
    if (!snap.exists) return null;

    final data = snap.data()!;
    final roleStr = (data['role'] as String?) ?? '';
    return UserRoleX.fromString(roleStr);
  }

}
