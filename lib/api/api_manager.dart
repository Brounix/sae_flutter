import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiManager {
  final String _baseUrl = 'api.rawg.io';
  final String _apiKey = '818d548ac16c461585d8de97929fa6ad';

  Future<dynamic> get(String endpoint, {Map<String, String>? params}) async {
    final Uri uri = Uri.https(_baseUrl, '/api/$endpoint', {
      'key': _apiKey,
      ...?params,
    });

    print('Fetching URL: $uri');

    final Map<String, String> requestHeaders = {
      'User-Agent': 'sae_flutter/1.0.0',
      'Content-Type': 'application/json',
    };

    try {
      final response = await http.get(uri, headers: requestHeaders).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw Exception('Request timed out');
        },
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        print('GET request failed: ${response.statusCode} | Body: ${response.body}');
        throw Exception('Failed to fetch data: ${response.statusCode}');
      }
    } catch (e) {
      print('Request error: $e');
      throw Exception('Failed to fetch data');
    }
  }


  Future<dynamic> getUser(String endpoint, {required String token, Map<String, String>? params}) async {
    final Uri uri = Uri.https(_baseUrl, '/api/$endpoint', {
      'key': _apiKey,
      ...?params,
    });

    final Map<String, String> requestHeaders = {
      'User-Agent': 'sae_flutter/1.0.0',
      'Content-Type': 'application/json',
      'token': 'Token $token',
    };

    final response = await http.get(uri, headers: requestHeaders).timeout(
      const Duration(seconds: 10),
      onTimeout: () {
        throw Exception('Request timed out');
      },
    );


    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      print('GET request failed: ${response.statusCode}, Error: ${response.body}');
      throw Exception('Failed to fetch user data');
    }
  }

  Future<dynamic> post(
      String endpoint, {
        required String token,
        Map<String, dynamic>? body,
      }) async {
    final Uri uri = Uri.https(_baseUrl, '/api/$endpoint', {
      'key': _apiKey,
    });

    final Map<String, String> requestHeaders = {
      'User-Agent': 'sae_flutter/1.0.0',
      'Content-Type': 'application/json',
      'token': 'Token $token',
    };

    final response = await http.post(
      uri,
      headers: requestHeaders,
      body: jsonEncode(body),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      print('POST request failed: ${response.statusCode}');
      throw Exception('Failed to post data');
    }
  }

  Future<dynamic> postAuth(
      String endpoint, {
        Map<String, dynamic>? body,
      }) async {
    final Uri uri = Uri.https(_baseUrl, '/api/$endpoint', {
    });

    final Map<String, String> requestHeaders = {
      'User-Agent': 'sae_flutter/1.0.0',
      'Content-Type': 'application/json',
    };

    final response = await http.post(
      uri,
      headers: requestHeaders,
      body: jsonEncode(body),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      print('POST request failed: ${response.statusCode}');
      throw Exception('Failed to post data');
    }
  }


}
