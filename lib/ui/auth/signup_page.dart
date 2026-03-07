import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();

  String _role = 'patient'; // patient | therapist
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _signup() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      // 1) Create Firebase Auth user
      final cred = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _email.text.trim(),
        password: _password.text,
      );

      final uid = cred.user!.uid;

      // 2) Create Firestore profile in ONE atomic batch
      final db = FirebaseFirestore.instance;
      final batch = db.batch();

      // users/{uid}
      batch.set(db.collection('users').doc(uid), {
        'fullName': _name.text.trim(),
        'email': _email.text.trim(),
        'role': _role, // 'patient' or 'therapist'
        'createdAt': FieldValue.serverTimestamp(),
      });

      // If therapist -> also create therapists/{uid}
      if (_role == 'therapist') {
        batch.set(db.collection('therapists').doc(uid), {
          'fullName': _name.text.trim(),
          'ratingAvg': 0.0,
          'ratingCount': 0,
          'locationText': 'Jordan, Amman',
          'locationUrl': 'https://maps.google.com/?q=Amman+Jordan',
          'bio': '',
          'specialties': <String>[],
          'therapiesCount': 0,
          'createdAt': FieldValue.serverTimestamp(),
        });
      }

      await batch.commit();

      if (mounted) Navigator.pop(context); // back to login
    } on FirebaseAuthException catch (e) {
      setState(() => _error = e.message ?? e.code);
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sign up')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _name,
              decoration: const InputDecoration(labelText: 'Full name'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _email,
              decoration: const InputDecoration(labelText: 'Email'),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _password,
              decoration: const InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            const SizedBox(height: 12),

            DropdownButtonFormField<String>(
              value: _role,
              items: const [
                DropdownMenuItem(value: 'patient', child: Text('Patient')),
                DropdownMenuItem(value: 'therapist', child: Text('Therapist')),
              ],
              onChanged: _loading ? null : (v) => setState(() => _role = v ?? 'patient'),
              decoration: const InputDecoration(labelText: 'Role'),
            ),

            const SizedBox(height: 16),
            if (_error != null)
              Text(_error!, style: const TextStyle(color: Colors.red)),
            const SizedBox(height: 8),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _loading ? null : _signup,
                child: _loading
                    ? const SizedBox(
                  height: 18,
                  width: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
                    : const Text('Create account'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
