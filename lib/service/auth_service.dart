import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';

import '../models/enums.dart';
import '../models/app_user.dart';
import 'dart:io' show Platform;

class AuthService {
  static String get baseUrl => 
    Platform.isAndroid ? 'http://10.0.2.2:5001/api/auth' : 'http://localhost:5001/api/auth';
  
  // Singleton pattern for simplicity
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  AppUser? _currentUser;
  AppUser? get currentUser => _currentUser;

  // Stream controller to mimic authStateChanges
  final _authStateController = StreamController<AppUser?>.broadcast();
  Stream<AppUser?> authStateChanges() => _authStateController.stream;

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    if (token != null) {
      try {
        final response = await http.get(
          Uri.parse('$baseUrl/me'),
          headers: {'Authorization': 'Bearer $token'},
        );

        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          data['token'] = token; // Inject token back into model
          _currentUser = AppUser.fromJson(data);
          _authStateController.add(_currentUser);
        } else {
          await logout();
        }
      } catch (e) {
        // Assume network error, keep offline state or logout
      }
    }
  }

  Future<AppUser> signUpEmailPassword({
    required String email,
    required String password,
    required String fullName,
    required UserRole role,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/signup'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'email': email.trim(),
        'password': password,
        'fullName': fullName.trim(),
        'role': role.value,
      }),
    );

    if (response.statusCode == 201) {
      final user = AppUser.fromJson(json.decode(response.body));
      await _saveUser(user);
      return user;
    } else {
      throw Exception('Failed to sign up: ${json.decode(response.body)['message']}');
    }
  }

  Future<AppUser> loginEmailPassword({
    required String email,
    required String password,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/login'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'email': email.trim(),
        'password': password,
      }),
    );

    if (response.statusCode == 200) {
      final user = AppUser.fromJson(json.decode(response.body));
      await _saveUser(user);
      return user;
    } else {
      throw Exception('Failed to login: ${json.decode(response.body)['message']}');
    }
  }

  Future<void> _saveUser(AppUser user) async {
    _currentUser = user;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', user.token);
    _authStateController.add(user);
  }

  Future<void> logout() async {
    _currentUser = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    _authStateController.add(null);
  }

  Future<UserRole?> getCurrentUserRole() async {
    if (_currentUser == null) return null;
    return UserRoleX.fromString(_currentUser!.role);
  }
}
