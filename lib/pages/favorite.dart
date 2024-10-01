import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:sae_flutter/widget/bottom_bar.dart';
import 'package:sae_flutter/widget/card_game.dart';
import 'package:shimmer/shimmer.dart';

class FavoritesPage extends StatefulWidget {
  const FavoritesPage({Key? key}) : super(key: key);

  @override
  _FavoritesPageState createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {
  List<dynamic> games = [];
  int currentPage = 1;
  bool isLoading = false;
  String apiKey = '';
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    apiKey = '4807c08683494754b36d62164f04e35c'; // Replace with your actual API key
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

    final username = 'Brounix';
    final response = await http.get(Uri.parse(
        'https://api.rawg.io/api/users/$username/favorites?key=$apiKey&page=$currentPage'));

    if (response.statusCode == 200) {
      setState(() {
        games.addAll(jsonDecode(response.body)['results']);
        currentPage++;
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
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const TextField(
          decoration: InputDecoration(
            hintText: 'Search',
            prefixIcon: Icon(Icons.search, color: Colors.white),
            border: InputBorder.none,
            filled: true,
            fillColor: Color(0xFF2C2C2C),
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
          // ... order by and text widgets (same as GameListPage)

          Expanded(
            child: MasonryGridView.count(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              crossAxisCount: 2,
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
                    rating: rating,
                    platforms: platforms,
                    isLargeCard: isLargeCard,
                  );
                } else if (isLoading) {
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