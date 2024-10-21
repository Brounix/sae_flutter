import 'package:shared_preferences/shared_preferences.dart';

class ApiKeyManager {
  static final ApiKeyManager _instance = ApiKeyManager._internal();

  factory ApiKeyManager() {
    return _instance;
  }

  ApiKeyManager._internal();

  String? _apiKey;

  Future<void> setApiKey(String apiKey) async {
    _apiKey = apiKey;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('apiKey', apiKey);
  }

  String? get apiKey => _apiKey;
}