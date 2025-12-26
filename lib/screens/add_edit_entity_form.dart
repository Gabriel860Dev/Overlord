// lib/screens/add_edit_entity_form.dart

import 'package:flutter/material.dart';
import 'package:dark_age/models/ability.dart';
import 'package:dark_age/models/armor.dart';
import 'package:dark_age/models/die_specification.dart';
import 'package:dark_age/models/item.dart';
import 'package:dark_age/models/passive.dart';
import 'package:dark_age/models/status_effect.dart';
import 'package:dark_age/models/weapon.dart';
import 'package:dark_age/widgets/form_helpers.dart';
import 'package:dark_age/widgets/image_picker_button.dart';
import 'package:uuid/uuid.dart';

enum EntityType { item, weapon, armor, ability, passive, statusEffect }

class AddEditEntityForm extends StatefulWidget {
  final EntityType entityType;
  final dynamic initialEntity;
  final void Function(dynamic) onSave;
  final List<String> characterAttributes;
  final List<String> characterPericias;
  final List<Weapon> characterWeapons;
  final List<Ability> characterAbilities;

  const AddEditEntityForm({
    super.key,
    required this.entityType,
    this.initialEntity,
    required this.onSave,
    this.characterAttributes = const [],
    this.characterPericias = const [],
    this.characterWeapons = const [],
    this.characterAbilities = const [],
  });

  @override
  State<AddEditEntityForm> createState() => _AddEditEntityFormState();
}

class _AddEditEntityFormState extends State<AddEditEntityForm> {
  // Common Controllers
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  String? _imagePath;
  final List<ItemEffect> _effects = [];

  // Weapon & Ability
  final _modifierController = TextEditingController(text: '0');
  final _multiplierController = TextEditingController(text: '1.0');
  final List<DieSpecification> _dice = [];
  final List<ConditionalEffect> _triggers = [];

  // Armor
  final _defenseValueController = TextEditingController(text: '0');
  Map<String, double> _resistances = {};

  // Ability
  final _costAmountController = TextEditingController(text: '0');
  final _bonusModifierController = TextEditingController(text: '0');
  final _costPerRoundController = TextEditingController(text: '0');
  final _cooldownController = TextEditingController(text: '0');
  String _costType = 'Nenhum';
  String _costSource = 'Padrão';
  String _abilityType = 'Dano';
  List<BaseComponent> _baseComponents = [];
  List<DieSpecification> _abilityDice = []; // DADOS PARA HABILIDADES
  Armor? _armorToCreate;

  // Passive
  final _triggerValueController = TextEditingController(text: '0');
  String _triggerType = 'Sempre Ativo';
  String _triggerValueType = 'Valor Fixo';
  String _triggerFrequency = 'Acumulável';
  bool _basedOnTotal = false;
  final List<PassiveEffect> _passiveEffects = [];

  // Status Effect
  final _durationController = TextEditingController();
  final _valueController = TextEditingController(text: '0');
  String _bonusType = 'Modificador';
  List<String> _selectedTargets = [];

  final List<String> _damageTypes = const [
    'Cortante','Impacto','Perfurante','Fogo','Gelo','Elétrico','Água','Sangue','Morte','Conhecimento','Energia','Especial','Cura'
  ];

  @override
  void initState() {
    super.initState();
    _loadInitialEntity();
  }
   // Helper para agrupar todos os alvos possíveis
  Map<String, List<String>> _getAllTargets() {
    return {
      'Status': ['Vida', 'Esforço', 'Sanidade', 'Loucura', 'Esforço Temporário'],
      'Combate': ['Bloqueio', 'Armadura'],
      'Atributos': widget.characterAttributes,
      'Perícias': widget.characterPericias,
      'Armas': widget.characterWeapons.map((w) => w.name).toList(),
      'Habilidades': widget.characterAbilities.map((a) => a.name).toList(),
    };
  }

