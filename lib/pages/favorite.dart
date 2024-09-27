import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import '../widget/bottom_bar.dart';

@RoutePage()
class FavoritesPage extends StatelessWidget {
  const FavoritesPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Favorite'), // Customize the title
      ),
      body: const Center(
        child: Text(
          'Favorite Page Content',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}