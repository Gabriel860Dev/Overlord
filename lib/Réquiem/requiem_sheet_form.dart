// lib/Réquiem/requiem_sheet_form.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:overlord/Réquiem/requiem_character_sheet.dart';
import 'package:overlord/Réquiem/requiem_races_db.dart';
import 'package:overlord/Réquiem/requiem_classes_db.dart';
import 'package:overlord/Réquiem/requiem_weapon.dart';
import 'package:overlord/Réquiem/requiem_weapons_db.dart';

class RequiemSheetForm extends StatefulWidget {
  final RequiemCharacterSheet? initialSheet;
  final Function(RequiemCharacterSheet) onSave;
  final Function(String, String)? onDiceRolledFromSheet; 

  const RequiemSheetForm({
    Key? key,
    this.initialSheet,
    required this.onSave,
    this.onDiceRolledFromSheet,
  }) : super(key: key);

  @override
  State<RequiemSheetForm> createState() => _RequiemSheetFormState();
}

class _RequiemSheetFormState extends State<RequiemSheetForm> {
  late RequiemCharacterSheet _sheet;
  final _nameController = TextEditingController();
  final _levelController = TextEditingController();

  List<RequiemWeapon> _equippedWeapons = [];

  @override
  void initState() {
    super.initState();
    _sheet = widget.initialSheet ?? RequiemCharacterSheet(name: '');
    _nameController.text = _sheet.name;
    _levelController.text = _sheet.level.toString();
    
    // Carrega as armas reais salvas na ficha!
    _equippedWeapons = List.from(_sheet.weapons);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _levelController.dispose();
    super.dispose();
  }

