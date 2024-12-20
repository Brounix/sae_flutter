import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../api/api_manager.dart';
import '../api/game_repository.dart';
import '../domain/game_detail_notifier.dart';

class GameDetailPage extends StatelessWidget {
  final String gameId;

  const GameDetailPage({Key? key, required this.gameId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => GameDetailNotifier(GameRepository(ApiManager()))
        ..fetchGameDetails(gameId),
      child: Scaffold(
        backgroundColor: const Color(0xFF303030),
        appBar: AppBar(
          title: const Text(
            'Game Details',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: const Color(0xFF252222),
        ),
        body: Consumer<GameDetailNotifier>(
          builder: (context, notifier, child) {
            if (notifier.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (notifier.gameDetails == null) {
              return const Center(
                child: Text(
                  'Failed to load game details',
                  style: TextStyle(color: Colors.white),
                ),
              );
            }

            return _buildGameDetailContent(context, notifier);
          },
        ),
      ),
    );
  }

  Widget _buildGameDetailContent(
      BuildContext context, GameDetailNotifier notifier) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildScreenshotCarousel(notifier.screenshots),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  notifier.gameDetails['name'],
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  'Release Date: ${notifier.gameDetails['released']}',
                  style: const TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 10),
                const Divider(color: Colors.white24),
                const SizedBox(height: 10),
                const Text(
                  'About',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFFFFFFF),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  notifier.gameDetails['description_raw'] ??
                      'No description available',
                  style: const TextStyle(color: Colors.white),
                ),
                const SizedBox(height: 20),
                const Divider(color: Colors.white24),
                const SizedBox(height: 10),
                Text(
                  'Genres: ${_getListAsString(notifier.gameDetails['genres'])}',
                  style: const TextStyle(color: Colors.white),
                ),
                Text(
                  'Tags: ${_getListAsString(notifier.gameDetails['tags'])}',
                  style: const TextStyle(color: Colors.white),
                ),
                const SizedBox(height: 20),
                const Divider(color: Colors.white24),
                const SizedBox(height: 10),
                Text(
                  'Publisher: ${_getListAsString(notifier.gameDetails['publishers'])}',
                  style: const TextStyle(color: Colors.white),
                ),
                Text(
                  'Developer: ${_getListAsString(notifier.gameDetails['developers'])}',
                  style: const TextStyle(color: Colors.white),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScreenshotCarousel(List<dynamic>? screenshots) {
    if (screenshots == null || screenshots.isEmpty) {
      return const SizedBox.shrink();
    }

    return SizedBox(
      height: 200,
      child: PageView.builder(
        itemCount: screenshots.length,
        itemBuilder: (context, index) {
          final screenshot = screenshots[index];
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.network(
                screenshot['image'],
                fit: BoxFit.cover,
                width: double.infinity,
              ),
            ),
          );
        },
      ),
    );
  }

  String _getListAsString(List<dynamic> list) {
    return list.map((item) => item['name']).join(', ');
  }
}
