import 'package:flutter/material.dart';
import '../repo/user_repository.dart';

class FollowingNotifier extends ChangeNotifier {
  final UserRepository userRepository;

  List<dynamic> following = [];
  bool isLoading = false;
  String errorMessage = '';

  FollowingNotifier(this.userRepository);

  Future<void> fetchFollowing() async {
    print('Pad de route API');
  }

  void _setLoading(bool value) {
    isLoading = value;
    notifyListeners();
  }
}
