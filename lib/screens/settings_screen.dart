// lib/screens/settings_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:overlord/theme_manager.dart';
import 'package:overlord/localization.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeManager = ThemeManager();
    final strings = AppStrings.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(strings.get('settings'))),
      body: AnimatedBuilder(
        animation: themeManager,
        builder: (context, child) {
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _buildSectionHeader(context, strings.get('language')),
              Card(
                child: ListTile(
                  leading: const Icon(Icons.language),
                  title: Text(themeManager.currentLocale.languageCode == 'pt' ? 'Português' : 'English'),
                  trailing: DropdownButton<String>(
                    value: themeManager.currentLocale.languageCode,
                    underline: const SizedBox(),
                    dropdownColor: Theme.of(context).cardColor,
                    items: const [
                      DropdownMenuItem(value: 'pt', child: Text('🇧🇷 PT-BR')),
                      DropdownMenuItem(value: 'en', child: Text('🇺🇸 EN-US')),
                    ],
                    onChanged: (val) { if (val != null) themeManager.setLanguage(val); },
                  ),
                ),
              ),
              const SizedBox(height: 20),
              _buildSectionHeader(context, strings.get('theme_visuals')),
              Card(
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.palette),
                      title: Text(strings.get('select_theme')),
                      trailing: DropdownButton<AppThemeMode>(
                        value: themeManager.currentMode,
                        underline: const SizedBox(),
                        dropdownColor: Theme.of(context).cardColor,
                        items: const [
                          DropdownMenuItem(value: AppThemeMode.dark, child: Text('Dark')),
                          DropdownMenuItem(value: AppThemeMode.light, child: Text('Light')),
                          DropdownMenuItem(value: AppThemeMode.purple, child: Text('Roxo')),
                          DropdownMenuItem(value: AppThemeMode.blue, child: Text('Azul')),
                          DropdownMenuItem(value: AppThemeMode.gold, child: Text('Dourado')),
                          DropdownMenuItem(value: AppThemeMode.custom, child: Text('Custom')),
                        ],
                        onChanged: (val) { if (val != null) themeManager.setThemeMode(val); },
                      ),
                    ),
                    if (themeManager.currentMode == AppThemeMode.custom) ...[
                      const Divider(),
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(strings.get('custom_colors'), style: const TextStyle(fontWeight: FontWeight.bold)),
                            const SizedBox(height: 10),
                            // Layout: 3 em cima, 2 em baixo
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                _buildColorPicker(context, strings.get('primary_color'), themeManager.customPrimary, 
                                  (c) => themeManager.setCustomColors(c, themeManager.customAccent, themeManager.customText, themeManager.customBackground, themeManager.customSecondaryBackground)),
                                
                                _buildColorPicker(context, strings.get('accent_color'), themeManager.customAccent, 
                                  (c) => themeManager.setCustomColors(themeManager.customPrimary, c, themeManager.customText, themeManager.customBackground, themeManager.customSecondaryBackground)),
                                
                                _buildColorPicker(context, strings.get('text_color'), themeManager.customText, 
                                  (c) => themeManager.setCustomColors(themeManager.customPrimary, themeManager.customAccent, c, themeManager.customBackground, themeManager.customSecondaryBackground)),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                // Fundo Principal (Scaffold)
                                _buildColorPicker(context, "Fundo Principal", themeManager.customBackground, 
                                  (c) => themeManager.setCustomColors(themeManager.customPrimary, themeManager.customAccent, themeManager.customText, c, themeManager.customSecondaryBackground)),
                                
                                // Fundo Secundário (Cards/Barras)
                                _buildColorPicker(context, "Fundo Secundário", themeManager.customSecondaryBackground, 
                                  (c) => themeManager.setCustomColors(themeManager.customPrimary, themeManager.customAccent, themeManager.customText, themeManager.customBackground, c)),
                              ],
                            ),
                          ],
                        ),
                      )
                    ]
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
      child: Text(title, style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Theme.of(context).colorScheme.secondary)),
    );
  }

  Widget _buildColorPicker(BuildContext context, String label, Color currentColor, Function(Color) onColorChanged) {
    return Column(
      children: [
        Text(label, style: Theme.of(context).textTheme.bodySmall?.copyWith(fontSize: 10)),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: () {
            showDialog(
              context: context,
              builder: (context) {
                Color tempColor = currentColor;
                TextEditingController hexController = TextEditingController(
                  text: '#${currentColor.value.toRadixString(16).toUpperCase().substring(2)}'
                );

                return AlertDialog(
                  backgroundColor: Theme.of(context).cardColor,
                  title: Text(label, style: TextStyle(color: Theme.of(context).colorScheme.onSurface)),
                  content: StatefulBuilder(
                    builder: (context, setStateDialog) {
                      return SingleChildScrollView(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            ColorPicker(
                              pickerColor: tempColor,
                              onColorChanged: (color) {
                                setStateDialog(() {
                                  tempColor = color;
                                  hexController.text = '#${color.value.toRadixString(16).toUpperCase().substring(2)}';
                                });
                              },
                              enableAlpha: false,
                              pickerAreaHeightPercent: 0.7,
                              labelTypes: const [],
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    color: tempColor,
                                    shape: BoxShape.circle,
                                    border: Border.all(color: Colors.grey),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: TextField(
                                    controller: hexController,
                                    decoration: InputDecoration(
                                      labelText: 'Hex (#RRGGBB)',
                                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                                      isDense: true,
                                      contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                                    ),
                                    style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
                                    onSubmitted: (value) {
                                      try {
                                        String cleanHex = value.replaceAll('#', '');
                                        if (cleanHex.length == 6) {
                                          setStateDialog(() {
                                            tempColor = Color(int.parse('0xFF$cleanHex'));
                                          });
                                        }
                                      } catch (e) {
                                        // Ignora erro
                                      }
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(), 
                      child: const Text('Cancelar')
                    ),
                    TextButton(
                      onPressed: () {
                        onColorChanged(tempColor);
                        Navigator.of(context).pop();
                      }, 
                      child: const Text('OK', style: TextStyle(fontWeight: FontWeight.bold))
                    ),
                  ],
                );
              },
            );
          },
          child: Container(
            width: 40, height: 40,
            decoration: BoxDecoration(
              color: currentColor, 
              shape: BoxShape.circle, 
              border: Border.all(color: Theme.of(context).colorScheme.onSurface, width: 2)
            ),
          ),
        ),
      ],
    );
  }
}