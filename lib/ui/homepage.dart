import 'package:flutter/material.dart';
import 'package:sae_flutter/ui/creation.dart';
import 'package:sae_flutter/ui/favorite.dart';
import 'package:sae_flutter/ui/game_list.dart';
import 'package:sae_flutter/ui/profile.dart';
import 'package:sae_flutter/ui/widget/bottom_bar.dart';

import 'neardy_user.dart';

class MainPage extends StatefulWidget {
  const MainPage({Key? key}) : super(key: key);

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _selectedIndex = 2;

  final List<Widget> _pages = [
    const FavoritesPage(),
    const NeardyUserPage(),
    const GameListPage(),
    const CreationPage(),
    ProfilePage(),
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
            Icons.list,
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