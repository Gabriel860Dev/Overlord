// lib/screens/equipment_screen.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:dark_age/models/item.dart';
import 'package:dark_age/widgets/custom_app_bar.dart';
import 'package:dark_age/widgets/global_menu.dart';

class EquipmentScreen extends StatelessWidget {
  final List<Item> backpackItems;
  final VoidCallback onAddItem;
  final Function(Item) onEditItem;
  final Function(Item) onDeleteItem;
  final VoidCallback onClearHistory;
  final VoidCallback onAddNewDie;
  final VoidCallback onHelp;
  final VoidCallback onAbout;
  final VoidCallback onRateApp;

  const EquipmentScreen({
    super.key,
    required this.backpackItems,
    required this.onAddItem,
    required this.onEditItem,
    required this.onDeleteItem,
    required this.onClearHistory,
    required this.onAddNewDie,
    required this.onHelp,
    required this.onAbout,
    required this.onRateApp,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[850],
      appBar: CustomAppBar(
        title: 'Overlord',
        subtitle: 'Mochila e Equipamentos',
        actions: [
          GlobalMenu(
            onClearHistory: onClearHistory,
            onAddNewDie: onAddNewDie,
            onHelp: onHelp,
            onAbout: onAbout,
            onRateApp: onRateApp,
          ),
        ],
      ),
      body: backpackItems.isEmpty
          ? const Center(
              child: Text(
                'Mochila vazia.\nAdicione itens na sua ficha.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18, color: Colors.white),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(8),
              itemCount: backpackItems.length,
              itemBuilder: (context, index) {
                final item = backpackItems[index];
                return Card(
                  color: Colors.grey[900],
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundImage: item.imagePath != null && File(item.imagePath!).existsSync()
                          ? FileImage(File(item.imagePath!))
                          : null,
                      child: item.imagePath == null || !File(item.imagePath!).existsSync()
                          ? const Icon(Icons.inventory_2)
                          : null,
                    ),
                    title: Text(item.name, style: const TextStyle(color: Colors.white)),
                    subtitle: Text(item.description, style: const TextStyle(color: Colors.grey), maxLines: 2, overflow: TextOverflow.ellipsis),
                    onTap: () => onEditItem(item),
                    trailing: PopupMenuButton<String>(
                      icon: const Icon(Icons.more_vert, color: Colors.white),
                      onSelected: (value) {
                        if (value == 'edit') {
                          onEditItem(item);
                        } else if (value == 'delete') {
                          onDeleteItem(item);
                        }
                      },
                      itemBuilder: (context) => [
                        const PopupMenuItem(value: 'edit', child: Text('Modificar')),
                        const PopupMenuItem(value: 'delete', child: Text('Excluir')),
                      ],
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: onAddItem,
        backgroundColor: Colors.blueAccent,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
