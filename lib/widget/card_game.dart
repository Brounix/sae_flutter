import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:shimmer/shimmer.dart';

import '../pages/game_details.dart';

class GameCard extends StatefulWidget {
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
  State<GameCard> createState() => _GameCardState();
}

class _GameCardState extends State<GameCard> {
  String apiKey = '4807c08683494754b36d62164f04e35c';
  Set<String> favoriteGameIds = {};
  Set<String> userGames = {};
  bool isLoading = true; // Add loading state
  String? username;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    username = await getUserData();
    if (username != null) {
      favoriteGameIds = await getFavoriteGameIds(username!);
      userGames = await getUserGames(username!);
    }
    setState(() {
      isLoading = false;
    });
  }

  Future<Set<String>> getFavoriteGameIds(String username) async {
    final response = await http.get(Uri.parse(
        'https://api.rawg.io/api/users/$username/favorites?key=$apiKey'));

    if (response.statusCode == 200) {
      final favoriteGames = jsonDecode(response.body)['results'] as List;
      return favoriteGames.map((game) => game['id'].toString()).toSet();
    } else {
      print('Failed to fetch favorite games');
      return {};
    }
  }

  Future<Set<String>> getUserGames(String username) async {
    final response = await http.get(Uri.parse(
        'https://api.rawg.io/api/users/$username/games?key=$apiKey'));

    if (response.statusCode == 200) {
      final userGamesData = jsonDecode(response.body)['results'] as List;
      return userGamesData.map((game) => game['id'].toString()).toSet();
    } else {
      print('Failed to fetch user games');
      return {};
    }
  }

  Future<String?> getUserData() async {
    const String apiUrl = 'https://api.rawg.io/api/users/current';

    final response = await http.get(
      Uri.parse(apiUrl),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Token $apiKey',
      },
    );

    if (response.statusCode == 200) {
      var userData = json.decode(response.body);

      if (userData != null && userData.containsKey('username')) {
        return userData['username'] as String?;
      } else {
        print('Le champ "username" est manquant');
        return null;
      }
    } else {
      print('Error fetching user data: ${response.statusCode}');
      return null;
    }
  }


  Future<void> toggleFavoriteGame(String username, String gameId, bool isFavorite) async {
    final String apiUrl = 'https://api.rawg.io/api/users/$username/favorites?key=$apiKey';

    final response = await http.post(
      Uri.parse(apiUrl),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Token $apiKey',
      },
      body: jsonEncode({
        'game_id': gameId,
        'action': isFavorite ? 'remove' : 'add',
      }),
    );

    print('API response: ${response.body}');  // Ajoute ceci pour voir la réponse de l'API

    if (response.statusCode == 200) {
      print(isFavorite ? 'Jeu retiré des favoris' : 'Jeu ajouté aux favoris');
    } else {
      print('Erreur lors de la modification des favoris : ${response.statusCode}');
    }
  }



  Future<void> toggleUserGame(String username, String gameId, bool isInLibrary) async {
    final String apiUrl = 'https://api.rawg.io/api/users/$username/games?key=$apiKey';

    final response = await http.post(
      Uri.parse(apiUrl),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Token $apiKey',
      },
      body: jsonEncode({
        'game_id': gameId,
        'action': isInLibrary ? 'remove' : 'add',
      }),
    );

    if (response.statusCode == 200) {
      print(isInLibrary ? 'Jeu retiré de la bibliothèque' : 'Jeu ajouté à la bibliothèque');
    } else {
      print('Erreur lors de la modification de la bibliothèque : ${response.statusCode}');
    }
  }


  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      // Show a loading indicator while data is being fetched
      return ShimmerGameCard();
    }

    bool isFavorite = favoriteGameIds.contains(widget.gameId);
    bool isUserGame = userGames.contains(widget.gameId);

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => GameDetailPage(
              gameId: widget.gameId,
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
              aspectRatio: widget.isLargeCard ? 16 / 10 : 16 / 9,
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(16.0),
                      topRight: Radius.circular(16.0),
                    ),
                    child: Image.network(
                      widget.imageUrl,
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
                      children: _buildPlatformIcons(widget.platforms),
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
                    widget.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: widget.isLargeCard ? 3 : 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Genres: ${_shortenGenres(widget.genres)}',
                    style: const TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.star, color: Colors.amber, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        widget.rating.toString(),
                        style: const TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      IconButton(
                        icon: Icon(
                          isUserGame
                              ? Icons.add_circle
                              : Icons.add_circle_outline,
                          color: Colors.white,
                        ),
                          onPressed: () async {
                            setState(() {
                              isUserGame = !isUserGame;
                            });
                            await toggleUserGame(username!, widget.gameId, isUserGame);
                          }

                      ),
                      IconButton(
                        icon: Icon(
                          isFavorite ? Icons.favorite : Icons.favorite_border,
                          color: Colors.white,
                        ),
                          onPressed: () async {
                            setState(() {
                              isFavorite = !isFavorite;
                            });
                            await toggleFavoriteGame(username!, widget.gameId, isFavorite);
                          }

                      ),
                    ],
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