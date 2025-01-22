import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:shimmer/shimmer.dart';

import '../../data_source/api_key_manager.dart';
import '../../data_source/api_manager.dart';
import '../../repo/game_repository.dart';
import '../game_details.dart';

class GameCard extends StatefulWidget {
  final String gameId;
  final String title;
  final String imageUrl;
  final String genres;
  final double rating;
  final List<String> platforms;
  final bool isLargeCard;
  final Function? onFavoriteChanged;

  const GameCard({
    required this.gameId,
    required this.title,
    required this.imageUrl,
    required this.genres,
    required this.rating,
    required this.platforms,
    required this.isLargeCard,
    this.onFavoriteChanged,
  });

  @override
  _GameCardState createState() => _GameCardState();
}

class _GameCardState extends State<GameCard> {
  String? apiKey = ApiKeyManager().apiKey;
  String? globalApiKey = '818d548ac16c461585d8de97929fa6ad';
  Set<String> favoriteGameIds = {};
  Set<String> userGameIds = {};
  bool isLoading = true;
  String? username;
  final GameRepository _gameRepository = GameRepository(
    ApiManager(),
  );
  late final Function onFavoriteChanged;

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  Future<void> _initializeData() async {
    if (!mounted) return;
    await _fetchFavoriteGames();
    await _fetchUserGames();
    if (mounted) {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _fetchFavoriteGames() async {
    try {
      final favorites = await _gameRepository.getFavoriteGameIds();
      if (mounted) {
        setState(() {
          favoriteGameIds = favorites;
        });
      }
    } catch (e) {
      print('Error fetching favorite games: $e');
    }
  }

  Future<void> _fetchUserGames() async {
    try {
      final userGames = await _gameRepository.getUserGames();
      if (mounted) {
        setState(() {
          userGameIds = userGames;
        });
      }
    } catch (e) {
      print('Error fetching user games: $e');
    }
  }

  Future<void> _toggleFavorite(String gameId, String slug) async {
    final isFavorite = favoriteGameIds.contains(gameId);
    await _gameRepository.toggleFavoriteGame(
        gameId, isFavorite, slug);
    await _fetchFavoriteGames();
  }

  Future<void> _toggleUserGame(String gameId) async {
    final isInLibrary = userGameIds.contains(gameId);
    await _gameRepository.toggleUserGame(gameId, isInLibrary);
    await _fetchUserGames();
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return ShimmerGameCard();
    }

    bool isFavorite = favoriteGameIds.contains(widget.gameId);
    bool isUserGame = userGameIds.contains(widget.gameId);

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
                            await _toggleUserGame(widget.gameId);
                          }),
                      IconButton(
                        icon: Icon(
                          isFavorite ? Icons.favorite : Icons.favorite_border,
                          color: Colors.white,
                        ),
                        onPressed: () async {
                          await _toggleFavorite(widget.gameId, widget.title);
                          widget.onFavoriteChanged!();
                          setState(() {
                            isFavorite = !isFavorite;
                          });

                        },
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
      if (i >= 4) {
        // Show a "more" icon if there are more than 3 platforms
        platformIcons
            .add(const Icon(Icons.more_horiz, color: Colors.white, size: 20));
        break;
      }

      switch (platforms[i]) {
        case 'PlayStation 4':
          platformIcons.add(const Icon(FontAwesomeIcons.playstation,
              color: Colors.white, size: 20));
          break;
        case 'PlayStation 5':
          platformIcons.add(const Icon(FontAwesomeIcons.playstation,
              color: Colors.white, size: 20));
          break;
        case 'Xbox One':
          platformIcons.add(
              const Icon(FontAwesomeIcons.xbox, color: Colors.white, size: 20));
          break;
        case 'Xbox Series S/X':
          platformIcons.add(
              const Icon(FontAwesomeIcons.xbox, color: Colors.white, size: 20));
          break;
        case 'PC':
          platformIcons.add(const Icon(FontAwesomeIcons.windows,
              color: Colors.white, size: 20));
          break;
        case 'Nintendo Switch':
          platformIcons.add(const Icon(FontAwesomeIcons.gamepad,
              color: Colors.white, size: 20));
          break;
        case 'Nintendo 3DS':
          platformIcons.add(const Icon(FontAwesomeIcons.gamepad,
              color: Colors.white, size: 20));
          break;
        case 'Nintendo DS':
          platformIcons.add(const Icon(FontAwesomeIcons.gamepad,
              color: Colors.white, size: 20));
          break;
        case 'Nintendo DSi':
          platformIcons.add(const Icon(FontAwesomeIcons.gamepad,
              color: Colors.white, size: 20));
          break;
        case 'macOS':
          platformIcons.add(const Icon(FontAwesomeIcons.computer,
              color: Colors.white, size: 20));
          break;
        case 'Android':
          platformIcons.add(const Icon(FontAwesomeIcons.android,
              color: Colors.white, size: 20));
          break;
        case 'iOS':
          platformIcons.add(const Icon(FontAwesomeIcons.apple,
              color: Colors.white, size: 20));
          break;
        // Add more cases for other platforms if needed
        default:
          platformIcons.add(
              const Icon(Icons.devices_other, color: Colors.white, size: 20));
      }
    }

    return platformIcons;
  }

  // Function to shorten the genres string
  String _shortenGenres(String genres) {
    List<String> genresList = genres.split(', ');

    if (genresList.length > 3) {
      return genresList.sublist(0, 3).join(', ') +
          '...'; // Show only first 3 genres
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
