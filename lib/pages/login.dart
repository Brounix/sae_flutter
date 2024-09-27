import 'dart:convert';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_svg/flutter_svg.dart';
import 'package:sae_flutter/pages/splash_screen.dart';
import 'package:url_launcher/url_launcher.dart';

import '../main.dart';
import 'game_list.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false; // Add a loading state variable

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/background.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Title: RAWG logo
                  SvgPicture.asset(
                    'assets/rawg.svg',
                    height: 50,
                    color: Colors.white,
                  ),
                  const SizedBox(height: 40),

                  // mail input
                  TextFormField(
                    controller: _emailController,
                    style: const TextStyle(color: Color(0xFFFFFFFF)),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: const Color(0xFF252222),
                      labelText: 'Mail',
                      labelStyle: const TextStyle(color: Color(0xFF7E7E7E)),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your username';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Password input
                  TextFormField(
                    controller: _passwordController,
                    obscureText: true,
                    style: const TextStyle(color: Color(0xFFFFFFFF)),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: const Color(0xFF252222),
                      labelText: 'Password',
                      labelStyle: const TextStyle(color: Color(0xFF7E7E7E)),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your password';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Login button with loading indicator
                  ElevatedButton(
                    onPressed: _isLoading
                        ? null // Disable button while loading
                        : () {
                      if (_formKey.currentState!.validate()) {
                        _login();
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF3D3D3D),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 100,
                        vertical: 16,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                    child: _isLoading
                        ? const CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(
                          Colors.white), // Set loading indicator color
                    )
                        : const Text('Login',
                        style: TextStyle(
                            fontSize: 16, color: Color(0xFF7E7E7E))),
                  ),
                  const SizedBox(height: 20),

                  RichText(
                    text: TextSpan(
                      text: 'Not registered yet? ',
                      style: const TextStyle(color: Colors.white),
                      children: [
                        WidgetSpan(
                          child: InkWell(
                            onTap: () async {
                              await launchUrl(
                                  Uri.parse("https://rawg.io/signup"));
                            },
                            child: const Text(
                              'Register',
                              style: TextStyle(
                                color: Colors.blue,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _login() async {
    setState(() {
      _isLoading = true;
    });

    await Future.delayed(const Duration(seconds: 2));

    final response = await http.post(
      Uri.parse('https://rawg.io/api/auth/login'),
      headers: {
        'User-Agent': 'sae_flutter/1.0.0',
      },
      body: {
        'email': _emailController.text,
        'password': _passwordController.text,
      },
    );

    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(response.body);
      final apiKey = jsonResponse['key'];

      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => MainPage()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invalid credentials')),
      );
    }

    setState(() {
      _isLoading = false; // Hide loading indicator
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}