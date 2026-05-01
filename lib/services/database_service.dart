import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/user_model.dart';
import '../models/message_model.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  static Database? _database;

  factory DatabaseService() {
    return _instance;
  }

  DatabaseService._internal();

  Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'cosmic_messenger.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    // Users table
    await db.execute('''
      CREATE TABLE users (
        id TEXT PRIMARY KEY,
        username TEXT NOT NULL UNIQUE,
        email TEXT NOT NULL UNIQUE,
        profileImagePath TEXT,
        bio TEXT,
        isOnline INTEGER DEFAULT 0,
        createdAt TEXT NOT NULL
      )
    ''');

    // Messages table
    await db.execute('''
      CREATE TABLE messages (
        id TEXT PRIMARY KEY,
        senderId TEXT NOT NULL,
        receiverId TEXT NOT NULL,
        content TEXT NOT NULL,
        timestamp TEXT NOT NULL,
        isRead INTEGER DEFAULT 0,
        FOREIGN KEY (senderId) REFERENCES users(id),
        FOREIGN KEY (receiverId) REFERENCES users(id)
      )
    ''');

    // Friends table
    await db.execute('''
      CREATE TABLE friends (
        id TEXT PRIMARY KEY,
        userId TEXT NOT NULL,
        friendId TEXT NOT NULL,
        addedAt TEXT NOT NULL,
        FOREIGN KEY (userId) REFERENCES users(id),
        FOREIGN KEY (friendId) REFERENCES users(id),
        UNIQUE(userId, friendId)
      )
    ''');

    // Notifications table
    await db.execute('''
      CREATE TABLE notifications (
        id TEXT PRIMARY KEY,
        userId TEXT NOT NULL,
        type TEXT NOT NULL,
        title TEXT NOT NULL,
        message TEXT NOT NULL,
        isRead INTEGER DEFAULT 0,
        createdAt TEXT NOT NULL,
        FOREIGN KEY (userId) REFERENCES users(id)
      )
    ''');
  }

  // User operations
  Future<void> insertUser(User user) async {
    final db = await database;
    await db.insert('users', user.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<User?> getUser(String id) async {
    final db = await database;
    final result = await db.query('users', where: 'id = ?', whereArgs: [id]);
    if (result.isNotEmpty) {
      return User.fromMap(result.first);
    }
    return null;
  }

  Future<List<User>> getAllUsers() async {
    final db = await database;
    final result = await db.query('users');
    return result.map((map) => User.fromMap(map)).toList();
  }

  Future<void> updateUser(User user) async {
    final db = await database;
    await db.update('users', user.toMap(), where: 'id = ?', whereArgs: [user.id]);
  }

  // Message operations
  Future<void> insertMessage(Message message) async {
    final db = await database;
    await db.insert('messages', message.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<Message>> getMessages(String userId1, String userId2) async {
    final db = await database;
    final result = await db.query(
      'messages',
      where: '(senderId = ? AND receiverId = ?) OR (senderId = ? AND receiverId = ?)',
      whereArgs: [userId1, userId2, userId2, userId1],
      orderBy: 'timestamp ASC',
    );
    return result.map((map) => Message.fromMap(map)).toList();
  }

  Future<List<Message>> getUnreadMessages(String userId) async {
    final db = await database;
    final result = await db.query(
      'messages',
      where: 'receiverId = ? AND isRead = 0',
      whereArgs: [userId],
    );
    return result.map((map) => Message.fromMap(map)).toList();
  }

  Future<void> markMessageAsRead(String messageId) async {
    final db = await database;
    await db.update('messages', {'isRead': 1}, where: 'id = ?', whereArgs: [messageId]);
  }

  // Friends operations
  Future<void> addFriend(String userId, String friendId) async {
    final db = await database;
    final friendshipId = '$userId-$friendId';
    await db.insert(
      'friends',
      {
        'id': friendshipId,
        'userId': userId,
        'friendId': friendId,
        'addedAt': DateTime.now().toIso8601String(),
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<User>> getFriends(String userId) async {
    final db = await database;
    final result = await db.rawQuery('''
      SELECT u.* FROM users u
      INNER JOIN friends f ON u.id = f.friendId
      WHERE f.userId = ?
    ''', [userId]);
    return result.map((map) => User.fromMap(map)).toList();
  }

  Future<void> removeFriend(String userId, String friendId) async {
    final db = await database;
    await db.delete(
      'friends',
      where: 'userId = ? AND friendId = ?',
      whereArgs: [userId, friendId],
    );
  }

  // Notifications operations
  Future<void> insertNotification(String userId, String type, String title, String message) async {
    final db = await database;
    final id = DateTime.now().millisecondsSinceEpoch.toString();
    await db.insert('notifications', {
      'id': id,
      'userId': userId,
      'type': type,
      'title': title,
      'message': message,
      'isRead': 0,
      'createdAt': DateTime.now().toIso8601String(),
    });
  }

  Future<List<Map<String, dynamic>>> getNotifications(String userId) async {
    final db = await database;
    return await db.query(
      'notifications',
      where: 'userId = ?',
      whereArgs: [userId],
      orderBy: 'createdAt DESC',
    );
  }

  Future<int> getUnreadNotificationsCount(String userId) async {
    final db = await database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM notifications WHERE userId = ? AND isRead = 0',
      [userId],
    );
    return (result.first['count'] as int?) ?? 0;
  }

  Future<void> markNotificationAsRead(String notificationId) async {
    final db = await database;
    await db.update('notifications', {'isRead': 1}, where: 'id = ?', whereArgs: [notificationId]);
  }
}
