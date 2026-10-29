// lib/screens/add_edit_entity_form.dart

import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:overlord/models/ability.dart';
import 'package:overlord/models/armor.dart';
import 'package:overlord/models/die_specification.dart';
import 'package:overlord/models/item.dart';
import 'package:overlord/models/passive.dart';
import 'package:overlord/models/status_effect.dart';
import 'package:overlord/models/weapon.dart';
import 'package:overlord/widgets/effect_configurator.dart';
import 'package:overlord/models/elemental_system.dart';
import 'package:overlord/utils/smart_entity_parser.dart';

enum EntityType { weapon, armor, item, ability, ritual, passive, statusEffect }

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
  String _creationMode = 'Simples'; 

  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();

  // COMUNS HABILIDADE/RITUAL
  String _abilityType = 'Dano';
  final _costAmountController = TextEditingController(text: '0');
  String _costType = 'Esforço';
  String _costSource = 'Padrão';
  final _cooldownController = TextEditingController(text: '0');
  
  // DADOS E MULTIPLICADORES
  final List<DieSpecification> _bonusDice = [];
  final _bonusModifierController = TextEditingController(text: '0');
  final _multiplierController = TextEditingController(text: '1.0');
  
  // COMPONENTES BASE (Atributos/Pericias)
  final List<BaseComponent> _baseComponents = [];
  
  // ATAQUE
  bool _useWeaponDamage = false;
  String? _attackSkill;
  final _attackBonusController = TextEditingController(text: '0');
  final _attackMultiplierController = TextEditingController(text: '1.0');
  
  // BUFFS / EFEITOS
  final List<PassiveEffect> _effects = [];
  final List<ConditionalEffect> _conditionalEffects = [];
  Armor? _armorToCreate;

  // OPÇÕES AVANÇADAS
  final _targetCountController = TextEditingController(text: '1');
  final _rangeController = TextEditingController(text: 'Corpo-a-Corpo');
  final _areaController = TextEditingController(text: 'Nenhuma');
  bool _hasBurn = false;
  final _burnDamageController = TextEditingController(text: '1d6');
  final _burnDurationController = TextEditingController(text: '3');

  // MACROS BUFF SIMPLES
  String _simpleBuffMacro = 'Todos os Atributos';
  String _simpleBuffBonusType = 'Modificador';
  final _simpleBuffValueController = TextEditingController(text: '0');

  // NOVOS CAMPOS PARA O LEGADO DA NEVASCA E PASSIVAS
  final List<StatusEffect> _selfStatusEffectsToApply = [];
  String? _dynamicHealingStat;
  final _dynamicHealingPercentageController = TextEditingController(text: '0.0');

  // PASSIVAS E OUTROS
  String _triggerType = 'Ativável';
  String _triggerValueType = 'Fixo';
  final _triggerValueController = TextEditingController(text: '0');
  String _triggerFrequency = 'Acumulável';
  final _maxStacksController = TextEditingController(text: '0'); // CORREÇÃO: Controle de Acúmulo Máximo!
  bool _basedOnTotal = false;

  // ARMADURAS
  final _reductionValueController = TextEditingController(text: '0');
  final _maxHitsController = TextEditingController(text: '0');

  // STATUS EFFECT
  String _effectTypeStr = 'statChange';
  String _effectTriggerStr = 'instant';
  final _valueFormulaController = TextEditingController(text: '1d4');
  final _durationFormulaController = TextEditingController(text: '0');
  String _targetStat = 'Vida';
  bool _isPercentage = false;

  final List<String> _abilityTypes = ['Dano', 'Defesa', 'Restaurar Vida', 'Restaurar Esforço', 'Buff/Transformação', 'Criar Armadura', 'Misto'];
  final List<String> _costTypes = ['Esforço', 'Vida', 'Sanidade', 'Loucura', 'Nenhum'];
  final List<String> _costSources = ['Padrão', 'Apenas Temporário', 'Híbrido (Temp. > Padrão)'];
  // CORREÇÃO: Adicionado Gatilhos Específicos
  final List<String> _triggerTypes = ['Sempre Ativo', 'Início do Turno', 'Fim do Turno', 'Sem Atacar no Turno', 'Dano Sofrido', 'Dano Causado', 'Esquiva', 'Bloqueio', 'Vida Perdida', 'Esforço Gasto', 'Sanidade Perdida', 'Loucura Gasta', 'Acerto Crítico', 'Falha Crítica', 'Cooldown', 'Ativável', 'Oculto', 'Manual (Apenas Botão)'];
  final List<String> _triggerFrequencies = ['Sempre', 'Uma Vez por Combate', 'Uma Vez por Cooldown', 'Acumulável'];

