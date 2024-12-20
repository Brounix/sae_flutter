import 'package:flutter/material.dart';
import '../api/game_repository.dart';

class CreationNotifier extends ChangeNotifier {
  final GameRepository gameRepository;

  List<dynamic> userGames = [];
  bool isLoading = false;
  String errorMessage = '';

  CreationNotifier(this.gameRepository);

  Future<void> fetchUserGames() async {
    _setLoading(true);
    try {
      final fetchedGames = await gameRepository.fetchUserGames();
      userGames = fetchedGames;
      errorMessage = '';
    } catch (e) {
      errorMessage = 'Error fetching user games: $e';
      userGames = [];
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool value) {
    isLoading = value;
    notifyListeners();
  }
}
