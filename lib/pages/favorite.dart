import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:sae_flutter/widget/bottom_bar.dart';
import 'package:sae_flutter/widget/card_game.dart';
import 'package:shimmer/shimmer.dart';
import '../ApiKeyManager.dart';
import 'game_list.dart';

class FavoritesPage extends StatefulWidget {
  const FavoritesPage({Key? key}) : super(key: key);

  @override
  _FavoritesPageState createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {
  List<dynamic> games = [];
  bool isLoading = false;
  String? apiKey = ApiKeyManager().apiKey;

  @override
  void initState() {
    super.initState();
    _fetchGames();
  }

  Future<void> _fetchGames() async {
    setState(() {
      isLoading = true;
    });

    final response = await http.get(
      Uri.parse('https://api.rawg.io/api/users/current/favorites'),
      headers: {
        'User-Agent': 'sae_flutter/1.0.0',
        'token': 'Token $apiKey',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body)['results'] ?? [];
      setState(() {
        games = data;
        isLoading = false;
      });
    } else {
      print('Failed to fetch favorite games');
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF303030),
      body: Column(
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Your Favorites Games',
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
                'Games you like',
                style: TextStyle(color: Colors.grey),
              ),
            ),
          ),
          Expanded(
            child: games.isEmpty && !isLoading
                ? Center(
                  child: Text(
                    "No favorites here !",
                    style: TextStyle(color: Colors.white, fontSize: 18),
                  ),
                )
                : MasonryGridView.count(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                crossAxisCount: 2,
                itemCount: games.length + 1,
                itemBuilder: (context, index) {
                  if (index < games.length) {
                    final game = games[index];

                    if (game == null) {
                      return Container();
                    }

                    bool isLargeCard = game['name'].length > 20 || (game['genres'] as List).length > 3;
                    final platforms = (game['platforms'] as List)
                        .map<String>((platform) => platform['platform']['name'].toString())
                        .toList();
                    final rating = game['rating'] ?? 0.0;

                    return GameCard(
                      game: game,
                      gameId: game['id'].toString(),
                      title: game['name'] ?? 'Titre non disponible',
                      imageUrl: game['background_image'] ?? '',
                      genres: (game['genres'] as List?)?.map((genre) => genre['name']).join(', ') ?? 'Genres non disponibles',
                      rating: rating,
                      platforms: platforms,
                      isLargeCard: isLargeCard,
                    );
                  } else {
                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => GameListPage()),
                        );
                      },
                      child: Container(
                        height: 200,
                        decoration: BoxDecoration(
                          color: Colors.grey[900],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Center(
                          child: Icon(Icons.add, color: Colors.white, size: 50),
                        ),
                      ),
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
