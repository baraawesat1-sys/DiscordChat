import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/friends_provider.dart';
import '../providers/chat_provider.dart';
import '../theme/app_theme.dart';
import 'chat_screen.dart';
import 'friends_screen.dart';
import 'profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    final authProvider = context.read<AuthProvider>();
    final friendsProvider = context.read<FriendsProvider>();

    if (authProvider.currentUser != null) {
      await authProvider.setOnlineStatus(true);
      await friendsProvider.loadFriends(authProvider.currentUser!.id);
      await friendsProvider.loadAllUsers();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primaryDark,
      appBar: AppBar(
        title: const Text('COSMIC MESSENGER'),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.account_circle),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const ProfileScreen()),
              );
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          // Background
          Positioned.fill(
            child: CustomPaint(
              painter: HomeBackgroundPainter(),
            ),
          ),
          // Content
          IndexedStack(
            index: _selectedIndex,
            children: [
              const ChatListScreen(),
              const FriendsScreen(),
              const NotificationsScreen(),
            ],
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        backgroundColor: AppTheme.primaryDarker,
        selectedItemColor: AppTheme.accentCyan,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.chat),
            label: 'الرسائل',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people),
            label: 'الأصدقاء',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications),
            label: 'الإشعارات',
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    final authProvider = context.read<AuthProvider>();
    if (authProvider.currentUser != null) {
      authProvider.setOnlineStatus(false);
    }
    super.dispose();
  }
}

class ChatListScreen extends StatelessWidget {
  const ChatListScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final authProvider = context.read<AuthProvider>();
    final friendsProvider = context.watch<FriendsProvider>();

    if (friendsProvider.friends.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.chat_bubble_outline,
              size: 64,
              color: AppTheme.accentCyan.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'لا توجد محادثات',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              'أضف أصدقاء لبدء المحادثة',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: friendsProvider.friends.length,
      itemBuilder: (context, index) {
        final friend = friendsProvider.friends[index];
        return ChatListTile(
          friend: friend,
          currentUserId: authProvider.currentUser!.id,
        );
      },
    );
  }
}

class ChatListTile extends StatelessWidget {
  final dynamic friend;
  final String currentUserId;

  const ChatListTile({
    Key? key,
    required this.friend,
    required this.currentUserId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppTheme.primaryDarker.withOpacity(0.5),
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: AppTheme.accentPurple,
          child: Text(
            friend.username[0].toUpperCase(),
            style: const TextStyle(color: Colors.white),
          ),
        ),
        title: Text(
          friend.username,
          style: const TextStyle(color: AppTheme.accentCyan),
        ),
        subtitle: Text(
          friend.email,
          style: const TextStyle(color: Colors.grey),
        ),
        trailing: Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: friend.isOnline ? Colors.green : Colors.grey,
          ),
        ),
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => ChatScreen(
                friend: friend,
                currentUserId: currentUserId,
              ),
            ),
          );
        },
      ),
    );
  }
}

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.notifications_none,
            size: 64,
            color: AppTheme.accentCyan.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'لا توجد إشعارات',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
        ],
      ),
    );
  }
}

class HomeBackgroundPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // Draw stars
    final starPaint = Paint()
      ..color = Colors.white.withOpacity(0.3)
      ..strokeWidth = 0.5;

    for (int i = 0; i < 100; i++) {
      final x = (i * 43 + 789) % size.width.toInt();
      final y = (i * 71 + 234) % size.height.toInt();
      canvas.drawCircle(Offset(x.toDouble(), y.toDouble()), 0.5, starPaint);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
