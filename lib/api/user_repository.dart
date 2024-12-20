import 'dart:convert';
import '../api/api_manager.dart';
import '../api/api_key_manager.dart';

class UserRepository {
  final ApiManager _apiManager;

  UserRepository(this._apiManager);

  Future<bool> auth(String email, String password) async {
    final Map<String, dynamic> body = {
      'email': email,
      'password': password,
    };

    try {
      final response = await _apiManager.postAuth(
        'auth/login',
        body: body,
      );

      if (response != null && response['key'] != null) {
        final apiKey = response['key'];

        await ApiKeyManager().setApiKey(apiKey);
        return true;
      } else {
        print('Auth failed: Missing API key in response');
        return false;
      }
    } catch (e) {
      print('Auth error: $e');
      throw Exception('Authentication failed: $e');
    }
  }

  Future<List<dynamic>> fetchFollowers() async {
    try {
      final response = await _apiManager.getUser(
        'users/current/followers',
        token: ApiKeyManager().apiKey!,
      );

      if (response['results'] != null) {
        final followers = response['results'] as List;
        print('Fetching followers : $followers');

        return followers.where((game) => game != null).toList();
      } else {
        print('No followers found in the response');
        return [];
      }
    } catch (e) {
      print('Error fetching followers : $e');
      throw Exception('Failed to fetch followers');
    }
  }

  Future<Map<String, dynamic>> fetchUserProfile() async {
    try {
      final response = await _apiManager.getUser(
        'users/current',
        token: ApiKeyManager().apiKey!,
      );

      return {
        'avatar': response['avatar'] ?? '',
        'email': response['email'] ?? 'Not Available',
        'name': response['full_name'] ?? 'Not Available',
        'username': response['username'] ?? 'Not Available',
        'bio': response['bio'] ?? 'No bio available',
        'followersCount': response['followers_count'] ?? 0,
        'followingCount': response['following_count'] ?? 0,
      };
    } catch (e) {
      print('Error fetching user profile: $e');
      throw Exception('Failed to fetch user profile');
    }
  }

  updateUserProfile(String field, String value) {}


}
