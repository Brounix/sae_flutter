import 'package:flutter/material.dart';
import '../api/game_repository.dart';


class GameListNotifier extends ChangeNotifier {
  final GameRepository _gameRepository;

  List<dynamic> games = [];
  int currentPage = 1;
  bool isLoading = false;

  String? selectedOrderBy;
  List<String>? selectedGenres = [];
  List<String>? selectedPlatforms = [];

  GameListNotifier(this._gameRepository);

  Future<void> fetchGames() async {
    if (isLoading) return;

    isLoading = true;
    notifyListeners();

    try {
      final fetchedGames = await _gameRepository.fetchGames(
        page: currentPage,
        orderBy: selectedOrderBy,
        genres: selectedGenres,
        platforms: selectedPlatforms,
      );
      games.addAll(fetchedGames);
      currentPage++;
    } catch (e) {
      print('Error fetching games: $e');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> reloadGames() async {
    if (isLoading) return;

    currentPage = 1;
    games.clear();
    notifyListeners();

    await fetchGames();
  }

  void updateFilters(String? orderBy, String? genre, String? platform) {
    selectedOrderBy = orderBy;
    selectedGenres = genre != null ? [genre] : [];
    selectedPlatforms = platform != null ? [platform] : [];
    currentPage = 1;
    games.clear();
    notifyListeners();
    fetchGames();
  }
}