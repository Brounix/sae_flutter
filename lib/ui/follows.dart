import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../api/api_key_manager.dart';

class FollowsPage extends StatefulWidget {
  const FollowsPage({Key? key}) : super(key: key);

  @override
  _FollowsPageState createState() => _FollowsPageState();
}

class _FollowsPageState extends State<FollowsPage> {
  List<dynamic> users = [];
  String? apiKey = ApiKeyManager().apiKey;

  @override
  void initState() {
    super.initState();
    _fetchUsers();
  }

  Future<void> _fetchUsers() async {
    final response =
        await http.get(Uri.parse('https://rawg.io/api/users?key=$apiKey'));

    if (response.statusCode == 200) {
      setState(() {
        users = jsonDecode(response.body)['results'];
      });
    } else {
      print('Erreur lors de la récupération des utilisateurs');
    }
  }

  @override
  Widget build(BuildContext context) {
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
                  borderSide: const BorderSide(
                      color: Colors.white), // Couleur de la bordure au focus
                ),
              ),
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Text(
              'Follow',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          Expanded(
            child: users.isNotEmpty
                ? ListView.builder(
                    padding: const EdgeInsets.all(16.0),
                    itemCount: users.length,
                    itemBuilder: (context, index) {
                      final user = users[index];
                      return _buildUserCard(user);
                    },
                  )
                : const Center(child: CircularProgressIndicator()),
          ),
        ],
      ),
    );
  }

  // Méthode pour construire une carte utilisateur
  Widget _buildUserCard(dynamic user) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: ListTile(
        leading: CircleAvatar(
          backgroundImage: NetworkImage(
              user['profile_image'] ?? ''), // Image de profil de l'utilisateur
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
