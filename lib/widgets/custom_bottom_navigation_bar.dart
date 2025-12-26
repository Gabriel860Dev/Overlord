// lib/widgets/custom_bottom_navigation_bar.dart

import 'package:flutter/material.dart';

class CustomBottomNavigationBar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onTabTapped;

  const CustomBottomNavigationBar({
    super.key,
    required this.selectedIndex,
    required this.onTabTapped,
  });

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: selectedIndex,
      selectedItemColor: Colors.white,
      backgroundColor: Colors.grey[850],
      unselectedItemColor: Colors.grey,
      onTap: onTabTapped,
      items: [
        BottomNavigationBarItem(
          icon: Image.asset('assets/icons/ic_action_tabletop_white.png', height: 24, color: selectedIndex == 0 ? Colors.white : Colors.grey),
          label: 'Mesa',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.history, color: selectedIndex == 1 ? Colors.white : Colors.grey),
          label: 'Histórico',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person, color: selectedIndex == 2 ? Colors.white : Colors.grey),
          label: 'Fichas',
        ),
      ],
      type: BottomNavigationBarType.fixed,
    );
  }
}