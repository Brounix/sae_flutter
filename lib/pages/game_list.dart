import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:sae_flutter/widget/bottom_bar.dart';
import 'package:shimmer/shimmer.dart';

import 'game_details.dart';

class GameListPage extends StatefulWidget {
  const GameListPage({Key? key}) : super(key: key);

  @override
  _GameListPageState createState() => _GameListPageState();
}

class _GameListPageState extends State<GameListPage> {
  List<dynamic> games = [];
  int currentPage = 1;
  bool isLoading = false;
  String apiKey = ''; // Store API key here
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    apiKey = '4807c08683494754b36d62164f04e35c';
    _fetchGames();

    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        _fetchGames();
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _fetchGames() async {
    if (isLoading) return;
    setState(() {
      isLoading = true;
    });

    final response = await http.get(Uri.parse(
        'https://api.rawg.io/api/games?key=$apiKey&page=$currentPage'));

    if (response.statusCode == 200) {
      setState(() {
        games.addAll(jsonDecode(response.body)['results']);
        currentPage++;
        isLoading = false;
      });
    } else {
      print('Failed to fetch games');
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF303030),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const TextField(
          decoration: InputDecoration(
            hintText: 'Search',
            prefixIcon: Icon(Icons.search, color: Colors.white),
            border: InputBorder.none,
            filled: true,
            fillColor: const Color(0xFF2C2C2C),
            contentPadding: EdgeInsets.symmetric(vertical: 0),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding:
            const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Row(
              children: [
                const Text(
                  'Order by: ',
                  style: TextStyle(color: Colors.white),
                ),
                DropdownButton<String>(
                  value: 'Name',
                  dropdownColor: Colors.black,
                  items: <String>['Name', 'Release Date', 'Popularity']
                      .map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(
                        value,
                        style: const TextStyle(color: Colors.white),
                      ),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {},
                ),
              ],
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'New and trending',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Based on player counts and release date',
                style: TextStyle(color: Colors.grey),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: MasonryGridView.count(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              crossAxisCount: 2,  // Number of columns
              itemCount: games.length + (isLoading ? 2 : 0),
              itemBuilder: (context, index) {
                if (index < games.length) {
                  final game = games[index];

                  bool isLargeCard = game['name'].length > 20 || (game['genres'] as List).length > 3;

                  final platforms = (game['platforms'] as List)
                      .map<String>((platform) => platform['platform']['name'].toString())
                      .toList();
                  final rating = game['rating'] ?? 0.0;

                  return GameCard(
                    game : game,
                    gameId: game['id'].toString(),
                    title: game['name'],
                    imageUrl: game['background_image'] ?? '',
                    genres: (game['genres'] as List).map((genre) => genre['name']).join(', '),
                    rating: rating, // Pass the rating
                    platforms: platforms, // Pass the platforms
                    isLargeCard: isLargeCard,
                  );

                } else if (isLoading) {
                  // Show shimmer effect when loading more items
                  return ShimmerGameCard();
                } else {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }
              },
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
            ),
          ),
          if (isLoading)
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: CircularProgressIndicator(),
            ),
        ],
      ),
    );
  }
}

class GameCard extends StatelessWidget {
  final String gameId;
  final String title;
  final String imageUrl;
  final String genres;
  final bool isLargeCard;
  final double rating; // Add rating field
  final List<String> platforms; // Add platforms field
  final dynamic game;

