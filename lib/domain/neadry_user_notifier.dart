import 'package:flutter/material.dart';
import '../data_source/api_manager.dart';
import '../model/geo_manager.dart';
import '../repo/firebase_repo.dart';
import '../repo/user_repository.dart';

class NearbyUsersNotifier extends ChangeNotifier {
  final FirebaseRepository _firebaseRepository = FirebaseRepository();
  final UserRepository _userRepository = UserRepository(ApiManager());

  List<Map<String, dynamic>> _nearbyUsers = [];
  String _errorMessage = '';
  bool _isLoading = false;

  List<Map<String, dynamic>> get nearbyUsers => _nearbyUsers;
  String get errorMessage => _errorMessage;
  bool get isLoading => _isLoading;

  Future<void> fetchNearbyUsers(double radiusInKm) async {
    print('fetchNearbyUsers started');
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      final userProfile = await _userRepository.fetchUserProfile();

      final userId = userProfile['username'];
      print('User ID: $userId');

      final position = await GeoManager().getUserLocation();

      if (position == null) {
        print('Error: Position is null');
        _errorMessage = "Impossible d'obtenir votre position. Vérifiez vos permissions.";
        return;
      }

      await _firebaseRepository.saveUserLocation(userId, position);

      final users = await _firebaseRepository.getNearbyUsers(position, radiusInKm);
      print('Nearby users fetched: $users');

      final List<Map<String, dynamic>> updatedUsers = [];
      for (var user in users) {
        print('Processing user: $user');
        try {
          final userProfile = await _userRepository.fetchUserProfileByUsername(user['id']);
          print('User profile fetched for ${user['id']}: $userProfile');
          updatedUsers.add({
            'avatar': userProfile['avatar'] ?? '',
            'username': userProfile['username'] ?? 'Unknown',
            'name': userProfile['name'] ?? 'Unknown',
          });
        } catch (e) {
          print('Error fetching user profile for ${user['id']}: $e');
          updatedUsers.add({
            'avatar': user['avatar'] ?? '',
            'username': user['username'] ?? 'Unknown',
            'name': 'Unknown',
          });
        }
      }

      _nearbyUsers = updatedUsers;

    } catch (e) {
      print('Error during fetchNearbyUsers: $e');
      _errorMessage = "Erreur lors de la récupération des utilisateurs proches : $e";
    } finally {
      print('fetchNearbyUsers finished');
      _isLoading = false;
      notifyListeners();
    }
  }
}
