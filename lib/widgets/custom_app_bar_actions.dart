import 'package:flutter/material.dart';
import 'package:overlord/widgets/global_menu.dart';
import 'package:overlord/models/character_sheet.dart'; // Import necessário

class CustomAppBarActions extends StatelessWidget {
  final VoidCallback onClearHistory;
  final VoidCallback onAddNewDie;
  final VoidCallback onHelp;
  final VoidCallback onAbout;
  final VoidCallback onRateApp;
  final List<CharacterSheet> sheets; // <--- ADICIONE ISTO

  const CustomAppBarActions({
    super.key,
    required this.onClearHistory,
    required this.onAddNewDie,
    required this.onHelp,
    required this.onAbout,
    required this.onRateApp,
    required this.sheets, // <--- ADICIONE ISTO
  });

  @override
  Widget build(BuildContext context) {
    return GlobalMenu(
      onClearHistory: onClearHistory,
      onAddNewDie: onAddNewDie,
      onHelp: onHelp,
      onAbout: onAbout,
      onRateApp: onRateApp,
      sheets: sheets, onConnect: () {  }, onSettings: () {  }, // <--- PASSE ADIANTE AQUI
    );
  }
}