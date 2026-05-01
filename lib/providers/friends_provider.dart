import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/database_service.dart';

class FriendsProvider extends ChangeNotifier {
  final DatabaseService _dbService = DatabaseService();
  List<User> _friends = [];
  List<User> _allUsers = [];
  bool _isLoading = false;

  List<User> get friends => _friends;
  List<User> get allUsers => _allUsers;
  bool get isLoading => _isLoading;

  Future<void> loadFriends(String userId) async {
    try {
      _isLoading = true;
      notifyListeners();

      _friends = await _dbService.getFriends(userId);

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      debugPrint('Load friends error: $e');
    }
  }

  Future<void> loadAllUsers() async {
    try {
      _isLoading = true;
      notifyListeners();

      _allUsers = await _dbService.getAllUsers();

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      debugPrint('Load all users error: $e');
    }
  }

  Future<bool> addFriend(String userId, String friendId) async {
    try {
      await _dbService.addFriend(userId, friendId);

      // Reload friends
      await loadFriends(userId);

      // Add notification
      await _dbService.insertNotification(
        friendId,
        'friend_request',
        'طلب صداقة جديد',
        'تمت إضافتك كصديق',
      );

      return true;
    } catch (e) {
      debugPrint('Add friend error: $e');
      return false;
    }
  }

  Future<bool> removeFriend(String userId, String friendId) async {
    try {
      await _dbService.removeFriend(userId, friendId);

      // Reload friends
      await loadFriends(userId);

      return true;
    } catch (e) {
      debugPrint('Remove friend error: $e');
      return false;
    }
  }

  List<User> searchFriends(String query) {
    if (query.isEmpty) {
      return _friends;
    }

    return _friends
        .where((friend) =>
            friend.username.toLowerCase().contains(query.toLowerCase()) ||
            friend.email.toLowerCase().contains(query.toLowerCase()))
        .toList();
  }

  List<User> searchAllUsers(String query) {
    if (query.isEmpty) {
      return _allUsers;
    }

    return _allUsers
        .where((user) =>
            user.username.toLowerCase().contains(query.toLowerCase()) ||
            user.email.toLowerCase().contains(query.toLowerCase()))
        .toList();
  }

  bool isFriend(String userId, String friendId) {
    return _friends.any((friend) => friend.id == friendId);
  }
}
