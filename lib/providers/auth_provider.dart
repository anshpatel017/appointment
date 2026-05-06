import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/user.dart';
import '../database/database_helper.dart';

class AuthProvider extends ChangeNotifier {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  AppUser? _currentUser;
  bool _isLoading = false;

  AppUser? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _currentUser != null;
  bool get isDoctor => _currentUser?.role == 'Admin' || _currentUser?.role == 'Doctor';

  Future<Map<String, dynamic>> login(String email, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      final user = await _dbHelper.loginUser(email, password);
      if (user != null) {
        _currentUser = user;
        _isLoading = false;
        notifyListeners();
        return {'success': true};
      } else {
        _isLoading = false;
        notifyListeners();
        return {'success': false, 'message': 'Invalid email or password'};
      }
    } catch (e) {
      debugPrint('Login Error: $e');
      _isLoading = false;
      notifyListeners();
      return {'success': false, 'message': 'An error occurred during login'};
    }
  }

  Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
    required String role,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      final newUser = AppUser(
        id: const Uuid().v4(),
        name: name,
        email: email,
        password: password,
        role: role,
      );

      await _dbHelper.registerUser(newUser);
      _currentUser = newUser;
      
      _isLoading = false;
      notifyListeners();
      return {'success': true};
    } catch (e) {
      debugPrint('Registration Error: $e');
      _isLoading = false;
      notifyListeners();
      if (e.toString().contains('UNIQUE constraint failed')) {
        return {'success': false, 'message': 'Email already exists'};
      }
      return {'success': false, 'message': 'An error occurred during registration: ${e.toString().split('\n').first}'};
    }
  }

  void logout() {
    _currentUser = null;
    notifyListeners();
  }
}
