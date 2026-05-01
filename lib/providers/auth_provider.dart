import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../models/user_model.dart';
import '../services/database_service.dart';

class AuthProvider extends ChangeNotifier {
  User? _currentUser;
  final DatabaseService _dbService = DatabaseService();
  bool _isLoading = false;

  User? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _currentUser != null;

  Future<void> initializeAuth() async {
    _isLoading = true;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('userId');

    if (userId != null) {
      _currentUser = await _dbService.getUser(userId);
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<bool> register(String username, String email) async {
    try {
      _isLoading = true;
      notifyListeners();

      // Check if username or email already exists
      final users = await _dbService.getAllUsers();
      if (users.any((u) => u.username == username || u.email == email)) {
        _isLoading = false;
        notifyListeners();
        return false;
      }

      const uuid = Uuid();
      final userId = uuid.v4();

      final newUser = User(
        id: userId,
        username: username,
        email: email,
        createdAt: DateTime.now(),
      );

      await _dbService.insertUser(newUser);

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('userId', userId);

      _currentUser = newUser;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> login(String username) async {
    try {
      _isLoading = true;
      notifyListeners();

      final users = await _dbService.getAllUsers();
      final user = users.firstWhere(
        (u) => u.username == username,
        orElse: () => throw Exception('User not found'),
      );

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('userId', user.id);

      _currentUser = user;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    try {
      if (_currentUser != null) {
        // Update online status
        final updatedUser = _currentUser!.copyWith(isOnline: false);
        await _dbService.updateUser(updatedUser);
      }

      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('userId');

      _currentUser = null;
      notifyListeners();
    } catch (e) {
      debugPrint('Logout error: $e');
    }
  }

  Future<void> updateProfile({
    String? bio,
    String? profileImagePath,
  }) async {
    if (_currentUser == null) return;

    try {
      final updatedUser = _currentUser!.copyWith(
        bio: bio ?? _currentUser!.bio,
        profileImagePath: profileImagePath ?? _currentUser!.profileImagePath,
      );

      await _dbService.updateUser(updatedUser);
      _currentUser = updatedUser;
      notifyListeners();
    } catch (e) {
      debugPrint('Update profile error: $e');
    }
  }

  Future<void> setOnlineStatus(bool isOnline) async {
    if (_currentUser == null) return;

    try {
      final updatedUser = _currentUser!.copyWith(isOnline: isOnline);
      await _dbService.updateUser(updatedUser);
      _currentUser = updatedUser;
      notifyListeners();
    } catch (e) {
      debugPrint('Set online status error: $e');
    }
  }
}
