import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';

import '../widget/bottom_bar.dart';

@RoutePage()
class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'This is the Profile Page',
              style: TextStyle(fontSize: 24),
            ),
            SizedBox(height: 20),
            Text(
              'You can add more content here',
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}