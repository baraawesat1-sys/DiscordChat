import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/friends_provider.dart';
import '../providers/auth_provider.dart';
import '../theme/app_theme.dart';

class FriendsScreen extends StatefulWidget {
  const FriendsScreen({Key? key}) : super(key: key);

  @override
  State<FriendsScreen> createState() => _FriendsScreenState();
}

class _FriendsScreenState extends State<FriendsScreen> {
  final _searchController = TextEditingController();
  bool _isSearching = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.read<AuthProvider>();
    final friendsProvider = context.watch<FriendsProvider>();

    return Column(
      children: [
        // Search bar
        Padding(
          padding: const EdgeInsets.all(16),
          child: TextField(
            controller: _searchController,
            onChanged: (value) {
              setState(() {
                _isSearching = value.isNotEmpty;
              });
            },
            decoration: InputDecoration(
              hintText: 'ابحث عن أصدقاء...',
              prefixIcon: const Icon(Icons.search),
              prefixIconColor: AppTheme.accentCyan,
              suffixIcon: _isSearching
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchController.clear();
                        setState(() {
                          _isSearching = false;
                        });
                      },
                    )
                  : null,
            ),
            textDirection: TextDirection.rtl,
          ),
        ),
        // Friends or search results
        Expanded(
          child: _isSearching
              ? _buildSearchResults(friendsProvider, authProvider.currentUser!.id)
              : _buildFriendsList(friendsProvider, authProvider.currentUser!.id),
        ),
      ],
    );
  }

  Widget _buildFriendsList(FriendsProvider friendsProvider, String userId) {
    if (friendsProvider.friends.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.people_outline,
              size: 64,
              color: AppTheme.accentCyan.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'لا توجد أصدقاء',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              'ابحث عن مستخدمين لإضافتهم كأصدقاء',
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
        return FriendTile(
          friend: friend,
          onRemove: () {
            friendsProvider.removeFriend(userId, friend.id);
          },
        );
      },
    );
  }

  Widget _buildSearchResults(FriendsProvider friendsProvider, String userId) {
    final results = friendsProvider.searchAllUsers(_searchController.text);
    final filteredResults = results.where((user) => user.id != userId).toList();

    if (filteredResults.isEmpty) {
      return Center(
        child: Text(
          'لم يتم العثور على نتائج',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: filteredResults.length,
      itemBuilder: (context, index) {
        final user = filteredResults[index];
        final isFriend = friendsProvider.isFriend(userId, user.id);

        return Card(
          color: AppTheme.primaryDarker.withOpacity(0.5),
          margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: AppTheme.accentPurple,
              child: Text(
                user.username[0].toUpperCase(),
                style: const TextStyle(color: Colors.white),
              ),
            ),
            title: Text(
              user.username,
              style: const TextStyle(color: AppTheme.accentCyan),
            ),
            subtitle: Text(
              user.email,
              style: const TextStyle(color: Colors.grey),
            ),
            trailing: isFriend
                ? const Icon(Icons.check, color: Colors.green)
                : ElevatedButton(
                    onPressed: () {
                      friendsProvider.addFriend(userId, user.id);
                    },
                    child: const Text('إضافة'),
                  ),
          ),
        );
      },
    );
  }
}

class FriendTile extends StatelessWidget {
  final dynamic friend;
  final VoidCallback onRemove;

  const FriendTile({
    Key? key,
    required this.friend,
    required this.onRemove,
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
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: friend.isOnline ? Colors.green : Colors.grey,
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              icon: const Icon(Icons.close, color: Colors.red),
              onPressed: onRemove,
            ),
          ],
        ),
      ),
    );
  }
}
