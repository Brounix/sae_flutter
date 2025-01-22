import 'package:flutter/material.dart';
import '../repo/game_repository.dart';

class FavoritesNotifier extends ChangeNotifier {
  final GameRepository gameRepository;

  List<dynamic> favoriteGames = [];
  bool isLoading = false;
  String errorMessage = '';

  FavoritesNotifier(this.gameRepository);

  Future<void> fetchFavorites() async {
    _setLoading(true);
    try {
      final games = await gameRepository.fetchFavorites();
      favoriteGames = games;
      errorMessage = '';
    } catch (e) {
      errorMessage = 'Error fetching favorite games: $e';
      favoriteGames = [];
    } finally {
      _setLoading(false);
    }
  }

  void refreshFavorites() {
    fetchFavorites();
  }

  void _setLoading(bool value) {
    isLoading = value;
    notifyListeners();
  }
}
