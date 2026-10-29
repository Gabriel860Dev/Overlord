// lib/widgets/custom_bottom_navigation_bar.dart

import 'package:flutter/material.dart';
import 'package:overlord/localization.dart';

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
    final theme = Theme.of(context);
    final strings = AppStrings.of(context);
    
    return BottomNavigationBar(
      currentIndex: selectedIndex,
      selectedItemColor: theme.bottomNavigationBarTheme.selectedItemColor ?? theme.colorScheme.primary,
      unselectedItemColor: theme.bottomNavigationBarTheme.unselectedItemColor ?? Colors.grey,
      backgroundColor: theme.bottomNavigationBarTheme.backgroundColor ?? theme.colorScheme.surface,
      onTap: onTabTapped,
      items: [
        BottomNavigationBarItem(
          icon: const Icon(Icons.casino), // Ícone de dado nativo para a aba da Mesa!
          label: strings.get('table'),
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.history),
          label: strings.get('history'),
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.person),
          label: strings.get('sheets'),
        ),
      ],
      type: BottomNavigationBarType.fixed,
    );
  }
}