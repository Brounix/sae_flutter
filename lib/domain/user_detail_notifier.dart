import 'package:flutter/material.dart';

class SelectedUserNotifier extends ChangeNotifier {
  Map<String, dynamic>? _selectedUser;

  Map<String, dynamic>? get selectedUser => _selectedUser;

  void selectUser(Map<String, dynamic> user) {
    _selectedUser = user;
    notifyListeners();
  }

  void clearSelectedUser() {
    _selectedUser = null;
    notifyListeners();
  }
}
