import 'package:flutter/material.dart';
import '../api/user_repository.dart';

class FollowersNotifier extends ChangeNotifier {
  final UserRepository userRepository;

  List<dynamic> followers = [];
  bool isLoading = false;
  String errorMessage = '';

  FollowersNotifier(this.userRepository);

  Future<void> fetchFollowers() async {
    _setLoading(true);
    try {
      final fetchedFollowers = await userRepository.fetchFollowers();
      followers = fetchedFollowers;
      errorMessage = '';
    } catch (e) {
      errorMessage = 'Error fetching followers: $e';
      followers = [];
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool value) {
    isLoading = value;
    notifyListeners();
  }
}
