import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../domain/following_notifier.dart';

class UserFollowingPage extends StatefulWidget {
  const UserFollowingPage({Key? key}) : super(key: key);

  @override
  _UserFollowingPageState createState() => _UserFollowingPageState();
}

class _UserFollowingPageState extends State<UserFollowingPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final notifier = Provider.of<FollowingNotifier>(context, listen: false);
      notifier.fetchFollowing();
    });
  }

  @override
  Widget build(BuildContext context) {
    final followingNotifier = Provider.of<FollowingNotifier>(context);

    return Scaffold(
      backgroundColor: const Color(0xFF303030),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search users',
                hintStyle: const TextStyle(color: Colors.white54),
                prefixIcon: const Icon(Icons.search, color: Colors.white54),
                filled: true,
                fillColor: Colors.grey[800],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Colors.transparent),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Colors.transparent),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Colors.white),
                ),
              ),
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Text(
              'Following',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          Expanded(
            child: followingNotifier.isLoading
                ? const Center(
              child: CircularProgressIndicator(),
            )
                : followingNotifier.following.isNotEmpty
                ? ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: followingNotifier.following.length,
              itemBuilder: (context, index) {
                final user = followingNotifier.following[index];
                return _buildUserCard(user);
              },
            )
                : const Center(
              child: Text(
                'No users followed.',
                style: TextStyle(
                  color: Colors.white54,
                  fontSize: 18,
                ),
              ),
            ),
          ),
          if (followingNotifier.errorMessage.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                followingNotifier.errorMessage,
                style: const TextStyle(color: Colors.red, fontSize: 16),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildUserCard(dynamic user) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: ListTile(
        leading: CircleAvatar(
          backgroundImage: NetworkImage(user['profile_image'] ?? ''),
        ),
        title: Text(
          user['username'] ?? 'Unknown',
          style: const TextStyle(color: Colors.white, fontSize: 16),
        ),
        trailing: IconButton(
          icon: const Icon(Icons.remove_red_eye, color: Colors.white),
          onPressed: () {
            // Voir le profil de l'utilisateur
          },
        ),
      ),
    );
  }
}
