import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:provider/provider.dart';
import '../domain/favorite_notifier.dart';
import '../ui/widget/search_bar.dart';
import '../ui/widget/card_game.dart';

class FavoritesPage extends StatefulWidget {
  const FavoritesPage({Key? key}) : super(key: key);

  @override
  _FavoritesPageState createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final notifier = Provider.of<FavoritesNotifier>(context, listen: false);
      notifier.fetchFavorites();
    });
  }

  @override
  Widget build(BuildContext context) {
    final favoritesNotifier = Provider.of<FavoritesNotifier>(context);

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
                'Your Favorite Games',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async {
                favoritesNotifier.refreshFavorites();
              },
              child: favoritesNotifier.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : favoritesNotifier.favoriteGames.isEmpty
                      ? const Center(
                          child: Text(
                            "No favorites here!",
                            style: TextStyle(color: Colors.white, fontSize: 18),
                          ),
                        )
                      : MasonryGridView.count(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          crossAxisCount: 2,
                          itemCount: favoritesNotifier.favoriteGames.length,
                          itemBuilder: (context, index) {
                            final game = favoritesNotifier.favoriteGames[index];
                            if (game == null) return Container();

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
                              onFavoriteChanged: () =>
                                  favoritesNotifier.refreshFavorites(),
                            );
                          },
                          mainAxisSpacing: 10,
                          crossAxisSpacing: 10,
                        ),
            ),
          ),
          if (favoritesNotifier.errorMessage.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                favoritesNotifier.errorMessage,
                style: const TextStyle(color: Colors.red, fontSize: 16),
              ),
            ),
        ],
      ),
    );
  }
}
