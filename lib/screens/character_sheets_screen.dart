// lib/screens/character_sheets_screen.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:dark_age/models/character_sheet.dart';
import 'package:dark_age/models/dice_roll_handler.dart';
import 'package:dark_age/screens/new_character_sheet_form.dart';
import 'package:dark_age/widgets/custom_app_bar.dart';
import 'package:dark_age/widgets/global_menu.dart';

class CharacterSheetsScreen extends StatefulWidget {
  final Function(CharacterSheet) onSaveSheet;
  final Function(String) onDeleteSheet;
  final List<CharacterSheet> characterSheets;
  final VoidCallback onClearHistory;
  final VoidCallback onAddNewDie;
  final VoidCallback onHelp;
  final VoidCallback onAbout;
  final VoidCallback onRateApp;
  final DiceRollHandler onDiceRolledFromSheet;
  final void Function(String) showToast;

  const CharacterSheetsScreen({
    super.key,
    required this.onSaveSheet,
    required this.onDeleteSheet,
    required this.characterSheets,
    required this.onClearHistory,
    required this.onAddNewDie,
    required this.onHelp,
    required this.onAbout,
    required this.onRateApp,
    required this.onDiceRolledFromSheet,
    required this.showToast,
  });

  @override
  State<CharacterSheetsScreen> createState() => _CharacterSheetsScreenState();
}

class _CharacterSheetsScreenState extends State<CharacterSheetsScreen> {

  void _navigateAndEditSheet(CharacterSheet sheet) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => NewCharacterSheetForm(
          initialSheet: sheet,
          onSave: widget.onSaveSheet,
          onDiceRolledFromSheet: widget.onDiceRolledFromSheet,
          showToast: widget.showToast,
        ),
      ),
    );
  }

  void _navigateAndCreateSheet() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => NewCharacterSheetForm(
          onSave: widget.onSaveSheet,
          onDiceRolledFromSheet: widget.onDiceRolledFromSheet,
          showToast: widget.showToast,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[850],
      appBar: CustomAppBar(
        title: 'Overlord',
        subtitle: 'Fichas de Personagem',
        actions: [
          GlobalMenu(
            onClearHistory: widget.onClearHistory,
            onAddNewDie: widget.onAddNewDie,
            onHelp: widget.onHelp,
            onAbout: widget.onAbout,
            onRateApp: widget.onRateApp,
          ),
        ],
      ),
      body: widget.characterSheets.isEmpty
          ? const Center(
              child: Text(
                'Nenhuma ficha criada.\nToque em + para adicionar uma nova.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18, color: Colors.white),
              ),
            )
          : ListView.builder(
              itemCount: widget.characterSheets.length,
              itemBuilder: (context, index) {
                final sheet = widget.characterSheets[index];
                return Card(
                  color: Colors.grey[900],
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.grey[700],
                      backgroundImage: sheet.imagePath != null && File(sheet.imagePath!).existsSync()
                          ? FileImage(File(sheet.imagePath!))
                          : null,
                      child: sheet.imagePath == null || !File(sheet.imagePath!).existsSync()
                          ? const Icon(Icons.person, color: Colors.white)
                          : null,
                    ),
                    title: Text(sheet.name, style: const TextStyle(color: Colors.white)),
                    subtitle: Text(sheet.classe ?? 'Sem classe', style: const TextStyle(color: Colors.grey)),
                    onTap: () => _navigateAndEditSheet(sheet),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.redAccent),
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Excluir Ficha?'),
                            content: Text('Tem certeza que deseja excluir a ficha de ${sheet.name}?'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.of(context).pop(),
                                child: const Text('Cancelar'),
                              ),
                              TextButton(
                                onPressed: () {
                                  widget.onDeleteSheet(sheet.id);
                                  Navigator.of(context).pop();
                                },
                                child: const Text('Excluir'),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateAndCreateSheet,
        backgroundColor: Colors.blueAccent,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
