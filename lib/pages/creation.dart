import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import '../ApiKeyManager.dart';
import '../widget/card_game.dart';
import 'game_list.dart';

class CreationPage extends StatefulWidget {
  const CreationPage({Key? key}) : super(key: key);

  @override
  _CreationPageState createState() => _CreationPageState();
}

class _CreationPageState extends State<CreationPage> {
  List<dynamic> userGames = [];
  bool isLoading = false;
  String? apiKey = ApiKeyManager().apiKey;

  @override
  void initState() {
    super.initState();
    _fetchUserGames();
  }

  Future<void> _fetchUserGames() async {
    setState(() {
      isLoading = true;
    });

    final response = await http.get(
      Uri.parse('https://api.rawg.io/api/users/current/games'),
      headers: {
        'User-Agent': 'sae_flutter/1.0.0',
        'token': 'Token $apiKey',
      },
    );

    if (response.statusCode == 200) {
      setState(() {
        userGames = jsonDecode(response.body)['results'] ?? [];
        isLoading = false;
      });
    } else {
      print('Erreur lors de la récupération des jeux');
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
                'Your Games',
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
                'Games you played',
                style: TextStyle(color: Colors.grey),
              ),
            ),
          ),
          Expanded(
            child: userGames.isEmpty && !isLoading
                ? const Center(
                  child: Text(
                    "No games here !",
                    style: TextStyle(color: Colors.white, fontSize: 18),
                  ),
                )
                : MasonryGridView.count(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                crossAxisCount: 2,
                itemCount: userGames.length + 1,
                itemBuilder: (context, index) {
                  if (index < userGames.length) {
                    final game = userGames[index];

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
  String _getListAsString(List<dynamic> list) {
    return list.map((item) => item['name']).join(', ');
  }
}