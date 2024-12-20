import 'package:flutter/material.dart';
import 'package:sae_flutter/api/user_repository.dart';

class ProfileNotifier extends ChangeNotifier {
  final UserRepository gameRepository;

  String email = 'N/A';
  String name = 'N/A';
  String username = 'N/A';
  String bio = '';
  String avatarUrl = '';
  int followersCount = 0;
  int followingCount = 0;

  ProfileNotifier(this.gameRepository);

  Future<void> loadUserProfile() async {
    try {
      final userProfile = await gameRepository.fetchUserProfile();
      email = userProfile['email'];
      name = userProfile['name'];
      username = userProfile['username'];
      bio = userProfile['bio'];
      avatarUrl = userProfile['avatar'];
      followersCount = userProfile['followersCount'];
      followingCount = userProfile['followingCount'];
      notifyListeners();
    } catch (e) {
      print('Error loading user profile: $e');
    }
  }

  Future<void> updateUserProfile(String field, String value) async {
    try {
      await gameRepository.updateUserProfile(field, value);
      switch (field) {
        case 'email':
          email = value;
          break;
        case 'name':
          name = value;
          break;
        case 'username':
          username = value; 
          break;
        case 'bio':
          bio = value;
          break;
      }
      notifyListeners();
    } catch (e) {
      print('Error updating $field: $e');
    }
  }
}
