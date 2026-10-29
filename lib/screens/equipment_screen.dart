// lib/screens/equipment_screen.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:overlord/models/item.dart';
import 'package:overlord/widgets/custom_app_bar.dart';
import 'package:overlord/widgets/global_menu.dart';
import 'package:overlord/localization.dart';

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
    final theme = Theme.of(context);
    final strings = AppStrings.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: CustomAppBar(
        title: strings.get('app_title'),
        subtitle: strings.get('backpack_subtitle'),
        actions: [
          GlobalMenu(
            onClearHistory: onClearHistory,
            onAddNewDie: onAddNewDie,
            onHelp: onHelp,
            onAbout: onAbout,
            onRateApp: onRateApp, sheets: const [], onConnect: () {  }, onSettings: () {  },
          ),
        ],
      ),
      body: backpackItems.isEmpty
          ? Center(
              child: Text(
                strings.get('backpack_empty'),
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyLarge,
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(8),
              itemCount: backpackItems.length,
              itemBuilder: (context, index) {
                final item = backpackItems[index];
                return Card(
                  color: theme.cardColor,
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: theme.colorScheme.surface,
                      backgroundImage: item.imagePath != null && File(item.imagePath!).existsSync()
                          ? FileImage(File(item.imagePath!))
                          : null,
                      child: item.imagePath == null || !File(item.imagePath!).existsSync()
                          ? Icon(Icons.inventory_2, color: theme.iconTheme.color)
                          : null,
                    ),
                    title: Text(item.name, style: TextStyle(color: theme.textTheme.bodyLarge?.color)),
                    subtitle: Text(item.description, style: TextStyle(color: theme.textTheme.bodySmall?.color), maxLines: 2, overflow: TextOverflow.ellipsis),
                    onTap: () => onEditItem(item),
                    trailing: PopupMenuButton<String>(
                      icon: Icon(Icons.more_vert, color: theme.iconTheme.color),
                      onSelected: (value) {
                        if (value == 'edit') {
                          onEditItem(item);
                        } else if (value == 'delete') {
                          onDeleteItem(item);
                        }
                      },
                      itemBuilder: (context) => [
                        PopupMenuItem(value: 'edit', child: Text(strings.get('modify'))),
                        PopupMenuItem(value: 'delete', child: Text(strings.get('remove'))),
                      ],
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: onAddItem,
        backgroundColor: theme.colorScheme.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}