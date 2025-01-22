import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:provider/provider.dart';
import '../domain/creation_notifier.dart';
import '../ui/widget/search_bar.dart';
import '../ui/widget/card_game.dart';

class CreationPage extends StatefulWidget {
  const CreationPage({Key? key}) : super(key: key);

  @override
  _CreationPageState createState() => _CreationPageState();
}

class _CreationPageState extends State<CreationPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final notifier = Provider.of<CreationNotifier>(context, listen: false);
      notifier.fetchUserGames();
    });
  }

  @override
  Widget build(BuildContext context) {
    final creationNotifier = Provider.of<CreationNotifier>(context);

    return Scaffold(
      backgroundColor: const Color(0xFF303030),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ExpandableSearchBar(),
          ),
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
            child: RefreshIndicator(
              onRefresh: () async {
                creationNotifier.fetchUserGames();
              },
              child: creationNotifier.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : creationNotifier.userGames.isEmpty
                      ? const Center(
                          child: Text(
                            "No games here!",
                            style: TextStyle(color: Colors.white, fontSize: 18),
                          ),
                        )
                      : MasonryGridView.count(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          crossAxisCount: 2,
                          itemCount: creationNotifier.userGames.length,
                          itemBuilder: (context, index) {
                            final game = creationNotifier.userGames[index];
                            bool isLargeCard = game['name'].length > 20 ||
                                (game['genres'] as List).length > 3;
                            final platforms = (game['platforms'] as List)
                                .map<String>((platform) =>
                                    platform['platform']['name'].toString())
                                .toList();
                            final rating = game['rating'] ?? 0.0;

                            return GameCard(
                              gameId: game['id'].toString(),
                              title: game['name'] ?? 'Titre non disponible',
                              imageUrl: game['background_image'] ?? '',
                              genres: (game['genres'] as List?)
                                      ?.map((genre) => genre['name'])
                                      .join(', ') ??
                                  'Genres non disponibles',
                              rating: rating,
                              platforms: platforms,
                              isLargeCard: isLargeCard,
                            );
                          },
                          mainAxisSpacing: 10,
                          crossAxisSpacing: 10,
                        ),
            ),
          ),
          if (creationNotifier.errorMessage.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                creationNotifier.errorMessage,
                style: const TextStyle(color: Colors.red, fontSize: 16),
              ),
            ),
        ],
      ),
    );
  }
}
