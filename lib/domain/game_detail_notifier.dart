import 'package:flutter/material.dart';

import '../api/game_repository.dart';

class GameDetailNotifier extends ChangeNotifier {
  final GameRepository _gameRepository;

  dynamic gameDetails;
  List<dynamic>? screenshots;
  List<dynamic>? youtubeVideos;
  List<dynamic>? twitchStreams;

  bool isLoading = false;

  GameDetailNotifier(this._gameRepository);

  Future<void> fetchGameDetails(String gameId) async {
    isLoading = true;
    notifyListeners();

    try {
      gameDetails = await _gameRepository.fetchGameDetails(gameId);

      screenshots = await _gameRepository.fetchScreenshots(gameId);

      // videos / streams
      // youtubeVideos = await _gameRepository.fetchYouTubeVideos(gameId);
      // twitchStreams = await _gameRepository.fetchTwitchStreams(gameId);
    } catch (error) {
      debugPrint('Error fetching game details: $error');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
