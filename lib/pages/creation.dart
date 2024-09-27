import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import '../widget/bottom_bar.dart'; // Import your bottom bar

@RoutePage()
class CreationPage extends StatelessWidget {
  const CreationPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Creation'), // Customize the title
      ),
      body: const Center(
        child: Text(
          'Creation Page Content',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}