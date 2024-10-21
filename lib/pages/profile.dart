import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../ApiKeyManager.dart';

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String email = 'N/A';
  String name = 'N/A';
  String username = 'N/A';
  String bio = '';
  String? apiKey = ApiKeyManager().apiKey;

  TextEditingController emailController = TextEditingController();
  TextEditingController nameController = TextEditingController();
  TextEditingController usernameController = TextEditingController();
  TextEditingController bioController = TextEditingController();

  @override
  void initState() {
    super.initState();
    emailController.text = email;
    nameController.text = name;
    usernameController.text = username;
    bioController.text = bio;
    getUserProfile();
  }

  @override
  void dispose() {
    emailController.dispose();
    nameController.dispose();
    usernameController.dispose();
    bioController.dispose();
    super.dispose();
  }

  Future<void> getUserProfile() async {
    final url = Uri.parse('https://api.rawg.io/api/users/current');
    final headers = {
      'User-Agent': 'sae_flutter/1.0.0',
      'Content-Type': 'application/json',
      'token': 'Token $apiKey',
    };

    try {
      final response = await http.get(url, headers: headers);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          email = data['email'] ?? 'Not Available';
          name = data['full_name'] ?? 'Not Available';
          username = data['username'] ?? 'Not Available';
          bio = data['bio'] ?? 'No bio available';

          emailController.text = email;
          nameController.text = name;
          usernameController.text = username;
          bioController.text = bio;
        });
      } else {
        if (response.statusCode == 401) {
          print('Unauthorized access. Please log in.');
        } else {
          print('Failed to load user data. Status code: ${response.statusCode}');
        }
      }
    } on http.ClientException catch (e) {
      print('Network error: $e');
    } on FormatException catch (e) {
      print('Error decoding response: $e');
    } catch (e) {
      print('Error fetching profile data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
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
                const CircleAvatar(radius: 40, backgroundColor: Colors.grey),
                const SizedBox(height: 10),
                Text(username, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                Text('Followers: 12  Following: 8', style: TextStyle(color: Colors.grey[500])),
                const SizedBox(height: 20),
                buildEditableField('Mail', emailController),
                buildEditableField('Name', nameController),
                buildEditableField('Username', usernameController),
                buildEditableField('Bio', bioController, maxLines: 3),
                const SizedBox(height: 20),
                buildStyledButton('Change Password', Colors.grey, () => changePassword(context)),
                buildStyledButton('Logout', const Color(0xFF671111), () => logout(context)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildEditableField(String label, TextEditingController controller, {int maxLines = 1}) {
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
            suffixIcon: IconButton(
              icon: const Icon(Icons.edit, color: Colors.white70),
              onPressed: () => showConfirmationDialog(context, label, controller.text),
            ),
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


  void changePassword(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Change Password'),
          content: const Text('Functionality not implemented yet.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
          ],
        );
      },
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
                Navigator.of(context).pop();
                // Effectuer ici la déconnexion
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

  void showConfirmationDialog(BuildContext context, String field, String value) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirmation'),
          content: Text('Are you sure you want to change your $field to "$value"?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                updateUserProfile(field, value);
                Navigator.of(context).pop();
              },
              child: const Text('Confirm'),
            ),
          ],
        );
      },
    );
  }
}