  void _loadInitialEntity() {
    if (widget.initialEntity == null) return;
    final entity = widget.initialEntity;

    _nameController.text = entity.name ?? '';
     if (entity is Item || entity is Ability || entity is StatusEffect || entity is Passive) {
      _descriptionController.text = entity.description ?? '';
    }
    if (entity is Item || entity is Ability || entity is StatusEffect) {
       _imagePath = entity.imagePath;
    }
    if (entity is Item) {
       _effects.addAll(entity.effects);
    }

    switch (widget.entityType) {
      case EntityType.weapon:
        final weapon = entity as Weapon;
        _modifierController.text = weapon.modifier.toString();
        _multiplierController.text = weapon.multiplier.toString();
        _dice.addAll(weapon.dice);
        _triggers.addAll(weapon.triggers);
        break;
      case EntityType.armor:
        final armor = entity as Armor;
        _defenseValueController.text = armor.defenseValue.toString();
        _resistances = Map.from(armor.resistances);
        break;
      case EntityType.ability:
        final ability = entity as Ability;
        _abilityType = ability.abilityType;
        _costPerRoundController.text = ability.costPerRound.toString();
        _costType = ability.costType;
        _costSource = ability.costSource;
        _costAmountController.text = ability.costAmount.toString();
        _cooldownController.text = ability.cooldown.toString();
        _baseComponents = List.from(ability.baseComponents);
        _multiplierController.text = ability.multiplier.toString();
        _bonusModifierController.text = ability.bonusModifier.toString();
        _abilityDice = List.from(ability.bonusDice);
        _armorToCreate = ability.armorToCreate;
        _effects.addAll(ability.effects);
        _triggers.addAll(ability.conditionalEffects);
        break;
      case EntityType.passive:
        final passive = entity as Passive;
        _triggerType = passive.triggerType;
        _triggerValueType = passive.triggerValueType;
        _triggerValueController.text = passive.triggerValue.toString();
        _triggerFrequency = passive.triggerFrequency;
        _cooldownController.text = passive.cooldown.toString();
        _passiveEffects.addAll(passive.effects);
        _basedOnTotal = passive.basedOnTotal;
        break;
      case EntityType.statusEffect:
        final effect = entity as StatusEffect;
        _durationController.text = effect.durationInRounds.toString();
        _bonusType = effect.bonusType;
        _valueController.text = effect.value.toString();
        _selectedTargets = List.from(effect.targets);
        break;
      case EntityType.item:
        break;
    }
  }