void _showEditSimpleEffectDialog(int index) {
    final effect = _effects[index];
    final valCtrl = TextEditingController(text: effect.value.toString());
    String bType = effect.bonusType;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: const Text('Editar Bônus', style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("Alvo(s): ${effect.targets.join(', ')}", style: const TextStyle(fontSize: 12, color: Colors.grey)),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              initialValue: bType,
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
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar', style: TextStyle(color: Colors.grey))),
          TextButton(
            onPressed: () {
              setState(() {
                _effects[index] = PassiveEffect(
                  targets: effect.targets,
                  bonusType: bType,
                  value: double.tryParse(valCtrl.text) ?? effect.value,
                  bonusDamageType: effect.bonusDamageType,
                  perRoundValue: effect.perRoundValue
                );
              });
              Navigator.pop(ctx);
            },
            child: const Text('Salvar', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    if (widget.initialEntity != null) {
      if (widget.entityType == EntityType.ability || widget.entityType == EntityType.ritual) {
         _creationMode = 'Avançado'; 
      } else if (widget.entityType == EntityType.passive) {
         _creationMode = 'Padrão';
      } else {
         _creationMode = 'Simples';
      }
      _loadEntity(widget.initialEntity);
    } else {
       if (widget.entityType == EntityType.ability || widget.entityType == EntityType.ritual || widget.entityType == EntityType.passive) {
         _creationMode = 'Automático'; 
       } else {
         _creationMode = 'Simples';
       }
    }
  }

  void _loadEntity(dynamic entity) {
    _nameController.text = entity.name ?? '';
    _descriptionController.text = entity.description ?? '';
    
    if (entity is Ability) {
      _abilityType = _abilityTypes.contains(entity.abilityType) ? entity.abilityType : 'Dano';
      _costAmountController.text = entity.costAmount.toString();
      _costType = _costTypes.contains(entity.costType) ? entity.costType : 'Esforço';
      _costSource = _costSources.contains(entity.costSource) ? entity.costSource : 'Padrão';
      _cooldownController.text = entity.cooldown.toString();
      _bonusDice.addAll(entity.bonusDice);
      _bonusModifierController.text = entity.bonusModifier.toString();
      _multiplierController.text = entity.multiplier.toString();
      _baseComponents.addAll(entity.baseComponents);
      _useWeaponDamage = entity.useWeaponDamage;
      
      if (entity.attackSkill != null) {
         _attackSkill = widget.characterPericias.contains(entity.attackSkill) ? entity.attackSkill : null;
      }

      _attackBonusController.text = entity.attackBonus.toString();
      _attackMultiplierController.text = entity.attackMultiplier.toString();
      _effects.addAll(entity.effects);
      _armorToCreate = entity.armorToCreate;
      _conditionalEffects.addAll(entity.conditionalEffects);
      _targetCountController.text = entity.targetCount.toString();
      _rangeController.text = entity.range;
      _areaController.text = entity.areaOfEffect;
      _hasBurn = entity.hasBurn;
      _burnDamageController.text = entity.burnDamage;
      _burnDurationController.text = entity.burnDuration.toString();
      _selfStatusEffectsToApply.addAll(entity.selfStatusEffectsToApply);
      _dynamicHealingStat = entity.dynamicHealingStat;
      _dynamicHealingPercentageController.text = entity.dynamicHealingPercentage.toString();
    } else if (entity is Passive) {
      String tType = entity.triggerType == 'Manual' ? 'Manual (Apenas Botão)' : entity.triggerType;
      _triggerType = _triggerTypes.contains(tType) ? tType : 'Sempre Ativo';
      _triggerValueType = ['Fixo', 'Percentual'].contains(entity.triggerValueType) ? entity.triggerValueType : 'Fixo';
      _triggerValueController.text = entity.triggerValue.toString();
      _triggerFrequency = _triggerFrequencies.contains(entity.triggerFrequency) ? entity.triggerFrequency : 'Sempre';
      _basedOnTotal = entity.basedOnTotal;
      _cooldownController.text = entity.cooldown.toString();
      _maxStacksController.text = entity.stacks.toString(); // CARREGA ACÚMULOS
      _effects.addAll(entity.effects);
      _costAmountController.text = entity.costAmount.toString();
      _costType = _costTypes.contains(entity.costType) ? entity.costType : 'Esforço';
      _costSource = _costSources.contains(entity.costSource) ? entity.costSource : 'Padrão';
      _selfStatusEffectsToApply.addAll(entity.selfStatusEffectsToApply);
      _dynamicHealingStat = entity.dynamicHealingStat;
      _dynamicHealingPercentageController.text = entity.dynamicHealingPercentage.toString();
    } else if (entity is Weapon) {
      _bonusDice.addAll(entity.dice);
      _bonusModifierController.text = entity.modifier.toString();
      _multiplierController.text = entity.multiplier.toString();
      if (entity.attackSkill != null) {
         _attackSkill = widget.characterPericias.contains(entity.attackSkill) ? entity.attackSkill : null;
      }
      _attackBonusController.text = entity.attackBonus.toString();
      _attackMultiplierController.text = entity.attackMultiplier.toString();
      _conditionalEffects.addAll(entity.triggers);
      _effects.addAll(entity.effects.map((e) => PassiveEffect(targets: e.targets, bonusType: e.bonusType, value: e.value, bonusDamageType: e.bonusDamageType, perRoundValue: e.perRoundValue)));
    } else if (entity is Armor) {
      _reductionValueController.text = entity.reductionValue.toString();
      _maxHitsController.text = entity.maxHits.toString();
      _effects.addAll(entity.effects.map((e) => PassiveEffect(targets: e.targets, bonusType: e.bonusType, value: e.value, bonusDamageType: e.bonusDamageType, perRoundValue: e.perRoundValue)));
    } else if (entity is Item) {
      _effects.addAll(entity.effects.map((e) => PassiveEffect(targets: e.targets, bonusType: e.bonusType, value: e.value, bonusDamageType: e.bonusDamageType, perRoundValue: e.perRoundValue)));
    } else if (entity is StatusEffect) {
      _effectTypeStr = EffectType.values.any((e) => e.name == entity.type.name) ? entity.type.name : EffectType.statChange.name;
      _effectTriggerStr = EffectTrigger.values.any((e) => e.name == entity.trigger.name) ? entity.trigger.name : EffectTrigger.instant.name;
      _valueFormulaController.text = entity.valueFormula;
      _durationFormulaController.text = entity.durationFormula;
      
      final allPossibleStats = ['Vida', 'Sanidade', 'Esforço', ...widget.characterAttributes, ...widget.characterPericias, 'Defesa', 'Esquiva'];
      _targetStat = allPossibleStats.contains(entity.targetStat) ? entity.targetStat : 'Vida';
      
      _isPercentage = entity.isPercentage;
    }
  }

  void _runAutoGenerator() {
    final desc = _descriptionController.text;
    if (desc.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Escreva a descrição primeiro!')));
      return;
    }

    Ability parsedAbility = SmartEntityParser.parseTextToEntity(desc, 'Ability');

    setState(() {
      _nameController.text = parsedAbility.name;
      _costAmountController.text = parsedAbility.costAmount.toString();
      _costType = parsedAbility.costType;
      _cooldownController.text = parsedAbility.cooldown.toString();
      
      _effects.clear();
      _effects.addAll(parsedAbility.effects);
      
      _selfStatusEffectsToApply.clear();
      _selfStatusEffectsToApply.addAll(parsedAbility.selfStatusEffectsToApply);
      
      _dynamicHealingStat = parsedAbility.dynamicHealingStat;
      _dynamicHealingPercentageController.text = parsedAbility.dynamicHealingPercentage.toString();

      _creationMode = 'Avançado';
    });
    
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('✨ Habilidade Inteligente Gerada! Revise no modo Avançado.'), backgroundColor: Colors.green));
  }

  void _saveForm() {
    if (_formKey.currentState!.validate()) {
      dynamic entity;
      final tTrigger = _triggerType == 'Manual (Apenas Botão)' ? 'Manual' : _triggerType;

      if (widget.entityType == EntityType.ability || widget.entityType == EntityType.ritual) {
        entity = Ability(
          selfStatusEffectsToApply: _selfStatusEffectsToApply,
          dynamicHealingStat: _dynamicHealingStat,
          dynamicHealingPercentage: double.tryParse(_dynamicHealingPercentageController.text) ?? 0.0,
          id: widget.initialEntity?.id,
          name: _nameController.text.isNotEmpty ? _nameController.text : 'Nova Habilidade',
          description: _descriptionController.text,
          abilityType: _abilityType,
          costAmount: int.tryParse(_costAmountController.text) ?? 0,
          costType: _costType,
          costSource: _costSource,
          cooldown: int.tryParse(_cooldownController.text) ?? 0,
          bonusDice: _bonusDice,
          bonusModifier: int.tryParse(_bonusModifierController.text) ?? 0,
          multiplier: double.tryParse(_multiplierController.text) ?? 1.0,
          baseComponents: _baseComponents,
          useWeaponDamage: _useWeaponDamage,
          attackSkill: _attackSkill,
          attackBonus: int.tryParse(_attackBonusController.text) ?? 0,
          attackMultiplier: double.tryParse(_attackMultiplierController.text) ?? 1.0,
          effects: _effects,
          armorToCreate: _armorToCreate,
          conditionalEffects: _conditionalEffects,
          targetCount: int.tryParse(_targetCountController.text) ?? 1,
          range: _rangeController.text.isEmpty ? 'Corpo-a-Corpo' : _rangeController.text,
          areaOfEffect: _areaController.text.isEmpty ? 'Nenhuma' : _areaController.text,
          hasBurn: _hasBurn,
          burnDamage: _burnDamageController.text,
          burnDuration: int.tryParse(_burnDurationController.text) ?? 0,
          
          imagePath: widget.initialEntity?.imagePath,
          isActive: widget.initialEntity?.isActive ?? false,
          usesInCombat: widget.initialEntity?.usesInCombat ?? 0,
          currentCooldown: widget.initialEntity?.currentCooldown ?? 0,
          dotDamage: widget.initialEntity?.dotDamage ?? 0,
          dotTurns: widget.initialEntity?.dotTurns ?? 0,
          dotElement: widget.initialEntity?.dotElement ?? 'Fogo',
          stunDuration: widget.initialEntity?.stunDuration,
          costPerRound: widget.initialEntity?.costPerRound ?? 0,
          extraCosts: widget.initialEntity?.extraCosts ?? const {},
          actionType: widget.initialEntity?.actionType ?? 'MAG',
        );
      } else if (widget.entityType == EntityType.passive) {
        entity = Passive(
          costAmount: int.tryParse(_costAmountController.text) ?? 0,
          costType: _costType,
          costSource: _costSource,
          selfStatusEffectsToApply: _selfStatusEffectsToApply,
          dynamicHealingStat: _dynamicHealingStat,
          dynamicHealingPercentage: double.tryParse(_dynamicHealingPercentageController.text) ?? 0.0,
          id: widget.initialEntity?.id,
          name: _nameController.text.isNotEmpty ? _nameController.text : 'Nova Passiva',
          description: _descriptionController.text,
          triggerType: tTrigger,
          triggerValueType: _triggerValueType,
          triggerValue: int.tryParse(_triggerValueController.text) ?? 0,
          triggerFrequency: _triggerFrequency,
          basedOnTotal: _basedOnTotal,
          cooldown: int.tryParse(_cooldownController.text) ?? 0,
          effects: _effects,
          
          isActive: widget.initialEntity?.isActive ?? false,
          stacks: int.tryParse(_maxStacksController.text) ?? 0, // CORREÇÃO: Salva os Stacks Máximos Corretamente
          currentCooldown: widget.initialEntity?.currentCooldown ?? 0,
        );
      } else if (widget.entityType == EntityType.weapon) {
        entity = Weapon(
          id: widget.initialEntity?.id ?? const Uuid().v4(),
          name: _nameController.text.isNotEmpty ? _nameController.text : 'Nova Arma',
          description: _descriptionController.text,
          dice: _bonusDice,
          modifier: int.tryParse(_bonusModifierController.text) ?? 0,
          multiplier: double.tryParse(_multiplierController.text) ?? 1.0,
          attackSkill: _attackSkill,
          attackBonus: int.tryParse(_attackBonusController.text) ?? 0,
          attackMultiplier: double.tryParse(_attackMultiplierController.text) ?? 1.0,
          triggers: _conditionalEffects,
          effects: _effects.map((e) => ItemEffect(targets: e.targets, bonusType: e.bonusType, value: e.value, bonusDamageType: e.bonusDamageType, perRoundValue: e.perRoundValue)).toList(),
          isEquipped: widget.initialEntity?.isEquipped ?? false,
          imagePath: widget.initialEntity?.imagePath,
        );
      } else if (widget.entityType == EntityType.armor) {
        entity = Armor(
          id: widget.initialEntity?.id ?? const Uuid().v4(),
          name: _nameController.text.isNotEmpty ? _nameController.text : 'Nova Armadura',
          description: _descriptionController.text,
          reductionValue: int.tryParse(_reductionValueController.text) ?? 0,
          maxHits: int.tryParse(_maxHitsController.text) ?? 0,
          effects: _effects.map((e) => ItemEffect(targets: e.targets, bonusType: e.bonusType, value: e.value, bonusDamageType: e.bonusDamageType, perRoundValue: e.perRoundValue)).toList(),
          currentHits: widget.initialEntity != null ? widget.initialEntity!.currentHits : (int.tryParse(_maxHitsController.text) ?? 0),
          isEquipped: widget.initialEntity?.isEquipped ?? false,
          imagePath: widget.initialEntity?.imagePath,
          reductionTypes: widget.initialEntity?.reductionTypes ?? [],
          resistances: widget.initialEntity?.resistances ?? {},
        );
      } else if (widget.entityType == EntityType.item) {
        entity = Item(
          id: widget.initialEntity?.id ?? const Uuid().v4(),
          name: _nameController.text.isNotEmpty ? _nameController.text : 'Novo Item',
          description: _descriptionController.text,
          effects: _effects.map((e) => ItemEffect(targets: e.targets, bonusType: e.bonusType, value: e.value, bonusDamageType: e.bonusDamageType, perRoundValue: e.perRoundValue)).toList(),
          isEquipped: widget.initialEntity?.isEquipped ?? false,
          imagePath: widget.initialEntity?.imagePath,
        );
      } else if (widget.entityType == EntityType.statusEffect) {
         EffectType eType = EffectType.values.firstWhere((e) => e.name == _effectTypeStr, orElse: () => EffectType.statChange);
         EffectTrigger eTrigger = EffectTrigger.values.firstWhere((e) => e.name == _effectTriggerStr, orElse: () => EffectTrigger.instant);
         
         entity = StatusEffect(
           id: widget.initialEntity?.id ?? const Uuid().v4(),
           name: _nameController.text.isNotEmpty ? _nameController.text : 'Novo Efeito',
           description: _descriptionController.text,
           type: eType,
           trigger: eTrigger,
           valueFormula: _valueFormulaController.text,
           durationFormula: _durationFormulaController.text,
           targetStat: _targetStat,
           isPercentage: _isPercentage,
           
           value: widget.initialEntity?.value ?? 0.0,
           perRoundValue: widget.initialEntity?.perRoundValue ?? 0.0,
           durationInRounds: widget.initialEntity?.durationInRounds ?? 0,
           imagePath: widget.initialEntity?.imagePath,
           targets: widget.initialEntity?.targets ?? [],
           bonusType: widget.initialEntity?.bonusType ?? 'Modificador',
         );
      }
      
      widget.onSave(entity);
      Navigator.of(context).pop();
    }
  }

  Widget _buildTextField(TextEditingController controller, String label, {bool isNumber = false, bool isRequired = false, int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        maxLines: maxLines,
        style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: Colors.black26,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        ),
        validator: isRequired ? (v) => v == null || v.isEmpty ? 'Obrigatório' : null : null,
      ),
    );
  }

  // CORREÇÃO: Processar Danos Específicos Corretamente
  List<String> _getSimplifiedTargets(String macro) {
    if (macro.startsWith('Dano ')) {
      return [macro.replaceAll('Dano ', '')];
    }

    switch(macro) {
      case 'Todos os Testes': return ['FOR','CON','DES','INT','SAB','CAR', ...widget.characterPericias]; 
      case 'Todos os Atributos': return ['FOR','CON','DES','INT','SAB','CAR'];
      case 'Todas as Perícias': return widget.characterPericias.isNotEmpty ? widget.characterPericias : ['Acrobacia', 'Atletismo', 'Oculto', 'Pontaria'];
      case 'Perícias Físicas': return ['Atletismo', 'Acrobacia', 'Reflexo', 'Ladinagem', 'Artes-marciais', 'Furtividade'];
      case 'Todos os Danos': return ElementalSystem.allElements; // PUXA A LISTA COMPLETA
      case 'Tudo': return ['FOR','CON','DES','INT','SAB','CAR', 'Vida', 'Esforço', 'Sanidade', ...widget.characterPericias];
      default: return [macro];
    }
  }

  void _addSimpleBuff() {
    setState(() {
      _effects.add(PassiveEffect(
        targets: _getSimplifiedTargets(_simpleBuffMacro),
        bonusType: _simpleBuffBonusType,
        value: double.tryParse(_simpleBuffValueController.text) ?? 0.0
      ));
    });
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Efeito adicionado!'), backgroundColor: Colors.blueAccent));
  }

  void _showAddDieDialog(List<DieSpecification> listToUpdate) {
    int q = 1; int s = 20; String type = 'Físico';
    final damageTypes = [...ElementalSystem.allElements, 'Cura']; // Puxa todos do Sistema + Cura

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Adicionar Dado'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
             TextFormField(initialValue: '1', decoration: const InputDecoration(labelText: 'Quantidade'), keyboardType: TextInputType.number, onChanged: (v) => q = int.tryParse(v) ?? 1),
             TextFormField(initialValue: '20', decoration: const InputDecoration(labelText: 'Lados (Ex: 6 para d6)'), keyboardType: TextInputType.number, onChanged: (v) => s = int.tryParse(v) ?? 20),
             DropdownButtonFormField<String>(
               initialValue: damageTypes.contains(type) ? type : damageTypes.first, 
               items: damageTypes.map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
               onChanged: (v) => type = v!, decoration: const InputDecoration(labelText: 'Tipo de Dano'),
             ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
          TextButton(onPressed: () { setState(() => listToUpdate.add(DieSpecification(quantity: q, sides: s, damageType: type))); Navigator.pop(context); }, child: const Text('Adicionar')),
        ],
      ),
    );
  }

  Widget _buildDiceSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            ElevatedButton.icon(
              onPressed: () => _showAddDieDialog(_bonusDice),
              icon: const Icon(Icons.add),
              label: const Text('Adicionar Dados'),
            ),
          ],
        ),
        if (_bonusDice.isNotEmpty)
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _bonusDice.length,
            itemBuilder: (context, index) {
              final die = _bonusDice[index];
              return ListTile(
                title: Text('${die.quantity}d${die.sides} (${die.damageType})'),
                trailing: IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: () => setState(() => _bonusDice.removeAt(index))),
              );
            },
          ),
      ],
    );
  }

 void _showAddConditionalEffectDialog(List<ConditionalEffect> listToUpdate) {
    String effectType = 'Multiplicador de Dano';
    String conditionSource = 'ROLAGEM';
    String conditionOperator = '>=';
    final descCtrl = TextEditingController();
    final targetValueCtrl = TextEditingController(text: '20');
    final requiredSuccessesCtrl = TextEditingController(text: '1');
    final modifierCtrl = TextEditingController(text: '0');
    final multiplierCtrl = TextEditingController(text: '2.0');
    final dieSidesCtrl = TextEditingController(text: '100'); 
    
    int q = 1; int s = 6; String dmgType = 'Físico';

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Theme.of(context).cardColor,
        title: const Text('Novo Gatilho Preciso', style: TextStyle(color: Colors.amber)),
        content: StatefulBuilder(
          builder: (context, setDialogState) {
            return SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(controller: descCtrl, style: const TextStyle(color: Colors.white), decoration: const InputDecoration(labelText: 'Descrição (Ex: 30% de chance...)', filled: true)),
                  const SizedBox(height: 12),
                  const Text('Condição de Ativação:', style: TextStyle(color: Colors.white70, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: DropdownButtonFormField<String>(
                          initialValue: conditionSource,
                          dropdownColor: Colors.grey[900],
                          items: ['ROLAGEM', 'DADO_INDEPENDENTE', 'DANO_SOFRIDO', 'VIDA_ATUAL', 'STATUS'].map((e) => DropdownMenuItem(value: e, child: Text(e, style: const TextStyle(color: Colors.white, fontSize: 10)))).toList(),
                          onChanged: (v) => setDialogState(() => conditionSource = v!),
                          decoration: const InputDecoration(labelText: 'Alvo', filled: true),
                        ),
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        flex: 1,
                        child: DropdownButtonFormField<String>(
                          initialValue: conditionOperator,
                          dropdownColor: Colors.grey[900],
                          items: ['==', '>=', '<=', '>', '<', '!='].map((e) => DropdownMenuItem(value: e, child: Text(e, style: const TextStyle(color: Colors.white)))).toList(),
                          onChanged: (v) => setDialogState(() => conditionOperator = v!),
                          decoration: const InputDecoration(labelText: 'Op.', filled: true),
                        ),
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        flex: 1,
                        child: TextField(controller: targetValueCtrl, keyboardType: TextInputType.number, style: const TextStyle(color: Colors.white), decoration: const InputDecoration(labelText: 'Valor', filled: true))
                      ),
                    ],
                  ),
                  if (conditionSource == 'ROLAGEM') ...[
                    const SizedBox(height: 8),
                    TextField(controller: requiredSuccessesCtrl, keyboardType: TextInputType.number, style: const TextStyle(color: Colors.white), decoration: const InputDecoration(labelText: 'Quantos dados precisam passar?', filled: true)),
                  ],
                  if (conditionSource == 'DADO_INDEPENDENTE') ...[
                    const SizedBox(height: 8),
                    TextField(controller: dieSidesCtrl, keyboardType: TextInputType.number, style: const TextStyle(color: Colors.white), decoration: const InputDecoration(labelText: 'Faces do Dado Extra (Ex: 100 para d100)', filled: true)),
                    const Padding(
                      padding: EdgeInsets.only(top: 4.0),
                      child: Text('O sistema vai rolar este dado separadamente para testar a condição.', style: TextStyle(color: Colors.grey, fontSize: 11)),
                    ),
                  ],
                  const Divider(color: Colors.white24, height: 32),
                  const Text('Efeito ao Ativar:', style: TextStyle(color: Colors.white70, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    initialValue: effectType,
                    dropdownColor: Colors.grey[900],
                    items: ['Multiplicador de Dano', 'Adicionar Dados', 'Adicionar Modificador'].map((e) => DropdownMenuItem(value: e, child: Text(e, style: const TextStyle(color: Colors.white)))).toList(),
                    onChanged: (v) => setDialogState(() => effectType = v!),
                    decoration: const InputDecoration(labelText: 'O que acontece?', filled: true),
                  ),
                  const SizedBox(height: 12),
                  if (effectType == 'Multiplicador de Dano')
                    TextField(controller: multiplierCtrl, keyboardType: TextInputType.number, style: const TextStyle(color: Colors.white), decoration: const InputDecoration(labelText: 'Multiplicador (Ex: 2.0 para Dobro)', filled: true)),
                  if (effectType == 'Adicionar Modificador')
                    TextField(controller: modifierCtrl, keyboardType: TextInputType.number, style: const TextStyle(color: Colors.white), decoration: const InputDecoration(labelText: 'Bônus Fixo (+)', filled: true)),
                  if (effectType == 'Adicionar Dados')
                    Row(
                      children: [
                        Expanded(child: TextField(onChanged: (v)=> q = int.tryParse(v) ?? 1, decoration: const InputDecoration(labelText: 'Qtd', filled: true), keyboardType: TextInputType.number, style: const TextStyle(color: Colors.white))),
                        const SizedBox(width: 4),
                        Expanded(child: TextField(onChanged: (v)=> s = int.tryParse(v) ?? 6, decoration: const InputDecoration(labelText: 'Faces', filled: true), keyboardType: TextInputType.number, style: const TextStyle(color: Colors.white))),
                        const SizedBox(width: 4),
                        Expanded(
                          flex: 2,
                          child: DropdownButtonFormField<String>(
                            initialValue: dmgType, dropdownColor: Colors.grey[900],
                            items: [...ElementalSystem.allElements, 'Cura'].map((e) => DropdownMenuItem(value: e, child: Text(e, style: const TextStyle(color: Colors.white, fontSize: 11)))).toList(),
                            onChanged: (v) => setDialogState(() => dmgType = v!),
                            decoration: const InputDecoration(labelText: 'Tipo', filled: true),
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
            style: ElevatedButton.styleFrom(backgroundColor: Colors.amber[700]),
            onPressed: () {
               listToUpdate.add(ConditionalEffect(
                 description: descCtrl.text.isEmpty ? 'Gatilho Personalizado' : descCtrl.text,
                 effectType: effectType,
                 conditionSource: conditionSource,
                 conditionOperator: conditionOperator,
                 conditionTargetValue: int.tryParse(targetValueCtrl.text) ?? 20,
                 conditionMaxValue: conditionSource == 'DADO_INDEPENDENTE' ? (int.tryParse(dieSidesCtrl.text) ?? 100) : 20,
                 conditionDieSides: conditionSource == 'DADO_INDEPENDENTE' ? (int.tryParse(dieSidesCtrl.text) ?? 100) : 20,
                 requiredSuccesses: int.tryParse(requiredSuccessesCtrl.text) ?? 1,
                 bonusDice: effectType == 'Adicionar Dados' ? [DieSpecification(quantity: q, sides: s, damageType: dmgType)] : const [],
                 multiplier: effectType == 'Multiplicador de Dano' ? (double.tryParse(multiplierCtrl.text) ?? 2.0) : 1.0,
                 bonusModifier: effectType == 'Adicionar Modificador' ? (int.tryParse(modifierCtrl.text) ?? 0) : 0,
               ));
               setState((){});
               Navigator.pop(ctx);
            }, 
            child: const Text('Adicionar', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold))
          ),
        ],
      )
    );
  }

  Widget _buildConditionalEffectsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ElevatedButton.icon(
          onPressed: () => _showAddConditionalEffectDialog(_conditionalEffects),
          icon: const Icon(Icons.add_task), label: const Text('Novo Gatilho Condicional')
        ),
        if (_conditionalEffects.isNotEmpty)
          ..._conditionalEffects.map((c) => ListTile(title: Text(c.description), trailing: IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: () => setState(() => _conditionalEffects.remove(c)))))
      ],
    );
  }

  Widget _buildBaseComponentsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ElevatedButton.icon(
          onPressed: () {
            String type = 'Atributo';
            String value = widget.characterAttributes.isNotEmpty ? widget.characterAttributes.first : 'FOR';
            showDialog(
              context: context,
              builder: (ctx) => AlertDialog(
                title: const Text('Adicionar Atributo/Perícia como Bônus Extra'),
                content: StatefulBuilder(
                  builder: (ctx, setDialogState) => Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      DropdownButtonFormField<String>(
                        initialValue: type, items: ['Atributo', 'Perícia'].map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
                        onChanged: (v) { setDialogState(() { type = v!; value = type == 'Atributo' ? widget.characterAttributes.first : widget.characterPericias.first; }); },
                      ),
                      DropdownButtonFormField<String>(
                        initialValue: value, items: (type == 'Atributo' ? widget.characterAttributes : widget.characterPericias).map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
                        onChanged: (v) => value = v!,
                      ),
                    ]
                  ),
                ),
                actions: [
                  TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
                  TextButton(onPressed: () { setState(() => _baseComponents.add(BaseComponent(type: type, value: value))); Navigator.pop(ctx); }, child: const Text('Adicionar')),
                ],
              )
            );
          },
          icon: const Icon(Icons.add), label: const Text('Adicionar Atributo/Perícia (Bônus Passivo)')
        ),
        if (_baseComponents.isNotEmpty)
          ..._baseComponents.map((c) => ListTile(title: Text('${c.type}: ${c.value}'), trailing: IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: () => setState(() => _baseComponents.remove(c)))))
      ],
    );
  }

  Widget _buildAutoMode() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Padding(
          padding: EdgeInsets.all(16),
          child: Text(
            "Descreva a habilidade com suas palavras. O motor inteligente lerá o texto e configurará os dados, os custos e a magia para você!",
            style: TextStyle(color: Colors.amber, fontSize: 14),
            textAlign: TextAlign.center,
          ),
        ),
        TextFormField(
          controller: _descriptionController,
          maxLines: 8,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: "Ex: Causa 2d6 de fogo, custa 2 de esforço e ataca com Oculto em área de 6 metros.",
            filled: true,
            fillColor: Colors.black26,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        const SizedBox(height: 24),
        ElevatedButton.icon(
          onPressed: _runAutoGenerator,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.purpleAccent,
            padding: const EdgeInsets.symmetric(vertical: 16)
          ),
          icon: const Icon(Icons.auto_awesome, color: Colors.white, size: 28),
          label: const Text("GERAR HABILIDADE", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
        )
      ],
    );
  }

  Widget _buildSimpleMode() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildTextField(_nameController, 'Nome', isRequired: true),
        _buildTextField(_descriptionController, 'Descrição Rápida', maxLines: 2),
        const SizedBox(height: 16),
        DropdownButtonFormField<String>(
          initialValue: _abilityType,
          items: ['Dano', 'Restaurar Vida', 'Restaurar Esforço', 'Buff/Transformação'].map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
          onChanged: (v) => setState(() => _abilityType = v!),
          decoration: const InputDecoration(labelText: 'O que isso faz?', filled: true, fillColor: Colors.black26),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(child: _buildTextField(_costAmountController, 'Custo', isNumber: true)),
            const SizedBox(width: 8),
            Expanded(
              child: DropdownButtonFormField<String>(
                initialValue: _costType,
                items: ['Esforço', 'Vida', 'Sanidade'].map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
                onChanged: (v) => setState(() => _costType = v!),
                decoration: const InputDecoration(labelText: 'Gasta o quê?', filled: true, fillColor: Colors.black26),
              ),
            ),
          ],
        ),
        const Divider(color: Colors.white24, height: 32),
        
        if (_abilityType == 'Dano' || _abilityType == 'Restaurar Vida' || _abilityType == 'Restaurar Esforço') ...[
          const Text('Dados e Bônus', style: TextStyle(color: Colors.amber, fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 8),
          _buildDiceSection(),
          const SizedBox(height: 16),
          Row(
            children: [
               Expanded(child: _buildTextField(_bonusModifierController, 'Bônus Fixo (+)', isNumber: true)),
               const SizedBox(width: 8),
               Expanded(child: _buildTextField(_multiplierController, 'Multiplicador de Dano (x)', isNumber: true)),
            ]
          ),
          const SizedBox(height: 16),
          SwitchListTile(
            title: const Text('Somar Dano da Arma Equipada?', style: TextStyle(fontSize: 14)),
            value: _useWeaponDamage,
            onChanged: (val) => setState(() => _useWeaponDamage = val),
            activeThumbColor: Colors.amber,
          ),
          SwitchListTile(
            title: const Text('Exige Teste de Acerto?', style: TextStyle(fontSize: 14)),
            value: _attackSkill != null,
            onChanged: (val) {
               setState(() {
                 _attackSkill = val ? (widget.characterPericias.isNotEmpty ? widget.characterPericias.first : 'Pontaria') : null;
               });
            },
            activeThumbColor: Colors.amber,
          ),
          if (_attackSkill != null)
            Padding(
              padding: const EdgeInsets.only(left: 16.0),
              child: Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      initialValue: _attackSkill,
                      items: widget.characterPericias.map((p) => DropdownMenuItem(value: p, child: Text(p))).toList(),
                      onChanged: (v) => setState(() => _attackSkill = v),
                      decoration: const InputDecoration(labelText: 'Ataca com...', filled: true),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(child: _buildTextField(_attackMultiplierController, 'Multiplicador Acerto (x)', isNumber: true)),
                ],
              ),
            ),
        ],

        if (_abilityType == 'Buff/Transformação') ...[
          const Text('Configuração Rápida de Transformação', style: TextStyle(color: Colors.purpleAccent, fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            initialValue: _simpleBuffMacro,
            items: [
              'Todos os Testes', 'Tudo', 'Todos os Atributos', 'Todas as Perícias', 'Perícias Físicas', 'Todos os Danos', 
              'Vida', 'Esforço', 'Sanidade', 'FOR', 'CON', 'DES', 'INT', 'SAB', 'CAR', 
              ...ElementalSystem.allElements.map((e) => 'Dano $e') // Puxa TODOS os danos dinamicamente
            ].map((t) => DropdownMenuItem(value: t, child: Text(t, style: const TextStyle(fontSize: 13)))).toList(),
            onChanged: (v) => setState(() => _simpleBuffMacro = v!),
            decoration: const InputDecoration(labelText: 'Onde ganha Bônus?', filled: true, fillColor: Colors.black26),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                flex: 2,
                child: DropdownButtonFormField<String>(
                  initialValue: _simpleBuffBonusType,
                  items: ['Modificador', 'Percentual', 'Pontos de Bônus', 'Multiplicador'].map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
                  onChanged: (v) => setState(() => _simpleBuffBonusType = v!),
                  decoration: const InputDecoration(labelText: 'Tipo de Bônus', filled: true),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(flex: 1, child: _buildTextField(_simpleBuffValueController, 'Valor', isNumber: true)),
              IconButton(
                icon: const Icon(Icons.add_circle, color: Colors.greenAccent, size: 36),
                onPressed: _addSimpleBuff,
              )
            ],
          ),
          if (_effects.isNotEmpty) ...[
            const SizedBox(height: 16),
            const Text("Efeitos Ativos (Clique para editar, Lixeira para apagar):", style: TextStyle(color: Colors.grey, fontSize: 12)),
            ..._effects.asMap().entries.map((entry) {
              int idx = entry.key;
              var e = entry.value;
              return ListTile(
                title: Text("${e.targets.join(', ')}: +${e.value} (${e.bonusType})", style: const TextStyle(color: Colors.white, fontSize: 13)),
                onTap: () => _showEditSimpleEffectDialog(idx),
                trailing: IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: () => setState(() => _effects.removeAt(idx))),
              );
            })
          ]
      ],
      ]);
  }

  Widget _buildAdvancedMode() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildTextField(_nameController, 'Nome', isRequired: true),
        _buildTextField(_descriptionController, 'Descrição', maxLines: 4),
        const SizedBox(height: 16),
        
        const Text('Configurações de Conjuração', style: TextStyle(color: Colors.amber, fontWeight: FontWeight.bold, fontSize: 16)),
        DropdownButtonFormField<String>(
          initialValue: _abilityType,
          items: _abilityTypes.map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
          onChanged: (v) => setState(() => _abilityType = v!),
          decoration: const InputDecoration(labelText: 'Tipo de Habilidade', filled: true, fillColor: Colors.black26),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(child: _buildTextField(_costAmountController, 'Custo', isNumber: true)),
            const SizedBox(width: 8),
            Expanded(
              child: DropdownButtonFormField<String>(
                initialValue: _costType,
                items: _costTypes.map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
                onChanged: (v) => setState(() => _costType = v!),
                decoration: const InputDecoration(labelText: 'Tipo de Recurso', filled: true, fillColor: Colors.black26),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (_costType == 'Esforço')
          DropdownButtonFormField<String>(
            initialValue: _costSource,
            items: _costSources.map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
            onChanged: (v) => setState(() => _costSource = v!),
            decoration: const InputDecoration(labelText: 'Fonte do Esforço', filled: true, fillColor: Colors.black26),
          ),
        _buildTextField(_cooldownController, 'Cooldown (em turnos)', isNumber: true),

        const Divider(color: Colors.white24, height: 32),
        const Text('Alvos, Distância e Área', style: TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(child: _buildTextField(_targetCountController, 'Nº de Alvos', isNumber: true)),
            const SizedBox(width: 8),
            Expanded(flex: 2, child: _buildTextField(_rangeController, 'Distância (ex: 6 metros)')),
          ],
        ),
        const SizedBox(height: 8),
        _buildTextField(_areaController, 'Área de Efeito (ex: Raio de 3m)'),
        
        const Divider(color: Colors.white24, height: 32),
        const Text('Dano Contínuo (Burn)', style: TextStyle(color: Colors.orangeAccent, fontWeight: FontWeight.bold, fontSize: 16)),
        SwitchListTile(
          title: const Text('Aplica Burn no Alvo?', style: TextStyle(fontSize: 14)),
          value: _hasBurn,
          onChanged: (val) => setState(() => _hasBurn = val),
          activeThumbColor: Colors.orangeAccent,
        ),
        if (_hasBurn)
          Row(
            children: [
              Expanded(child: _buildTextField(_burnDamageController, 'Dano por Turno (ex: 1d6)')),
              const SizedBox(width: 8),
              Expanded(child: _buildTextField(_burnDurationController, 'Duração (Turnos)', isNumber: true)),
            ],
          ),

        const Divider(color: Colors.white24, height: 32),
        if (_abilityType != 'Buff/Transformação') ...[
          const Text('Dados Base', style: TextStyle(color: Colors.amber, fontWeight: FontWeight.bold, fontSize: 16)),
          _buildDiceSection(),
          Row(
            children: [
               Expanded(child: _buildTextField(_bonusModifierController, 'Bônus Fixo (+)', isNumber: true)),
               const SizedBox(width: 8),
               Expanded(child: _buildTextField(_multiplierController, 'Multiplicador Final (x)', isNumber: true)),
            ]
          ),
          const SizedBox(height: 16),
          const Text('Composição Avançada', style: TextStyle(color: Colors.amber, fontWeight: FontWeight.bold, fontSize: 16)),
          SwitchListTile(
            title: const Text('Somar Dano da Arma Equipada?', style: TextStyle(fontSize: 14)),
            value: _useWeaponDamage,
            onChanged: (val) => setState(() => _useWeaponDamage = val),
            activeThumbColor: Colors.amber,
          ),
          _buildBaseComponentsSection(),
          const SizedBox(height: 16),
          const Text('Regras de Acerto', style: TextStyle(color: Colors.amber, fontWeight: FontWeight.bold, fontSize: 16)),
          DropdownButtonFormField<String?>(
            initialValue: _attackSkill,
            items: [
              const DropdownMenuItem<String?>(value: null, child: Text('Acerto Automático')),
              ...widget.characterPericias.map((p) => DropdownMenuItem(value: p, child: Text('Rolar $p')))
            ],
            onChanged: (v) => setState(() => _attackSkill = v),
            decoration: const InputDecoration(labelText: 'Perícia de Ataque', filled: true, fillColor: Colors.black26),
          ),
          if (_attackSkill != null)
             Row(
               children: [
                 Expanded(child: _buildTextField(_attackBonusController, 'Bônus de Acerto (+)', isNumber: true)),
                 const SizedBox(width: 8),
                 Expanded(child: _buildTextField(_attackMultiplierController, 'Multiplicador Acerto (x)', isNumber: true)),
               ],
             ),
          const Divider(color: Colors.white24, height: 32),
          const Text('Gatilhos Dinâmicos (Dano/Efeitos Condicionais)', style: TextStyle(color: Colors.amber, fontWeight: FontWeight.bold, fontSize: 16)),
          _buildConditionalEffectsSection(),
        ],
        
        const Divider(color: Colors.white24, height: 32),
        const Text('Efeitos Passivos (Buffs)', style: TextStyle(color: Colors.purpleAccent, fontWeight: FontWeight.bold, fontSize: 16)),
        EffectConfigurator(
          effects: _effects,
          onEffectsChanged: (newEffects) => setState(() {}),
          characterAttributes: widget.characterAttributes,
          characterPericias: widget.characterPericias,
        ),
      ],
    );
  }

  Widget _buildPassiveForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildTextField(_nameController, 'Nome da Passiva', isRequired: true),
        _buildTextField(_descriptionController, 'Descrição', maxLines: 4),
        const SizedBox(height: 16),
        const Text('Regras de Ativação', style: TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.bold, fontSize: 16)),
        DropdownButtonFormField<String>(
          initialValue: _triggerType,
          items: _triggerTypes.map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
          onChanged: (v) => setState(() => _triggerType = v!),
          decoration: const InputDecoration(labelText: 'Gatilho (Quando ativa?)', filled: true, fillColor: Colors.black26),
        ),
        if (!['Sempre Ativo', 'Ativável', 'Oculto', 'Manual (Apenas Botão)', 'Sem Atacar no Turno'].contains(_triggerType)) ...[
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  initialValue: _triggerValueType,
                  items: ['Fixo', 'Percentual'].map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
                  onChanged: (v) => setState(() => _triggerValueType = v!),
                  decoration: const InputDecoration(labelText: 'Tipo de Valor', filled: true),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(child: _buildTextField(_triggerValueController, 'Valor Necessário', isNumber: true)),
            ],
          ),
          SwitchListTile(
            title: const Text('Calcular % no Valor Total do Atributo?'),
            value: _basedOnTotal,
            onChanged: _triggerValueType == 'Percentual' ? (val) => setState(() => _basedOnTotal = val) : null,
          ),
        ],
        const SizedBox(height: 16),
        DropdownButtonFormField<String>(
          initialValue: _triggerFrequency,
          items: _triggerFrequencies.map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
          onChanged: (v) => setState(() => _triggerFrequency = v!),
          decoration: const InputDecoration(labelText: 'Frequência de Ativação', filled: true, fillColor: Colors.black26),
        ),
        // CORREÇÃO: Mostrar Cooldown e Acúmulos Baseados na Frequência!
        if (_triggerFrequency == 'Uma Vez por Cooldown')
           _buildTextField(_cooldownController, 'Cooldown (Turnos)', isNumber: true),
        if (_triggerFrequency == 'Acumulável')
           _buildTextField(_maxStacksController, 'Acúmulo Máximo (0 = Infinito)', isNumber: true),
        
        const Divider(color: Colors.white24, height: 32),
        const Text('Efeitos Concedidos', style: TextStyle(color: Colors.purpleAccent, fontWeight: FontWeight.bold, fontSize: 16)),
        EffectConfigurator(
          effects: _effects,
          onEffectsChanged: (newEffects) => setState(() {}),
          characterAttributes: widget.characterAttributes,
          characterPericias: widget.characterPericias,
        ),
      ],
    );
  }

  Widget _buildWeaponForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildTextField(_nameController, 'Nome da Arma', isRequired: true),
        _buildTextField(_descriptionController, 'Descrição', maxLines: 3),
        const SizedBox(height: 16),
        const Text('Dano da Arma', style: TextStyle(color: Colors.amber, fontWeight: FontWeight.bold, fontSize: 16)),
        _buildDiceSection(),
        Row(
          children: [
             Expanded(child: _buildTextField(_bonusModifierController, 'Bônus Fixo (+)', isNumber: true)),
             const SizedBox(width: 8),
             Expanded(child: _buildTextField(_multiplierController, 'Multiplicador (x)', isNumber: true)),
          ]
        ),
        const SizedBox(height: 16),
        const Text('Ataque', style: TextStyle(color: Colors.amber, fontWeight: FontWeight.bold, fontSize: 16)),
        DropdownButtonFormField<String?>(
          initialValue: _attackSkill,
          items: [
            const DropdownMenuItem<String?>(value: null, child: Text('Acerto Automático')),
            ...widget.characterPericias.map((p) => DropdownMenuItem(value: p, child: Text('Rolar $p')))
          ],
          onChanged: (v) => setState(() => _attackSkill = v),
          decoration: const InputDecoration(labelText: 'Perícia de Ataque', filled: true, fillColor: Colors.black26),
        ),
        if (_attackSkill != null)
           Row(
             children: [
               Expanded(child: _buildTextField(_attackBonusController, 'Bônus de Acerto (+)', isNumber: true)),
               const SizedBox(width: 8),
               Expanded(child: _buildTextField(_attackMultiplierController, 'Multiplicador Acerto (x)', isNumber: true)),
             ],
           ),
        const Divider(color: Colors.white24, height: 32),
        const Text('Gatilhos de Arma', style: TextStyle(color: Colors.amber, fontWeight: FontWeight.bold, fontSize: 16)),
        _buildConditionalEffectsSection(),
        const Divider(color: Colors.white24, height: 32),
        const Text('Efeitos Passivos (Equipada)', style: TextStyle(color: Colors.purpleAccent, fontWeight: FontWeight.bold, fontSize: 16)),
        EffectConfigurator(
          effects: _effects,
          onEffectsChanged: (newEffects) => setState(() {}),
          characterAttributes: widget.characterAttributes,
          characterPericias: widget.characterPericias,
        ),
      ],
    );
  }

  Widget _buildArmorForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildTextField(_nameController, 'Nome da Armadura', isRequired: true),
        _buildTextField(_descriptionController, 'Descrição', maxLines: 3),
        const SizedBox(height: 16),
        const Text('Defesa', style: TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.bold, fontSize: 16)),
        Row(
          children: [
             Expanded(child: _buildTextField(_reductionValueController, 'Redução Fixa', isNumber: true)),
             const SizedBox(width: 8),
             Expanded(child: _buildTextField(_maxHitsController, 'Máximo de Hits', isNumber: true)),
          ]
        ),
        const Divider(color: Colors.white24, height: 32),
        const Text('Efeitos Passivos (Equipada)', style: TextStyle(color: Colors.purpleAccent, fontWeight: FontWeight.bold, fontSize: 16)),
        EffectConfigurator(
          effects: _effects,
          onEffectsChanged: (newEffects) => setState(() {}),
          characterAttributes: widget.characterAttributes,
          characterPericias: widget.characterPericias,
        ),
      ],
    );
  }

  Widget _buildItemForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildTextField(_nameController, 'Nome do Item', isRequired: true),
        _buildTextField(_descriptionController, 'Descrição', maxLines: 3),
        const Divider(color: Colors.white24, height: 32),
        const Text('Efeitos Passivos (Equipado)', style: TextStyle(color: Colors.purpleAccent, fontWeight: FontWeight.bold, fontSize: 16)),
        EffectConfigurator(
          effects: _effects,
          onEffectsChanged: (newEffects) => setState(() {}),
          characterAttributes: widget.characterAttributes,
          characterPericias: widget.characterPericias,
        ),
      ],
    );
  }

  Widget _buildStatusEffectForm() {
    final allPossibleStats = {'Vida', 'Sanidade', 'Esforço', ...widget.characterAttributes, ...widget.characterPericias, 'Defesa', 'Esquiva'}.toList();
    if (!allPossibleStats.contains(_targetStat)) {
       _targetStat = allPossibleStats.isNotEmpty ? allPossibleStats.first : 'Vida';
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildTextField(_nameController, 'Nome do Efeito', isRequired: true),
        _buildTextField(_descriptionController, 'Descrição', maxLines: 3),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: DropdownButtonFormField<String>(
                initialValue: _effectTypeStr,
                items: EffectType.values.map((e) => DropdownMenuItem(value: e.name, child: Text(e.name))).toList(),
                onChanged: (v) => setState(() => _effectTypeStr = v!),
                decoration: const InputDecoration(labelText: 'Tipo', filled: true),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: DropdownButtonFormField<String>(
                initialValue: _effectTriggerStr,
                items: EffectTrigger.values.map((e) => DropdownMenuItem(value: e.name, child: Text(e.name))).toList(),
                onChanged: (v) => setState(() => _effectTriggerStr = v!),
                decoration: const InputDecoration(labelText: 'Gatilho', filled: true),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (_effectTypeStr == 'statChange')
           DropdownButtonFormField<String>(
             initialValue: _targetStat,
             items: allPossibleStats.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
             onChanged: (v) => setState(() => _targetStat = v!),
             decoration: const InputDecoration(labelText: 'Atributo Afetado', filled: true),
           ),
        const SizedBox(height: 16),
        Row(
          children: [
             Expanded(child: _buildTextField(_valueFormulaController, 'Valor/Dano (ex: 1d4)')),
             const SizedBox(width: 8),
             Expanded(child: _buildTextField(_durationFormulaController, 'Duração (Turnos)')),
          ]
        ),
        SwitchListTile(
          title: const Text('É Percentual?'),
          value: _isPercentage,
          onChanged: (v) => setState(() => _isPercentage = v),
        ),
      ],
    );
  }

void _runPassiveAutoGenerator() {
    final desc = _descriptionController.text;
    if (desc.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Escreva a descrição primeiro!')));
      return;
    }

    Passive parsedPassive = SmartEntityParser.parseTextToEntity(desc, 'Passive');

    setState(() {
      _nameController.text = parsedPassive.name;
      _triggerType = parsedPassive.triggerType;
      _costAmountController.text = parsedPassive.costAmount.toString();
      _costType = parsedPassive.costType;
      _cooldownController.text = parsedPassive.cooldown.toString();
      
      _effects.clear();
      _effects.addAll(parsedPassive.effects);
      
      _selfStatusEffectsToApply.clear();
      _selfStatusEffectsToApply.addAll(parsedPassive.selfStatusEffectsToApply);

      _dynamicHealingStat = parsedPassive.dynamicHealingStat;
      _dynamicHealingPercentageController.text = parsedPassive.dynamicHealingPercentage.toString();

      _creationMode = 'Padrão';
    });
    
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('✨ Passiva Inteligente Gerada! Revise-a.', style: TextStyle(color: Colors.white)), backgroundColor: Colors.green));
  }

  Widget _buildPassiveAutoMode() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Padding(
          padding: EdgeInsets.all(16),
          child: Text(
            "Descreva sua passiva! A inteligência vai ler os gatilhos e buffs (Ex: Quando sofrer dano, ganha +10 em FOR, acumulável).",
            style: TextStyle(color: Colors.amber, fontSize: 14),
            textAlign: TextAlign.center,
          ),
        ),
        TextFormField(
          controller: _descriptionController,
          maxLines: 8,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: "Ex: Acumulável manualmente apertando no botão. Concede +15% de Dano Físico e +2 em FOR.",
            filled: true,
            fillColor: Colors.black26,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        const SizedBox(height: 24),
        ElevatedButton.icon(
          onPressed: _runPassiveAutoGenerator,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.purpleAccent,
            padding: const EdgeInsets.symmetric(vertical: 16)
          ),
          icon: const Icon(Icons.auto_awesome, color: Colors.white, size: 28),
          label: const Text("GERAR PASSIVA", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isAbilityOrRitual = widget.entityType == EntityType.ability || widget.entityType == EntityType.ritual;
    final isPassive = widget.entityType == EntityType.passive;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.initialEntity == null ? 'Nova Criação' : 'Editar Criação'),
        backgroundColor: theme.appBarTheme.backgroundColor,
      ),
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Column(
        children: [
          if (isAbilityOrRitual)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: SegmentedButton<String>(
                segments: const [
                  ButtonSegment(value: 'Simples', label: Text('Simples'), icon: Icon(Icons.flash_on)),
                  ButtonSegment(value: 'Avançado', label: Text('Avançado'), icon: Icon(Icons.settings)),
                  ButtonSegment(value: 'Automático', label: Text('Auto'), icon: Icon(Icons.auto_awesome)),
                ],
                selected: {_creationMode},
                onSelectionChanged: (Set<String> newSelection) {
                  setState(() => _creationMode = newSelection.first);
                },
                style: ButtonStyle(
                  backgroundColor: WidgetStateProperty.resolveWith<Color>((Set<WidgetState> states) {
                    if (states.contains(WidgetState.selected)) return theme.colorScheme.primary.withOpacity(0.8);
                    return Colors.transparent;
                  }),
                ),
              ),
            )
          else if (isPassive)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: SegmentedButton<String>(
                segments: const [
                  ButtonSegment(value: 'Padrão', label: Text('Padrão'), icon: Icon(Icons.settings)),
                  ButtonSegment(value: 'Automático', label: Text('Auto'), icon: Icon(Icons.auto_awesome)),
                ],
                selected: {['Padrão', 'Automático'].contains(_creationMode) ? _creationMode : 'Padrão'},
                onSelectionChanged: (Set<String> newSelection) {
                  setState(() => _creationMode = newSelection.first);
                },
                style: ButtonStyle(
                  backgroundColor: WidgetStateProperty.resolveWith<Color>((Set<WidgetState> states) {
                    if (states.contains(WidgetState.selected)) return theme.colorScheme.primary.withOpacity(0.8);
                    return Colors.transparent;
                  }),
                ),
              ),
            ),
            
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Form(
                key: _formKey,
                child: isAbilityOrRitual
                    ? (_creationMode == 'Automático' ? _buildAutoMode() : _creationMode == 'Simples' ? _buildSimpleMode() : _buildAdvancedMode())
                    : (isPassive 
                        ? (_creationMode == 'Automático' ? _buildPassiveAutoMode() : _buildPassiveForm()) 
                        : (widget.entityType == EntityType.weapon
                            ? _buildWeaponForm()
                            : (widget.entityType == EntityType.armor
                                ? _buildArmorForm()
                                : (widget.entityType == EntityType.statusEffect
                                    ? _buildStatusEffectForm()
                                    : _buildItemForm())))),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: _creationMode != 'Automático' 
          ? FloatingActionButton.extended(
              onPressed: _saveForm,
              label: const Text('Salvar'),
              icon: const Icon(Icons.save),
              backgroundColor: theme.colorScheme.secondary,
            )
          : null,
    );
  }
}