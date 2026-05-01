import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/message_model.dart';
import '../services/database_service.dart';

class ChatProvider extends ChangeNotifier {
  final DatabaseService _dbService = DatabaseService();
  final Map<String, List<Message>> _conversations = {};
  bool _isLoading = false;

  bool get isLoading => _isLoading;

  List<Message> getConversation(String userId1, String userId2) {
    final key = _getConversationKey(userId1, userId2);
    return _conversations[key] ?? [];
  }

  Future<void> loadConversation(String userId1, String userId2) async {
    try {
      _isLoading = true;
      notifyListeners();

      final messages = await _dbService.getMessages(userId1, userId2);
      final key = _getConversationKey(userId1, userId2);
      _conversations[key] = messages;

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      debugPrint('Load conversation error: $e');
    }
  }

  Future<bool> sendMessage(String senderId, String receiverId, String content) async {
    try {
      const uuid = Uuid();
      final messageId = uuid.v4();

      final message = Message(
        id: messageId,
        senderId: senderId,
        receiverId: receiverId,
        content: content,
        timestamp: DateTime.now(),
        isRead: false,
      );

      await _dbService.insertMessage(message);

      final key = _getConversationKey(senderId, receiverId);
      if (_conversations.containsKey(key)) {
        _conversations[key]!.add(message);
      } else {
        _conversations[key] = [message];
      }

      // Add notification
      await _dbService.insertNotification(
        receiverId,
        'message',
        'رسالة جديدة',
        'لديك رسالة جديدة من المستخدم',
      );

      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Send message error: $e');
      return false;
    }
  }

  Future<void> markMessageAsRead(String messageId) async {
    try {
      await _dbService.markMessageAsRead(messageId);
      notifyListeners();
    } catch (e) {
      debugPrint('Mark message as read error: $e');
    }
  }

  Future<List<Message>> getUnreadMessages(String userId) async {
    try {
      return await _dbService.getUnreadMessages(userId);
    } catch (e) {
      debugPrint('Get unread messages error: $e');
      return [];
    }
  }

  String _getConversationKey(String userId1, String userId2) {
    final ids = [userId1, userId2]..sort();
    return '${ids[0]}_${ids[1]}';
  }

  void clearConversation(String userId1, String userId2) {
    final key = _getConversationKey(userId1, userId2);
    _conversations.remove(key);
    notifyListeners();
  }
}