  void _saveEntity() {
    dynamic newEntity;
    String id = widget.initialEntity?.id ?? const Uuid().v4();
    String name = _nameController.text.isNotEmpty ? _nameController.text : 'Sem nome';

    switch (widget.entityType) {
      case EntityType.item:
        newEntity = Item(id: id, name: name, description: _descriptionController.text, imagePath: _imagePath, effects: _effects, isEquipped: widget.initialEntity?.isEquipped ?? false);
        break;
      case EntityType.weapon:
        newEntity = Weapon(id: id, name: name, description: _descriptionController.text, imagePath: _imagePath, effects: _effects, isEquipped: widget.initialEntity?.isEquipped ?? false, dice: _dice, modifier: int.tryParse(_modifierController.text) ?? 0, multiplier: double.tryParse(_multiplierController.text) ?? 1.0, triggers: _triggers);
        break;
      case EntityType.armor:
         newEntity = Armor(id: id, name: name, description: _descriptionController.text, imagePath: _imagePath, effects: _effects, isEquipped: widget.initialEntity?.isEquipped ?? false, defenseValue: int.tryParse(_defenseValueController.text) ?? 0, resistances: _resistances, currentDefenseValue: widget.initialEntity?.currentDefenseValue);
        break;
      case EntityType.ability:
         newEntity = Ability(id: id, name: name, description: _descriptionController.text, imagePath: _imagePath, abilityType: _abilityType, effects: _effects, costPerRound: int.tryParse(_costPerRoundController.text) ?? 0, costType: _costType, costSource: _costSource, costAmount: int.tryParse(_costAmountController.text) ?? 0, cooldown: int.tryParse(_cooldownController.text) ?? 0, baseComponents: _baseComponents, multiplier: double.tryParse(_multiplierController.text) ?? 1.0, bonusDice: _abilityDice, bonusModifier: int.tryParse(_bonusModifierController.text) ?? 0, armorToCreate: _armorToCreate, conditionalEffects: _triggers, isActive: widget.initialEntity?.isActive ?? false, usesInCombat: widget.initialEntity?.usesInCombat ?? 0);
        break;
      case EntityType.passive:
        newEntity = Passive(id: id, name: name, description: _descriptionController.text, triggerType: _triggerType, triggerValueType: _triggerValueType, triggerValue: int.tryParse(_triggerValueController.text) ?? 0, triggerFrequency: _triggerFrequency, cooldown: int.tryParse(_cooldownController.text) ?? 0, effects: _passiveEffects, basedOnTotal: _basedOnTotal, isActive: widget.initialEntity?.isActive ?? (_triggerType == 'Sempre Ativo'), stacks: widget.initialEntity?.stacks ?? 0);
        break;
      case EntityType.statusEffect:
         newEntity = StatusEffect(id: id, name: name, description: _descriptionController.text, durationInRounds: int.tryParse(_durationController.text) ?? -1, imagePath: _imagePath, bonusType: _bonusType, value: double.tryParse(_valueController.text) ?? 0, targets: _selectedTargets);
        break;
    }

    if (newEntity != null) {
      widget.onSave(newEntity);
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[850],
      appBar: AppBar(
        title: Text(_getAppBarTitle(), style: const TextStyle(color: Colors.white)),
        backgroundColor: Colors.grey[900],
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ..._buildFormFields(),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _saveEntity,
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16)),
              child: Text('Salvar ${_getEntityTypeString()}', style: const TextStyle(fontSize: 18)),
            ),
          ],
        ),
      ),
    );
  }

  String _getAppBarTitle() {
    final action = widget.initialEntity == null ? 'Novo' : 'Editar';
    return '$action ${_getEntityTypeString()}';
  }

  String _getEntityTypeString() {
    switch (widget.entityType) {
      case EntityType.item: return 'Item';
      case EntityType.weapon: return 'Arma';
      case EntityType.armor: return 'Armadura';
      case EntityType.ability: return 'Habilidade';
      case EntityType.passive: return 'Passiva';
      case EntityType.statusEffect: return 'Efeito';
    }
  }

  List<Widget> _buildFormFields() {
    List<Widget> fields = [];
    if (widget.entityType != EntityType.passive) {
      fields.add(Center(child: ImagePickerButton(imagePath: _imagePath, onImagePicked: (newPath) => setState(() => _imagePath = newPath), defaultIcon: _getDefaultIcon())));
      fields.add(const SizedBox(height: 16));
    }
    fields.add(buildTextField(_nameController, 'Nome do ${_getEntityTypeString()}'));
    fields.add(const SizedBox(height: 16));
    fields.add(buildTextField(_descriptionController, 'Descrição', isMultiline: true));
    fields.add(const SizedBox(height: 16));

    switch (widget.entityType) {
      case EntityType.weapon: fields.addAll(_buildWeaponFields()); break;
      case EntityType.armor: fields.addAll(_buildArmorFields()); break;
      case EntityType.ability: fields.addAll(_buildAbilityFields()); break;
      case EntityType.passive: fields.addAll(_buildPassiveFields()); break;
      case EntityType.statusEffect: fields.addAll(_buildStatusEffectFields()); break;
      case EntityType.item: break;
    }

    if ([EntityType.item, EntityType.weapon, EntityType.armor, EntityType.ability].contains(widget.entityType)) {
      fields.add(buildSectionHeaderWithButton("Efeitos", _addOrEditEffect));
      fields.addAll(_effects.map((effect) => ListTile(
            title: Text('${effect.bonusType} em ${effect.targets.join(", ")}', style: const TextStyle(color: Colors.white)),
            subtitle: Text('Valor: ${effect.value}${effect.bonusType == 'Percentual' ? '%' : ''}', style: const TextStyle(color: Colors.grey)),
            trailing: IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: () => setState(() => _effects.remove(effect))),
            onTap: () => _addOrEditEffect(effectToEdit: effect),
          )));
    }

    return fields;
  }

  List<Widget> _buildWeaponFields() {
    return [
      buildSectionHeaderWithButton('Dados:', () => _addOrEditDie()),
      ..._dice.map((d) => ListTile(
        title: Text('${d.quantity}d${d.sides} (${d.damageType})', style: const TextStyle(color: Colors.white)),
        trailing: IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: () => setState(() => _dice.remove(d))),
        onTap: () => _addOrEditDie(dieToEdit: d),
      )),
      const SizedBox(height: 16),
      buildTextField(_modifierController, 'Modificador (Bônus)', keyboardType: TextInputType.number),
      const SizedBox(height: 16),
      buildTextField(_multiplierController, 'Multiplicador (Ex: 1.5)',
          keyboardType: const TextInputType.numberWithOptions(decimal: true)),
      const SizedBox(height: 16),
      buildSectionHeaderWithButton('Gatilhos', () => _addOrEditTrigger()),
       ..._triggers.map((t) => ListTile(
        title: Text(t.description, style: const TextStyle(color: Colors.white)),
        subtitle: Text(_getTriggerEffectSubtitle(t), style: const TextStyle(color: Colors.grey)),
        trailing: IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: () => setState(() => _triggers.remove(t))),
        onTap: () => _addOrEditTrigger(effectToEdit: t),
      )),
    ];
  }

  List<Widget> _buildArmorFields() {
    return [
       buildTextField(_defenseValueController, 'Valor de Armadura', keyboardType: TextInputType.number),
       const SizedBox(height: 16),
       buildSectionHeaderWithButton('Resistências/Vulnerabilidades', () => _addOrEditResistance()),
       ..._resistances.entries.map((entry) {
          final percentage = ((1 - entry.value) * 100).toStringAsFixed(0);
          final type = entry.value < 1.0 ? 'Resistência' : 'Vulnerabilidade';
          return ListTile(
            title: Text(entry.key, style: const TextStyle(color: Colors.white)),
            subtitle: Text('$percentage% de $type', style: TextStyle(color: entry.value < 1.0 ? Colors.greenAccent : Colors.redAccent)),
            trailing: IconButton(
              icon: const Icon(Icons.delete, color: Colors.redAccent),
              onPressed: () => setState(() => _resistances.remove(entry.key)),
            ),
            onTap: () => _addOrEditResistance(damageType: entry.key),
          );
       }),
    ];
  }

  List<Widget> _buildAbilityFields() {
    bool showDiceAndBases = _abilityType == 'Dano' || _abilityType == 'Defesa' || _abilityType == 'Restaurar Vida' || _abilityType == 'Restaurar Esforço';
    String costLabel = 'Valor do Custo';
     if (_abilityType == 'Restaurar Vida' || _abilityType == 'Restaurar Esforço') {
      costLabel = 'Valor a Restaurar';
    }

    return [
      buildDropdownField(_abilityType, ['Dano','Defesa','Buff/Transformação','Restaurar Vida','Restaurar Esforço','Criar Armadura'],
          'Tipo de Habilidade', (newValue) => setState(() => _abilityType = newValue!)),
      const SizedBox(height: 16),
      if (_abilityType == 'Criar Armadura')
        Card(
          color: Colors.grey[900],
          child: ListTile(
            leading: const Icon(Icons.shield, color: Colors.white),
            title: Text(_armorToCreate?.name ?? 'Nenhuma armadura definida', style: const TextStyle(color: Colors.white)),
            subtitle: const Text("Toque para definir a armadura criada por esta habilidade.", style: TextStyle(color: Colors.grey)),
            onTap: _defineArmorForAbility,
          ),
        ),
      if (_abilityType != 'Buff/Transformação') ...[
        buildDropdownField(_costType, ['Nenhum', 'Vida', 'Esforço', 'Sanidade'], 'Tipo de Custo (Instantâneo)',
            (newValue) => setState(() => _costType = newValue!)),
        if (_costType == 'Esforço') ...[
          const SizedBox(height: 16),
          buildDropdownField(_costSource, ['Padrão', 'Apenas Temporário', 'Híbrido (Temp. > Padrão)'], 'Fonte do Custo',
              (newValue) => setState(() => _costSource = newValue!)),
        ],
        if (_costType != 'Nenhum') ...[
          const SizedBox(height: 16),
          buildTextField(_costAmountController, costLabel, keyboardType: TextInputType.number),
        ],
        const SizedBox(height: 16),
        buildTextField(_cooldownController, 'Cooldown (em rounds)', keyboardType: TextInputType.number),
      ],
       if (showDiceAndBases) ...[
          const SizedBox(height: 16),
          buildSectionHeaderWithButton('Dados da Habilidade:', () => _addOrEditDie(isAbility: true)),
          ..._abilityDice.map((d) => ListTile(
              title: Text('${d.quantity}d${d.sides} (${d.damageType})', style: const TextStyle(color: Colors.white)),
              trailing: IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () => setState(() => _abilityDice.remove(d)),
              ))),
          const SizedBox(height: 16),
          buildSectionHeaderWithButton('Bases da Habilidade (Bónus de Dados):', _addBaseComponent),
          ..._baseComponents.map((c) => ListTile(
              title: Text('${c.type}: ${c.value}', style: const TextStyle(color: Colors.white)),
              trailing: IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () => setState(() => _baseComponents.remove(c)),
              ))),
          const SizedBox(height: 16),
          buildTextField(_bonusModifierController, 'Modificador de Bónus (Ex: 5, -2)', keyboardType: TextInputType.number),
       ],
        if (showDiceAndBases) ...[
          const SizedBox(height: 16),
          buildSectionHeaderWithButton('Gatilhos (Efeitos Condicionais):', () => _addOrEditTrigger()),
           ..._triggers.map((t) => ListTile(
            title: Text(t.description, style: const TextStyle(color: Colors.white)),
            subtitle: Text(_getTriggerEffectSubtitle(t), style: const TextStyle(color: Colors.grey)),
            trailing: IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: () => setState(() => _triggers.remove(t))),
             onTap: () => _addOrEditTrigger(effectToEdit: t),
          )),
        ]
    ];
  }

  List<Widget> _buildPassiveFields() {
    final statusBasedTriggers = ['Vida Perdida', 'Esforço Gasto', 'Sanidade Perdida', 'Loucura Gasta'];
    bool isStatusBasedTrigger = statusBasedTriggers.contains(_triggerType);

    return [
       buildSectionHeader("Gatilho"),
        buildDropdownField(
          _triggerType,
          ['Sempre Ativo','Ativável','Cooldown', ...statusBasedTriggers, 'Dano Sofrido'],
          'Tipo de Gatilho',
          (newValue) => setState(() => _triggerType = newValue!),
        ),
        if (_triggerType == 'Cooldown') ...[
          const SizedBox(height: 16),
          buildTextField(_cooldownController, 'Cooldown (em rounds)', keyboardType: TextInputType.number),
        ],
        if (isStatusBasedTrigger || _triggerType == 'Dano Sofrido') ...[
            const SizedBox(height: 16),
            buildDropdownField(
            _triggerFrequency,
            ['Acumulável', 'Uma Vez por Cooldown'],
            'Frequência do Gatilho',
            (newValue) => setState(() => _triggerFrequency = newValue!),
          ),
            if (_triggerFrequency == 'Uma Vez por Cooldown') ...[
              const SizedBox(height: 16),
              buildTextField(_cooldownController, 'Cooldown (em rounds)', keyboardType: TextInputType.number),
            ],
        ],
        if (isStatusBasedTrigger)
          CheckboxListTile(
            title: const Text("Inversamente Proporcional ao Status Total", style: TextStyle(color: Colors.white)),
            value: _basedOnTotal,
            onChanged: (newValue) => setState(() => _basedOnTotal = newValue ?? false),
            activeColor: Colors.blueAccent,
            checkColor: Colors.white,
            controlAffinity: ListTileControlAffinity.leading,
          ),
        if ((isStatusBasedTrigger && !_basedOnTotal) || _triggerType == 'Dano Sofrido') ...[
          const SizedBox(height: 16),
            buildDropdownField(
            _triggerValueType,
            ['Valor Fixo', 'Percentual'],
            'Tipo de Valor do Gatilho',
            (newValue) => setState(() => _triggerValueType = newValue!),
          ),
          const SizedBox(height: 16),
          buildTextField(_triggerValueController, 'Disparar a cada... (${_triggerValueType == 'Percentual' ? '%' : 'pontos'})'),
        ],
        const SizedBox(height: 16),
        buildSectionHeaderWithButton("Efeitos", _addOrEditPassiveEffect),
         ..._passiveEffects.map((effect) => ListTile(
              title: Text(
                  effect.bonusType == 'Conceder Armadura' ? 'Concede: ${effect.grantsArmor?.name}' : '${effect.bonusType} em ${effect.targets.join(", ")}',
                  style: const TextStyle(color: Colors.white)),
              subtitle: Text(
                effect.bonusType == 'Conceder Armadura'
                    ? effect.grantsArmor?.description ?? 'Sem descrição'
                    : 'Valor: ${effect.value}${effect.bonusType == 'Percentual' ? '%' : ''}',
                  style: const TextStyle(color: Colors.grey),
              ),
              trailing: IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () => setState(() => _passiveEffects.remove(effect)),
              ),
              onTap: () => _addOrEditPassiveEffect(effectToEdit: effect),
            )),
    ];
  }

  List<Widget> _buildStatusEffectFields() {
    return [
      buildTextField(_durationController, 'Duração em Turnos (-1 para permanente)',
                keyboardType: TextInputType.number),
            const SizedBox(height: 16),
            buildSectionHeader("Efeito"),
            buildDropdownField(
              _bonusType,
              ['Pontos de Bônus', 'Modificador', 'Percentual'],
              'Tipo de Bônus',
              (newValue) => setState(() => _bonusType = newValue!),
            ),
            const SizedBox(height: 16),
            buildTextField(_valueController, 'Valor do Efeito', keyboardType: TextInputType.number),
            const SizedBox(height: 16),
            CategorizedTargetSelector(
              selectedTargets: _selectedTargets,
              onSelectionChanged: (newSelection) {
                setState(() {
                  _selectedTargets = newSelection;
                });
              },
              allTargets: _getAllTargets(),
            )
    ];
  }

  IconData _getDefaultIcon() {
    switch (widget.entityType) {
      case EntityType.item: return Icons.backpack;
      case EntityType.weapon: return Icons.colorize;
      case EntityType.armor: return Icons.shield;
      case EntityType.ability: case EntityType.statusEffect: return Icons.star;
      case EntityType.passive: return Icons.auto_awesome;
    }
  }

  void _addOrEditEffect({ItemEffect? effectToEdit}) {
    final isEditing = effectToEdit != null;
    String bonusType = isEditing ? effectToEdit.bonusType : 'Pontos de Bônus';
    List<String> selectedTargets = isEditing ? List<String>.from(effectToEdit.targets) : [];
    final valueController = TextEditingController(text: isEditing ? effectToEdit.value.toString() : '0');

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.grey[850],
          title: Text(isEditing ? 'Editar Efeito' : 'Novo Efeito', style: const TextStyle(color: Colors.white)),
          content: StatefulBuilder(builder: (context, setDialogState) {
            return SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  buildDropdownField(
                    bonusType,
                    ['Pontos de Bônus', 'Modificador', 'Percentual'],
                    'Tipo de Bônus',
                    (newValue) => setDialogState(() => bonusType = newValue!),
                  ),
                  const SizedBox(height: 16),
                  CategorizedTargetSelector(
                    selectedTargets: selectedTargets,
                    onSelectionChanged: (newSelection) {
                       setDialogState(() {
                        selectedTargets = newSelection;
                      });
                    },
                    allTargets: _getAllTargets(),
                  ),
                  const SizedBox(height: 16),
                  buildTextField(valueController, 'Valor', keyboardType: TextInputType.number),
                ],
              ),
            );
          }),
          actions: [
            TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancelar', style: TextStyle(color: Colors.white70))),
            TextButton(
              onPressed: () {
                if (selectedTargets.isEmpty) return;
                final newEffect = ItemEffect(
                  targets: selectedTargets,
                  bonusType: bonusType,
                  value: double.tryParse(valueController.text) ?? 0,
                );
                setState(() {
                  if (isEditing) {
                    final index = _effects.indexOf(effectToEdit);
                    if (index != -1) _effects[index] = newEffect;
                  } else {
                    _effects.add(newEffect);
                  }
                });
                Navigator.of(context).pop();
              },
              child: Text(isEditing ? 'Salvar' : 'Adicionar',
                  style: const TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }

  void _addOrEditDie({DieSpecification? dieToEdit, Function(DieSpecification)? onSave, bool isAbility = false}) {
    final isEditing = dieToEdit != null;
    final quantityController = TextEditingController(text: isEditing ? dieToEdit.quantity.toString() : '1');
    final sidesController = TextEditingController(text: isEditing ? dieToEdit.sides.toString() : '20');
    String selectedDamageType = isEditing ? dieToEdit.damageType : _damageTypes.first;

    showDialog(context: context, builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.grey[850],
          title: Text(isEditing ? 'Modificar Dado' : 'Adicionar Dado', style: const TextStyle(color: Colors.white)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              buildTextField(quantityController, 'Quantidade', keyboardType: TextInputType.number),
              const SizedBox(height: 8),
              buildTextField(sidesController, 'Lados do Dado', keyboardType: TextInputType.number),
              const SizedBox(height: 8),
              buildDropdownField(selectedDamageType, _damageTypes, 'Tipo de Dano', (newValue) {
                  if (newValue != null) selectedDamageType = newValue;
                }),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancelar', style: TextStyle(color: Colors.white70))),
            TextButton(
              onPressed: () {
                final quantity = int.tryParse(quantityController.text) ?? 1;
                final sides = int.tryParse(sidesController.text) ?? 20;
                if (quantity > 0 && sides > 0) {
                  final newDie = DieSpecification(quantity: quantity, sides: sides, damageType: selectedDamageType);
                  if(onSave != null) {
                    onSave(newDie);
                  } else {
                     setState(() {
                       if (isAbility) {
                         if (isEditing) {
                            final index = _abilityDice.indexOf(dieToEdit);
                            if (index != -1) _abilityDice[index] = newDie;
                          } else {
                            _abilityDice.add(newDie);
                          }
                       } else {
                         if (isEditing) {
                           final index = _dice.indexOf(dieToEdit);
                           if (index != -1) _dice[index] = newDie;
                         } else {
                           _dice.add(newDie);
                         }
                       }
                      });
                  }
                }
                Navigator.of(context).pop();
              },
              child: Text(isEditing ? 'Salvar' : 'Adicionar', style: const TextStyle(color: Colors.blueAccent)),
            ),
          ],
        );
      },
    );
  }

  void _addOrEditTrigger({ConditionalEffect? effectToEdit}) {
    final isEditing = effectToEdit != null;
    final descriptionController = TextEditingController(text: isEditing ? effectToEdit.description : '');
    String conditionSource = isEditing ? effectToEdit.conditionSource : 'DADO_EXTRA';
    final requiredSuccessesController = TextEditingController(text: isEditing ? effectToEdit.requiredSuccesses.toString() : '1');
    final dieSidesController = TextEditingController(text: isEditing ? effectToEdit.conditionDieSides.toString() : '20');
    final targetValueController = TextEditingController(text: isEditing ? effectToEdit.conditionTargetValue.toString() : '18');
    String conditionOperator = isEditing ? effectToEdit.conditionOperator : '>=';
    String effectType = isEditing ? effectToEdit.effectType : 'Multiplicador de Dano';
    final multiplierController = TextEditingController(text: isEditing ? effectToEdit.multiplier.toString() : '1.5');
    List<DieSpecification> bonusDice = isEditing ? List.from(effectToEdit.bonusDice) : [];
    final bonusModifierController = TextEditingController(text: isEditing ? effectToEdit.bonusModifier.toString() : '5');

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.grey[850],
          title: Text(isEditing ? 'Editar Gatilho' : 'Novo Gatilho', style: const TextStyle(color: Colors.white)),
          content: StatefulBuilder(builder: (context, setDialogState) {
            return SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  buildTextField(descriptionController, 'Nome/Descrição do Gatilho'),
                  const SizedBox(height: 16),
                  buildSectionHeader('Condição'),
                  buildDropdownField(conditionSource, ['ROLAGEM', 'DADO_EXTRA'], 'Fonte da Condição',
                      (val) => setDialogState(() => conditionSource = val!)),
                  const SizedBox(height: 8),
                  if (conditionSource == 'ROLAGEM')
                    buildTextField(requiredSuccessesController, 'Sucessos Necessários', keyboardType: TextInputType.number),
                  if (conditionSource == 'DADO_EXTRA')
                    buildTextField(dieSidesController, 'Lados do Dado Extra', keyboardType: TextInputType.number),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        flex: 1,
                        child: buildDropdownField(conditionOperator, ['>=', '<='], '', (val) => setDialogState(() => conditionOperator = val!)),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        flex: 2,
                        child: buildTextField(targetValueController, 'Valor Alvo', keyboardType: TextInputType.number),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  buildSectionHeader('Efeito'),
                  buildDropdownField(effectType, ['Multiplicador de Dano', 'Adicionar Dados', 'Adicionar Modificador'],
                      'Tipo de Efeito', (val) => setDialogState(() => effectType = val!)),
                  const SizedBox(height: 8),
                  if (effectType == 'Multiplicador de Dano')
                    buildTextField(multiplierController, 'Multiplicador (Ex: 1.5)',
                        keyboardType: const TextInputType.numberWithOptions(decimal: true)),
                  if (effectType == 'Adicionar Dados')
                    ...bonusDice.map((d) => ListTile(
                          title: Text('${d.quantity}d${d.sides}', style: const TextStyle(color: Colors.white)),
                          trailing: IconButton(
                              icon: const Icon(Icons.delete, color: Colors.redAccent),
                              onPressed: () => setDialogState(() => bonusDice.remove(d))),
                        )),
                  if (effectType == 'Adicionar Dados')
                    TextButton.icon(
                        onPressed: () => _addOrEditDie(onSave: (newDie) => setDialogState(() => bonusDice.add(newDie))),
                        icon: const Icon(Icons.add, color: Colors.white),
                        label: const Text('Adicionar Dado Bônus', style: TextStyle(color: Colors.white))),
                  if (effectType == 'Adicionar Modificador')
                    buildTextField(bonusModifierController, 'Modificador Bônus', keyboardType: TextInputType.number),
                ],
              ),
            );
          }),
          actions: [
            TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancelar', style: TextStyle(color: Colors.white70))),
            TextButton(
              onPressed: () {
                final newTrigger = ConditionalEffect(
                  description: descriptionController.text,
                  conditionSource: conditionSource,
                  requiredSuccesses: int.tryParse(requiredSuccessesController.text) ?? 1,
                  conditionDieSides: int.tryParse(dieSidesController.text) ?? 20,
                  conditionTargetValue: int.tryParse(targetValueController.text) ?? 18,
                  conditionOperator: conditionOperator,
                  effectType: effectType,
                  multiplier: double.tryParse(multiplierController.text) ?? 1.5,
                  bonusDice: bonusDice,
                  bonusModifier: int.tryParse(bonusModifierController.text) ?? 5,
                );
                setState(() {
                  if (isEditing) {
                    final index = _triggers.indexOf(effectToEdit);
                    if (index != -1) _triggers[index] = newTrigger;
                  } else {
                    _triggers.add(newTrigger);
                  }
                });
                Navigator.of(context).pop();
              },
              child: Text(isEditing ? 'Salvar' : 'Adicionar', style: const TextStyle(color: Colors.blueAccent)),
            ),
          ],
        );
      },
    );
  }

  void _addOrEditResistance({String? damageType}) {
    final isEditing = damageType != null;
    String selectedDamageType = damageType ?? _damageTypes.first;
    final resistanceController = TextEditingController(text: isEditing ? ((1 - (_resistances[damageType] ?? 1.0)) * 100).toStringAsFixed(0) : '50');

    showDialog(context: context, builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[850],
        title: Text(isEditing ? 'Editar Resistência' : 'Nova Resistência', style: const TextStyle(color: Colors.white)),
        content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
                if (!isEditing)
                buildDropdownField(selectedDamageType, _damageTypes, 'Tipo de Dano', (newValue) {
                    if (newValue != null) selectedDamageType = newValue;
                }),
                const SizedBox(height: 16),
                buildTextField(resistanceController, 'Valor (% de Resistência/Vulnerabilidade)'),
                const Text('Valores positivos são resistência (50% = metade do dano). Valores negativos são vulnerabilidade (-50% = 50% a mais de dano).', style: TextStyle(color: Colors.grey, fontSize: 12))
            ],
        ),
        actions: [
            TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancelar')),
            TextButton(onPressed: () {
                final value = double.tryParse(resistanceController.text) ?? 0;
                final multiplier = 1 - (value / 100);
                setState(() {
                    _resistances[selectedDamageType] = multiplier;
                });
                Navigator.of(context).pop();
            }, child: const Text('Salvar'))
        ],
    ));
  }

  void _addBaseComponent() {
    String type = 'Atributo';
    String? value;

    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            backgroundColor: Colors.grey[850],
            title: const Text('Adicionar Base', style: TextStyle(color: Colors.white)),
            content: StatefulBuilder(builder: (context, setDialogState) {
              final items = type == 'Atributo' ? widget.characterAttributes : widget.characterPericias;
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  buildDropdownField(type, ['Atributo', 'Perícia'], 'Tipo',
                      (newValue) => setDialogState(() {
                            type = newValue!;
                            value = null;
                          })),
                  const SizedBox(height: 16),
                  if (items.isNotEmpty)
                    buildDropdownField(value, items, 'Valor', (newValue) => setDialogState(() => value = newValue)),
                ],
              );
            }),
            actions: [
              TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancelar')),
              TextButton(
                  onPressed: () {
                    if (value != null) {
                      setState(() => _baseComponents.add(BaseComponent(type: type, value: value!)));
                    }
                    Navigator.of(context).pop();
                  },
                  child: const Text('Adicionar')),
            ],
          );
        });
  }

  void _defineArmorForAbility() {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => AddEditEntityForm(
        entityType: EntityType.armor,
        initialEntity: _armorToCreate,
        onSave: (savedArmor) {
          setState(() {
            _armorToCreate = savedArmor as Armor;
          });
        },
      )
    ));
  }

  void _addOrEditPassiveEffect({PassiveEffect? effectToEdit}) {
     final isEditing = effectToEdit != null;
    String bonusType = isEditing ? effectToEdit.bonusType : 'Pontos de Bônus';
    List<String> selectedTargets = isEditing ? List<String>.from(effectToEdit.targets) : [];
    final valueController = TextEditingController(text: isEditing ? effectToEdit.value.toString() : '0');
    Armor? grantsArmor = isEditing ? effectToEdit.grantsArmor : null;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.grey[850],
          title: Text(isEditing ? 'Editar Efeito' : 'Novo Efeito', style: const TextStyle(color: Colors.white)),
          content: StatefulBuilder(builder: (context, setDialogState) {
            void defineArmorForEffect() {
              _defineArmorForPassive((newArmor) {
                setDialogState(() => grantsArmor = newArmor);
              }, initialArmor: grantsArmor);
            }

            return SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  buildDropdownField(
                    bonusType,
                    ['Pontos de Bônus', 'Modificador', 'Percentual', 'Conceder Armadura'],
                    'Tipo de Bônus',
                    (newValue) => setDialogState(() => bonusType = newValue!),
                  ),
                  const SizedBox(height: 16),
                  if (bonusType != 'Conceder Armadura')
                    CategorizedTargetSelector(
                      selectedTargets: selectedTargets,
                      onSelectionChanged: (newSelection) {
                        setDialogState(() {
                          selectedTargets = newSelection;
                        });
                      },
                      allTargets: _getAllTargets(),
                    ),
                  if (bonusType == 'Conceder Armadura') ...[
                    const SizedBox(height: 16),
                    ListTile(
                      leading: const Icon(Icons.shield, color: Colors.white),
                      title: Text(grantsArmor?.name ?? 'Definir Armadura', style: const TextStyle(color: Colors.white)),
                      onTap: defineArmorForEffect,
                      tileColor: Colors.grey[800],
                    )
                  ],
                  if (bonusType != 'Conceder Armadura') ...[
                    const SizedBox(height: 16),
                    buildTextField(valueController, bonusType == 'Pontos de Bônus' ? 'Pontos' : 'Valor'),
                  ]
                ],
              ),
            );
          }),
          actions: [
             TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancelar', style: TextStyle(color: Colors.grey))),
            TextButton(
              onPressed: () {
                if (selectedTargets.isEmpty && bonusType != 'Conceder Armadura') return;
                if (grantsArmor == null && bonusType == 'Conceder Armadura') return;

                final newEffect = PassiveEffect(
                  targets: selectedTargets,
                  bonusType: bonusType,
                  value: double.tryParse(valueController.text) ?? 0,
                  grantsArmor: grantsArmor,
                );

                setState(() {
                  if (isEditing) {
                    final index = _passiveEffects.indexOf(effectToEdit);
                    if (index != -1) _passiveEffects[index] = newEffect;
                  } else {
                    _passiveEffects.add(newEffect);
                  }
                });

                Navigator.of(context).pop();
              },
              child: Text(isEditing ? 'Salvar' : 'Adicionar', style: const TextStyle(color: Colors.blueAccent)),
            ),
          ],
        );
      },
    );
  }

  void _defineArmorForPassive(Function(Armor) onSave, {Armor? initialArmor}) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => AddEditEntityForm(
        entityType: EntityType.armor,
        initialEntity: initialArmor,
        onSave: (savedArmor) {
          onSave(savedArmor as Armor);
        },
      )
    ));
  }


  String _getTriggerEffectSubtitle(ConditionalEffect effect) {
    switch (effect.effectType) {
      case 'Multiplicador de Dano': return 'Multiplicador: x${effect.multiplier}';
      case 'Adicionar Dados': return 'Adiciona: ${effect.bonusDice.map((d) => '${d.quantity}d${d.sides}').join(', ')}';
      case 'Adicionar Modificador': return 'Adiciona: +${effect.bonusModifier} de modificador';
      default: return '';
    }
  }
}
