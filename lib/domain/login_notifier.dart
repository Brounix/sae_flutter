import 'package:flutter/material.dart';
import '../api/user_repository.dart';

class LoginNotifier extends ChangeNotifier {
  final UserRepository _userRepository;

  LoginNotifier(this._userRepository);

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      final success = await _userRepository.auth(email, password);
      _isLoading = false;
      notifyListeners();
      return success;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      print('Login error: $e');
      return false;
    }
  }
}
