// lib/widgets/effect_configurator.dart

import 'package:flutter/material.dart';
import 'package:overlord/models/passive.dart';
import 'package:overlord/models/elemental_system.dart'; // IMPORT DO SEU SISTEMA ADICIONADO AQUI

class EffectConfigurator extends StatefulWidget {
  final List<PassiveEffect> effects;
  final ValueChanged<List<PassiveEffect>> onEffectsChanged;
  final List<String> characterAttributes;
  final List<String> characterPericias;

  const EffectConfigurator({
    super.key,
    required this.effects,
    required this.onEffectsChanged,
    this.characterAttributes = const [],
    this.characterPericias = const [],
  });

  @override
  State<EffectConfigurator> createState() => _EffectConfiguratorState();
}

class _EffectConfiguratorState extends State<EffectConfigurator> {
  void _showEditEffectDialog(int index) {
    final effect = widget.effects[index];
    final valCtrl = TextEditingController(text: effect.value.toString());
    final perRoundCtrl = TextEditingController(text: effect.perRoundValue.toString());
    String bType = effect.bonusType;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: const Text('Editar Bônus Passivo', style: TextStyle(color: Colors.purpleAccent)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Alvo(s): ${effect.targets.join(', ')}", style: const TextStyle(fontSize: 12, color: Colors.grey)),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: ['Modificador', 'Percentual', 'Pontos de Bônus', 'Multiplicador'].contains(bType) ? bType : 'Modificador',
                dropdownColor: Colors.grey[800],
                items: ['Modificador', 'Percentual', 'Pontos de Bônus', 'Multiplicador'].map((t) => DropdownMenuItem(value: t, child: Text(t, style: const TextStyle(color: Colors.white)))).toList(),
                onChanged: (v) => bType = v!,
                decoration: const InputDecoration(labelText: 'Tipo de Bônus', filled: true),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: valCtrl,
                keyboardType: TextInputType.number,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(labelText: 'Novo Valor (Ex: 2.0 para Dobro)', filled: true),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: perRoundCtrl,
                keyboardType: TextInputType.number,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(labelText: 'Valor por Turno (Cura/Regen)', filled: true),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar', style: TextStyle(color: Colors.grey))),
          TextButton(
            onPressed: () {
              setState(() {
                widget.effects[index] = PassiveEffect(
                  targets: effect.targets,
                  bonusType: bType,
                  value: double.tryParse(valCtrl.text) ?? effect.value,
                  bonusDamageType: effect.bonusDamageType,
                  perRoundValue: double.tryParse(perRoundCtrl.text) ?? effect.perRoundValue,
                );
              });
              widget.onEffectsChanged(widget.effects);
              Navigator.pop(ctx);
            },
            child: const Text('Salvar', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _showAddEffectDialog() async {
    List<String> selectedTargets = [];
    String bonusType = 'Modificador';
    final valCtrl = TextEditingController(text: '0');
    final perRoundCtrl = TextEditingController(text: '0');

    // BUSCANDO ELEMENTOS DO SEU SISTEMA OFICIAL
    await ElementalSystem.loadCustomElements();
    final systemElementNames = ElementalSystem.allElements;

    final allTargets = [
      'Todos os Testes', 'Tudo', 'Todos os Atributos', 'Todas as Perícias', 'Perícias Físicas', 'Todos os Danos',
      'Vida', 'Esforço', 'Sanidade',
      ...widget.characterAttributes,
      ...widget.characterPericias,
      'Defesa', 'Esquiva', 'Bloqueio', 'Ataque',
      ...systemElementNames.map((e) => 'Dano $e')
    ];

    if (!mounted) return;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Theme.of(context).cardColor,
        title: const Text('Adicionar Efeito Passivo', style: TextStyle(color: Colors.purpleAccent)),
        content: StatefulBuilder(
          builder: (ctx, setDialogState) {
            return SizedBox(
              width: double.maxFinite,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text("Selecione os Alvos:", style: TextStyle(color: Colors.grey, fontSize: 12)),
                  const SizedBox(height: 4),
                  Container(
                    height: 150,
                    decoration: BoxDecoration(
                      color: Colors.black26,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.white12),
                    ),
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: allTargets.length,
                      itemBuilder: (context, index) {
                        final target = allTargets[index];
                        final isSelected = selectedTargets.contains(target);
                        return CheckboxListTile(
                          dense: true,
                          title: Text(target, style: const TextStyle(color: Colors.white, fontSize: 13)),
                          value: isSelected,
                          activeColor: Colors.purpleAccent,
                          onChanged: (bool? value) {
                            setDialogState(() {
                              if (value == true) {
                                selectedTargets.add(target);
                              } else {
                                selectedTargets.remove(target);
                              }
                            });
                          },
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    initialValue: bonusType,
                    dropdownColor: Colors.grey[900],
                    items: ['Modificador', 'Percentual', 'Pontos de Bônus', 'Multiplicador'].map((t) => DropdownMenuItem(value: t, child: Text(t, style: const TextStyle(color: Colors.white)))).toList(),
                    onChanged: (v) => setDialogState(() => bonusType = v!),
                    decoration: const InputDecoration(labelText: 'Tipo de Bônus', filled: true),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: valCtrl,
                          keyboardType: const TextInputType.numberWithOptions(signed: true, decimal: true),
                          style: const TextStyle(color: Colors.white),
                          decoration: const InputDecoration(
                            labelText: 'Valor Base',
                            filled: true,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextField(
                          controller: perRoundCtrl,
                          keyboardType: const TextInputType.numberWithOptions(signed: true, decimal: true),
                          style: const TextStyle(color: Colors.white),
                          decoration: const InputDecoration(
                            labelText: 'Ganho/Turno',
                            filled: true,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          }
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar', style: TextStyle(color: Colors.grey))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.purpleAccent),
            onPressed: () {
              if (selectedTargets.isEmpty) {
                 ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Selecione pelo menos um alvo!')));
                 return;
              }
              final val = double.tryParse(valCtrl.text) ?? 0;
              final perRoundVal = double.tryParse(perRoundCtrl.text) ?? 0;
              
              setState(() {
                widget.effects.add(PassiveEffect(
                  targets: selectedTargets,
                  bonusType: bonusType,
                  value: val,
                  perRoundValue: perRoundVal
                ));
              });
              widget.onEffectsChanged(widget.effects);
              Navigator.pop(ctx);
            },
            child: const Text('Adicionar', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.purpleAccent.withOpacity(0.2),
            foregroundColor: Colors.purpleAccent,
            side: const BorderSide(color: Colors.purpleAccent),
          ),
          onPressed: _showAddEffectDialog,
          icon: const Icon(Icons.add),
          label: const Text('Adicionar Efeito Passivo'),
        ),
        const SizedBox(height: 8),
        if (widget.effects.isNotEmpty)
          Container(
            decoration: BoxDecoration(
              color: Colors.black26,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.white12),
            ),
            child: ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: widget.effects.length,
              itemBuilder: (context, index) {
                final e = widget.effects[index];
                final turnInfo = e.perRoundValue != 0 ? ' (+${e.perRoundValue}/turno)' : '';
                return ListTile(
                  dense: true,
                  onTap: () => _showEditEffectDialog(index),
                  title: Text(
                    '${e.targets.join(', ')}: ${e.value > 0 ? '+' : ''}${e.value} (${e.bonusType})$turnInfo',
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                  subtitle: const Text("Clique para editar", style: TextStyle(color: Colors.white30, fontSize: 10)),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.redAccent),
                    tooltip: 'Remover Efeito',
                    onPressed: () {
                      setState(() {
                        widget.effects.removeAt(index);
                      });
                      widget.onEffectsChanged(widget.effects);
                    },
                  ),
                );
              },
            ),
          )
        else
          const Text('Nenhum efeito passivo adicionado.', style: TextStyle(color: Colors.grey, fontSize: 13, fontStyle: FontStyle.italic)),
      ],
    );
  }
}