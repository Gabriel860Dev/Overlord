import 'package:flutter/material.dart';
import 'package:dark_age/widgets/global_menu.dart';

class CustomAppBarActions extends StatelessWidget {
  final VoidCallback onClearHistory;
  final VoidCallback onAddNewDie;
  final VoidCallback onHelp;
  final VoidCallback onAbout;
  final VoidCallback onRateApp;

  const CustomAppBarActions({
    super.key,
    required this.onClearHistory,
    required this.onAddNewDie,
    required this.onHelp,
    required this.onAbout,
    required this.onRateApp,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        GlobalMenu(
          onClearHistory: onClearHistory,
          onAddNewDie: onAddNewDie,
          onHelp: onHelp,
          onAbout: onAbout,
          onRateApp: onRateApp,
        ),
      ],
    );
  }
}