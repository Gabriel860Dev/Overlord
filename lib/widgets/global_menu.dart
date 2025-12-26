import 'package:flutter/material.dart';

class GlobalMenu extends StatelessWidget {
  final VoidCallback onClearHistory;
  final VoidCallback onAddNewDie;
  final VoidCallback onHelp;
  final VoidCallback onAbout;
  final VoidCallback onRateApp;

  const GlobalMenu({
    super.key,
    required this.onClearHistory,
    required this.onAddNewDie,
    required this.onHelp,
    required this.onAbout,
    required this.onRateApp,
  });

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.more_vert),
      onSelected: (String result) {
        switch (result) {
          case 'Apagar histórico':
            onClearHistory();
            break;
          case 'Adicionar novo dado':
            onAddNewDie();
            break;
          case 'Ajuda':
            onHelp();
            break;
          case 'Sobre':
            onAbout();
            break;
          case 'Avaliar app':
            onRateApp();
            break;
        }
      },
      itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
        const PopupMenuItem<String>(
          value: 'Apagar histórico',
          child: Text('Apagar histórico'),
        ),
        const PopupMenuItem<String>(
          value: 'Adicionar novo dado',
          child: Text('Adicionar novo dado'),
        ),
        const PopupMenuItem<String>(
          value: 'Ajuda',
          child: Text('Ajuda'),
        ),
        const PopupMenuItem<String>(
          value: 'Sobre',
          child: Text('Sobre'),
        ),
        const PopupMenuItem<String>(
          value: 'Avaliar app',
          child: Text('Avaliar app'),
        ),
      ],
    );
  }
}