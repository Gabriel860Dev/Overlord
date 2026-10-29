// lib/widgets/form_helpers.dart

import 'package:flutter/material.dart';
import 'package:multi_select_flutter/multi_select_flutter.dart';

/// Constrói um campo de texto padronizado.
/// Atualizado para suportar 'hintText' e 'onChanged'.
Widget buildTextField(
  TextEditingController controller,
  String label, {
  bool isMultiline = false,
  TextInputType? keyboardType,
  String? helperText,
  String? hintText,               // NOVO: Texto de dica (placeholder)
  ValueChanged<String>? onSubmitted,
  ValueChanged<String>? onChanged,// NOVO: Callback para mudanças em tempo real
  VoidCallback? onTapOutside,
}) {
  // O 'inputDecorationTheme' do main.dart cuida das cores, aqui cuidamos da estrutura.
  return TextField(
    controller: controller,
    keyboardType: keyboardType,
    maxLines: isMultiline ? 3 : 1,
    minLines: isMultiline ? 1 : 1,
    onSubmitted: onSubmitted,
    onChanged: onChanged,         // Conectamos o callback aqui
    onTapOutside: (_) {
      FocusManager.instance.primaryFocus?.unfocus();
      onTapOutside?.call();
    },
    decoration: InputDecoration(
      labelText: label,
      helperText: helperText,
      hintText: hintText,         // Conectamos a dica aqui
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
  final validValue = items.contains(currentValue) ? currentValue : null;

  return DropdownButtonFormField<String>(
    initialValue: validValue,
    items: items.map((String value) {
      return DropdownMenuItem<String>(
        value: value,
        child: Builder(builder: (context) {
          return Text(
            value,
            style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color),
          );
        }),
      );
    }).toList(),
    onChanged: onChanged,
    decoration: InputDecoration(
      labelText: label,
    ),
  );
}

/// Constrói um cabeçalho de seção.
Widget buildSectionHeader(String title) {
  return Builder(
    builder: (context) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Text(
          title,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.secondary,
              ),
        ),
      );
    },
  );
}

/// Constrói um cabeçalho de seção com um botão de ação.
Widget buildSectionHeaderWithButton(String title, VoidCallback onPressed) {
  return Builder(
    builder: (context) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(child: buildSectionHeader(title)),
          IconButton(
            icon: Icon(Icons.add_circle, color: Theme.of(context).colorScheme.primary),
            onPressed: onPressed,
          )
        ],
      );
    },
  );
}

/// WIDGET: Um seletor de alvos organizado por categorias expansíveis.
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
  State<CategorizedTargetSelector> createState() =>
      _CategorizedTargetSelectorState();
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
        final theme = Theme.of(context);
        return AlertDialog(
          backgroundColor: theme.cardColor,
          title: Text("Selecionar Alvos", style: theme.textTheme.titleLarge),
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
                      title: Text(category,
                          style: TextStyle(
                              color: theme.colorScheme.secondary, fontWeight: FontWeight.bold)),
                      iconColor: theme.iconTheme.color,
                      collapsedIconColor: theme.unselectedWidgetColor,
                      children: targets.map((target) {
                        return CheckboxListTile(
                          title: Text(target,
                              style: TextStyle(color: theme.textTheme.bodyLarge?.color)),
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
                          activeColor: theme.colorScheme.primary,
                          checkColor: theme.colorScheme.onPrimary,
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
              child: const Text('CANCELAR'),
            ),
            TextButton(
              onPressed: () {
                widget.onSelectionChanged(_selectedTargets);
                Navigator.of(context).pop();
              },
              child: const Text('OK', style: TextStyle(fontWeight: FontWeight.bold)),
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
            backgroundColor: Theme.of(context).cardColor,
            foregroundColor: Theme.of(context).textTheme.bodyLarge?.color,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8.0,
          runSpacing: 4.0,
          children: _selectedTargets.map((target) {
            return Chip(
              label: Text(target, style: const TextStyle(color: Colors.white)),
              backgroundColor: Theme.of(context).colorScheme.primary,
              deleteIconColor: Colors.white70,
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

// Widget MultiSelectDialogField para usar na seleção de perícias.
Widget buildMultiSelectPericias({
  required BuildContext context,
  required List<String> initialValue,
  required ValueChanged<List<String>> onConfirm,
  required List<String> allItems,
}) {
  final theme = Theme.of(context);
  
  return MultiSelectDialogField<String>(
    items: allItems.map((e) => MultiSelectItem<String>(e, e)).toList(),
    initialValue: initialValue,
    title: Text("Selecionar Perícias", style: theme.textTheme.titleLarge),
    buttonText: Text("Adicionar Perícias", style: theme.textTheme.bodyMedium),
    decoration: BoxDecoration(
      color: theme.cardColor,
      borderRadius: BorderRadius.circular(8),
      border: Border.all(color: theme.dividerColor),
    ),
    backgroundColor: theme.scaffoldBackgroundColor,
    itemsTextStyle: theme.textTheme.bodyMedium,
    selectedItemsTextStyle: TextStyle(color: theme.colorScheme.primary, fontWeight: FontWeight.bold),
    confirmText: Text('ADICIONAR', style: TextStyle(color: theme.colorScheme.primary, fontWeight: FontWeight.bold)),
    cancelText: Text('CANCELAR', style: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.6))),
    onConfirm: onConfirm,
    chipDisplay: MultiSelectChipDisplay.none(),
  );
}