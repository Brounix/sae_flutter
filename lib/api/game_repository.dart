import 'package:sae_flutter/api/api_key_manager.dart';
import 'package:sae_flutter/api/api_manager.dart';

class GameRepository {
  final ApiManager _apiManager;

  GameRepository(this._apiManager);


  Future<List<dynamic>> fetchGames({
    required int page,
    String? orderBy,
    List<String>? genres,
    List<String>? platforms,
  }) async {
    Map<String, String> params = {
      'page': page.toString(),
    };

    if (orderBy != null) {
      params['ordering'] = orderBy;
    }

    if (genres != null && genres.isNotEmpty) {
      params['genres'] = genres.join(',').toLowerCase();
    }

    if (platforms != null && platforms.isNotEmpty) {
      params['platforms'] = platforms.join(',').toLowerCase();
    }

    try {
      final response = await _apiManager.get('games', params: params);

      return response['results'] ?? [];
    } catch (e) {
      print('Error fetching games: $e');
      throw Exception('Failed to fetch games');
    }
  }

  Future<Map<String, dynamic>> fetchGameDetails(String gameId) async {
    try {
      final response = await _apiManager.get('games/$gameId');

      if (response is Map<String, dynamic>) {
        return response;
      } else {
        throw Exception('Unexpected response format: not a Map<String, dynamic>');
      }
    } catch (e) {
      print('Error fetching games details: $e');
      throw Exception('Failed to fetch game details');
    }
  }


  Future<List<dynamic>> fetchScreenshots(String gameId) async {
    try {
      final response = await _apiManager.get('games/$gameId/screenshots');

      return response['results'] ?? [];
    } catch (e) {
      print('Error fetching screens: $e');
      throw Exception('Failed to fetch screens');
    }
  }

  Future<List<dynamic>> fetchYouTubeVideos(String gameId) async {
    try {
      final response = await _apiManager.get('games/$gameId/youtube');

      return response['results'] ?? [];
    } catch (e) {
      print('Error fetching ytb: $e');
      throw Exception('Failed to fetch ytb');
    }
  }

  Future<List<dynamic>> fetchTwitchStreams(String gameId) async {
    try {
      final response = await _apiManager.get('games/$gameId/twitch');

      return response['results'] ?? [];
    } catch (e) {
      print('Error fetching twitch: $e');
      throw Exception('Failed to fetch twitch');
    }
  }




  Future<List<dynamic>> fetchFavorites() async {
    try {
      final response = await _apiManager.getUser(
        'users/current/favorites',
        token: ApiKeyManager().apiKey!,
      );

      if (response['results'] != null) {
        final favoriteGames = response['results'] as List;

        return favoriteGames.where((game) => game != null).toList();
      } else {
        print('No favorite games found in the response');
        return [];
      }
    } catch (e) {
      print('Error fetching favorite games: $e');
      throw Exception('Failed to fetch favorite games');
    }
  }

  Future<List<dynamic>> fetchUserGames() async {
    try {
      final response = await _apiManager.getUser(
        'users/current/games',
        token: ApiKeyManager().apiKey!,
      );

      if (response['results'] != null) {
        final favoriteGames = response['results'] as List;

        return favoriteGames.where((game) => game != null).toList();
      } else {
        print('No user games found in the response');
        return [];
      }
    } catch (e) {
      print('Error fetching user games: $e');
      throw Exception('Failed to fetch user games');
    }
  }



  Future<Set<String>> getFavoriteGameIds() async {
    print('Fetching favorite games...');
    try {
      final response = await _apiManager.getUser(
        'users/current/favorites',
        token: ApiKeyManager().apiKey!,
      );

      if (response['results'] != null) {
        final favoriteGames = response['results'] as List;

        final validGames = favoriteGames.where((game) => game != null).toList();

        if (validGames.isEmpty) {
          print('No valid games found.');
          return {};
        }

        return validGames.map((game) => game['id'].toString()).toSet();
      } else {
        print('No results found in the response');
        return {};
      }
    } catch (e) {
      print('Error fetching favorite games: $e');
      return {};
    }
  }

  Future<Set<String>> getUserGames() async {
    print('Fetching recent games...');
    try {
      final response = await _apiManager.getUser(
        'users/current/games',
        token: ApiKeyManager().apiKey!,
      );

      if (response['results'] != null) {
        final recentGames = response['results'] as List;

        final validGames = recentGames.where((game) => game != null).toList();

        if (validGames.isEmpty) {
          print('No valid recent games found.');
          return {};
        }

        return validGames.map((game) => game['id'].toString()).toSet();
      } else {
        print('No recent games found in the response');
        return {};
      }
    } catch (e) {
      print('Error fetching recent games: $e');
      return {};
    }
  }

  Future<void> toggleFavoriteGame(String gameId, bool isFavorite, slug) async {
    try {
      final response = await _apiManager.getUser(
        'users/current/favorites',
        token: ApiKeyManager().apiKey!,
      );

      final List<dynamic> favoriteGames = response['results'] ?? [];
      print('Liste actuelle des favoris : $favoriteGames');
      print('Jeu : $slug, $gameId');

      int gamePosition = -1;
      for (int i = 0; i < 7; i++) {
        if (favoriteGames[i] != null && favoriteGames[i]['name'] == slug) {
          gamePosition = i;
          break;
        }
      }

      if (isFavorite) {
        print('Le jeu est déjà dans les favoris à la position $gamePosition, suppression en cours...');

        final responseRemove = await _apiManager.post(
          'users/current/favorites',
          body: {
            'game': gameId,
            'action': 'remove',
            'position': gamePosition,
          },
          token: ApiKeyManager().apiKey!,
        );

        if (responseRemove != null) {
          print('Jeu retiré des favoris à la position $gamePosition.');
        } else {
          print('Erreur lors de la suppression des favoris.');
        }

        return;
      }

      int targetPosition = favoriteGames.indexOf(null);
      if (targetPosition == -1) {
        targetPosition = favoriteGames.length;
      }

      print('Ajout du jeu aux favoris à la position $targetPosition...');

      final responseAdd = await _apiManager.post(
        'users/current/favorites',
        body: {
          'game': gameId,
          'action': 'add',
          'position': targetPosition,
        },
        token: ApiKeyManager().apiKey!,
      );

      if (responseAdd != null) {
        print('Jeu ajouté aux favoris à la position $targetPosition.');
      } else {
        print('Erreur lors de l\'ajout aux favoris.');
      }
    } catch (e) {
      print('Erreur lors de la modification des favoris : $e');
    }
  }


  Future<void> toggleUserGame(String gameId, bool isInLibrary) async {
    try {
      final response = await _apiManager.post(
        'users/current/games',
        body: {
          'game': gameId,
        },
        token: ApiKeyManager().apiKey!,
      );

      if (response != null) {
        print(isInLibrary ? 'Jeu retiré des récents' : 'Jeu ajouté aux récents');
      } else {
        print('Erreur lors de la modification des récents');
      }
    } catch (e) {
      print('Error toggling user game: $e');
    }
  }
}
