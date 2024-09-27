import 'package:flutter/material.dart';
import 'package:sae_flutter/pages/creation.dart';
import 'package:sae_flutter/pages/favorite.dart';
import 'package:sae_flutter/pages/follows.dart';
import 'package:sae_flutter/pages/game_list.dart';
import 'package:sae_flutter/pages/profile.dart';
import 'package:sae_flutter/widget/bottom_bar.dart';

class MainPage extends StatefulWidget {
  const MainPage({Key? key}) : super(key: key);

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _selectedIndex = 2; // Default selected index

  final List<Widget> _pages = [
    const FavoritesPage(),
    const FollowsPage(),
    const GameListPage(),
    const CreationPage(),
    const ProfilePage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),
      extendBody: true,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: SizedBox(
        height: 80,
        width: 80,
        child: FloatingActionButton(
          shape: const CircleBorder(),
          backgroundColor: const Color(0xFF252222),
          onPressed: () {
            setState(() {
              _selectedIndex = 2;
            });
          },
          child: Icon(
            Icons.add,
            size: 36,
            color: _selectedIndex == 2 ? Colors.white : Colors.grey,
          ),
        ),
      ),
      bottomNavigationBar: MyBottomBar(
        selectedIndex: _selectedIndex,
        onItemTapped: _onItemTapped,
      ),
    );
  }
}