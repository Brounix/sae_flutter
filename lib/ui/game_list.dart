import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:sae_flutter/ui/widget/card_game.dart';
import 'package:sae_flutter/ui/widget/search_bar.dart';

import '../domain/game_list_notifier.dart';

class GameListPage extends StatefulWidget {
  const GameListPage({super.key});

  @override
  _GameListPageState createState() => _GameListPageState();
}

class _GameListPageState extends State<GameListPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.
    addPostFrameCallback((_) {
      final notifier = Provider.of<GameListNotifier>(context, listen: false);
      notifier.fetchGames();
    });
  }

  @override
  Widget build(BuildContext context) {
    final notifier = Provider.of<GameListNotifier>(context);

    return Scaffold(
      backgroundColor: const Color(0xFF303030),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ExpandableSearchBar(
              onFilterChanged: (orderBy, genre, platform) {
                notifier.updateFilters(orderBy, genre, platform);
              },
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
            child: Consumer<GameListNotifier>(
              builder: (context, notifier, child) {
                return RefreshIndicator(
                  onRefresh: notifier.reloadGames,
                  child: notifier.games.isEmpty
                      ? Center(
                    child: notifier.isLoading
                        ? const CircularProgressIndicator()
                        : const Text(
                      'No games found',
                      style: TextStyle(color: Colors.white),
                    ),
                  )
                      : MasonryGridView.count(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16.0,
                    mainAxisSpacing: 16.0,
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    controller: ScrollController()
                      ..addListener(() {
                        if (!notifier.isLoading &&
                            notifier.currentPage > 1 &&
                            notifier.games.isNotEmpty) {
                          notifier.fetchGames();
                        }
                      }),
                    itemCount: notifier.games.length,
                    itemBuilder: (context, index) {
                      final game = notifier.games[index];
                      bool isLargeCard = game['name'].length > 20 ||
                          (game['genres'] as List).length > 3;

                      final platforms = (game['platforms'] as List)
                          .map<String>((platform) =>
                          platform['platform']['name'].toString())
                          .toList();
                      final rating = game['rating'] ?? 0.0;

                      return GameCard(
                        gameId: game['id'].toString(),
                        title: game['name'],
                        imageUrl: game['background_image'] ?? '',
                        genres: (game['genres'] as List)
                            .map((genre) => genre['name'])
                            .join(', '),
                        rating: rating,
                        platforms: platforms,
                        isLargeCard: isLargeCard,
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
