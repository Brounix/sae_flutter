import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:sae_flutter/ui/login.dart';
import 'package:sae_flutter/ui/user_following.dart';
import 'package:sae_flutter/ui/user_follows.dart';
import 'dart:convert';
import '../api/api_key_manager.dart';
import '../domain/profile_notifier.dart';

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String email = 'N/A';
  String name = 'N/A';
  String username = 'N/A';
  String bio = '';
  String avatarUrl = '';
  String? apiKey = ApiKeyManager().apiKey;
  int followersCount = 0;
  int followingCount = 0;

  TextEditingController emailController = TextEditingController();
  TextEditingController nameController = TextEditingController();
  TextEditingController usernameController = TextEditingController();
  TextEditingController bioController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ProfileNotifier>(context, listen: false).loadUserProfile();
    });
    emailController.text = email;
    nameController.text = name;
    usernameController.text = username;
    bioController.text = bio;
  }

  @override
  void dispose() {
    emailController.dispose();
    nameController.dispose();
    usernameController.dispose();
    bioController.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    final profileNotifier = Provider.of<ProfileNotifier>(context);

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/background.png',
              fit: BoxFit.cover,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundColor: Colors.grey,
                  backgroundImage: profileNotifier.avatarUrl.isNotEmpty
                      ? NetworkImage(profileNotifier.avatarUrl)
                      : null,
                  child: profileNotifier.avatarUrl.isEmpty
                      ? const Icon(Icons.person, size: 40, color: Colors.white)
                      : null,
                ),
                const SizedBox(height: 10),
                Text(profileNotifier.username,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                buildStatButton(
                  'Followers: ${profileNotifier.followersCount}',
                      () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => UserFollowsPage(),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                buildStatButton(
                  'Following: ${profileNotifier.followingCount}',
                      () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => UserFollowingPage(),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                buildEditableField(
                  'Mail',
                  profileNotifier.email,
                      (value) => profileNotifier.updateUserProfile('email', value),
                ),
                buildEditableField(
                  'Name',
                  profileNotifier.name,
                      (value) => profileNotifier.updateUserProfile('name', value),
                ),
                buildEditableField(
                  'Username',
                  profileNotifier.username,
                      (value) => profileNotifier.updateUserProfile('username', value),
                ),
                buildEditableField(
                  'Bio',
                  profileNotifier.bio,
                      (value) => profileNotifier.updateUserProfile('bio', value),
                  maxLines: 3,
                ),
                buildStyledButton(
                  'Logout',
                  const Color(0xFF671111),
                      () => logout(context),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildEditableField(
      String label, String value, ValueChanged<String> onUpdate,
      {int maxLines = 1}) {
    final controller = TextEditingController(text: value);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Material(
        elevation: 5,
        borderRadius: BorderRadius.circular(20),
        child: TextField(
          controller: controller,
          maxLines: maxLines,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
          decoration: InputDecoration(
            labelText: label,
            labelStyle: const TextStyle(
              color: Colors.white70,
              fontWeight: FontWeight.normal,
            ),
            filled: true,
            fillColor: const Color(0xFF252222),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
              borderSide: BorderSide.none,
            ),
          ),
          onEditingComplete: () {
            onUpdate(controller.text);
            FocusScope.of(context).unfocus();
          },
        ),
      ),
    );
  }

  Widget buildStatButton(String text, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
        decoration: BoxDecoration(
          color: Colors.grey[800],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          text,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
          ),
        ),
      ),
    );
  }

  Widget buildStyledButton(String text, Color color, VoidCallback onPressed) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          elevation: 5,
          padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide.none,
          ),
        ),
        onPressed: onPressed,
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 16,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  void logout(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Logout'),
          content: const Text('Are you sure you want to log out?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                ApiKeyManager().setApiKey('');

                Navigator.of(context).pop();

                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => LoginPage()),
                      (route) => false,
                );
              },
              child: const Text('Logout'),
            ),
          ],
        );
      },
    );
  }


  Future<void> updateUserProfile(String field, String value) async {
    final url = Uri.parse('https://api.rawg.io/api/users/current');
    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer your_api_key_here',
    };
    final body = jsonEncode({field: value});

    try {
      final response = await http.patch(url, headers: headers, body: body);

      if (response.statusCode == 200) {
        print('$field updated successfully.');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$field updated successfully!')),
        );
      } else {
        print('Failed to update $field. Status code: ${response.statusCode}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update $field.')),
        );
      }
    } catch (e) {
      print('Error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An error occurred while updating $field.')),
      );
    }
  }

  void showConfirmationDialog(
      BuildContext context, String field, String value) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirmation'),
          content:
              Text('Are you sure you want to change your $field to $value?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                updateUserProfile(field, value);
              },
              child: const Text('Confirm'),
            ),
          ],
        );
      },
    );
  }
}