  const GameCard({
    required this.gameId,
    required this.game,
    required this.title,
    required this.imageUrl,
    required this.genres,
    required this.rating, // Initialize rating
    required this.platforms, // Initialize platforms
    this.isLargeCard = false, // Default to false
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => GameDetailPage(
              gameId: gameId,
            ),
          ),
        );
      },
    child: Card(
      color: const Color(0xFF2C2C2C),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
      ),
      elevation: 6,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AspectRatio(
            aspectRatio: isLargeCard ? 16 / 10 : 16 / 9,
            child: Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16.0),
                    topRight: Radius.circular(16.0),
                  ),
                  child: Image.network(
                    imageUrl,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    alignment: Alignment.center,
                  ),
                ),
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.7),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: Row(
                    children: _buildPlatformIcons(platforms), // Show platform icons
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: isLargeCard ? 3 : 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                // Shorten genres if needed
                Text(
                  'Genres: ${_shortenGenres(genres)}',
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.star, color: Colors.amber, size: 16), // Star icon for rating
                    const SizedBox(width: 4),
                    Text(
                      rating.toString(),
                      style: const TextStyle(color: Colors.white),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.center,
                  child: IconButton(
                    icon: const Icon(Icons.favorite_border, color: Colors.white),
                    onPressed: () {},
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
    );
  }

  // Function to build platform icons
  List<Widget> _buildPlatformIcons(List<String> platforms) {
    List<Widget> platformIcons = [];

    for (int i = 0; i < platforms.length; i++) {
      if (i >= 4) { // Show a "more" icon if there are more than 3 platforms
        platformIcons.add(const Icon(Icons.more_horiz, color: Colors.white, size: 20));
        break;
      }

      switch (platforms[i]) {
        case 'PlayStation 4':
          platformIcons.add(const Icon(FontAwesomeIcons.playstation, color: Colors.white, size: 20));
          break;
        case 'PlayStation 5':
          platformIcons.add(const Icon(FontAwesomeIcons.playstation, color: Colors.white, size: 20));
          break;
        case 'Xbox One':
          platformIcons.add(const Icon(FontAwesomeIcons.xbox, color: Colors.white, size: 20));
          break;
        case 'Xbox Series S/X':
          platformIcons.add(const Icon(FontAwesomeIcons.xbox, color: Colors.white, size: 20));
          break;
        case 'PC':
          platformIcons.add(const Icon(FontAwesomeIcons.windows, color: Colors.white, size: 20));
          break;
        case 'Nintendo Switch':
          platformIcons.add(const Icon(FontAwesomeIcons.gamepad, color: Colors.white, size: 20));
          break;
        case 'Nintendo 3DS':
          platformIcons.add(const Icon(FontAwesomeIcons.gamepad, color: Colors.white, size: 20));
          break;
        case 'Nintendo DS':
          platformIcons.add(const Icon(FontAwesomeIcons.gamepad, color: Colors.white, size: 20));
          break;
        case 'Nintendo DSi':
          platformIcons.add(const Icon(FontAwesomeIcons.gamepad, color: Colors.white, size: 20));
          break;
        case 'macOS':
          platformIcons.add(const Icon(FontAwesomeIcons.computer, color: Colors.white, size: 20));
          break;
        case 'Android':
          platformIcons.add(const Icon(FontAwesomeIcons.android, color: Colors.white, size: 20));
          break;
        case 'iOS':
          platformIcons.add(const Icon(FontAwesomeIcons.apple, color: Colors.white, size: 20));
          break;
      // Add more cases for other platforms if needed
        default:
          platformIcons.add(const Icon(Icons.devices_other, color: Colors.white, size: 20));
      }
    }

    return platformIcons;
  }

  // Function to shorten the genres string
  String _shortenGenres(String genres) {
    List<String> genresList = genres.split(', ');

    if (genresList.length > 3) {
      return genresList.sublist(0, 3).join(', ') + '...'; // Show only first 3 genres
    }

    return genres;
  }
}


class ShimmerGameCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[700]!,
      highlightColor: Colors.grey[500]!,
      child: Card(
        color: const Color(0xFF2C2C2C),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.0),
        ),
        elevation: 6,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AspectRatio(
              aspectRatio: 16 / 9,
              child: Container(
                color: Colors.grey[800],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: double.infinity,
                    height: 20,
                    color: Colors.grey[800],
                  ),
                  const SizedBox(height: 10),
                  Container(
                    width: 100,
                    height: 14,
                    color: Colors.grey[800],
                  ),
                  const SizedBox(height: 10),
                  Container(
                    width: 150,
                    height: 14,
                    color: Colors.grey[800],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
