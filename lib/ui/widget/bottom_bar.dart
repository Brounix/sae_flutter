import 'package:flutter/material.dart';

class MyBottomBar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemTapped;

  const MyBottomBar({
    Key? key,
    required this.selectedIndex,
    required this.onItemTapped,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.topCenter,
      children: [
        BottomAppBar(
          shape: const CircularNotchedRectangle(),
          notchMargin: 8.0,
          color: const Color(0xFF252222),
          child: SizedBox(
            height: 60.0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                IconButton(
                  icon: Icon(
                    Icons.favorite,
                    color: selectedIndex == 0 ? Colors.white : Colors.grey,
                  ),
                  onPressed: () {
                    onItemTapped(0);
                  },
                ),
                IconButton(
                  icon: Icon(
                    Icons.group_add_outlined,
                    color: selectedIndex == 1 ? Colors.white : Colors.grey,
                  ),
                  onPressed: () {
                    onItemTapped(1);
                  },
                ),
                const SizedBox(width: 40),
                IconButton(
                  icon: Icon(
                    Icons.add,
                    color: selectedIndex == 3 ? Colors.white : Colors.grey,
                  ),
                  onPressed: () {
                    onItemTapped(3);
                  },
                ),
                IconButton(
                  icon: Icon(
                    Icons.person_outline,
                    color: selectedIndex == 4 ? Colors.white : Colors.grey,
                  ),
                  onPressed: () {
                    onItemTapped(4);
                  },
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}