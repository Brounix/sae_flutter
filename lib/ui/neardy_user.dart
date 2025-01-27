import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sae_flutter/ui/user_detail.dart';
import '../data_source/api_manager.dart';
import '../domain/neadry_user_notifier.dart';
import '../domain/user_detail_notifier.dart';
import '../repo/user_repository.dart';


class NeardyUserPage extends StatefulWidget {
  const NeardyUserPage({Key? key}) : super(key: key);

  @override
  _NeardyUserPageState createState() => _NeardyUserPageState();
}

class _NeardyUserPageState extends State<NeardyUserPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final nearbyUsersNotifier = Provider.of<NearbyUsersNotifier>(context, listen: false);

      try {
        //final userProfile = await UserRepository(ApiManager()).fetchUserProfile();
        nearbyUsersNotifier.fetchNearbyUsers(10.0);
      } catch (e) {
        print('Error fetching user profile: $e');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final nearbyUsersNotifier = Provider.of<NearbyUsersNotifier>(context);
    final selectedUserNotifier = Provider.of<SelectedUserNotifier>(context, listen: false);

    return Scaffold(
      backgroundColor: const Color(0xFF303030),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Text(
              'Nearby Users',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          Expanded(
            child: nearbyUsersNotifier.isLoading
                ? const Center(child: CircularProgressIndicator())
                : nearbyUsersNotifier.errorMessage.isNotEmpty
                ? Center(
              child: Text(
                nearbyUsersNotifier.errorMessage,
                style: const TextStyle(color: Colors.red, fontSize: 18),
              ),
            )
                : ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: nearbyUsersNotifier.nearbyUsers.length,
              itemBuilder: (context, index) {
                final user = nearbyUsersNotifier.nearbyUsers[index];
                return _buildUserCard(user, selectedUserNotifier);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserCard(Map<String, dynamic> user, SelectedUserNotifier selectedUserNotifier) {
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
            selectedUserNotifier.selectUser(user);
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const UserDetailPage(),
              ),
            );
          },
        ),
      ),
    );
  }
}
