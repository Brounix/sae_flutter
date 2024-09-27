import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class GameDetailPage extends StatefulWidget {
  final String gameId;

  const GameDetailPage({Key? key, required this.gameId}) : super(key: key);

  @override
  _GameDetailPageState createState() => _GameDetailPageState();
}

class _GameDetailPageState extends State<GameDetailPage> {
  dynamic gameDetails;

  @override
  void initState() {
    super.initState();
    _fetchGameDetails();
  }

  Future<void> _fetchGameDetails() async {
    final apiKey = '4807c08683494754b36d62164f04e35c';
    final response = await http.get(Uri.parse(
        'https://api.rawg.io/api/games/${widget.gameId}?key=$apiKey'));

    if (response.statusCode == 200) {
      setState(() {
        gameDetails = jsonDecode(response.body);
      });
    } else {
      print('Failed to fetch game details');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF303030), // Set background color
      appBar: AppBar(
        title: const Text('Game Details'),
        backgroundColor: const Color(0xFF252222), // Set app bar color
      ),
      body: gameDetails != null
          ? _buildGameDetailContent()
          : const Center(child: CircularProgressIndicator()),
    );
  }

  Widget _buildGameDetailContent() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Image.network(
            gameDetails['background_image'] ?? '',
            width: double.infinity,
            height: 200,
            fit: BoxFit.cover,
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  gameDetails['name'],
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white, // Set title color
                  ),
                ),
                Text(
                  'Release Date: ${gameDetails['released']}',
                  style: const TextStyle(color: Colors.grey), // Set color for release date
                ),
                const SizedBox(height: 10),
                const Divider(color: Colors.white24), // Adds a line divider
                const SizedBox(height: 10),
                const Text(
                  'About',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFFFFFFF), // Set color for "About"
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  gameDetails['description_raw'] ?? 'No description available',
                  style: const TextStyle(color: Colors.white), // Set description color
                ),
                const SizedBox(height: 20),
                const Divider(color: Colors.white24), // Adds a line divider
                const SizedBox(height: 10),
                Text(
                  'Genres: ${_getListAsString(gameDetails['genres'])}',
                  style: const TextStyle(color: Colors.white), // Set color for genres
                ),
                Text(
                  'Tags: ${_getListAsString(gameDetails['tags'])}',
                  style: const TextStyle(color: Colors.white), // Set color for tags
                ),
                const SizedBox(height: 20),
                const Divider(color: Colors.white24), // Adds a line divider
                const SizedBox(height: 10),
                Text(
                  'Publisher: ${_getListAsString(gameDetails['publishers'])}',
                  style: const TextStyle(color: Colors.white), // Set color for publisher
                ),
                Text(
                  'Developer: ${_getListAsString(gameDetails['developers'])}',
                  style: const TextStyle(color: Colors.white), // Set color for developer
                ),
                const SizedBox(height: 20),
                if (gameDetails['website'] != null)
                  Text(
                    'Website: ${gameDetails['website']}',
                    style: const TextStyle(color: Colors.blue), // Set color for website
                  ),
                const SizedBox(height: 20),
                const Divider(color: Colors.white24), // Adds a line divider
                const SizedBox(height: 20),
                const Text(
                  'YouTube Videos',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white, // Set color for "YouTube Videos"
                  ),
                ),
                const SizedBox(height: 10),
                _buildVideoSection(), // Placeholder for YouTube video section
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Widget to display YouTube videos (for now, placeholder with static URLs)
  Widget _buildVideoSection() {
    return Column(
      children: [
        _buildVideoItem('Minecraft Hostage Simulator', 'https://www.youtube.com/watch?v=dQw4w9WgXcQ'),
        const SizedBox(height: 10),
        _buildVideoItem('Minecraft Hostage Simulator 2', 'https://www.youtube.com/watch?v=dQw4w9WgXcQ'),
      ],
    );
  }

  Widget _buildVideoItem(String title, String videoUrl) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 5),
        Image.network(
          'https://img.youtube.com/vi/dQw4w9WgXcQ/0.jpg', // YouTube thumbnail example
          height: 150,
          width: double.infinity,
          fit: BoxFit.cover,
        ),
        const SizedBox(height: 5),
        InkWell(
          onTap: () {
            // Handle video click, perhaps using url_launcher to open videoUrl
          },
          child: const Text(
            'Watch Video',
            style: TextStyle(color: Colors.blue),
          ),
        ),
      ],
    );
  }

  String _getListAsString(List<dynamic> list) {
    return list.map((item) => item['name']).join(', ');
  }
}