  void _saveSheet() {
    _sheet.name = _nameController.text.trim();
    if (_sheet.name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Dê um nome ao seu personagem!', style: TextStyle(color: Colors.white))),
      );
      return;
    }
    // Guarda a lista de armas na ficha antes de salvar no Banco de Dados
    _sheet.weapons = _equippedWeapons;
    widget.onSave(_sheet);
    Navigator.of(context).pop();
  }

  // ==========================================
  // MOTOR DE DADOS
  // ==========================================
  void _rollTest(String traitName, int points) {
    int d20s = 1 + (points ~/ 10); 
    int d10s = (points % 10) >= 5 ? 1 : 0; 
    int mod = points % 5; 

    String formula = "${d20s}d20";
    if (d10s > 0) formula += "+1d10";
    if (mod > 0) formula += "+$mod";

    if (widget.onDiceRolledFromSheet != null) {
      widget.onDiceRolledFromSheet!(formula, "Teste de $traitName");
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Rolando: $formula')));
    }
  }

  void _rollWeaponDamage(RequiemWeapon weapon) {
    String damageFormula = weapon.getDamageFormula(_sheet.totalAttributes);
    if (widget.onDiceRolledFromSheet != null) {
      widget.onDiceRolledFromSheet!(damageFormula, "Ataque: ${weapon.name}");
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Dano: $damageFormula')));
    }
  }

  // ==========================================
  // EDITOR DE ARMAS (O POP-UP PARA CRIAR/EDITAR)
  // ==========================================
  void _showWeaponEditor({RequiemWeapon? existingWeapon, int? index}) {
    // Clona a arma existente ou pega a Espada como base
    RequiemWeapon editW = existingWeapon != null 
        ? RequiemWeapon.fromJson(existingWeapon.toJson())
        : RequiemWeaponsDB.getWeaponClone('Espada');

    final nameCtrl = TextEditingController(text: editW.name);
    final descCtrl = TextEditingController(text: editW.description);
    final baseDiceCtrl = TextEditingController(text: editW.baseDiceCount.toString());
    final sidesCtrl = TextEditingController(text: editW.diceSides.toString());
    final bonusPerDieCtrl = TextEditingController(text: editW.bonusPerDie.toString());
    final flatBonusCtrl = TextEditingController(text: editW.extraFlatBonus.toString());
    final masteryCtrl = TextEditingController(text: editW.masteryPercentage.toString());
    final critCtrl = TextEditingController(text: editW.criticalMargin.toString());
    final elementNameCtrl = TextEditingController(text: editW.elementName ?? '');
    final elementPctCtrl = TextEditingController(text: editW.elementPercentage.toString());
    
    // Gatilhos
    final trigTargetCtrl = TextEditingController(text: editW.triggerTargetValue.toString());
    final trigValCtrl = TextEditingController(text: editW.triggerEffectValue.toString());
    final trigDescCtrl = TextEditingController(text: editW.triggerDescription);

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) {
          
          void loadPreset(String presetName) {
            final preset = RequiemWeaponsDB.getWeaponClone(presetName);
            setDialogState(() {
              editW = preset;
              nameCtrl.text = preset.name;
              descCtrl.text = preset.description;
              baseDiceCtrl.text = preset.baseDiceCount.toString();
              sidesCtrl.text = preset.diceSides.toString();
              bonusPerDieCtrl.text = preset.bonusPerDie.toString();
              flatBonusCtrl.text = preset.extraFlatBonus.toString();
              masteryCtrl.text = preset.masteryPercentage.toString();
              critCtrl.text = preset.criticalMargin.toString();
              elementNameCtrl.text = preset.elementName ?? '';
              elementPctCtrl.text = preset.elementPercentage.toString();
            });
          }

          Widget buildField(String label, TextEditingController ctrl, {bool isNumber = false, int flex = 1}) {
            return Expanded(
              flex: flex,
              child: Padding(
                padding: const EdgeInsets.only(right: 8.0, bottom: 12.0),
                child: TextField(
                  controller: ctrl,
                  keyboardType: isNumber ? TextInputType.number : TextInputType.text,
                  inputFormatters: isNumber ? [FilteringTextInputFormatter.digitsOnly] : [],
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                  decoration: InputDecoration(
                    labelText: label, labelStyle: const TextStyle(color: Colors.white54, fontSize: 12),
                    filled: true, fillColor: Colors.black45,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(6), borderSide: BorderSide.none),
                  ),
                ),
              ),
            );
          }

          return AlertDialog(
            backgroundColor: Colors.grey[900],
            title: Text(existingWeapon == null ? 'Forjar Arma' : 'Editar Arma', style: const TextStyle(color: Colors.redAccent)),
            content: SizedBox(
              width: double.maxFinite,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Escolher Molde
                    DropdownButtonFormField<String>(
                      decoration: InputDecoration(labelText: 'Carregar Molde (Opcional)', filled: true, fillColor: Colors.red.shade900.withOpacity(0.3)),
                      dropdownColor: Colors.grey[850],
                      style: const TextStyle(color: Colors.white),
                      items: RequiemWeaponsDB.weaponNames.map((n) => DropdownMenuItem(value: n, child: Text(n))).toList(),
                      onChanged: (val) { if (val != null) loadPreset(val); },
                    ),
                    const SizedBox(height: 16),
                    
                    Row(children: [buildField('Nome da Arma', nameCtrl, flex: 2)]),
                    Row(children: [buildField('Descrição', descCtrl, flex: 2)]),
                    
                    // Escalonamento
                    DropdownButtonFormField<String>(
                      value: ['Força', 'Destreza', 'Constituição', 'Intelecto', 'Sabedoria', 'Arcanismo', 'Carisma', 'Punho'].contains(editW.scalingAttribute) ? editW.scalingAttribute : 'Força',
                      decoration: const InputDecoration(labelText: 'Escala Com Atributo:', filled: true, fillColor: Colors.black45),
                      dropdownColor: Colors.grey[850], style: const TextStyle(color: Colors.amber),
                      items: ['Força', 'Destreza', 'Constituição', 'Intelecto', 'Sabedoria', 'Arcanismo', 'Carisma', 'Punho']
                          .map((n) => DropdownMenuItem(value: n, child: Text(n))).toList(),
                      onChanged: (val) { if (val != null) setDialogState(() => editW.scalingAttribute = val); },
                    ),
                    const SizedBox(height: 12),

                    const Text('Dados de Dano (Base)', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
                    Row(
                      children: [
                        buildField('Qtd Dados', baseDiceCtrl, isNumber: true),
                        const Padding(padding: EdgeInsets.only(bottom: 12, right: 8), child: Text('d', style: TextStyle(color: Colors.white))),
                        buildField('Faces (Lados)', sidesCtrl, isNumber: true),
                      ],
                    ),
                    Row(
                      children: [
                        buildField('+ Bônus p/ Dado', bonusPerDieCtrl, isNumber: true),
                        buildField('+ Dano Fixo', flatBonusCtrl, isNumber: true),
                      ],
                    ),
                    
                    const Divider(color: Colors.white24),
                    const Text('Maestria e Crítico', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
                    Row(
                      children: [
                        buildField('Maestria (%)', masteryCtrl, isNumber: true),
                        buildField('Margem Crítica (20)', critCtrl, isNumber: true),
                      ],
                    ),

                    const Divider(color: Colors.white24),
                    const Text('Encantamento Elemental', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
                    Row(
                      children: [
                        buildField('Elemento (Ex: Fogo)', elementNameCtrl),
                        buildField('Dano (%)', elementPctCtrl, isNumber: true),
                      ],
                    ),

                    const Divider(color: Colors.white24),
                    SwitchListTile(
                      title: const Text('Possui Gatilho / Efeito?', style: TextStyle(color: Colors.white)),
                      activeColor: Colors.redAccent,
                      value: editW.hasTrigger,
                      onChanged: (val) => setDialogState(() => editW.hasTrigger = val),
                    ),
                    if (editW.hasTrigger) ...[
                      Row(
                        children: [
                          buildField('Rolar >= a:', trigTargetCtrl, isNumber: true),
                          buildField('Valor Dano Extra:', trigValCtrl, isNumber: true),
                        ],
                      ),
                      Row(children: [buildField('Descreva o Gatilho:', trigDescCtrl)]),
                    ]
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar', style: TextStyle(color: Colors.grey))),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
                onPressed: () {
                  // Salva os textos nos atributos reais
                  editW.name = nameCtrl.text;
                  editW.description = descCtrl.text;
                  editW.baseDiceCount = int.tryParse(baseDiceCtrl.text) ?? 1;
                  editW.diceSides = int.tryParse(sidesCtrl.text) ?? 6;
                  editW.bonusPerDie = int.tryParse(bonusPerDieCtrl.text) ?? 0;
                  editW.extraFlatBonus = int.tryParse(flatBonusCtrl.text) ?? 0;
                  editW.masteryPercentage = int.tryParse(masteryCtrl.text) ?? 0;
                  editW.criticalMargin = int.tryParse(critCtrl.text) ?? 20;
                  editW.elementName = elementNameCtrl.text;
                  editW.elementPercentage = int.tryParse(elementPctCtrl.text) ?? 0;
                  
                  editW.triggerTargetValue = int.tryParse(trigTargetCtrl.text) ?? 15;
                  editW.triggerEffectValue = int.tryParse(trigValCtrl.text) ?? 0;
                  editW.triggerDescription = trigDescCtrl.text;

                  setState(() {
                    if (existingWeapon == null) _equippedWeapons.add(editW);
                    else _equippedWeapons[index!] = editW;
                  });
                  Navigator.pop(ctx);
                },
                child: const Text('Forjar', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))
              )
            ],
          );
        }
      )
    );
  }

  // ==========================================
  // WIDGETS DE INTERFACE GERAIS
  // ==========================================

  Widget _buildDropdown(String label, String value, List<String> items, Function(String?) onChanged) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: DropdownButtonFormField<String>(
        decoration: InputDecoration(
          labelText: label, labelStyle: const TextStyle(color: Colors.deepPurpleAccent),
          filled: true, fillColor: Colors.black45,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
        ),
        dropdownColor: Colors.grey[900], style: const TextStyle(color: Colors.white, fontSize: 16),
        value: items.contains(value) ? value : items.first,
        items: items.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
        onChanged: onChanged,
      ),
    );
  }

  Widget _buildTraitRow(String name, int base, int extra, int total, Function(int) onBase, Function(int) onExtra) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              InkWell(
                onTap: () => _rollTest(name, total),
                borderRadius: BorderRadius.circular(20),
                child: const Padding(padding: EdgeInsets.only(right: 8.0), child: Icon(Icons.casino, color: Colors.deepPurpleAccent, size: 24)),
              ),
              Expanded(child: Text(name.toUpperCase(), style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold, letterSpacing: 0.5))),
              Text('Total: $total', style: const TextStyle(color: Colors.greenAccent, fontSize: 16, fontWeight: FontWeight.bold)),
            ]
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              const Text('Nível:', style: TextStyle(color: Colors.white54, fontSize: 12)),
              const SizedBox(width: 6),
              NumericInputField(value: base, onChanged: (v) => setState(() => onBase(v))),
              const SizedBox(width: 16),
              const Text('Treino:', style: TextStyle(color: Colors.amber, fontSize: 12)),
              const SizedBox(width: 6),
              NumericInputField(value: extra, onChanged: (v) => setState(() => onExtra(v))),
            ]
          ),
          const Divider(color: Colors.white12, height: 16),
        ]
      )
    );
  }

  Widget _buildStatusEditor(String title, int current, int maxTotal, int extraMax, Function(int) onCurrent, Function(int) onExtra, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: Colors.black38, borderRadius: BorderRadius.circular(8), border: Border(left: BorderSide(color: color, width: 4))),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title.toUpperCase(), style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 14)),
              Text('$current / $maxTotal', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 18)),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(children: [const Text('Atual:', style: TextStyle(color: Colors.white54, fontSize: 12)), const SizedBox(width: 6), NumericInputField(value: current, onChanged: (v) => setState(() => onCurrent(v)))]),
              Row(children: [const Text('Treino (+):', style: TextStyle(color: Colors.amber, fontSize: 12)), const SizedBox(width: 6), NumericInputField(value: extraMax, onChanged: (v) => setState(() => onExtra(v)))]),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildWeaponCard(RequiemWeapon weapon, int index) {
    String damageStr = weapon.getDamageFormula(_sheet.totalAttributes);
    String critDesc = weapon.getCriticalDescription();
    String passivesDesc = weapon.getExtraEffectsDescription();

    return Card(
      color: Colors.grey[900],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: const BorderSide(color: Colors.redAccent, width: 1)),
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => _rollWeaponDamage(weapon),
        borderRadius: BorderRadius.circular(12),
        splashColor: Colors.redAccent.withOpacity(0.3),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(weapon.name, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                  PopupMenuButton<String>(
                    icon: const Icon(Icons.more_vert, color: Colors.white54, size: 20),
                    color: Colors.grey[850],
                    onSelected: (val) {
                      if (val == 'edit') _showWeaponEditor(existingWeapon: weapon, index: index);
                      if (val == 'delete') setState(() => _equippedWeapons.removeAt(index));
                    },
                    itemBuilder: (ctx) => [
                      const PopupMenuItem(value: 'edit', child: Row(children: [Icon(Icons.edit, color: Colors.amber, size: 18), SizedBox(width: 8), Text('Editar', style: TextStyle(color: Colors.white))])),
                      const PopupMenuItem(value: 'delete', child: Row(children: [Icon(Icons.delete, color: Colors.redAccent, size: 18), SizedBox(width: 8), Text('Desequipar', style: TextStyle(color: Colors.white))])),
                    ]
                  ),
                ],
              ),
              if (weapon.description.isNotEmpty)
                Padding(padding: const EdgeInsets.only(bottom: 8.0), child: Text(weapon.description, style: const TextStyle(color: Colors.white70, fontStyle: FontStyle.italic, fontSize: 12))),
              
              Row(
                children: [
                  const Icon(Icons.fitness_center, color: Colors.redAccent, size: 16),
                  const SizedBox(width: 6),
                  Text('Dano: $damageStr', style: const TextStyle(color: Colors.redAccent, fontSize: 16, fontWeight: FontWeight.w900)),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(color: Colors.black45, borderRadius: BorderRadius.circular(4)),
                    child: Text(weapon.scalingAttribute.toUpperCase(), style: const TextStyle(color: Colors.amber, fontSize: 10, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
              const Divider(color: Colors.white24, height: 16),

              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Crítico:', style: TextStyle(color: Colors.white54, fontSize: 12)),
                        Text(critDesc, style: const TextStyle(color: Colors.white, fontSize: 12)),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Passivas / Efeitos:', style: TextStyle(color: Colors.white54, fontSize: 12)),
                        Text(passivesDesc, style: const TextStyle(color: Colors.white, fontSize: 12)),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final resourceName = RequiemClassesDB.getClassByName(_sheet.className)?.resourceType ?? 'Mana';
    final sortedSkills = _sheet.baseSkills.keys.toList()..sort();

    return DefaultTabController(
      length: 3, 
      child: Scaffold(
        backgroundColor: const Color(0xFF121212),
        body: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(icon: const Icon(Icons.arrow_back, color: Colors.white), onPressed: () => Navigator.of(context).pop()),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.greenAccent.shade700, foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      ),
                      icon: const Icon(Icons.save, size: 20),
                      label: const Text('Salvar Ficha', style: TextStyle(fontWeight: FontWeight.bold)),
                      onPressed: _saveSheet,
                    )
                  ],
                ),
              ),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 3,
                          child: TextField(
                            controller: _nameController,
                            style: const TextStyle(color: Colors.white, fontSize: 16),
                            decoration: InputDecoration(
                              labelText: 'Nome do Personagem', labelStyle: const TextStyle(color: Colors.deepPurpleAccent),
                              filled: true, fillColor: Colors.black45,
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          flex: 1,
                          child: TextField(
                            controller: _levelController,
                            keyboardType: TextInputType.number,
                            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                            style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                            decoration: InputDecoration(
                              labelText: 'Nível', labelStyle: const TextStyle(color: Colors.deepPurpleAccent),
                              filled: true, fillColor: Colors.black45,
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                            ),
                            onChanged: (val) { setState(() { _sheet.level = int.tryParse(val) ?? 1; }); },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _buildDropdown('Raça', _sheet.raceName, RequiemRacesDB.raceNames, (val) { if (val != null) setState(() => _sheet.raceName = val); }),
                    _buildDropdown('Classe', _sheet.className, RequiemClassesDB.classNames, (val) { if (val != null) setState(() => _sheet.className = val); }),
                  ],
                ),
              ),

              const TabBar(
                indicatorColor: Colors.deepPurpleAccent, labelColor: Colors.deepPurpleAccent, unselectedLabelColor: Colors.white54,
                tabs: [Tab(text: "Status & Atr", icon: Icon(Icons.person)), Tab(text: "Combate", icon: Icon(Icons.hardware)), Tab(text: "Perícias", icon: Icon(Icons.library_books))],
              ),
              const Divider(color: Colors.white12, height: 1),

              Expanded(
                child: TabBarView(
                  children: [
                    SingleChildScrollView(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('STATUS (DINÂMICO)', style: TextStyle(color: Colors.white70, fontSize: 14, fontWeight: FontWeight.bold, letterSpacing: 1)),
                          const SizedBox(height: 8),
                          _buildStatusEditor('Pontos de Vida', _sheet.currentHp, _sheet.maxHp, _sheet.extraMaxHp, (v) => _sheet.currentHp = v, (v) => _sheet.extraMaxHp = v, Colors.redAccent),
                          if (resourceName != 'Nenhum') _buildStatusEditor(resourceName, _sheet.currentMana, _sheet.maxResource, _sheet.extraMaxMana, (v) => _sheet.currentMana = v, (v) => _sheet.extraMaxMana = v, Colors.blueAccent),
                          _buildStatusEditor('Estamina', _sheet.currentStamina, _sheet.maxStamina, _sheet.extraMaxStamina, (v) => _sheet.currentStamina = v, (v) => _sheet.extraMaxStamina = v, Colors.orangeAccent),
                          _buildStatusEditor('Sanidade', _sheet.currentSanity, _sheet.maxSanity, _sheet.extraMaxSanity, (v) => _sheet.currentSanity = v, (v) => _sheet.extraMaxSanity = v, Colors.grey),
                          const SizedBox(height: 24),
                          const Row(children: [Icon(Icons.bar_chart, color: Colors.deepPurpleAccent), SizedBox(width: 8), Text('ATRIBUTOS', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: 1))]),
                          const Divider(color: Colors.deepPurpleAccent, thickness: 1.5, height: 24),
                          ..._sheet.baseAttributes.keys.map((key) => _buildTraitRow(key, _sheet.baseAttributes[key] ?? 0, _sheet.extraAttributes[key] ?? 0, _sheet.totalAttributes[key] ?? 0, (v) => _sheet.baseAttributes[key] = v, (v) => _sheet.extraAttributes[key] = v)).toList(),
                        ],
                      ),
                    ),

                    SingleChildScrollView(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('ARMAS EQUIPADAS', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                              IconButton(
                                icon: const Icon(Icons.add_circle, color: Colors.redAccent, size: 30),
                                onPressed: () => _showWeaponEditor(), // Abre o Editor Limpo!
                              )
                            ],
                          ),
                          const Divider(color: Colors.redAccent, thickness: 1.5, height: 24),
                          if (_equippedWeapons.isEmpty) const Center(child: Text("Nenhuma arma equipada.", style: TextStyle(color: Colors.white54))),
                          ..._equippedWeapons.asMap().entries.map((entry) => _buildWeaponCard(entry.value, entry.key)).toList(),
                        ],
                      ),
                    ),

                    SingleChildScrollView(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ...sortedSkills.map((key) => _buildTraitRow(key, _sheet.baseSkills[key] ?? 0, _sheet.extraSkills[key] ?? 0, _sheet.totalSkills[key] ?? 0, (v) => _sheet.baseSkills[key] = v, (v) => _sheet.extraSkills[key] = v)).toList(),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class NumericInputField extends StatefulWidget {
  final int value;
  final Function(int) onChanged;

  const NumericInputField({Key? key, required this.value, required this.onChanged}) : super(key: key);

  @override
  State<NumericInputField> createState() => _NumericInputFieldState();
}

class _NumericInputFieldState extends State<NumericInputField> {
  late TextEditingController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(text: widget.value.toString());
  }

  @override
  void didUpdateWidget(NumericInputField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) {
      int currentTextVal = int.tryParse(_ctrl.text) ?? 0;
      if (currentTextVal != widget.value) _ctrl.text = widget.value.toString();
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 48, height: 36,
      child: TextField(
        controller: _ctrl,
        keyboardType: TextInputType.number,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        textAlign: TextAlign.center,
        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
        decoration: InputDecoration(contentPadding: EdgeInsets.zero, filled: true, fillColor: Colors.white10, border: OutlineInputBorder(borderRadius: BorderRadius.circular(6), borderSide: BorderSide.none)),
        onChanged: (val) { widget.onChanged(int.tryParse(val) ?? 0); },
      ),
    );
  }
}