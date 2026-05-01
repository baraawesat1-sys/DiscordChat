class User {
  final String id;
  final String username;
  final String email;
  final String? profileImagePath;
  final String? bio;
  final bool isOnline;
  final DateTime createdAt;

  User({
    required this.id,
    required this.username,
    required this.email,
    this.profileImagePath,
    this.bio,
    this.isOnline = false,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'profileImagePath': profileImagePath,
      'bio': bio,
      'isOnline': isOnline ? 1 : 0,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'] as String,
      username: map['username'] as String,
      email: map['email'] as String,
      profileImagePath: map['profileImagePath'] as String?,
      bio: map['bio'] as String?,
      isOnline: (map['isOnline'] as int?) == 1,
      createdAt: DateTime.parse(map['createdAt'] as String),
    );
  }

  User copyWith({
    String? id,
    String? username,
    String? email,
    String? profileImagePath,
    String? bio,
    bool? isOnline,
    DateTime? createdAt,
  }) {
    return User(
      id: id ?? this.id,
      username: username ?? this.username,
      email: email ?? this.email,
      profileImagePath: profileImagePath ?? this.profileImagePath,
      bio: bio ?? this.bio,
      isOnline: isOnline ?? this.isOnline,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
