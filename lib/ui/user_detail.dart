import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../domain/user_detail_notifier.dart';

class UserDetailPage extends StatelessWidget {
  const UserDetailPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final selectedUserNotifier = Provider.of<SelectedUserNotifier>(context);
    final user = selectedUserNotifier.selectedUser;

    if (user == null) {
      return Scaffold(
        backgroundColor: const Color(0xFF303030),
        body: const Center(
          child: Text(
            'Aucun utilisateur sélectionné',
            style: TextStyle(color: Colors.white, fontSize: 18),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFF303030),
      appBar: AppBar(
        backgroundColor: const Color(0xFF424242),
        title: Text(user['username'] ?? 'Unknown'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              backgroundImage: NetworkImage(user['avatar'] ?? ''),
              radius: 50,
            ),
            const SizedBox(height: 16),
            Text(
              'Nom : ${user['name'] ?? 'Unknown'}',
              style: const TextStyle(color: Colors.white, fontSize: 18),
            ),
            const SizedBox(height: 8),
            Text(
              'Username : ${user['username'] ?? 'Unknown'}',
              style: const TextStyle(color: Colors.white, fontSize: 18),
            ),
          ],
        ),
      ),
    );
  }
}
