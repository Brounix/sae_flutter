import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sae_flutter/ui/widget/search_bar.dart';
import '../domain/followers_notifier.dart';

class UserFollowsPage extends StatefulWidget {
  const UserFollowsPage({Key? key}) : super(key: key);

  @override
  _FollowsPageState createState() => _FollowsPageState();
}

class _FollowsPageState extends State<UserFollowsPage> {

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.
    addPostFrameCallback((_) {
      final notifier = Provider.of<FollowersNotifier>(context, listen: false);
      notifier.fetchFollowers();
    });
  }

  @override
  Widget build(BuildContext context) {
    final followersNotifier = Provider.of<FollowersNotifier>(context);

    return Scaffold(
      backgroundColor: const Color(0xFF303030),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ExpandableSearchBar(),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Text(
              'Followers',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          Expanded(
            child: followersNotifier.isLoading
                ? const Center(
              child: CircularProgressIndicator(),
            )
                : followersNotifier.followers.isNotEmpty
                ? ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: followersNotifier.followers.length,
              itemBuilder: (context, index) {
                final user = followersNotifier.followers[index];
                return _buildUserCard(user);
              },
            )
                : const Center(
              child: Text(
                'No followers found.',
                style: TextStyle(
                  color: Colors.white54,
                  fontSize: 18,
                ),
              ),
            ),
          ),
          if (followersNotifier.errorMessage.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                followersNotifier.errorMessage,
                style: const TextStyle(color: Colors.red, fontSize: 16),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildUserCard(dynamic user) {
    return Card(
      color: const Color(0xFF434343),
      elevation: 5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: ListTile(
        leading: CircleAvatar(
          backgroundImage: NetworkImage(user['avatar'] ?? ''),
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