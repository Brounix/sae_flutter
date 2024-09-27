import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';

import '../widget/bottom_bar.dart';

@RoutePage()
class FollowsPage extends StatelessWidget {
  const FollowsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Follows'), // Customize the title
      ),
      body: const Center(
        child: Text(
          'Follows Page Content',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}