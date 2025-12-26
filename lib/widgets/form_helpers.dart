// lib/widgets/form_helpers.dart

import 'package:flutter/material.dart';

/// Constrói um campo de texto padronizado para os formulários do app.
Widget buildTextField(
  TextEditingController controller,
  String label, {
  bool isMultiline = false,
  TextInputType? keyboardType,
}) {
  return TextField(
    controller: controller,
    style: const TextStyle(color: Colors.white),
    keyboardType: keyboardType,
    maxLines: isMultiline ? 3 : 1,
    minLines: isMultiline ? 1 : 1,
    decoration: InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.white70),
      filled: true,
      fillColor: Colors.grey[800],
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
    ),
  );
}

/// Constrói um menu dropdown padronizado.
Widget buildDropdownField(
  String? currentValue,
  List<String> items,
  String label,
  void Function(String?)? onChanged,
) {
  // Garante que o valor inicial esteja na lista, caso contrário, define como nulo.
  final validValue = items.contains(currentValue) ? currentValue : null;

  return DropdownButtonFormField<String>(
    initialValue: validValue,
    items: items
        .map((String value) => DropdownMenuItem<String>(
            value: value,
            child: Text(value, style: const TextStyle(color: Colors.white))))
        .toList(),
    onChanged: onChanged,
    dropdownColor: Colors.grey[850],
    decoration: InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.white70),
      filled: true,
      fillColor: Colors.grey[800],
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
    ),
  );
}


/// Constrói um cabeçalho de seção simples.
Widget buildSectionHeader(String title) => Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(title,
          style: const TextStyle(
              fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
    );

/// Constrói um cabeçalho de seção com um botão de ação (geralmente um '+').
Widget buildSectionHeaderWithButton(String title, VoidCallback onPressed) => Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        buildSectionHeader(title),
        IconButton(
            icon: const Icon(Icons.add_circle, color: Colors.white),
            onPressed: onPressed)
      ],
    );

/// NOVO WIDGET: Um seletor de alvos organizado por categorias expansíveis.
class CategorizedTargetSelector extends StatefulWidget {
  final List<String> selectedTargets;
  final ValueChanged<List<String>> onSelectionChanged;
  final Map<String, List<String>> allTargets;

  const CategorizedTargetSelector({
    super.key,
    required this.selectedTargets,
    required this.onSelectionChanged,
    required this.allTargets,
  });

  @override
  State<CategorizedTargetSelector> createState() => _CategorizedTargetSelectorState();
}

class _CategorizedTargetSelectorState extends State<CategorizedTargetSelector> {
  late List<String> _selectedTargets;

  @override
  void initState() {
    super.initState();
    _selectedTargets = List.from(widget.selectedTargets);
  }

  void _showTargetDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.grey[850],
          title: const Text("Selecionar Alvos", style: TextStyle(color: Colors.white)),
          content: StatefulBuilder(
            builder: (context, setDialogState) {
              return SizedBox(
                width: double.maxFinite,
                child: ListView(
                  shrinkWrap: true,
                  children: widget.allTargets.entries.map((entry) {
                    final category = entry.key;
                    final targets = entry.value;
                    if (targets.isEmpty) return const SizedBox.shrink();

                    return ExpansionTile(
                      title: Text(category, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      iconColor: Colors.white,
                      collapsedIconColor: Colors.white,
                      children: targets.map((target) {
                        return CheckboxListTile(
                          title: Text(target, style: const TextStyle(color: Colors.white)),
                          value: _selectedTargets.contains(target),
                          onChanged: (isSelected) {
                            setDialogState(() {
                              if (isSelected == true) {
                                _selectedTargets.add(target);
                              } else {
                                _selectedTargets.remove(target);
                              }
                            });
                          },
                          activeColor: Colors.blueAccent,
                          checkColor: Colors.white,
                          controlAffinity: ListTileControlAffinity.leading,
                        );
                      }).toList(),
                    );
                  }).toList(),
                ),
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('CANCELAR', style: TextStyle(color: Colors.white70)),
            ),
            TextButton(
              onPressed: () {
                widget.onSelectionChanged(_selectedTargets);
                Navigator.of(context).pop();
              },
              child: const Text('OK', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ElevatedButton.icon(
          onPressed: _showTargetDialog,
          icon: const Icon(Icons.ads_click),
          label: const Text("Selecionar Alvos"),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.grey[800],
            foregroundColor: Colors.white,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8.0,
          runSpacing: 4.0,
          children: _selectedTargets.map((target) {
            return Chip(
              label: Text(target, style: const TextStyle(color: Colors.white)),
              backgroundColor: Colors.blueGrey,
              onDeleted: () {
                setState(() {
                  _selectedTargets.remove(target);
                  widget.onSelectionChanged(_selectedTargets);
                });
              },
            );
          }).toList(),
        ),
      ],
    );
  }
}