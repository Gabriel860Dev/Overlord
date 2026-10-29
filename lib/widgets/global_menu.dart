// lib/widgets/global_menu.dart

import 'package:flutter/material.dart';
import 'package:overlord/localization.dart';
import 'package:overlord/screens/saved_rolls_screen.dart';

class GlobalMenu extends StatelessWidget {
  final VoidCallback onClearHistory;
  final VoidCallback onAddNewDie;
  final VoidCallback onConnect;
  final VoidCallback onSettings;
  final VoidCallback onHelp;
  final VoidCallback onAbout;
  final VoidCallback onRateApp;

  const GlobalMenu({
    super.key,
    required this.onClearHistory,
    required this.onAddNewDie,
    required this.onConnect,
    required this.onSettings,
    required this.onHelp,
    required this.onAbout,
    required this.onRateApp,
    required List sheets, // Mantido para compatibilidade com o main.dart
  });

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);

    return PopupMenuButton<String>(
      icon: const Icon(Icons.more_vert),
      onSelected: (value) {
        if (value == 'clear_history') {
          onClearHistory();
        } else if (value == 'add_die') {
          onAddNewDie();
        } else if (value == 'connect') {
          onConnect();
        } else if (value == 'settings') {
          onSettings();
        } else if (value == 'help') {
          onHelp();
        } else if (value == 'about') {
          onAbout();
        } else if (value == 'rate') {
          onRateApp();
        } else if (value == 'saved_rolls') {
          // NOVO: Navega para a tela do Mural de Troféus
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const SavedRollsScreen()),
          );
        }
      },
      itemBuilder: (BuildContext context) {
        return [
          // MESA ONLINE
          PopupMenuItem<String>(
            value: 'connect',
            child: Row(
              children: [
                const Icon(Icons.wifi, color: Colors.green),
                const SizedBox(width: 8),
                Text(strings.get('connect_table') ?? 'Mesa Online'),
              ],
            ),
          ),
          
          // CONFIGURAÇÕES
          PopupMenuItem<String>(
            value: 'settings',
            child: Row(
              children: [
                const Icon(Icons.settings, color: Colors.grey),
                const SizedBox(width: 8),
                Text(strings.get('settings') ?? 'Configurações'),
              ],
            ),
          ),
          const PopupMenuDivider(),

          // MURAL DE TROFÉUS (NOVO)
          const PopupMenuItem<String>(
            value: 'saved_rolls',
            child: Row(
              children: [
                Icon(Icons.emoji_events, color: Colors.amber),
                SizedBox(width: 8),
                Text('Mural de Troféus', style: TextStyle(color: Colors.amber, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          
          // ADICIONAR DADO
          PopupMenuItem<String>(
            value: 'add_die',
            child: Row(
              children: [
                const Icon(Icons.add_box_outlined, color: Colors.grey),
                const SizedBox(width: 8),
                Text(strings.get('add_custom_die') ?? 'Adicionar Dado'),
              ],
            ),
          ),
          
          // LIMPAR HISTÓRICO
          PopupMenuItem<String>(
            value: 'clear_history',
            child: Row(
              children: [
                const Icon(Icons.delete_outline, color: Colors.grey),
                const SizedBox(width: 8),
                Text(strings.get('clear_history') ?? 'Limpar Histórico'),
              ],
            ),
          ),
          const PopupMenuDivider(),
          
          // AJUDA
          PopupMenuItem<String>(
            value: 'help',
            child: Row(
              children: [
                const Icon(Icons.help_outline, color: Colors.grey),
                const SizedBox(width: 8),
                Text(strings.get('help') ?? 'Ajuda'),
              ],
            ),
          ),
          
          // SOBRE
          PopupMenuItem<String>(
            value: 'about',
            child: Row(
              children: [
                const Icon(Icons.info_outline, color: Colors.grey),
                const SizedBox(width: 8),
                Text(strings.get('about') ?? 'Sobre'),
              ],
            ),
          ),
          
          // AVALIAR
          PopupMenuItem<String>(
            value: 'rate',
            child: Row(
              children: [
                const Icon(Icons.star_rate_outlined, color: Colors.grey),
                const SizedBox(width: 8),
                Text(strings.get('rate_app') ?? 'Avaliar App'),
              ],
            ),
          ),
        ];
      },
    );
  }
}