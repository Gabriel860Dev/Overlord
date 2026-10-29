// lib/screens/new_character_sheet_form.dart

import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:overlord/models/ability.dart';
import 'package:overlord/models/armor.dart';
import 'package:overlord/models/character_sheet.dart';
import 'package:overlord/models/dice_roll_handler.dart';
import 'package:overlord/models/die_specification.dart';
import 'package:overlord/models/item.dart';
import 'package:overlord/models/passive.dart';
import 'package:overlord/models/roll_result.dart';
import 'package:overlord/models/status_effect.dart';
import 'package:overlord/models/weapon.dart';
import 'package:overlord/screens/add_edit_entity_form.dart';
import 'package:overlord/widgets/status_bar.dart';
import 'package:overlord/models/passive_bonuses.dart';
import 'package:overlord/widgets/form_helpers.dart';
import 'package:overlord/localization.dart';
import 'package:overlord/screens/clash_screen.dart';
import 'package:overlord/data/system_rituals.dart'; 
import 'package:overlord/models/elemental_system.dart';
import 'package:share_plus/share_plus.dart';
import 'package:reorderable_grid_view/reorderable_grid_view.dart';


class ActiveEffect {
  final String id;
  final String name;
  final String sourceTypeDescription;
  final Color color;
  final String sourceId;
  final String sourceType;
  final String category;
  final IconData icon;

  ActiveEffect({
    required this.id,
    required this.name,
    required this.sourceTypeDescription,
    required this.color,
    required this.sourceId,
    required this.sourceType,
    required this.category,
    required this.icon,
  });
}

class NewCharacterSheetForm extends StatefulWidget {
  final void Function(CharacterSheet newSheet) onSave;
  final CharacterSheet? initialSheet;
  final DiceRollHandler onDiceRolledFromSheet;
  final void Function(String) showToast;

  const NewCharacterSheetForm({
    super.key,
    required this.onSave,
    this.initialSheet,
    required this.onDiceRolledFromSheet,
    required this.showToast,
  });

  @override
  State<NewCharacterSheetForm> createState() => _NewCharacterSheetFormState();
}



class _NewCharacterSheetFormState extends State<NewCharacterSheetForm> {
  final _nameController = TextEditingController();
  final _classController = TextEditingController();
  final _levelController = TextEditingController();
  final _parryDiceCountController = TextEditingController();
  final _esforcoExtraController = TextEditingController(text: '0');

  final _blockConController = TextEditingController(text: '100');
  final _blockForController = TextEditingController(text: '0');
  final _blockSabController = TextEditingController(text: '0');

  final Map<String, double> _blockResistances = {};
  

  String? _selectedAttributeForTier; // Controla qual atributo está brilhando

  int _getAttributeTier(int value) {
  if (value <= 10) return 0;      // 0-10
  if (value <= 49) return 1;      // 11-49
  if (value <= 99) return 2;      // 50-99
  if (value <= 249) return 3;     // 100-249
  if (value <= 349) return 4;     // 250-349
  if (value <= 499) return 5;     // 350-499
  if (value == 500) return 6;     // 500
  return 7;                       // 501+
}

  List<PassiveEffect> _updatePassiveEffectsPerRound(List<PassiveEffect> effects) {
    bool changed = false;
    final newEffects = effects.map((e) {
      if (e.perRoundValue != 0) {
        changed = true;
        return PassiveEffect(
          targets: e.targets,
          bonusType: e.bonusType,
          value: e.value + e.perRoundValue,
          perRoundValue: e.perRoundValue,
          grantsArmor: e.grantsArmor,
          bonusDamageType: e.bonusDamageType
        );
      }
      return e;
    }).toList();
    return changed ? newEffects : effects;
  }

  final _attributesControllers = {
    'FOR': TextEditingController(),'CON': TextEditingController(),'DES': TextEditingController(),
    'INT': TextEditingController(),'SAB': TextEditingController(),'CAR': TextEditingController()
  };
  final _statusControllers = {
    'Vida': {'atual': TextEditingController(), 'total': TextEditingController()},
    'Esforço': {'atual': TextEditingController(), 'total': TextEditingController()},
    'Esforço Temporário': {'atual': TextEditingController(), 'total': TextEditingController()},
    'Sanidade': {'atual': TextEditingController(), 'total': TextEditingController()},
    'Loucura': {'atual': TextEditingController(), 'total': TextEditingController()}
  };
  final Map<String, TextEditingController> _periciasControllers = {};

  final Map<String, int> _lastStatusValues = {};
  final Map<String, int> _unaccountedStatusLoss = {'Vida': 0, 'Esforço': 0, 'Sanidade': 0, 'Loucura': 0};
  int _unaccountedDamageTaken = 0; 
  bool _isDown = false;

  final List<String> _allPericias = const [
    'Acrobacia','Atletismo','Adestramento','Guerra','Pontaria','Oculto','Presença','Percepção','Pilotagem','Diplomacia','Tatico','Enganação','Atuação','Ladinagem','Artes-marciais','Sobrevivencia','Eclético','Direção','Atualidades','Montaria','Primeiros socorros','Tecnologia','Intimidação','Sorte','Furtividade','Poder de fogo','Investigação','Reflexo','Conhecimento ParaNormal','Mente','Memoria','Iniciativa','Intuição','Vontade','Esgrima','Antiguidade'
  ];
  List<String> _periciasExibidas = [];
  final List<Item> _inventory = [];
  final List<Ability> _abilities = [];
  final List<Ability> _rituals = []; 
  final List<Passive> _passives = [];
  List<StatusEffect> _statusEffects = [];
  final List<Armor> _temporaryArmors = [];
  String? _imagePath;
  int _hpPerLevel = 0;
  int _effortPerLevel = 0;
  int _sanityPerLevel = 0;
  int _pontosAtributoPorNivel = 0;
  int _pontosPericiaPorNivel = 0;
  int _vidaPorCon = 0;
  int _esforcoPorSab = 0;
  int _esforcoPorDes = 0;
  String _parryType = 'Comum';
  Color _effortColor = Colors.yellow;

  final Map<String, int> _parryDiceLimits = {
    'Comum': 6,
    'Avançado': 6,
    'Super': 8,
    'God': 10,
  };

  Timer? _saveDebounce;
  bool _isFirstSave = true;
  String? _sheetId;
  bool _isClassicLayout = false;

  @override
  void initState() {
    super.initState();
    _sheetId = widget.initialSheet?.id;
    if (widget.initialSheet != null) {
      _loadSheetData(widget.initialSheet!);
    } else {
      _parryDiceCountController.text = '4';
      _levelController.text = '1';
      WidgetsBinding.instance.addPostFrameCallback((_) => _saveFicha());
    }

    _setupListeners();
    _initializeLastStatusValues();
    _parryDiceCountController.addListener(_validateParryDiceCount);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkIfDown();
    });
  }

  void _validateParryDiceCount() {
    final limit = _parryDiceLimits[_parryType] ?? 4;
    final currentValue = int.tryParse(_parryDiceCountController.text) ?? 0;
    if (currentValue > limit) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _parryDiceCountController.text = limit.toString();
        _parryDiceCountController.selection = TextSelection.fromPosition(TextPosition(offset: _parryDiceCountController.text.length));
      });
    }
  }

  void _checkIfDown() {
    final currentHp = int.tryParse(_statusControllers['Vida']!['atual']!.text) ?? 0;
    setState(() {
      _isDown = currentHp <= 0;
    });
  }

  void _initializeLastStatusValues() {
    _statusControllers.forEach((key, controllers) {
      _lastStatusValues[key] = int.tryParse(controllers['atual']!.text) ?? 0;
    });
  }

  void _setupListeners() {
    final allControllers = [
      _nameController, _classController, _levelController, _parryDiceCountController,
      _esforcoExtraController, _blockConController, _blockForController, _blockSabController,
      ..._attributesControllers.values,
    ];

    for (var controller in allControllers) {
      controller.addListener(_onFieldChanged);
    }
    for (var c in _periciasControllers.values) {
      c.addListener(_onFieldChanged);
    }
  }

  void _onStatusChange(String status) {
    int newValue = int.tryParse(_statusControllers[status]!['atual']!.text) ?? 0;
    int oldValue = _lastStatusValues[status] ?? newValue;

    if (status == 'Loucura') _validateLoucura();

    if (status == 'Vida') {
      if (newValue <= 0 && oldValue > 0) {
        widget.showToast(AppStrings.of(context).get('fallen_message'));
      }
      setState(() {
        _isDown = newValue <= 0;
      });
    }

    if (newValue < oldValue) {
      int loss = oldValue - newValue;
      if (_unaccountedStatusLoss.containsKey(status)) {
        _unaccountedStatusLoss[status] = (_unaccountedStatusLoss[status] ?? 0) + loss;
      }
      
      if (status == 'Vida') {
        _unaccountedDamageTaken += loss;
      }
    }

    _lastStatusValues[status] = newValue;
    _checkAllStatusPassives();
    _onFieldChanged();
  }

  void _checkAllStatusPassives() {
    _checkDamageBasedPassives();
    _checkStatusBasedPassives('Vida Perdida', 'Vida');
    _checkStatusBasedPassives('Esforço Gasto', 'Esforço');
    _checkStatusBasedPassives('Sanidade Perdida', 'Sanidade');
    _checkStatusBasedPassives('Loucura Gasta', 'Loucura');
    _checkProportionalPassives();
  }

  void _checkDamageBasedPassives() {
    if (_unaccountedDamageTaken <= 0) return;

    for (var passive in _passives) {
      if (passive.triggerType == 'Dano Sofrido') {
        int triggerValue = _getTriggerValue(passive, 'Vida');

        if (triggerValue > 0 && _unaccountedDamageTaken >= triggerValue) {
          int timesTriggered = _unaccountedDamageTaken ~/ triggerValue;
          _triggerPassive(passive, timesTriggered);
          int damageConsumed = timesTriggered * triggerValue;
          _unaccountedDamageTaken -= damageConsumed; 
        }
      }
    }
  }

  void _checkStatusBasedPassives(String triggerType, String statusType) {
    int loss = _unaccountedStatusLoss[statusType] ?? 0;
    if (loss <= 0) return;

    for (var passive in _passives) {
      if (passive.triggerType == triggerType) {
        if (passive.basedOnTotal) continue;

        int triggerValue = _getTriggerValue(passive, statusType);

        if (triggerValue > 0 && loss >= triggerValue) {
          int timesTriggered = loss ~/ triggerValue;
          _triggerPassive(passive, timesTriggered);
          _unaccountedStatusLoss[statusType] = loss % triggerValue;
        }
      }
    }
  }

  void _checkProportionalPassives() {
    final statusMap = {
      'Vida Perdida': 'Vida', 'Esforço Gasto': 'Esforço',
      'Sanidade Perdida': 'Sanidade', 'Loucura Gasta': 'Loucura'
    };

    setState(() {
      for (var passive in _passives) {
        if (passive.basedOnTotal && statusMap.containsKey(passive.triggerType)) {
          String statusToCheck = statusMap[passive.triggerType]!;
          int current = int.tryParse(_statusControllers[statusToCheck]!['atual']!.text) ?? 0;
          int total = int.tryParse(_statusControllers[statusToCheck]!['total']!.text) ?? 1;
          
          int triggerValue = _getTriggerValue(passive, statusToCheck);
          if (triggerValue > 0) {
            passive.stacks = (total - current) ~/ triggerValue;
          } else {
            passive.stacks = total - current;
          }
        }
      }
    });
  }

  int _getTriggerValue(Passive passive, String statusType) {
    if (passive.triggerValueType == 'Percentual') {
      int total = int.tryParse(_statusControllers[statusType]!['total']!.text) ?? 1;
      return (total * (passive.triggerValue / 100)).round();
    }
    return passive.triggerValue;
  }

  void _triggerPassive(Passive passive, int times) {
    if (passive.triggerFrequency == 'Acumulável') {
      if (!passive.basedOnTotal) {
        setState(() => passive.stacks += times);
        widget.showToast('${passive.name} acumulou $times vez(es)!');
      }
    } else {
      if (passive.currentCooldown == 0) {
        setState(() {
          passive.isActive = true;
          if (passive.cooldown > 0) {
            passive.currentCooldown = passive.cooldown;
          }
        });
        widget.showToast('${passive.name} ativada!');
      }
    }
  }

  void _onFieldChanged() {
    if (mounted) {
      setState(() {});
    }
    if (_saveDebounce?.isActive ?? false) _saveDebounce!.cancel();
    _saveDebounce = Timer(const Duration(seconds: 2), () {
      if (mounted) {
        _saveFicha();
      }
    });
  }

  void _loadSheetData(CharacterSheet sheet) {
    _nameController.text = sheet.name;
    _classController.text = sheet.classe ?? '';
    _levelController.text = sheet.level?.toString() ?? '1';
    _inventory.clear();
    _inventory.addAll(sheet.backpack);
    _statusEffects.clear();
    _statusEffects.addAll(sheet.statusEffects);
    _imagePath = sheet.imagePath;
    _effortColor = Color(sheet.effortColor);
    _hpPerLevel = sheet.hpPerLevel;
    _effortPerLevel = sheet.effortPerLevel;
    _sanityPerLevel = sheet.sanityPerLevel;
    _pontosAtributoPorNivel = sheet.pontosAtributoPorNivel;
    _pontosPericiaPorNivel = sheet.pontosPericiaPorNivel;
    _vidaPorCon = sheet.vidaPorCon;
    _esforcoPorSab = sheet.esforcoPorSab;
    _esforcoPorDes = sheet.esforcoPorDes;
    _parryType = sheet.parryType;
    _parryDiceCountController.text = sheet.parryDiceCount.toString();
    _esforcoExtraController.text = sheet.esforcoExtra.toString();
    _blockConController.text = sheet.blockConPercentage.toString();
    _blockForController.text = sheet.blockForPercentage.toString();
    _blockSabController.text = sheet.blockSabPercentage.toString();

    _abilities.clear();
    _abilities.addAll(sheet.abilities);
    _rituals.clear();
    _rituals.addAll(sheet.rituals);
    _passives.clear();
    _passives.addAll(sheet.passives);
    _periciasExibidas = List.from(sheet.pericias.keys)..sort();

    sheet.attributes.forEach((key, value) => _attributesControllers[key]?.text = value?.toString() ?? '0');
    sheet.status.forEach((key, value) {
      if (_statusControllers.containsKey(key)) {
        _statusControllers[key]?['atual']?.text = value['atual']?.toString() ?? '0';
        _statusControllers[key]?['total']?.text = value['total']?.toString() ?? '0';
      }
    });

    _periciasControllers.clear();
    for (var pericia in _periciasExibidas) {
      _periciasControllers[pericia] = TextEditingController(text: sheet.pericias[pericia]?.toString() ?? '0');
      _periciasControllers[pericia]!.addListener(_onFieldChanged);
    }
  }

  @override
  void dispose() {
    _saveDebounce?.cancel();
    _saveFicha();

    final allControllers = [
      _nameController, _classController, _levelController, _parryDiceCountController,
      _esforcoExtraController, _blockConController, _blockForController, _blockSabController,
      ..._attributesControllers.values,
      ..._statusControllers.values.expand((map) => map.values),
      ..._periciasControllers.values,
    ];
    for (var controller in allControllers) {
      controller.removeListener(_onFieldChanged);
      controller.dispose();
    }
    _parryDiceCountController.removeListener(_validateParryDiceCount);
    super.dispose();
  }

  void _validateLoucura() {
    final currentValue = int.tryParse(_statusControllers['Loucura']!['atual']!.text) ?? 0;
    if (currentValue < 0) {
      _statusControllers['Loucura']!['atual']!.text = '0';
    } else if (currentValue > 100) {
      _statusControllers['Loucura']!['atual']!.text = '100';
    }
  }

  void _removeImage() {
    setState(() => _imagePath = null);
  }

  void _showImageOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewPadding.bottom),
          child: Wrap(
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: Text(AppStrings.of(context).get('select_gallery')),
                onTap: () async {
                  Navigator.of(context).pop();
                  final picker = ImagePicker();
                  final pickedFile = await picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
                  if (pickedFile != null) {
                    setState(() => _imagePath = pickedFile.path);
                  }
                },
              ),
              if (_imagePath != null)
                ListTile(
                  leading: const Icon(Icons.delete, color: Colors.redAccent),
                  title: Text(AppStrings.of(context).get('remove_image'), style: const TextStyle(color: Colors.redAccent)),
                  onTap: () {
                    Navigator.of(context).pop();
                    _removeImage();
                  },
                ),
            ],
          ),
        );
      },
    );
  }

  void _endCombat() {
    setState(() {
      for (var ability in _abilities) {
        ability.usesInCombat = 0;
        if (ability.costPerRound > 0) {
          ability.isActive = false;
        }
      }
      for (var ritual in _rituals) {
        ritual.usesInCombat = 0;
        if (ritual.costPerRound > 0) {
          ritual.isActive = false;
        }
      }
      for (var passive in _passives) {
        if (passive.triggerType == 'Cooldown' || passive.triggerFrequency == 'Uma Vez por Cooldown') {
          passive.currentCooldown = 0;
          passive.isActive = false;
        }
        // NOVA LINHA AQUI: Garante que TODA passiva acumulável zere e desative no fim do combate
        if (passive.triggerFrequency == 'Acumulável') {
          passive.stacks = 0;
          passive.isActive = false;
        }
        for (var effect in passive.effects) {
          if (effect.grantsArmor != null) {
            effect.grantsArmor!.currentHits = effect.grantsArmor!.maxHits;
          }
        }
      }
      _statusControllers['Esforço Temporário']!['atual']!.text = '0';
      _statusControllers['Esforço Temporário']!['total']!.text = '0';
      _temporaryArmors.clear();

      _inventory.whereType<Armor>().forEach((armor) {
        armor.currentHits = armor.maxHits;
      });
      _unaccountedStatusLoss.updateAll((key, value) => 0);
      _unaccountedDamageTaken = 0;
    });
    widget.showToast(AppStrings.of(context).get('combat_end_msg'));
  }

  void _nextRound() {
    int totalCost = 0;

    setState(() {
      for (var ability in _abilities) {
        if (ability.isActive && ability.costPerRound > 0) totalCost += ability.costPerRound;
        if (ability.currentCooldown > 0) ability.currentCooldown--;
      }
      for (var ritual in _rituals) {
        if (ritual.isActive && ritual.costPerRound > 0) totalCost += ritual.costPerRound;
        if (ritual.currentCooldown > 0) ritual.currentCooldown--;
      }

      if (totalCost > 0) _payEffort(totalCost, 'Híbrido (Temp. > Padrão)');

      List<StatusEffect> updatedStatusEffects = [];
      for(var effect in _statusEffects) {
        int newDuration = effect.durationInRounds;
        if (newDuration > 0) newDuration--;
        if (newDuration != 0) {
           double newValue = effect.value;
           if (effect.perRoundValue != 0) newValue += effect.perRoundValue;
           updatedStatusEffects.add(StatusEffect(id: effect.id, name: effect.name, description: effect.description, durationInRounds: newDuration, imagePath: effect.imagePath, targets: effect.targets, bonusType: effect.bonusType, value: newValue, perRoundValue: effect.perRoundValue, type: effect.type, trigger: effect.trigger, valueFormula: effect.valueFormula, durationFormula: effect.durationFormula, targetStat: effect.targetStat, isPercentage: effect.isPercentage));
        }
      }
      _statusEffects = updatedStatusEffects;

      for (int i = 0; i < _passives.length; i++) {
        var passive = _passives[i];
        if (passive.currentCooldown > 0) {
          passive.currentCooldown--;
          if (passive.currentCooldown == 0) {
            if (passive.triggerFrequency == 'Uma Vez por Cooldown') passive.isActive = false;
            for (var effect in passive.effects) {
              if (effect.grantsArmor != null) {
                effect.grantsArmor!.currentHits = effect.grantsArmor!.maxHits;
                widget.showToast('${passive.name}: Armadura Restaurada!');
              }
            }
            widget.showToast('${passive.name} ${AppStrings.of(context).get('ready_msg')}');
          }
        }
        if (passive.isActive || passive.triggerType == 'Sempre Ativo') {
           final updatedEffects = _updatePassiveEffectsPerRound(passive.effects);
           if (updatedEffects != passive.effects) {
             _passives[i] = Passive(id: passive.id, name: passive.name, description: passive.description, triggerType: passive.triggerType, triggerValueType: passive.triggerValueType, triggerValue: passive.triggerValue, triggerFrequency: passive.triggerFrequency, cooldown: passive.cooldown, basedOnTotal: passive.basedOnTotal, effects: updatedEffects, isActive: passive.isActive, stacks: passive.stacks, currentCooldown: passive.currentCooldown);
           }
        }
      }
    });
    widget.showToast(AppStrings.of(context).get('round_msg'));
  }

  void _repairArmor(Armor armor) {
    setState(() {
      armor.currentHits = armor.maxHits;
    });
    final strings = AppStrings.of(context);
    widget.showToast('${armor.name} ${strings.get('armor_repaired')}');
  }

  void _showRitualDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return SimpleDialog(
          title: const Center(child: Text("Adicionar Ritual")),
          children: [
            Center(
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  _showLearnRitualScreen();
                }, 
                child: const Text("Aprender", style: TextStyle(fontWeight: FontWeight.bold))
              ),
            ),
            const SizedBox(height: 12),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  _openEntityForm(isRitual: true);
                }, 
                child: const Text("Criar")
              ),
            ),
          ],
        );
      }
    );
  }

  Color _getRitualColor(Ability ritual) {
    for (var die in ritual.bonusDice) {
      final type = die.damageType;
      final key = ElementalSystem.data.keys.firstWhere(
        (k) => k.toLowerCase() == type.toLowerCase(), 
        orElse: () => ''
      );
      
      if (key.isNotEmpty) {
        return ElementalSystem.data[key]!.color;
      }
    }
    
    final textToCheck = "${ritual.name} ${ritual.description}".toLowerCase();
    for (var entry in ElementalSystem.data.entries) {
      if (textToCheck.contains(entry.key.toLowerCase())) {
        return entry.value.color;
      }
    }

    return Colors.purpleAccent; 
  }

  void _showLearnRitualScreen() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent, 
      builder: (context) {
        final rituals = SystemRituals.allRituals;
        
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.85,
          maxChildSize: 0.95,
          builder: (context, scrollController) {
            return Container(
              decoration: BoxDecoration(
                color: const Color(0xFF1A1A1A), 
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                border: Border.all(color: const Color(0xFF4A4A4A), width: 2),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.8), blurRadius: 15, spreadRadius: 2)],
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    decoration: const BoxDecoration(
                      border: Border(bottom: BorderSide(color: Color(0xFFFFD700), width: 1)),
                    ),
                    child: Center(
                      child: Text(
                        "GRIMÓRIO PROIBIDO",
                        style: TextStyle(
                          fontFamily: 'Cinzel',
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFFFFD700), 
                          letterSpacing: 2.0,
                          shadows: [Shadow(color: Colors.red.withOpacity(0.5), blurRadius: 10, offset: const Offset(0,0))]
                        ),
                      ),
                    ),
                  ),
                  
                  Expanded(
                    child: ListView.builder(
                      controller: scrollController,
                      padding: const EdgeInsets.all(16),
                      itemCount: rituals.length,
                      itemBuilder: (context, index) {
                        final ritual = rituals[index];
                        final color = _getRitualColor(ritual); 
                        
                        return Container(
                          margin: const EdgeInsets.only(bottom: 24),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.black45,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: color.withOpacity(0.5), width: 1),
                            boxShadow: [BoxShadow(color: color.withOpacity(0.1), blurRadius: 8, spreadRadius: 1)]
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                ritual.name.toUpperCase(),
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: color,
                                  letterSpacing: 1.2,
                                  shadows: [Shadow(color: color.withOpacity(0.5), blurRadius: 5)],
                                ),
                              ),
                              const SizedBox(height: 8),
                              Container(height: 1, width: 40, color: color.withOpacity(0.5)),
                              const SizedBox(height: 8),
                              Text(
                                "${ritual.costAmount} ${ritual.costType.toUpperCase()}",
                                style: const TextStyle(
                                  color: Color(0xFFFFD700), 
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                ritual.description,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.9),
                                  fontStyle: FontStyle.italic,
                                  fontSize: 14,
                                  height: 1.4,
                                  fontFamily: 'Lato', 
                                ),
                              ),
                              const SizedBox(height: 16),
                              SizedBox(
                                width: double.infinity,
                                child: OutlinedButton(
                                  style: OutlinedButton.styleFrom(
                                    side: BorderSide(color: color),
                                    foregroundColor: color,
                                    padding: const EdgeInsets.symmetric(vertical: 12),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                  ),
                                  onPressed: () {
                                     setState(() {
                                       _rituals.add(ritual); 
                                     });
                                     widget.showToast("${ritual.name} transcrito para a ficha!");
                                     Navigator.pop(context);
                                  },
                                  child: const Text("Aprender Ritual", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      }
    );
  }

  void _removePericia(String pericia) {
    setState(() {
      _periciasExibidas.remove(pericia);
      _periciasControllers[pericia]?.removeListener(_onFieldChanged);
      _periciasControllers[pericia]?.dispose();
      _periciasControllers.remove(pericia);
    });
  }

  void _performParryRoll() {
    final diceFaces = {'Comum': 4, 'Avançado': 8, 'Super': 12, 'God': 20};
    final faces = diceFaces[_parryType] ?? 4;
    final count = int.tryParse(_parryDiceCountController.text) ?? 0;
    final bonuses = _getBonusesFor(['Parry']);
    
    final bonusDice = _getDiceFromPoints(bonuses.bonusPoints, isAttribute: true);

    if (count > 0) {
      _performRoll(
        dice: [DieSpecification(quantity: count, sides: faces), ...bonusDice],
        modifier: bonuses.modifier,
        multiplier: bonuses.multiplier,
        name: '${AppStrings.of(context).get('parry')} $_parryType',
        bonusSources: bonuses.sources,
      );
    }
  }

  void _showBlockDamageDialog({Ability? preSelectedAbility}) {
    // 1. ESTADO INICIAL DA JANELA (Fundindo as duas lógicas)
    final damageController = TextEditingController();
    final tempBonusController = TextEditingController(text: '0');
    
    String enemyElement = 'Físico';
    List<String> myElements = ['Comum'];
    Ability? selectedAbility = preSelectedAbility;
    bool useBaseBlock = true;
    
    // Pegamos as porcentagens atuais da ficha
    int currentConPerc = int.tryParse(_blockConController.text) ?? 100;
    int currentForPerc = int.tryParse(_blockForController.text) ?? 0;
    int currentSabPerc = int.tryParse(_blockSabController.text) ?? 0;

    final conCtrl = TextEditingController(text: currentConPerc.toString());
    final forCtrl = TextEditingController(text: currentForPerc.toString());
    final sabCtrl = TextEditingController(text: currentSabPerc.toString());

    // Puxa a lista completa de elementos (Gravidade, Espaço, etc.)
    final allElements = ElementalSystem.allElements;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            final defAbilities = [..._abilities, ..._rituals].where((a) => a.abilityType == 'Defesa').toList();

            // --- CÁLCULO DE DADOS EM TEMPO REAL ---
            int diceCount = 0;
            if (useBaseBlock) {
              final conVal = (int.tryParse(_attributesControllers['CON']!.text) ?? 0) + _getBonusesFor(['CON']).bonusPoints;
              final forVal = (int.tryParse(_attributesControllers['FOR']!.text) ?? 0) + _getBonusesFor(['FOR']).bonusPoints;
              final sabVal = (int.tryParse(_attributesControllers['SAB']!.text) ?? 0) + _getBonusesFor(['SAB']).bonusPoints;

              double pCon = (int.tryParse(conCtrl.text) ?? 0) / 100;
              double pFor = (int.tryParse(forCtrl.text) ?? 0) / 100;
              double pSab = (int.tryParse(sabCtrl.text) ?? 0) / 100;

              double totalPts = (conVal * pCon) + (forVal * pFor) + (sabVal * pSab);
              diceCount += (totalPts / 10).floor() + 1; // 1 dado a cada 10 pts + 1 base
            }

            if (selectedAbility != null) {
              // Soma os dados extras que a Habilidade/Reação fornece!
              diceCount += selectedAbility!.bonusDice.fold(0, (sum, d) => sum + d.quantity);
            }

            // Cor baseada no primeiro elemento da sua defesa
            Color themeColor = myElements.contains('Comum') 
                ? Colors.amber 
                : (ElementalSystem.allElementsMap[myElements.first]?.color ?? Colors.amber);

            return Dialog(
              backgroundColor: Colors.transparent,
              insetPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
              child: Container(
                width: double.infinity,
                constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.9),
                decoration: BoxDecoration(
                  color: const Color(0xFF1A1A1A),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: themeColor.withOpacity(0.5), width: 2),
                  boxShadow: [BoxShadow(color: themeColor.withOpacity(0.2), blurRadius: 15)],
                ),
                child: Column(
                  children: [
                    // --- CABEÇALHO ---
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: themeColor.withOpacity(0.1),
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.shield, color: themeColor, size: 28),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(AppStrings.of(context).get('block_damage').toUpperCase(), style: TextStyle(color: themeColor, fontWeight: FontWeight.bold, letterSpacing: 1)),
                          ),
                        ],
                      ),
                    ),

                    // --- ÁREA DE SCROLL (Formulário completo sem cortar nada) ---
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // 1. INFORMAÇÕES DO ATAQUE INIMIGO
                            const Text("⚔️ DADOS DO ATAQUE INIMIGO:", style: TextStyle(color: Colors.redAccent, fontSize: 11, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Expanded(
                                  flex: 2,
                                  child: TextField(
                                    controller: damageController,
                                    keyboardType: TextInputType.number,
                                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                    decoration: InputDecoration(
                                      labelText: AppStrings.of(context).get('damage_received'),
                                      filled: true, fillColor: Colors.black26,
                                      border: const OutlineInputBorder(),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  flex: 3,
                                  child: DropdownButtonFormField<String>(
                                    initialValue: enemyElement,
                                    dropdownColor: Colors.grey[900],
                                    items: {'Físico', ...allElements}.map((e) => DropdownMenuItem(value: e, child: Text(e, style: const TextStyle(color: Colors.white)))).toList(),
                                    onChanged: (v) => setDialogState(() => enemyElement = v!),
                                    decoration: const InputDecoration(labelText: 'Elemento', filled: true, fillColor: Colors.black26, border: OutlineInputBorder()),
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 24),

                            // 2. ELEMENTOS DA SUA DEFESA
                            const Text("🛡️ SEUS ELEMENTOS (MULTI-SELEÇÃO):", style: TextStyle(color: Colors.cyanAccent, fontSize: 11, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 12),
                            Wrap(
                              spacing: 8, runSpacing: 8,
                              children: ['Comum', ...allElements].map((e) {
                                bool isSelected = myElements.contains(e);
                                Color eColor = e == 'Comum' ? Colors.amber : (ElementalSystem.allElementsMap[e]?.color ?? Colors.white);
                                return InkWell(
                                  onTap: () => setDialogState(() {
                                    if (e == 'Comum') {
                                      myElements = ['Comum'];
                                    } else {
                                      myElements.remove('Comum');
                                      isSelected ? myElements.remove(e) : myElements.add(e);
                                      if (myElements.isEmpty) myElements = ['Comum'];
                                    }
                                  }),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                    decoration: BoxDecoration(
                                      color: isSelected ? eColor.withOpacity(0.2) : Colors.black45,
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(color: isSelected ? eColor : Colors.white10),
                                    ),
                                    child: Text(e, style: TextStyle(color: isSelected ? eColor : Colors.white54, fontSize: 12, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
                                  ),
                                );
                              }).toList(),
                            ),

                            const SizedBox(height: 24),

                            // 3. HABILIDADES DE REAÇÃO E BÔNUS
                            const Text("🪄 HABILIDADES E BÔNUS EXTRAS:", style: TextStyle(color: Colors.purpleAccent, fontSize: 11, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 12),
                            if (defAbilities.isNotEmpty) ...[
                              DropdownButtonFormField<Ability?>(
                                initialValue: selectedAbility,
                                items: [
                                  const DropdownMenuItem<Ability?>(value: null, child: Text('Nenhuma Habilidade', style: TextStyle(color: Colors.white))),
                                  ...defAbilities.map((a) => DropdownMenuItem<Ability?>(value: a, child: Text(a.name, style: const TextStyle(color: Colors.white)))),
                                ],
                                onChanged: (newValue) {
                                  setDialogState(() {
                                    selectedAbility = newValue;
                                    if (selectedAbility == null) useBaseBlock = true;
                                  });
                                },
                                dropdownColor: Colors.grey[800],
                                decoration: const InputDecoration(labelText: 'Habilidade Defensiva (Reação)', filled: true, fillColor: Colors.black26, border: OutlineInputBorder()),
                              ),
                              const SizedBox(height: 8),
                            ],
                            
                            TextField(
                                controller: tempBonusController,
                                decoration: const InputDecoration(labelText: 'Bônus Fixo Adicional', helperText: 'Coberturas, Buffs de Aliados, etc.', filled: true, fillColor: Colors.black26, border: OutlineInputBorder()),
                                keyboardType: TextInputType.number,
                                style: const TextStyle(color: Colors.white)),

                            const SizedBox(height: 16),

                            // 4. ATRIBUTOS (Opcional se usar Habilidade)
                            CheckboxListTile(
                              title: const Text('Somar com Bloqueio Base (Atributos)', style: TextStyle(fontSize: 14, color: Colors.white)),
                              value: useBaseBlock,
                              activeColor: themeColor,
                              onChanged: selectedAbility == null ? null : (val) {
                                setDialogState(() => useBaseBlock = val ?? true);
                              },
                              controlAffinity: ListTileControlAffinity.leading,
                              contentPadding: EdgeInsets.zero,
                            ),

                            if (useBaseBlock) ...[
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(color: Colors.black26, borderRadius: BorderRadius.circular(12)),
                                child: Column(
                                  children: [
                                    _buildAttrRow("CON", conCtrl, Colors.orangeAccent, () => setDialogState(() {})),
                                    _buildAttrRow("FOR", forCtrl, Colors.redAccent, () => setDialogState(() {})),
                                    _buildAttrRow("SAB", sabCtrl, Colors.blueAccent, () => setDialogState(() {})),
                                  ]
                                )
                              )
                            ]
                          ],
                        ),
                      ),
                    ),

                    // --- RODAPÉ (RESULTADO) ---
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: const BoxDecoration(border: Border(top: BorderSide(color: Colors.white12))),
                      child: Column(
                        children: [
                          Text("DADOS A ROLAR: ${diceCount}d20", style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 15),
                          Row(
                            children: [
                              Expanded(
                                child: TextButton(onPressed: () => Navigator.pop(context), child: Text(AppStrings.of(context).get('cancel'), style: const TextStyle(color: Colors.grey)))
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                flex: 2,
                                child: SizedBox(
                                  height: 50,
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(backgroundColor: themeColor, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                                    onPressed: () {
                                      // Atualiza a ficha caso o jogador tenha alterado as % na hora
                                      _blockConController.text = conCtrl.text;
                                      _blockForController.text = forCtrl.text;
                                      _blockSabController.text = sabCtrl.text;
                                      
                                      Navigator.pop(context);
                                      final incomingDamage = int.tryParse(damageController.text) ?? 0;
                                      final tempBonus = int.tryParse(tempBonusController.text) ?? 0;
                                      
                                      // Envia TUDO (incluindo a lista de elementos selecionados) para o _executeBlock!
                                      _executeBlock(incomingDamage, enemyElement, selectedAbility, useBaseBlock, tempBonus, myElements);
                                    },
                                    child: Text(AppStrings.of(context).get('block').toUpperCase(), style: const TextStyle(color: Colors.black, fontWeight: FontWeight.w900, fontSize: 16)),
                                  ),
                                ),
                              ),
                            ]
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          }
        );
      },
    );
  }

  // Widget auxiliar para as linhas de atributo dentro da janela
  Widget _buildAttrRow(String label, TextEditingController ctrl, Color color, VoidCallback onChanged) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          SizedBox(width: 40, child: Text(label, style: TextStyle(color: color, fontWeight: FontWeight.bold))),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: ctrl,
              keyboardType: TextInputType.number,
              style: const TextStyle(color: Colors.white, fontSize: 14),
              onChanged: (_) => onChanged(),
              decoration: const InputDecoration(suffixText: "%", isDense: true, contentPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 10)),
            ),
          ),
        ],
      ),
    );
  }

  void _executeBlock(int incomingDamage, String attackerElement, [Ability? reactionAbility, bool useBaseBlock = true, int tempBonus = 0, List<String>? customDefenderElements]) {
    
    // Se não passarem elementos de defesa (ex: um ataque direto da mesa), usa 'Comum'
    List<String> defenderElements = customDefenderElements ?? ['Comum'];

    // 1. Recursos (Custos de Esforço/Vida)
    if (reactionAbility != null) {
      int cost = _calculateFatigueCost(reactionAbility);
      if (!_hasEnoughResources(cost, reactionAbility.costType, reactionAbility.costSource)) {
        widget.showToast("Recursos insuficientes!");
        return;
      }
      if (reactionAbility.costType == "Esforço") {
        _payEffort(cost, reactionAbility.costSource);
      } else {
        final ctrl = _statusControllers[reactionAbility.costType]!['atual']!;
        ctrl.text = ((int.tryParse(ctrl.text) ?? 0) - cost).toString();
        _onStatusChange(reactionAbility.costType);
      }

      setState(() => reactionAbility.usesInCombat++);
      if (reactionAbility.cooldown > 0) setState(() => reactionAbility.currentCooldown = reactionAbility.cooldown);

      if (reactionAbility.armorToCreate != null) {
        setState(() {
          final newArmor = Armor.fromJson(reactionAbility.armorToCreate!.toJson());
          _temporaryArmors.add(newArmor);
        });
        widget.showToast('${reactionAbility.armorToCreate!.name} invocada!');
      }
    }

    // 2. Preparação dos Dados
    List<DieSpecification> blockDice = [];
    int blockModifier = tempBonus; // Restaura o bônus temporário de reações

    if (useBaseBlock) {
      final conPerc = (int.tryParse(_blockConController.text) ?? 0) / 100;
      final forPerc = (int.tryParse(_blockForController.text) ?? 0) / 100;
      final sabPerc = (int.tryParse(_blockSabController.text) ?? 0) / 100;

      final conVal = (int.tryParse(_attributesControllers['CON']!.text) ?? 0) + _getBonusesFor(['CON']).bonusPoints;
      final forVal = (int.tryParse(_attributesControllers['FOR']!.text) ?? 0) + _getBonusesFor(['FOR']).bonusPoints;
      final sabVal = (int.tryParse(_attributesControllers['SAB']!.text) ?? 0) + _getBonusesFor(['SAB']).bonusPoints;

      double totalPoints = (conVal * conPerc) + (forVal * forPerc) + (sabVal * sabPerc);

      // Conversão de Pontos em Dados (1 dado a cada 10 pontos + 1 base)
      int diceCount = (totalPoints / 10).floor() + 1;
      blockDice.add(DieSpecification(quantity: diceCount, sides: 20, damageType: 'Cura'));
    }

    if (reactionAbility != null) {
      blockDice.addAll(reactionAbility.bonusDice);
      blockModifier += reactionAbility.bonusModifier;
    }

    // 3. Lógica de Clash (Vantagem Elemental)
    double multiplier = 1.0;
    if (!defenderElements.contains('Comum') && attackerElement != 'Comum') {
       multiplier = ElementalSystem.calculateClashMultiplier(defenderElements, [attackerElement]);
    }
    if (reactionAbility != null) multiplier *= reactionAbility.multiplier;

    // 4. Execução da Rolagem
    String rollName = "Bloqueio [${defenderElements.join('+')}]";
    if (reactionAbility != null) rollName += " + ${reactionAbility.name}";

    final blockRollResult = _performRoll(
      name: rollName,
      dice: blockDice,
      modifier: blockModifier,
      multiplier: multiplier,
      defenseTarget: incomingDamage,
    );

    // 5. Processamento de Dano e Armaduras
    int finalDamage = blockRollResult.total < 0 ? blockRollResult.total.abs() : 0;
    
    int armorRed = 0;
    double armorResist = 1.0;
    for (var a in [..._temporaryArmors, ..._getEquippedArmors()]) {
      if (a.reductionValue > 0 && (a.reductionTypes.isEmpty || a.reductionTypes.contains(attackerElement))) {
        armorRed += a.reductionValue;
      }
      armorResist *= (a.resistances[attackerElement] ?? 1.0);
    }

    finalDamage = max(0, finalDamage - armorRed);
    finalDamage = (finalDamage * armorResist).round();
    finalDamage = (finalDamage * (_blockResistances[attackerElement] ?? 1.0)).round();

    // Aplica o dano na Vida
    if (finalDamage > 0) {
      final hpCtrl = _statusControllers['Vida']!['atual']!;
      int current = int.tryParse(hpCtrl.text) ?? 0;
      hpCtrl.text = max(0, current - finalDamage).toString();
      _onStatusChange('Vida');
    }

    widget.showToast('Bloqueou com ${blockRollResult.total.abs()} de poder! Dano sofrido: $finalDamage');
  }

  void _showPericiasDialog() {
    final availablePericias = _allPericias.where((p) => !_periciasExibidas.contains(p)).toList()..sort();
    final strings = AppStrings.of(context);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).cardColor,
        title: Text(strings.get('add_skills'), style: TextStyle(color: Theme.of(context).colorScheme.onSurface)),
        content: buildMultiSelectPericias(
          context: context,
          initialValue: [],
          allItems: availablePericias,
          onConfirm: (List<String> values) {
            setState(() {
              for (var pericia in values) {
                if (!_periciasExibidas.contains(pericia)) {
                  _periciasExibidas.add(pericia);
                  _periciasControllers[pericia] = TextEditingController(text: '0');
                  _periciasControllers[pericia]!.addListener(_onFieldChanged);
                }
              }
              _periciasExibidas.sort();
            });
            Navigator.of(context).pop();
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(strings.get('close')),
          ),
        ],
      ),
    );
  }

  void _openEntityForm<T>({T? entity, bool isRitual = false}) {
    EntityType? type;
    if (isRitual) {
      type = EntityType.ritual;
    } else if (T == Weapon) {
      type = EntityType.weapon;
    }
    else if (T == Armor) {
      type = EntityType.armor;
    }
    else if (T == Item) {
      type = EntityType.item;
    }
    else if (T == Ability) {
      if (entity != null && _rituals.any((r) => r.id == (entity as Ability).id)) {
        type = EntityType.ritual;
      } else {
        type = EntityType.ability;
      }
    }
    else if (T == Passive) {
      type = EntityType.passive;
    }
    else if (T == StatusEffect) {
      type = EntityType.statusEffect;
    }

    if(type == null) {
      return;
    }

    Navigator.of(context).push(MaterialPageRoute(builder: (context) => AddEditEntityForm(
      entityType: type!,
      initialEntity: entity,
      characterAttributes: _attributesControllers.keys.toList(),
      characterPericias: _allPericias, 
      characterWeapons: _inventory.whereType<Weapon>().toList(),
      characterAbilities: _abilities,
      onSave: (savedEntity) {
        setState(() {
          if (entity != null) { // Editando
            if (savedEntity is Item) {
              final index = _inventory.indexWhere((i) => i.id == savedEntity.id);
              if (index != -1) {
                _inventory[index] = savedEntity;
              }
            } else if (savedEntity is Ability) {
              if (type == EntityType.ritual) {
                 final index = _rituals.indexWhere((r) => r.id == savedEntity.id);
                 if (index != -1) _rituals[index] = savedEntity;
              } else {
                 final index = _abilities.indexWhere((a) => a.id == savedEntity.id);
                 if (index != -1) _abilities[index] = savedEntity;
              }
            } else if (savedEntity is Passive) {
              final index = _passives.indexWhere((p) => p.id == savedEntity.id);
              if (index != -1) {
                _passives[index] = savedEntity;
              }
            } else if (savedEntity is StatusEffect) {
               final index = _statusEffects.indexWhere((e) => e.id == savedEntity.id);
               if (index != -1) {
                 _statusEffects[index] = savedEntity;
               }
            }
          } else { // Adicionando
            if (savedEntity is Item) {
              _inventory.add(savedEntity);
            }
            else if (savedEntity is Ability) {
              if (type == EntityType.ritual) {
                _rituals.add(savedEntity);
              } else {
                _abilities.add(savedEntity);
              }
            }
            else if (savedEntity is Passive) {
              _passives.add(savedEntity);
            }
            else if (savedEntity is StatusEffect) {
              _statusEffects.add(savedEntity);
            }
          }
        });
      },
    )));
  }

  PassiveBonuses _getBonusesFor(List<String> targets) {
    int modifier = 0;
    double totalPercentage = 0.0;
    int bonusPoints = 0;
    List<BonusSource> sources = [];

    void processEffect(dynamic effect, int stacks, String sourceName) {
      bool applies = false;
      for (var target in targets) {
        if (effect.targets.contains(target)) {
          applies = true;
          break;
        }
      }
      
      if (applies) {
        if (effect.bonusType == 'Modificador') {
          final totalValue = (effect.value as num).toInt() * stacks;
          modifier += totalValue;
          sources.add(BonusSource(sourceName: sourceName, value: '+$totalValue', type: 'Mod.'));
        } else if (effect.bonusType == 'Percentual') {
          final totalValue = (effect.value as num) * stacks.toDouble();
          totalPercentage += totalValue;
          sources.add(BonusSource(sourceName: sourceName, value: '+${totalValue.toStringAsFixed(0)}%', type: 'Mult.'));
        } else if (effect.bonusType == 'Pontos de Bônus') {
          final totalValue = (effect.value as num).toInt() * stacks;
          bonusPoints += totalValue;
          sources.add(BonusSource(sourceName: sourceName, value: '+$totalValue', type: 'Pts.'));
        }
      }
    }

    for (var passive in _passives.where((p) => p.isActive || p.triggerType == 'Sempre Ativo' || p.stacks > 0)) {
      int stacks = passive.stacks > 0 ? passive.stacks : 1;
      for (var effect in passive.effects) {
        processEffect(effect, stacks, passive.name);
      }
    }

    // REGRA DAS ARMAS: Ignora armas equipadas, elas servem apenas para atacar.
    for (var item in _inventory.where((i) => i.isEquipped && i is! Weapon)) {
      for (var effect in item.effects) {
        processEffect(effect, 1, item.name);
      }
    }

    for (var ability in _abilities.where((a) => a.isActive)) {
      for (var effect in ability.effects) {
        processEffect(effect, 1, ability.name);
      }
    }
    
    for (var ritual in _rituals.where((r) => r.isActive)) {
      for (var effect in ritual.effects) {
        processEffect(effect, 1, ritual.name);
      }
    }

    for (var statusEffect in _statusEffects) {
      processEffect(statusEffect, 1, statusEffect.name);
    }

    double multiplier = 1.0 + (totalPercentage / 100.0);

    return PassiveBonuses(modifier: modifier, multiplier: multiplier, bonusPoints: bonusPoints, sources: sources);
  }

  int _getTotalStatWithBonuses(String statName) {
    int baseTotal = int.tryParse(_statusControllers[statName]!['total']!.text) ?? 0;
    final bonuses = _getBonusesFor([statName]);
    return baseTotal + bonuses.modifier;
  }

  void _useWeapon(Weapon weapon) {
    if (weapon.attackSkill != null && weapon.attackSkill!.isNotEmpty) {
       _rollAttackThenDamage(
         attackName: "Ataque (${weapon.name})", 
         skillName: weapon.attackSkill!, 
         attackBonus: weapon.attackBonus,
         attackMultiplier: weapon.attackMultiplier, 
         damageName: weapon.name,
         damageDice: weapon.dice,
         damageModifier: weapon.modifier,
         damageMultiplier: weapon.multiplier,
         triggers: weapon.triggers,
       );
    } else {
      final damageTypes = weapon.dice.map((d) => d.damageType).toSet().toList();
      final targets = [weapon.name, ...damageTypes];

      final bonuses = _getBonusesFor(targets);
      final bonusDice = _getDiceFromPoints(bonuses.bonusPoints, isAttribute: true); 

      _performRoll(
        name: weapon.name,
        dice: [...weapon.dice, ...bonusDice],
        modifier: weapon.modifier + bonuses.modifier,
        multiplier: weapon.multiplier * bonuses.multiplier,
        triggers: weapon.triggers,
        bonusSources: bonuses.sources,
      );
    }
  }

  void _rollAttackThenDamage({
    required String attackName,
    required String skillName,
    required int attackBonus,
    required double attackMultiplier, 
    required String damageName,
    required List<DieSpecification> damageDice,
    required int damageModifier,
    required double damageMultiplier,
    required List<ConditionalEffect> triggers,
  }) {
    final skillPoints = int.tryParse(_periciasControllers[skillName]?.text ?? '0') ?? 0;
    final skillBonuses = _getBonusesFor([skillName]);
    final totalSkillPoints = skillPoints + skillBonuses.bonusPoints;
    
    final attackDice = _getDiceFromPoints(totalSkillPoints);
    final attackMod = _getModifierFromPoints(totalSkillPoints) + skillBonuses.modifier + attackBonus;

    _performRoll(
      name: "$attackName [$skillName]",
      dice: attackDice,
      modifier: attackMod,
      multiplier: skillBonuses.multiplier * attackMultiplier, 
      bonusSources: skillBonuses.sources,
    );

    final damageTypes = damageDice.map((d) => d.damageType).toSet().toList();
    final dmgBonuses = _getBonusesFor([damageName, ...damageTypes]);
    final dmgBonusDice = _getDiceFromPoints(dmgBonuses.bonusPoints, isAttribute: true); 

    _performRoll(
      name: "Dano ($damageName)",
      dice: [...damageDice, ...dmgBonusDice],
      modifier: damageModifier + dmgBonuses.modifier,
      multiplier: damageMultiplier * dmgBonuses.multiplier,
      triggers: triggers,
      bonusSources: dmgBonuses.sources,
    );
  }

  void _deleteAbility(Ability ability) {
    setState(() => _abilities.removeWhere((a) => a.id == ability.id));
  }

  int _calculateFatigueCost(Ability ability) {
    if (ability.costAmount <= 0) return 0;
    
    double multiplier = 1.0;
    switch (ability.usesInCombat) {
      case 0: multiplier = 1.0; break; 
      case 1: multiplier = 1.3; break; 
      case 2: multiplier = 1.6; break; 
      case 3: multiplier = 2.0; break; 
      case 4: multiplier = 2.5; break;
      case 5: multiplier = 3.0; break;
      case 6: multiplier = 4.0; break;
      case 7: multiplier = 5.0; break;
      default: multiplier = 7.0; break;
    }
    return (ability.costAmount * multiplier).round();
  }

  bool _hasEnoughResources(int cost, String costType, String costSource) {
    if (cost <= 0) return true;

    if (costType == 'Esforço') {
      final tempEffort = int.tryParse(_statusControllers['Esforço Temporário']!['atual']!.text) ?? 0;
      final standardEffort = int.tryParse(_statusControllers['Esforço']!['atual']!.text) ?? 0;
      
      switch(costSource) {
        case 'Apenas Temporário':
          return tempEffort >= cost;
        case 'Padrão':
          return standardEffort >= cost;
        case 'Híbrido (Temp. > Padrão)':
          return (tempEffort + standardEffort) >= cost;
        default:
          return standardEffort >= cost;
      }
    } else {
      final resource = int.tryParse(_statusControllers[costType]!['atual']!.text) ?? 0;
      return resource >= cost;
    }
  }

  void _payEffort(int cost, String source) {
    final tempEffortController = _statusControllers['Esforço Temporário']!['atual']!;
    final effortController = _statusControllers['Esforço']!['atual']!;
    int tempEffort = int.tryParse(tempEffortController.text) ?? 0;
    int effort = int.tryParse(effortController.text) ?? 0;
    final strings = AppStrings.of(context);

    if (source == 'Apenas Temporário') {
       tempEffortController.text = (tempEffort - cost).toString();
       _onStatusChange('Esforço Temporário');
       widget.showToast("$cost ${strings.get('temp_effort')}");
    } else if (source == 'Padrão') {
        effortController.text = (effort - cost).toString();
        _onStatusChange('Esforço');
    } else { 
      int costLeft = cost;
      int toDeductFromTemp = min(costLeft, tempEffort);
      if (toDeductFromTemp > 0) {
        tempEffortController.text = (tempEffort - toDeductFromTemp).toString();
        _onStatusChange('Esforço Temporário');
        costLeft -= toDeductFromTemp;
        widget.showToast("$toDeductFromTemp ${strings.get('temp_effort')}");
      }
      if (costLeft > 0) {
          effortController.text = (effort - costLeft).toString();
          _onStatusChange('Esforço');
      }
    }
  }

  void _useAbility(Ability ability) {
    final strings = AppStrings.of(context);
    
    if (ability.abilityType == 'Buff/Transformação' && ability.isActive) {
      setState(() => ability.isActive = false);
      widget.showToast('${ability.name} Desativada');
      return;
    }

    if (ability.currentCooldown > 0) {
      widget.showToast('${ability.name} ${strings.get('cooldown_msg')} ${ability.currentCooldown}');
      return;
    }

    if (ability.abilityType == 'Defesa') {
       _showBlockDamageDialog(preSelectedAbility: ability);
       return; 
    }

    int fatigueCost = 0;
    if (ability.abilityType == 'Buff/Transformação') {
      fatigueCost = ability.costAmount; 
    } else {
      fatigueCost = _calculateFatigueCost(ability);
    }

    if (!_hasEnoughResources(fatigueCost, ability.costType, ability.costSource)) {
      widget.showToast(strings.get('insufficient_resources'));
      return;
    }

    if (fatigueCost > 0) {
      if (ability.costType == "Esforço") {
        _payEffort(fatigueCost, ability.costSource);
      } else {
        final controller = _statusControllers[ability.costType]!['atual']!;
        int current = int.tryParse(controller.text) ?? 0;
        controller.text = (current - fatigueCost).toString();
        _onStatusChange(ability.costType);
      }
    }
    
    setState(() => ability.usesInCombat++);
    if (ability.cooldown > 0) setState(() => ability.currentCooldown = ability.cooldown);

    if (ability.abilityType == 'Dano' || ability.abilityType == 'Restaurar Vida' || ability.abilityType == 'Restaurar Esforço') {
       final dice = <DieSpecification>[];
      int modifier = ability.bonusModifier;
      int bonusPoints = 0;
      List<BonusSource> bonusSources = [];

      dice.addAll(ability.bonusDice);

      if (ability.useWeaponDamage) {
        final equippedWeapon = _inventory.whereType<Weapon>().where((w) => w.isEquipped).firstOrNull;
        if (equippedWeapon != null) {
           dice.addAll(equippedWeapon.dice);
           modifier += equippedWeapon.modifier;
           bonusSources.add(BonusSource(sourceName: equippedWeapon.name, value: "Base", type: "Arma"));
        }
      }

      for (var base in ability.baseComponents) {
        int points = 0;
        if (base.type == 'Atributo' && _attributesControllers.containsKey(base.value)) {
          points = int.tryParse(_attributesControllers[base.value]!.text) ?? 0;
        } else if (base.type == 'Perícia' && _periciasControllers.containsKey(base.value)) {
          points = int.tryParse(_periciasControllers[base.value]!.text) ?? 0;
        }
        final bonuses = _getBonusesFor([base.value]);
        bonusPoints += points + bonuses.bonusPoints;
        modifier += bonuses.modifier;
        bonusSources.addAll(bonuses.sources);
      }
      
      final damageTypes = ability.bonusDice.map((d) => d.damageType).toSet().toList();
      final abilityBonuses = _getBonusesFor([ability.name, ...damageTypes]);
      modifier += abilityBonuses.modifier;
      bonusSources.addAll(abilityBonuses.sources);

      dice.addAll(_getDiceFromPoints(bonusPoints));
      modifier += _getModifierFromPoints(bonusPoints);

        if (ability.attackSkill != null && ability.attackSkill!.isNotEmpty) {
           _rollAttackThenDamage(
             attackName: "Ataque (${ability.name})",
             skillName: ability.attackSkill!,
             attackBonus: ability.attackBonus,
             attackMultiplier: ability.attackMultiplier, 
             damageName: ability.name,
             damageDice: dice,
             damageModifier: modifier,
             damageMultiplier: ability.multiplier,
             triggers: ability.conditionalEffects,
           );
        } else {
          final result = _performRoll(
            name: ability.name,
            dice: dice,
            modifier: modifier,
            multiplier: ability.multiplier * abilityBonuses.multiplier,
            triggers: ability.conditionalEffects,
            bonusSources: bonusSources,
          );

          if (ability.abilityType == 'Restaurar Vida') {
            final vidaAtual = int.tryParse(_statusControllers['Vida']!['atual']!.text) ?? 0;
            final vidaTotal = _getTotalStatWithBonuses('Vida');
            final novaVida = min(vidaAtual + result.total, vidaTotal);
            _statusControllers['Vida']!['atual']!.text = novaVida.toString();
          } else if (ability.abilityType == 'Restaurar Esforço') {
            final esforcoAtual = int.tryParse(_statusControllers['Esforço']!['atual']!.text) ?? 0;
            final esforcoTotal = _getTotalStatWithBonuses('Esforço');
            final tempEsforcoAtual = int.tryParse(_statusControllers['Esforço Temporário']!['atual']!.text) ?? 0;
            final tempEsforcoTotal = int.tryParse(_statusControllers['Esforço Temporário']!['total']!.text) ?? 0;

            int amountToHeal = result.total;

            int healedEffort = min(amountToHeal, esforcoTotal - esforcoAtual);
            if (healedEffort > 0) {
              _statusControllers['Esforço']!['atual']!.text = (esforcoAtual + healedEffort).toString();
              amountToHeal -= healedEffort;
            }

            if (amountToHeal > 0) {
              _statusControllers['Esforço Temporário']!['total']!.text = (tempEsforcoTotal + amountToHeal).toString();
              _statusControllers['Esforço Temporário']!['atual']!.text = (tempEsforcoAtual + amountToHeal).toString();
              widget.showToast("$amountToHeal ${strings.get('temp_effort')}");
            }
          }
        }
    } else if (ability.abilityType == 'Buff/Transformação') {
      setState(() {
        ability.isActive = true;
      });
      widget.showToast('${ability.name} Ativada');
    } else if (ability.abilityType == 'Criar Armadura') {
      if (ability.armorToCreate != null) {
        setState(() {
          final newArmor = Armor.fromJson(ability.armorToCreate!.toJson());
          _temporaryArmors.add(newArmor);
        });
        widget.showToast('${ability.armorToCreate!.name} ${strings.get('item_created')}');
      }
    } else {
      widget.showToast('Uso para "${ability.abilityType}" ainda não implementado.');
    }
  }

  void _deletePassive(Passive passive) {
    setState(() => _passives.remove(passive));
  }

  void _levelUp() {
    setState(() {
      final currentLevel = int.tryParse(_levelController.text) ?? 0;
      _levelController.text = (currentLevel + 1).toString();
      final currentHp = int.tryParse(_statusControllers['Vida']!['total']!.text) ?? 0;
      _statusControllers['Vida']!['total']!.text = (currentHp + _hpPerLevel).toString();
      final currentEffort = int.tryParse(_statusControllers['Esforço']!['total']!.text) ?? 0;
      _statusControllers['Esforço']!['total']!.text = (currentEffort + _effortPerLevel).toString();
      final currentSanity = int.tryParse(_statusControllers['Sanidade']!['total']!.text) ?? 0;
      _statusControllers['Sanidade']!['total']!.text = (currentSanity + _sanityPerLevel).toString();
    });
  }

  void _levelDown() {
    setState(() {
      final currentLevel = int.tryParse(_levelController.text) ?? 1;
      if (currentLevel > 1) {
        _levelController.text = (currentLevel - 1).toString();
        final currentHp = int.tryParse(_statusControllers['Vida']!['total']!.text) ?? 0;
        _statusControllers['Vida']!['total']!.text = (currentHp - _hpPerLevel).toString();
        final currentEffort = int.tryParse(_statusControllers['Esforço']!['total']!.text) ?? 0;
        _statusControllers['Esforço']!['total']!.text = (currentEffort - _effortPerLevel).toString();
        final currentSanity = int.tryParse(_statusControllers['Sanidade']!['total']!.text) ?? 0;
        _statusControllers['Sanidade']!['total']!.text = (currentSanity - _sanityPerLevel).toString();
      }
    });
  }

  void _showGainsPerLevelDialog() {
    final hpController = TextEditingController(text: _hpPerLevel.toString());
    final effortController = TextEditingController(text: _effortPerLevel.toString());
    final sanityController = TextEditingController(text: _sanityPerLevel.toString());
    final atributoController = TextEditingController(text: _pontosAtributoPorNivel.toString());
    final periciaController = TextEditingController(text: _pontosPericiaPorNivel.toString());
    final vidaConController = TextEditingController(text: _vidaPorCon.toString());
    final esforcoSabController = TextEditingController(text: _esforcoPorSab.toString());
    final esforcoDesController = TextEditingController(text: _esforcoPorDes.toString());

    Widget modernField(String label, TextEditingController ctrl, IconData icon, Color color) {
      return Expanded(
        child: Container(
          margin: const EdgeInsets.all(4),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.black38,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: color.withOpacity(0.5)),
          ),
          child: Row(
            children: [
              Icon(icon, color: color, size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: ctrl,
                  keyboardType: TextInputType.number,
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  decoration: InputDecoration(
                    labelText: label,
                    labelStyle: const TextStyle(color: Colors.white54, fontSize: 11),
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    showDialog(
      context: context,
      builder: (context) {
        final level = int.tryParse(_levelController.text) ?? 1;
        final totalAtributo = level * (int.tryParse(atributoController.text) ?? 0);
        final totalPericia = level * (int.tryParse(periciaController.text) ?? 0);

        // Calcula dinamicamente o que o jogador já gastou na ficha
        final int spentAttributes = _attributesControllers.values.fold(0, (sum, ctrl) => sum + (int.tryParse(ctrl.text) ?? 0));
        final int spentSkills = _periciasControllers.values.fold(0, (sum, ctrl) => sum + (int.tryParse(ctrl.text) ?? 0));

        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.all(16),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFF1E1E1E),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.amber.withOpacity(0.5), width: 2),
              boxShadow: const [BoxShadow(color: Colors.black87, blurRadius: 20, spreadRadius: 5)],
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Center(
                    child: Text("Ganhos por Nível", style: TextStyle(color: Colors.amber, fontSize: 22, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
                  ),
                  const SizedBox(height: 20),
                  
                  const Text("RECURSOS BASE (Por Nível)", style: TextStyle(color: Colors.white54, fontSize: 12, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Row(children: [
                    modernField("Vida", hpController, Icons.favorite, Colors.redAccent),
                    modernField("Esforço", effortController, Icons.flash_on, Colors.orangeAccent),
                    modernField("San", sanityController, Icons.psychology, Colors.blueAccent),
                  ]),
                  
                  const SizedBox(height: 16),
                  const Text("PONTOS DE EVOLUÇÃO (Por Nível)", style: TextStyle(color: Colors.white54, fontSize: 12, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Row(children: [
                    modernField("Atributos", atributoController, Icons.fitness_center, Colors.greenAccent),
                    modernField("Perícias", periciaController, Icons.school, Colors.purpleAccent),
                  ]),

                  const SizedBox(height: 16),
                  const Text("ESCALA COM ATRIBUTOS", style: TextStyle(color: Colors.white54, fontSize: 12, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Row(children: [
                    modernField("Vida/CON", vidaConController, Icons.shield, Colors.red),
                    modernField("Esf/SAB", esforcoSabController, Icons.auto_awesome, Colors.amber),
                    modernField("Esf/DES", esforcoDesController, Icons.directions_run, Colors.cyan),
                  ]),
                  
                  const Divider(color: Colors.white24, height: 20),
                  
                  // PAINEL DE DISTRIBUIÇÃO (Cálculo de Pontos Gastos vs Permitidos)
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(color: Colors.black45, borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.white24)),
                    child: Column(
                      children: [
                        const Text("Resumo de Distribuição Atual", style: TextStyle(color: Colors.white70, fontWeight: FontWeight.bold, fontSize: 12)),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Column(
                              children: [
                                const Text("Atributos", style: TextStyle(color: Colors.greenAccent, fontSize: 11)),
                                Text("$spentAttributes / $totalAtributo", style: TextStyle(color: spentAttributes > totalAtributo ? Colors.redAccent : Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                              ],
                            ),
                            Column(
                              children: [
                                const Text("Perícias", style: TextStyle(color: Colors.purpleAccent, fontSize: 11)),
                                Text("$spentSkills / $totalPericia", style: TextStyle(color: spentSkills > totalPericia ? Colors.redAccent : Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                              ],
                            ),
                          ]
                        )
                      ]
                    )
                  ),

                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancelar", style: TextStyle(color: Colors.grey))),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.blue[800]),
                        onPressed: () {
                          setState(() {
                            _hpPerLevel = int.tryParse(hpController.text) ?? 0;
                            _effortPerLevel = int.tryParse(effortController.text) ?? 0;
                            _sanityPerLevel = int.tryParse(sanityController.text) ?? 0;
                            _pontosAtributoPorNivel = int.tryParse(atributoController.text) ?? 0;
                            _pontosPericiaPorNivel = int.tryParse(periciaController.text) ?? 0;
                            _vidaPorCon = int.tryParse(vidaConController.text) ?? 0;
                            _esforcoPorSab = int.tryParse(esforcoSabController.text) ?? 0;
                            _esforcoPorDes = int.tryParse(esforcoDesController.text) ?? 0;
                          });
                          Navigator.pop(context);
                        },
                        child: const Text("Salvar Status", style: TextStyle(color: Colors.white)),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.green[700]),
                        onPressed: () {
                          final con = int.tryParse(_attributesControllers['CON']!.text) ?? 0;
                          final sab = int.tryParse(_attributesControllers['SAB']!.text) ?? 0;
                          final des = int.tryParse(_attributesControllers['DES']!.text) ?? 0;
                          final level = int.tryParse(_levelController.text) ?? 1;
                          final vidaPorCon = int.tryParse(vidaConController.text) ?? _vidaPorCon;
                          final hpPerLevel = int.tryParse(hpController.text) ?? _hpPerLevel;
                          final esforcoPorSab = int.tryParse(esforcoSabController.text) ?? _esforcoPorSab;
                          final esforcoPorDes = int.tryParse(esforcoDesController.text) ?? _esforcoPorDes;
                          final effortPerLevel = int.tryParse(effortController.text) ?? _effortPerLevel;

                          final totalVida = (con * vidaPorCon) + (level * hpPerLevel);
                          final totalEsforco = (sab * esforcoPorSab) + (des * esforcoPorDes) + (level * effortPerLevel);

                          setState(() {
                            _statusControllers['Vida']!['total']!.text = totalVida.toString();
                            _statusControllers['Vida']!['atual']!.text = totalVida.toString();
                            _statusControllers['Esforço']!['total']!.text = totalEsforco.toString();
                            _statusControllers['Esforço']!['atual']!.text = totalEsforco.toString();
                            
                            _hpPerLevel = hpPerLevel;
                            _effortPerLevel = effortPerLevel;
                            _sanityPerLevel = int.tryParse(sanityController.text) ?? 0;
                            _pontosAtributoPorNivel = int.tryParse(atributoController.text) ?? 0;
                            _pontosPericiaPorNivel = int.tryParse(periciaController.text) ?? 0;
                            _vidaPorCon = vidaPorCon;
                            _esforcoPorSab = esforcoPorSab;
                            _esforcoPorDes = esforcoPorDes;
                          });
                          Navigator.pop(context);
                        },
                        child: const Text("Aplicar Total", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      ),
                    ]
                  )
                ],
              ),
            ),
          )
        );
      }
    );
  }

  TextField _buildDialogTextField(TextEditingController controller, String label) {
    final theme = Theme.of(context);
    return TextField(
      controller: controller,
      keyboardType: TextInputType.number,
      style: TextStyle(color: theme.colorScheme.onSurface),
      decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.7)),
          enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: theme.dividerColor))),
    );
  }

  CharacterSheet _buildCurrentSheet() {
    final periciasToSave = {for (final p in _periciasExibidas) p: int.tryParse(_periciasControllers[p]?.text ?? '0')};
    return CharacterSheet(
      id: _sheetId,
      folderId: widget.initialSheet?.folderId, // <--- ESTA É A CORREÇÃO QUE MANTÉM A FICHA NA PASTA!
      name: _nameController.text.isNotEmpty ? _nameController.text : 'Personagem sem nome',
      classe: _classController.text,
      level: int.tryParse(_levelController.text),
      backpack: _inventory,
      attributes: {for (final e in _attributesControllers.entries) e.key: int.tryParse(e.value.text)},
      status: {
        for (final e in _statusControllers.entries)
          e.key: {'atual': int.tryParse(e.value['atual']!.text), 'total': int.tryParse(e.value['total']!.text)}
      },
      pericias: periciasToSave,
      weapons: [],
      abilities: _abilities,
      rituals: _rituals,
      passives: _passives,
      statusEffects: _statusEffects,
      esforcoExtra: int.tryParse(_esforcoExtraController.text) ?? 0,
      imagePath: _imagePath,
      effortColor: _effortColor.value,
      hpPerLevel: _hpPerLevel,
      effortPerLevel: _effortPerLevel,
      sanityPerLevel: _sanityPerLevel,
      pontosAtributoPorNivel: _pontosAtributoPorNivel,
      pontosPericiaPorNivel: _pontosPericiaPorNivel,
      vidaPorCon: _vidaPorCon,
      esforcoPorSab: _esforcoPorSab,
      esforcoPorDes: _esforcoPorDes,
      parryType: _parryType,
      parryDiceCount: int.tryParse(_parryDiceCountController.text) ?? 4,
      armors: [],
      equippedArmor: null,
      blockConPercentage: int.tryParse(_blockConController.text) ?? 100,
      blockForPercentage: int.tryParse(_blockForController.text) ?? 0,
      blockSabPercentage: int.tryParse(_blockSabController.text) ?? 0,
    );
  }

  void _saveFicha() {
    if (!mounted) return;
    final newSheet = _buildCurrentSheet();
    if (_sheetId == null) setState(() => _sheetId = newSheet.id);
    widget.onSave(newSheet);
    if (_isFirstSave) {
      _isFirstSave = false;
    } else {
      widget.showToast(AppStrings.of(context).get('save'));
    }
  }

  void _exportSheetOptions() {
    _saveFicha(); // Garante que tudo tá salvo antes de exportar
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Theme.of(context).cardColor,
        title: const Text('Exportar Ficha', style: TextStyle(color: Colors.white)),
        content: const Text('Como deseja compartilhar sua ficha?', style: TextStyle(color: Colors.white70)),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              _exportSheetAsText();
            },
            child: const Text('Texto Legível', style: TextStyle(color: Colors.amber)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.blueAccent),
            onPressed: () {
              Navigator.pop(ctx);
              _exportSheetAsJson();
            },
            child: const Text('Código (App)', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _exportSheetAsJson() {
    final sheet = _buildCurrentSheet();
    String jsonString = jsonEncode(sheet.toJson());
    Share.share(jsonString, subject: 'Ficha [Código]: ${sheet.name}');
    Clipboard.setData(ClipboardData(text: jsonString));
    widget.showToast("Código da ficha copiado!");
  }

  void _exportSheetAsText() {
    final sheet = _buildCurrentSheet();
    StringBuffer sb = StringBuffer();
    sb.writeln('👤 *NOME:* ${sheet.name}');
    sb.writeln('🎭 *CLASSE:* ${sheet.classe} | *NÍVEL:* ${sheet.level}');
    sb.writeln('---');
    sb.writeln('❤️ *VIDA:* ${sheet.status["Vida"]?["atual"]}/${sheet.status["Vida"]?["total"]}');
    sb.writeln('⚡ *ESFORÇO:* ${sheet.status["Esforço"]?["atual"]}/${sheet.status["Esforço"]?["total"]}');
    sb.writeln('🧠 *SANIDADE:* ${sheet.status["Sanidade"]?["atual"]}/${sheet.status["Sanidade"]?["total"]}');
    sb.writeln('---');
    sb.writeln('📊 *ATRIBUTOS:*');
    sheet.attributes.forEach((key, val) => sb.writeln('  $key: $val'));
    sb.writeln('---');
    sb.writeln('📚 *PERÍCIAS (Ativas):*');
    sheet.pericias.forEach((key, val) {
      if (val != null && val > 0) sb.writeln('  $key: $val');
    });
    
    sb.writeln('---');
    sb.writeln('🎒 *INVENTÁRIO E EQUIPAMENTOS:*');
    if (_inventory.isEmpty) sb.writeln('  (Vazio)');
    for (var item in _inventory) {
      if (item is Weapon) {
        sb.writeln('  ⚔️ *${item.name}* (Arma)');
        sb.writeln('     Dano: ${item.dice.map((d) => "${d.quantity}d${d.sides} ${d.damageType}").join(" + ")} + ${item.modifier}');
        if (item.attackSkill != null && item.attackSkill!.isNotEmpty) sb.writeln('     Perícia: ${item.attackSkill} (+${item.attackBonus})');
        sb.writeln('     Crítico: x${item.multiplier}');
      } else if (item is Armor) {
        sb.writeln('  🛡️ *${item.name}* (Armadura)');
        sb.writeln('     Redução: -${item.reductionValue} | Hits: ${item.maxHits}');
      } else {
        sb.writeln('  📦 *${item.name}*');
      }
      if (item.description.isNotEmpty) sb.writeln('     📝 _${item.description}_');
    }

    if (_abilities.isNotEmpty || _rituals.isNotEmpty) {
      sb.writeln('---');
      sb.writeln('✨ *HABILIDADES E RITUAIS:*');
      for (var a in _abilities) {
        sb.writeln('  🔥 *${a.name}* (${a.abilityType})');
        if (a.costAmount > 0) sb.writeln('     💧 Custo: ${a.costAmount} ${a.costType}');
        if (a.bonusDice.isNotEmpty) sb.writeln('     🎲 Dano/Cura: ${a.bonusDice.map((d) => "${d.quantity}d${d.sides} ${d.damageType}").join(" + ")} + ${a.bonusModifier}');
        if (a.description.isNotEmpty) sb.writeln('     📝 _${a.description}_');
      }
      for (var r in _rituals) {
        sb.writeln('  🔯 *${r.name}* (Ritual)');
        if (r.costAmount > 0) sb.writeln('     💧 Custo: ${r.costAmount} ${r.costType}');
        if (r.bonusDice.isNotEmpty) sb.writeln('     🎲 Dano/Efeito: ${r.bonusDice.map((d) => "${d.quantity}d${d.sides} ${d.damageType}").join(" + ")} + ${r.bonusModifier}');
        if (r.description.isNotEmpty) sb.writeln('     📝 _${r.description}_');
      }
    }

    if (_passives.isNotEmpty) {
      sb.writeln('---');
      sb.writeln('🌀 *PASSIVAS:*');
      for (var p in _passives) {
        sb.writeln('  ⚙️ *${p.name}*');
        sb.writeln('     Gatilho: ${p.triggerType} | Acúmulo Máx: ${p.maxStacks}');
        for (var e in p.effects) {
          sb.writeln('     🔹 Efeito: ${e.targets.join(", ")} -> ${e.value > 0 ? "+" : ""}${e.value} (${e.bonusType})');
        }
        if (p.description.isNotEmpty) sb.writeln('     📝 _${p.description}_');
      }
    }
    
    String text = sb.toString();
    Share.share(text, subject: 'Ficha RPG: ${sheet.name}');
    Clipboard.setData(ClipboardData(text: text));
    widget.showToast("Texto da ficha copiado com todos os detalhes!");
  }

  void _exportEntity(dynamic entity) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Theme.of(context).cardColor,
        title: Text('Exportar: ${entity.name}', style: const TextStyle(color: Colors.white)),
        content: const Text('Como deseja exportar?', style: TextStyle(color: Colors.white70)),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              _exportAsText(entity);
            },
            child: const Text('Texto Legível', style: TextStyle(color: Colors.amber)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.blueAccent),
            onPressed: () {
              Navigator.pop(ctx);
              _exportAsJson(entity);
            },
            child: const Text('Código (App)', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _exportAsJson(dynamic entity) {
    String jsonString = jsonEncode(entity.toJson());
    Share.share(jsonString, subject: 'Código: ${entity.name}');
    Clipboard.setData(ClipboardData(text: jsonString));
    widget.showToast("Código (JSON) copiado!");
  }

  void _exportAsText(dynamic entity) {
    StringBuffer sb = StringBuffer();
    sb.writeln('📜 *${entity.name.toUpperCase()}* 📜');
    
    if (entity.description != null && entity.description.toString().isNotEmpty) {
      sb.writeln('📝 _${entity.description}_');
    }
    sb.writeln('---');

    if (entity is Weapon) {
      sb.writeln('⚔️ *Tipo:* Arma');
      sb.writeln('🎲 *Dano:* ${entity.dice.map((d) => "${d.quantity}d${d.sides} ${d.damageType}").join(" + ")} + ${entity.modifier}');
      if (entity.attackSkill != null && entity.attackSkill!.isNotEmpty) sb.writeln('🎯 *Perícia:* ${entity.attackSkill} (+${entity.attackBonus})');
      sb.writeln('💥 *Crítico:* x${entity.multiplier}');
    } else if (entity is Armor) {
      sb.writeln('🛡️ *Tipo:* Armadura');
      sb.writeln('🧱 *Redução:* -${entity.reductionValue}');
      sb.writeln('❤️ *Durabilidade:* ${entity.maxHits} Hits');
    } else if (entity is Ability) {
      String type = _rituals.any((r) => r.id == entity.id) ? 'Ritual' : 'Habilidade';
      sb.writeln('✨ *Tipo:* $type (${entity.abilityType})');
      if (entity.costAmount > 0) sb.writeln('💧 *Custo:* ${entity.costAmount} ${entity.costType}');
      if (entity.cooldown > 0) sb.writeln('⏳ *Recarga:* ${entity.cooldown} turnos');
      if (entity.bonusDice.isNotEmpty) sb.writeln('🎲 *Dados:* ${entity.bonusDice.map((d) => "${d.quantity}d${d.sides} ${d.damageType}").join(" + ")} + ${entity.bonusModifier}');
    } else if (entity is Passive) {
      sb.writeln('🌀 *Tipo:* Passiva');
      sb.writeln('⚙️ *Gatilho:* ${entity.triggerType} ${entity.triggerValue > 0 ? "(${entity.triggerValue})" : ""}');
      if (entity.maxStacks > 1) sb.writeln('🔄 *Acúmulo Máximo:* ${entity.maxStacks}');
      for (var e in entity.effects) {
        sb.writeln('🔹 *Efeito:* ${e.targets.join(", ")} -> ${e.value > 0 ? "+" : ""}${e.value} (${e.bonusType})');
      }
    } else if (entity is Item) {
      sb.writeln('🎒 *Tipo:* Item comum');
    }
    
    String text = sb.toString();
    Share.share(text, subject: 'RPG: ${entity.name}');
    Clipboard.setData(ClipboardData(text: text));
    widget.showToast("Texto copiado e menu aberto!");
  }

  void _importEntity(EntityType type) {
    final TextEditingController pasteController = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Theme.of(context).cardColor,
        title: const Text('Importar Código', style: TextStyle(color: Colors.white)),
        content: TextField(
          controller: pasteController,
          maxLines: 5,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            hintText: 'Cole o JSON aqui...',
            filled: true,
            fillColor: Colors.black26,
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar', style: TextStyle(color: Colors.grey))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.blueAccent),
            onPressed: () {
              try {
                final jsonMap = jsonDecode(pasteController.text);
                setState(() {
                  if (type == EntityType.weapon) {
                    _inventory.add(Weapon.fromJson(jsonMap));
                  } else if (type == EntityType.armor) _inventory.add(Armor.fromJson(jsonMap));
                  else if (type == EntityType.item) _inventory.add(Item.fromJson(jsonMap));
                  else if (type == EntityType.ability) _abilities.add(Ability.fromJson(jsonMap));
                  else if (type == EntityType.ritual) _rituals.add(Ability.fromJson(jsonMap));
                  else if (type == EntityType.passive) _passives.add(Passive.fromJson(jsonMap));
                  _onFieldChanged();
                });
                widget.showToast("Importado com sucesso!");
                Navigator.pop(ctx);
              } catch (e) {
                widget.showToast("Erro ao importar. Verifique o código.");
              }
            },
            child: const Text('Importar', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  RollResult _performRoll(
      {required String name,
      required List<DieSpecification> dice,
      int modifier = 0,
      double multiplier = 1.0,
      String extraDescription = '',
      int? defenseTarget,
      List<ConditionalEffect> triggers = const [],
      List<BonusSource> bonusSources = const []}) {
    return widget.onDiceRolledFromSheet(name, dice,
        modifier: modifier,
        multiplier: multiplier,
        extraDescription: extraDescription,
        defenseTarget: defenseTarget,
        triggers: triggers,
        bonusSources: bonusSources);
  }

  List<DieSpecification> _getDiceFromPoints(int points, {bool isAttribute = false}) {
    if (points <= 0) {
      return isAttribute ? [] : [DieSpecification(quantity: 1, sides: 20)];
    }
    
    int d20Count = 0; 
    
    if (!isAttribute) {
      d20Count = 1; 
    }
    
    d20Count += points ~/ 10;
    int remainder = points % 10;
    int d10Count = remainder ~/ 5;
    
    final dice = <DieSpecification>[];
    if (d20Count > 0) {
      dice.add(DieSpecification(quantity: d20Count, sides: 20));
    }
    if (d10Count > 0) {
      dice.add(DieSpecification(quantity: d10Count, sides: 10));
    }
    return dice;
  }

  int _getModifierFromPoints(int points) {
    if (points <= 0) {
      return 0;
    }
    int remainder = points % 10;
    return remainder % 5;
  }

  void _rollAttributeOrPericia(String name, String pointsString) {
  final strings = AppStrings.of(context);
  final translatedName = strings.translateTerm(name);
  
  // 1. Pega apenas o valor base (o que está na caixa de texto)
  int basePoints = int.tryParse(pointsString) ?? 0;
  
  // 2. Calcula bônus de itens e passivas (isso o sistema ainda deve somar)
  final bonuses = _getBonusesFor([name]);
  final totalPoints = basePoints + bonuses.bonusPoints;

  // 3. Define os dados e modificadores baseados APENAS nos pontos totais
  final dice = _getDiceFromPoints(totalPoints);
  final modifier = _getModifierFromPoints(totalPoints) + bonuses.modifier;
  
  // 4. Lógica Estética: Identifica o atributo apenas para o texto do Log
  String baseAttrText = "";
  if (_periciasExibidas.contains(name)) {
    // Busca qual atributo o jogador selecionou para essa perícia (ex: FOR, DES...)
    baseAttrText = " [${_getSkillBaseAttribute(name)}]"; 
  }
  
  // 5. Realiza a rolagem
  _performRoll(
    name: "$translatedName$baseAttrText", // O nome no chat será "Atletismo [FOR]"
    dice: dice,
    modifier: modifier,
    multiplier: bonuses.multiplier,
    bonusSources: bonuses.sources,
  );
}

  void _pickEffortColor() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Escolha uma cor'),
          content: SingleChildScrollView(
            child: ColorPicker(
              pickerColor: _effortColor,
              onColorChanged: (color) {
                setState(() => _effortColor = color);
              },
              pickerAreaHeightPercent: 0.8,
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _showPercentageDialog(String statusName) {
    final percentageController = TextEditingController();
    final strings = AppStrings.of(context);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).cardColor,
        title: Text('${strings.get('modify')} $statusName', style: TextStyle(color: Theme.of(context).colorScheme.onSurface)),
        content: _buildTextField(percentageController, "Porcentagem (%)", keyboardType: TextInputType.number),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(), child: Text(strings.get('cancel'))),
          TextButton(
            onPressed: () {
              final percentage = double.tryParse(percentageController.text) ?? 0;
              final total = double.tryParse(_statusControllers[statusName]!['total']!.text) ?? 0;
              if (total > 0) {
                final newValue = (total * (percentage / 100)).round();
                setState(() {
                  _statusControllers[statusName]!['atual']!.text = newValue.toString();
                });
                _onStatusChange(statusName);
              }
              Navigator.of(context).pop();
            },
            child: Text(strings.get('apply')),
          ),
        ],
      ),
    );
  }

  void _rest() {
    setState(() {
      // 1. Restaurar Vida e Esforço completos
      _statusControllers['Vida']!['atual']!.text = _getTotalStatWithBonuses('Vida').toString();
      _statusControllers['Esforço']!['atual']!.text = _getTotalStatWithBonuses('Esforço').toString();
      
      // Zerar esforço temporário
      _statusControllers['Esforço Temporário']!['atual']!.text = '0';
      _statusControllers['Esforço Temporário']!['total']!.text = '0';

      // 2. Zerar habilidades e rituais
      for (var ability in _abilities) {
        ability.usesInCombat = 0;
        ability.isActive = false;
        ability.currentCooldown = 0;
      }
      for (var ritual in _rituals) {
        ritual.usesInCombat = 0;
        ritual.isActive = false;
        ritual.currentCooldown = 0;
      }

      // 3. Zerar Passivas e Acúmulos
      for (var passive in _passives) {
        passive.isActive = false;
        passive.stacks = 0;
        passive.currentCooldown = 0;
        for (var effect in passive.effects) {
          if (effect.grantsArmor != null) {
            effect.grantsArmor!.currentHits = effect.grantsArmor!.maxHits;
          }
        }
      }

      // 4. Limpar Armaduras e Efeitos temporários
      _temporaryArmors.clear();
      _statusEffects.clear();

      // Restaurar hits de armaduras do inventário
      _inventory.whereType<Armor>().forEach((armor) {
        armor.currentHits = armor.maxHits;
      });

      _unaccountedStatusLoss.updateAll((key, value) => 0);
      _unaccountedDamageTaken = 0;
      _onFieldChanged();
    });
    widget.showToast(AppStrings.of(context).get('rest_msg'));
  }

Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.primary)),
    );
  }

  Widget _buildSectionHeaderWithButton(String title, VoidCallback onPressed) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildSectionHeader(title),
        IconButton(icon: const Icon(Icons.add_circle, color: Colors.white), onPressed: onPressed),
      ],
    );
  }

  Widget _buildSectionHeaderWithImport(String title, VoidCallback onAdd, VoidCallback onImport) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildSectionHeader(title),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(icon: const Icon(Icons.download, color: Colors.grey), onPressed: onImport, tooltip: "Importar"),
            IconButton(icon: const Icon(Icons.add_circle, color: Colors.white), onPressed: onAdd),
          ],
        )
      ],
    );
  }

  Widget _buildArmorSection() {
    final equippedArmors = _getEquippedArmors();
    final List<Armor> passiveArmors = [];
    _passives.where((p) => p.isActive || p.triggerType == 'Sempre Ativo').forEach((p) {
      for (var effect in p.effects) {
        if (effect.grantsArmor != null) passiveArmors.add(effect.grantsArmor!);
      }
    });

    final allArmors = [...equippedArmors, ..._temporaryArmors, ...passiveArmors];
    final strings = AppStrings.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildSectionHeader(strings.get('total_armor')), 
          ],
        ),
        if (allArmors.isEmpty)
          const Center(child: Text("Nenhuma armadura.", style: TextStyle(color: Colors.grey)))
        else
          ...allArmors.map((armor) {
            String subtitle;
            Color cardColor;
            
            String hitsInfo = armor.maxHits > 0 
                ? "Hits: ${armor.currentHits}/${armor.maxHits} | Redução: -${armor.reductionValue}" 
                : "Redução: -${armor.reductionValue}";

            if (_temporaryArmors.contains(armor)) {
              subtitle = 'Temp | $hitsInfo';
              cardColor = Colors.green[900]!.withAlpha(150);
            } else if (passiveArmors.contains(armor)) {
              subtitle = 'Passiva | $hitsInfo';
              cardColor = Colors.purple[900]!.withAlpha(150);
            } else {
              subtitle = 'Equipada | $hitsInfo';
              cardColor = Colors.blue[900]!.withAlpha(150);
            }

            return Card(
              color: cardColor,
              child: ListTile(
                leading: const Icon(Icons.shield, color: Colors.white),
                title: Text(armor.name, style: const TextStyle(color: Colors.white)),
                subtitle: Text(subtitle, style: const TextStyle(color: Colors.white70)),
              ),
            );
          }),
      ],
    );
  }

  Widget _buildBlockSection() {
    final strings = AppStrings.of(context);
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(strings.get('block')),
        Row(
          children: [
            Expanded(child: _buildTextField(_blockConController, "CON %", keyboardType: TextInputType.number)),
            const SizedBox(width: 8),
            Expanded(child: _buildTextField(_blockForController, "FOR %", keyboardType: TextInputType.number)),
            const SizedBox(width: 8),
            Expanded(child: _buildTextField(_blockSabController, "SAB %", keyboardType: TextInputType.number)),
            IconButton(
              icon: Icon(Icons.casino, size: 28, color: theme.iconTheme.color),
              onPressed: _showBlockDamageDialog,
              color: Colors.white,
            )
          ],
        )
      ],
    );
  }

// --- SISTEMA DE LIGAÇÃO: ATRIBUTOS & PERÍCIAS ---
  final Map<String, String> _customSkillBases = {};

  String _getSkillBaseAttribute(String skillName) {
    if (_customSkillBases.containsKey(skillName)) return _customSkillBases[skillName]!;
    
    switch (skillName) {
      case 'Atletismo': case 'Artes-marciais': return 'FOR';
      case 'Acrobacia': case 'Direção': case 'Esgrima': case 'Furtividade': case 'Iniciativa': case 'Ladinagem': case 'Pilotagem': case 'Poder de fogo': case 'Pontaria': case 'Reflexo': return 'DES';
      case 'Atualidades': case 'Eclético': case 'Guerra': case 'Investigação': case 'Memoria': case 'Mente': case 'Primeiros socorros': case 'Tatico': case 'Tecnologia': return 'INT';
      case 'Adestramento': case 'Antiguidade': case 'Conhecimento ParaNormal': case 'Intuição': case 'Montaria': case 'Oculto': case 'Percepção': case 'Presença': case 'Sobrevivencia': case 'Vontade': return 'SAB';
      case 'Atuação': case 'Diplomacia': case 'Enganação': case 'Intimidação': case 'Sorte': return 'CAR';
      default: return 'DES'; // Padrão de segurança
    }
  }

  // Dicionário com a Lore oficial de todas as perícias
  final Map<String, String> _skillDescriptions = {
    'Atletismo': 'Proezas físicas brutas. Usado para escalar superfícies difíceis, nadar contra a correnteza, correr maratonas, saltar buracos ou quebrar coisas na força.',
    'Artes-marciais': 'Combate desarmado. Pode ser focado na brutalidade esmagadora (FOR) ou com técnica e precisão em pontos vitais (DES).',
    'Acrobacia': 'Reflexos corporais e equilíbrio. Usado para aterrissagens graciosas, andar em cordas bambas ou escapar de amarras e agarrões.',
    'Direção': 'Controle de veículos terrestres civis (carros, motos) em situações de perigo, perseguições ou terrenos acidentados.',
    'Esgrima': 'Combate com armas brancas. Pode ser focado na velocidade e precisão dos cortes (DES) ou no impacto devastador dos golpes (FOR).',
    'Furtividade': 'A arte de não ser notado fisicamente. Mover-se em silêncio, esconder-se nas sombras e passar despercebido.',
    'Iniciativa': 'Tempo de reação pura. Determina sua velocidade mental e física para agir primeiro quando um combate estoura.',
    'Ladinagem': 'Mãos leves. Usado para abrir trancas, desarmar armadilhas mecânicas, prestidigitação e furtar bolsos.',
    'Pilotagem': 'Operação de veículos complexos e não convencionais, como barcos, helicópteros, aviões ou mechas de combate.',
    'Poder de fogo': 'Controle de armamento bélico pesado, como metralhadoras giratórias, lança-foguetes, explosivos em área e artilharia.',
    'Pontaria': 'Precisão pura. Usado para atirar com armas de fogo leves, bestas e arcos, ou arremessar facas exatamente onde você quer.',
    'Reflexo': 'Seu instinto de sobrevivência. Usado para desviar de explosões, armadilhas repentinas e efeitos em área.',
    'Atualidades': 'Conhecimento do mundo moderno. Notícias recentes, cultura pop, figuras públicas, política e eventos mundiais.',
    'Eclético': 'Conhecimentos gerais e curiosidades aleatórias. Aquele fato obscuro que você leu numa revista e que pode salvar a missão.',
    'Guerra': 'Tática em larga escala. Conhecimento sobre história militar, reconhecimento de armamento, logística e estratégias de exércitos.',
    'Investigação': 'Busca ativa. Usado para analisar cenas de crime, procurar compartimentos secretos e deduzir informações a partir de pistas visíveis.',
    'Memoria': 'Sua capacidade mental de retenção. Usado para decorar rapidamente documentos, lembrar de um rosto ou de uma senha vista de relance.',
    'Mente': 'O foco da sua razão. Resistência intelectual contra confusão, ilusões lógicas e capacidade de manter a calma sob pressão extrema.',
    'Primeiros socorros': 'Conhecimento médico de campo. Usado para estancar sangramentos, estabilizar aliados caídos e tratar ferimentos rápidos.',
    'Tatico': 'Leitura de combate. Avaliar o campo de batalha, posicionar aliados, encontrar pontos cegos e prever os movimentos do inimigo.',
    'Tecnologia': 'Maestria digital. Hackear sistemas, operar computadores criptografados, rastrear sinais e consertar ou sabotar eletrônicos.',
    'Adestramento': 'A empatia com a natureza. Usado para acalmar, treinar e comandar animais, ou entender o comportamento de bestas.',
    'Antiguidade': 'Conhecimento sobre civilizações mortas, ruínas, idiomas mortos, relíquias arqueológicas e rituais há muito esquecidos.',
    'Conhecimento ParaNormal': 'A prática e teoria do sobrenatural. Usado para identificar monstros, manipular rituais, canalizar energias e interagir com o tecido ocultista.',
    'Intuição': 'O "sexto sentido". Perceber mentiras, notar que alguém tem segundas intenções ou pressentir que algo está errado.',
    'Montaria': 'Capacidade de cavalgar e controlar animais de montaria em meio ao caos do combate e em viagens.',
    'Oculto': 'A arte da camuflagem mística. Usado exclusivamente para ocultar e esconder a própria aura de detecções sobrenaturais.',
    'Percepção': 'Sentidos aguçados. Usado para notar coisas escondidas passivamente, ouvir passos distantes ou ver através de neblina.',
    'Presença': 'A densidade do seu espírito. Usado para reconhecer e detectar auras, além de medir (ou resistir) à pressão espiritual de entidades colossais.',
    'Sobrevivencia': 'O instinto selvagem. Rastrear pegadas, caçar, encontrar água limpa, orientar-se pelas estrelas e não morrer nos ermos.',
    'Vontade': 'O escudo da sua alma. Resistência bruta contra controle mental, possessões espirituais, medo mágico e corrupção da sanidade.',
    'Atuação': 'A arte do disfarce e da performance. Usado para fingir ser outra pessoa, forçar emoções e criar distrações dramáticas.',
    'Diplomacia': 'Etiqueta e argumentação. Usado para convencer pacificamente, fazer aliados, negociar recompensas e apaziguar conflitos.',
    'Enganação': 'A mentira convincente. Usado para blefar, falsificar informações verbais e jogar com a ingenuidade ou ganância alheia.',
    'Intimidação': 'Coerção e terror. Pode ser baseada na brutalidade (FOR), na pressão da sua aura espiritual (SAB) ou na ameaça verbal calculada (CAR).',
    'Sorte': 'A intervenção do destino. Quando a lógica, o treinamento e a força falham, a sua conexão inexplicável com o universo inclina a balança.',
  };

  void _showSkillDetailsDialog(String skillName) {
    String currentBase = _getSkillBaseAttribute(skillName);
    
    List<String> allowedBases = [currentBase];
    if (skillName == 'Artes-marciais' || skillName == 'Esgrima') allowedBases = ['FOR', 'DES'];
    if (skillName == 'Intimidação') allowedBases = ['CAR', 'FOR', 'SAB'];

    // Busca a descrição no dicionário (ou usa uma genérica se não encontrar)
    String lore = _skillDescriptions[skillName] ?? "Uma habilidade fundamental do seu personagem.";

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) {
          return Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(color: Colors.grey[900], borderRadius: const BorderRadius.vertical(top: Radius.circular(20)), border: Border.all(color: Colors.white24)),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(skillName, style: const TextStyle(color: Colors.amber, fontSize: 24, fontWeight: FontWeight.bold)),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.redAccent),
                      tooltip: "Esquecer Perícia",
                      onPressed: () {
                        Navigator.pop(ctx);
                        _removePericia(skillName);
                      },
                    )
                  ],
                ),
                const Divider(color: Colors.white24),
                Text(lore, style: const TextStyle(color: Colors.white70, fontSize: 14, fontStyle: FontStyle.italic, height: 1.4)),
                const SizedBox(height: 20),
                if (allowedBases.length > 1) ...[
                  const Text("Atributo Base:", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    initialValue: currentBase,
                    dropdownColor: Colors.grey[850],
                    items: allowedBases.map((b) => DropdownMenuItem(value: b, child: Text(b, style: const TextStyle(color: Colors.white)))).toList(),
                    onChanged: (newBase) {
                      setModalState(() => currentBase = newBase!);
                      setState(() => _customSkillBases[skillName] = newBase!);
                      widget.showToast("Base de $skillName alterada para $newBase!");
                    },
                    decoration: const InputDecoration(filled: true, fillColor: Colors.black26),
                  ),
                ] else ...[
                  Text("Atributo Base Fixo: $currentBase", style: const TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.bold)),
                ],
                const SizedBox(height: 20),
              ],
            ),
          );
        }
      )
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final strings = AppStrings.of(context);

    return PopScope(
      canPop: true,
      onPopInvoked: (bool didPop) {
        if (didPop) {
          _saveFicha();
        }
      },
      child: SafeArea(
        child: DefaultTabController(
          length: 8,
          child: Scaffold(
            backgroundColor: theme.scaffoldBackgroundColor,
            appBar: AppBar(
              backgroundColor: theme.appBarTheme.backgroundColor,
              iconTheme: theme.iconTheme,
              title: Text(
                widget.initialSheet == null ? strings.get('new_sheet') : _nameController.text,
                style: theme.appBarTheme.titleTextStyle,
              ),
              actions: [
                // NOVO BOTÃO DE EXPORTAR A FICHA AQUI:
                IconButton(
                  icon: const Icon(Icons.share),
                  onPressed: _exportSheetOptions,
                  tooltip: 'Exportar Ficha Completa',
                ),
                // Botão de layout antigo mantido:
                IconButton(
                  icon: Icon(_isClassicLayout ? Icons.tab : Icons.view_list),
                  onPressed: () {
                    setState(() {
                      _isClassicLayout = !_isClassicLayout;
                    });
                  },
                  tooltip: 'Mudar Layout',
                ),
              ],
              bottom: _isClassicLayout
                  ? null
                  : TabBar(
                      isScrollable: true,
                      labelColor: theme.colorScheme.primary,
                      unselectedLabelColor: theme.unselectedWidgetColor,
                      indicatorColor: theme.colorScheme.secondary,
                      tabs: [
                        Tab(text: strings.get('general'), icon: const Icon(Icons.face)),
                        Tab(text: strings.get('skills'), icon: const Icon(Icons.psychology)),
                        Tab(text: strings.get('combat'), icon: const Icon(Icons.shield)),
                        Tab(text: strings.get('abilities'), icon: const Icon(Icons.whatshot)),
                        const Tab(text: 'Rituais', icon: Icon(Icons.star)), 
                        Tab(text: strings.get('passives'), icon: const Icon(Icons.auto_awesome)),
                        Tab(text: strings.get('backpack'), icon: const Icon(Icons.backpack)),
                        Tab(text: strings.get('effects'), icon: const Icon(Icons.swap_vert)),
                      ],
                    ),
            ),
            body: _isClassicLayout ? _buildClassicLayout() : _buildTabLayout(),
          ),
        ),
      ),
    );
  }

  Widget _buildTabLayout() {
    return TabBarView(
      children: [
        _buildGeneralTab(),
        _buildPericiasTab(),
        _buildCombatTab(),
        _buildAbilitiesTab(),
        _buildRitualsTab(), 
        _buildPassivesTab(),
        _buildEquipmentTab(),
        _buildBuffsTab(),
      ],
    );
  }

void _showAttributeDescriptions() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.85,
          decoration: BoxDecoration(
            color: Colors.grey[900],
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            border: Border.all(color: Colors.white24),
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: Colors.white24))),
                child: const Center(
                  child: Text("ESCALA DE PODER DOS ATRIBUTOS", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
                ),
              ),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    _buildLoreSection("💪 Força (For)", Colors.red, [
                      "0 – 10 (Normal): Um humano comum até um halterofilista. Consegue erguer o próprio peso.",
                      "11 – 30 (Exímio): Sobre-humano. Pode erguer carros populares e arremessar pessoas.",
                      "31 – 50 (Incomum): Arremessa motocicletas e segura animais de grande porte no braço.",
                      "51 – 99 (Lendário): Golpes racham concreto. Para um caminhão em movimento com o ombro.",
                      "100 – 249 (Mítico): Destruidor de Rochas. Parte pedras gigantes. Arremessa árvores.",
                      "250 – 349 (Semi-Deus): Demolidor. Derruba prédios com socos. Cria tremores no chão.",
                      "350 – 499 (Fenomenal): Força Geológica. Produz diamantes apertando carvão. Corta o ar.",
                      "500 (Divino): Partidor de Montanhas. Parte cordilheiras. Limite absoluto da matéria.",
                      "501+: Incompreensível. Você não é desta Era."
                    ]),
                    _buildLoreSection("🛡️ Constituição (Con)", Colors.white, [
                      "0 – 10 (Normal): Pessoa comum até alguém que aguenta pancadas em brigas de rua.",
                      "11 – 30 (Exímio): Corpo Calejado. Ignora dores. Corre por horas, resiste a infecções.",
                      "31 – 50 (Incomum): Ossos densos. Sobrevive a quedas altas e tiros de baixo calibre.",
                      "51 – 99 (Lendário): Vigor de Titã. Luta por dias. Pele dura como couro; cega lâminas.",
                      "100 – 249 (Mítico): Sobrevive a explosões. Sistema imunológico perfeito.",
                      "250 – 349 (Semi-Deus): Resiliência Absoluta. Resiste a tiros de tanque. Fôlego infinito.",
                      "350 – 499 (Fenomenal): Resiste a veneno letal para baleias. Luta com ferimentos massivos.",
                      "500 (Divino): Invulnerável. Mergulha no núcleo de vulcões sem romper um vaso sanguíneo.",
                      "501+: Incompreensível. Você não é desta Era."
                    ]),
                    _buildLoreSection("🏃 Destreza (Des)", Colors.green, [
                      "0 – 50: Humano comum a alguém que desvia de balas à queima-roupa e corre em paredes.",
                      "100 – 249 (Mítico): Velocidade dos Ventos. Corta flechas no ar. Atravessa campos em segundos.",
                      "250 – 349 (Semi-Deus): Nível Subsônico. Cria ondas de choque. Reflexos em câmera lenta.",
                      "350 – 499 (Fenomenal): Velocidade do Som. Cruza continentes. O som chega após o golpe.",
                      "500 (Divino): Rastro Catastrófico. Colapsa prédios apenas com o deslocamento de ar.",
                      "501+: Incompreensível."
                    ]),
                    _buildLoreSection("🧠 Inteligência (Int)", Colors.blueAccent, [
                      "0 – 50: Alfabetizado a gênio capaz de hackear nações e curar epidemias.",
                      "100 – 249 (Mítico): Decifra enigmas impossíveis e cria IAs autoconscientes.",
                      "250 – 349 (Semi-Deus): Tecnologia nível Stark/Wakanda. Física quântica como aritmética.",
                      "350 – 499 (Fenomenal): Terraformação planetária e cura para o envelhecimento celular.",
                      "500 (Divino): Conhecimento da Origem. Pode criar novos mundos habitáveis.",
                      "501+: Incompreensível."
                    ]),
                    _buildLoreSection("🦉 Sabedoria (Sab)", Colors.amber, [
                      "0 – 50: Senso comum a estrategista perfeito que nunca é pego de surpresa.",
                      "100 – 249 (Mítico): Intuição clarividente. Nunca se perde em labirintos míticos.",
                      "250 – 349 (Semi-Deus): Detecta mentiras de deuses. Ouve o 'som' do perigo a quilômetros.",
                      "350 – 499 (Fenomenal): O Enganador. Manipula entidades. Conhece magia ancestral.",
                      "500 (Divino): Onisciência Terrena. Conhece o destino. Molde a história e causa-efeito.",
                      "501+: Incompreensível."
                    ]),
                    _buildLoreSection("🎭 Carisma (Car)", Colors.orange, [
                      "0 – 50: Sociável a líder que altera ideologias de multidões com um discurso.",
                      "100 – 249 (Mítico): Entrada altera o clima. Pessoas se curvam. Gera religiões.",
                      "250 – 349 (Semi-Deus): Vontade é lei. Monstros obedecem por puro instinto.",
                      "350 – 499 (Fenomenal): A realidade estremece para obedecer a voz. Beleza/Terror puro.",
                      "500 (Divino): Aura Letal/Santificada. Presença mata ou purifica. Eixo da realidade.",
                      "501+: Incompreensível."
                    ]),
                  ],
                ),
              ),
            ],
          ),
        );
      }
    );
  }

  Widget _buildLoreSection(String title, Color color, List<String> descriptions) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: TextStyle(color: color, fontSize: 20, fontWeight: FontWeight.bold)),
          const Divider(color: Colors.white24),
          ...descriptions.map((desc) => Padding(
            padding: const EdgeInsets.only(bottom: 8.0, top: 4.0),
            child: Text("• $desc", style: const TextStyle(color: Colors.white70, height: 1.4, fontSize: 13)),
          )),
        ],
      ),
    );
  }

  Widget _buildClassicLayout() {
    final strings = AppStrings.of(context);
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          _buildGeneralTabContent(),
          const SizedBox(height: 16),
          _buildCollapsibleSection(strings.get('skills'), _buildPericiasTab(isCollapsible: true)),
          const SizedBox(height: 16),
          _buildCollapsibleSection(strings.get('combat'), _buildCombatTab(isCollapsible: true)),
          const SizedBox(height: 16),
          _buildCollapsibleSection(strings.get('abilities'), _buildAbilitiesTab(isCollapsible: true)),
          const SizedBox(height: 16),
          _buildCollapsibleSection('Rituais', _buildRitualsTab(isCollapsible: true)), 
          const SizedBox(height: 16),
          _buildCollapsibleSection(strings.get('passives'), _buildPassivesTab(isCollapsible: true)),
          const SizedBox(height: 16),
          _buildCollapsibleSection(strings.get('backpack'), _buildEquipmentTab(isCollapsible: true)),
          const SizedBox(height: 16),
          _buildCollapsibleSection(strings.get('effects'), _buildBuffsTab(isCollapsible: true)),
        ],
      ),
    );
  }

  Widget _buildCollapsibleSection(String title, Widget content) {
    final theme = Theme.of(context);
    return ExpansionTile(
      title: Text(title, style: theme.textTheme.titleLarge),
      iconColor: theme.colorScheme.secondary,
      collapsedIconColor: theme.unselectedWidgetColor,
      children: [content],
    );
  }

  Widget _buildGeneralTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: _buildGeneralTabContent(),
    );
  }

void _showCreateElementDialog() async {
    final nameCtrl = TextEditingController();
    final descCtrl = TextEditingController(); 
    
    await ElementalSystem.loadCustomElements();
    List<String> allPossible = ElementalSystem.allElements;
    
    List<String> strong = [];
    List<String> weak = [];

    if (!mounted) return;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          backgroundColor: Colors.grey[900],
          title: const Text("Criar Novo Elemento", style: TextStyle(color: Colors.purpleAccent)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: "Nome (Ex: Vácuo)", labelStyle: TextStyle(color: Colors.white54)), style: const TextStyle(color: Colors.white)),
                const SizedBox(height: 8),
                TextField(controller: descCtrl, decoration: const InputDecoration(labelText: "Lógica Narrativa", labelStyle: TextStyle(color: Colors.white54)), style: const TextStyle(color: Colors.white)),
                const SizedBox(height: 16),
                const Text("Vantagem contra:", style: TextStyle(color: Colors.greenAccent, fontSize: 12, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Wrap(spacing: 4, children: allPossible.map((e) => FilterChip(
                  label: Text(e, style: const TextStyle(fontSize: 10)),
                  selected: strong.contains(e),
                  onSelected: (val) => setDialogState(() => val ? strong.add(e) : strong.remove(e)),
                  selectedColor: Colors.green.withOpacity(0.3),
                )).toList()),
                const Divider(color: Colors.white24, height: 24),
                const Text("Desvantagem contra:", style: TextStyle(color: Colors.redAccent, fontSize: 12, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Wrap(spacing: 4, children: allPossible.map((e) => FilterChip(
                  label: Text(e, style: const TextStyle(fontSize: 10)),
                  selected: weak.contains(e),
                  onSelected: (val) => setDialogState(() => val ? weak.add(e) : weak.remove(e)),
                  selectedColor: Colors.red.withOpacity(0.3),
                )).toList()),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancelar", style: TextStyle(color: Colors.grey))),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.purpleAccent),
              onPressed: () async {
                if (nameCtrl.text.isEmpty) return;
                
                await ElementalSystem.saveCustomElement(ElementalInfo(
                  name: nameCtrl.text,
                  tier: 3, 
                  color: Colors.purpleAccent, 
                  advantages: strong,
                  disadvantages: weak,
                  narrativeLogic: descCtrl.text,
                ));
                
                if (mounted) {
                  widget.showToast('Elemento adicionado ao Grimório!');
                  setState((){}); 
                }
                Navigator.pop(ctx);
              },
              child: const Text("Salvar no Grimório", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            )
          ],
        ),
      ),
    );
  }

//interface dos ganhos por nivel
  Widget _buildGeneralTabContent() {
    final strings = AppStrings.of(context);
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                GestureDetector(
                  onTap: _showImageOptions,
                  child: Container(
                    decoration: _isDown ? BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.redAccent.withOpacity(0.8),
                          blurRadius: 20,
                          spreadRadius: 5,
                        )
                      ]
                    ) : null,
                    child: ColorFiltered(
                      colorFilter: _isDown 
                          ? const ColorFilter.mode(Colors.redAccent, BlendMode.modulate) 
                          : const ColorFilter.mode(Colors.transparent, BlendMode.multiply),
                      child: CircleAvatar(
                        radius: 50,
                        backgroundColor: Colors.grey[700],
                        backgroundImage:
                            _imagePath != null && _imagePath!.isNotEmpty && File(_imagePath!).existsSync() ? FileImage(File(_imagePath!)) : null,
                        child: _imagePath == null || _imagePath!.isEmpty || !File(_imagePath!).existsSync()
                            ? const Icon(Icons.person, size: 50, color: Colors.white)
                            : null,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                children: [
                  _buildTextField(_nameController, strings.get('name')),
                  const SizedBox(height: 8),
                  _buildTextField(_classController, strings.get('class')),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        
        // --- BOTÃO DE NÍVEL ELEGANTE (Abre o Pop-up Premium) ---
        _buildSectionHeaderWithButton("Nível e Ganhos", _showGainsPerLevelDialog),
        Row(
          children: [
            IconButton(onPressed: _levelDown, icon: const Icon(Icons.remove, color: Colors.white)),
            Expanded(child: _buildTextField(_levelController, strings.get('level'), keyboardType: TextInputType.number)),
            IconButton(onPressed: _levelUp, icon: const Icon(Icons.add, color: Colors.white)),
          ],
        ),

        const SizedBox(height: 16),
        _buildSectionHeader(strings.get('status')),
        const SizedBox(height: 8),
        ..._statusControllers.entries.map((entry) {
          final label = entry.key;
          if (label == 'Esforço Temporário' && (double.tryParse(_statusControllers['Esforço Temporário']!['total']!.text) ?? 0) <= 0) {
            return const SizedBox.shrink();
          }

          final controllers = entry.value;
          double currentValue = double.tryParse(controllers['atual']!.text) ?? 0;
          double totalValue = (label == 'Loucura') ? 100 : _getTotalStatWithBonuses(label).toDouble();

          Color barColor;
          VoidCallback? onTap;

          switch (label) {
            case 'Vida': barColor = Colors.red; break;
            case 'Esforço': barColor = _effortColor; onTap = _pickEffortColor; break;
            case 'Esforço Temporário': barColor = _effortColor.withAlpha(150); break;
            case 'Sanidade': barColor = Colors.grey; break;
            case 'Loucura': barColor = Colors.black; break;
            default: barColor = Colors.white;
          }

          return Padding(
            padding: const EdgeInsets.only(bottom: 16.0),
            child: Column(
              children: [
                GestureDetector(
                  onTap: onTap,
                  child: StatusBar(
                    label: strings.translateTerm(label),
                    currentValue: currentValue,
                    totalValue: totalValue,
                    barColor: barColor,
                    onPercentageTap: () => _showPercentageDialog(label),
                  ),
                ),
                const SizedBox(height: 8),
                _buildStatusRow(label, controllers),
              ],
            ),
          );
        }),
        const SizedBox(height: 16),
        _buildSectionHeader(strings.get('attributes')),
        
        AttributeRadarChart(
          attributes: {
            for (final e in _attributesControllers.entries) 
              // SOMA O VALOR BASE COM O BÔNUS NO GRÁFICO TAMBÉM
              e.key: (int.tryParse(e.value.text) ?? 0) + _getBonusesFor([e.key]).bonusPoints
          },
          selectedAttribute: _selectedAttributeForTier,
          onTapAttribute: (attr) {
            setState(() {
              if (_selectedAttributeForTier == attr) {
                _selectedAttributeForTier = null;
              } else {
                _selectedAttributeForTier = attr;
              }
            });
          },
          onDoubleTap: _showAttributeDescriptions,
        ),
        
        // Exibe o painel de brilho abaixo do gráfico caso um atributo seja clicado!
        if (_selectedAttributeForTier != null) _buildTierPanel(),
        const SizedBox(height: 16),

        ..._attributesControllers.entries.map((entry) {
           return _buildAttributeRow(entry.key, entry.value);
        }),

        // --- INÍCIO: MOTOR DO SISTEMA ---
        const SizedBox(height: 16),
        const Divider(color: Colors.white24, height: 40),
        const Text('Motor do Sistema', style: TextStyle(color: Colors.amber, fontWeight: FontWeight.bold, fontSize: 18)),
        const Text('Crie danos e fraquezas que afetam todas as fichas e a Mesa Online.', style: TextStyle(color: Colors.grey, fontSize: 12), textAlign: TextAlign.center),
        const SizedBox(height: 12),
        ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.purpleAccent.withOpacity(0.2),
            foregroundColor: Colors.purpleAccent,
            side: const BorderSide(color: Colors.purpleAccent),
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
          ),
          onPressed: _showCreateElementDialog,
          icon: const Icon(Icons.science),
          label: const Text('Criar Novo Elemento', style: TextStyle(fontWeight: FontWeight.bold)),
        ),
        const SizedBox(height: 32),
        // --- FIM: MOTOR DO SISTEMA ---

      ],
    );
  }

  Widget _buildTierPanel() {
    if (_selectedAttributeForTier == null) return const SizedBox.shrink();
    
    int baseValue = int.tryParse(_attributesControllers[_selectedAttributeForTier!]?.text ?? '0') ?? 0;
    int bonusPoints = _getBonusesFor([_selectedAttributeForTier!]).bonusPoints;
    int currentValue = baseValue + bonusPoints;
    
    int currentTier = _getAttributeTier(currentValue);
    
    Color attrColor = const {
      'FOR': Color(0xFFFF1744), 'CON': Color(0xFFEEEEEE), 'DES': Color(0xFF00E676), 
      'INT': Color(0xFF2979FF), 'SAB': Color(0xFFFFD600), 'CAR': Color(0xFFFF9100), 
    }[_selectedAttributeForTier!] ?? Colors.white;

    Widget tierBox(String label, int tierIndex) {
      bool isActive = currentTier == tierIndex;
      return Expanded(
        child: Container(
          // 1. AUMENTAMOS A MARGEM PARA A SOMBRA NÃO SER CORTADA PELO FLUTTER
          margin: const EdgeInsets.all(6), 
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            // Fundo bem mais vivo
            color: isActive ? attrColor.withOpacity(0.5) : Colors.black45,
            borderRadius: BorderRadius.circular(8),
            // Borda branca grossa para dar o efeito de "lâmpada de neon"
            border: Border.all(
              color: isActive ? Colors.white : Colors.white12, 
              width: isActive ? 2.5 : 1.0
            ),
            // 2. SOMBRA SÓLIDA E ESPALHADA (Sem opacity para forçar a renderização na tela)
            boxShadow: isActive ? [
              BoxShadow(color: attrColor, blurRadius: 15, spreadRadius: 4),
            ] : [],
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              color: isActive ? Colors.white : Colors.white30,
              fontSize: isActive ? 11 : 9,
              fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
              // Brilho forte no texto também
              shadows: isActive ? [
                const Shadow(color: Colors.white, blurRadius: 5),
                Shadow(color: attrColor, blurRadius: 15)
              ] : [],
            ),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
      child: Column(
        children: [
          Text(
            "Faixa de Poder: ${_selectedAttributeForTier!} ($currentValue)", 
            style: TextStyle(
              color: attrColor, 
              fontWeight: FontWeight.bold, 
              fontSize: 18, 
              shadows: [Shadow(color: attrColor, blurRadius: 15)]
            )
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              tierBox("0-10\nNormal", 0),
              tierBox("11-49\nExímio", 1),
              tierBox("50-99\nIncomum", 2),
              tierBox("100-249\nMítico", 3),
            ],
          ),
          Row(
            children: [
              tierBox("250-349\nSemi-Deus", 4),
              tierBox("350-499\nFenomenal", 5),
              tierBox("500\nDivino", 6),
              tierBox("501+\nAnomalia", 7),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPericiasTab({bool isCollapsible = false}) {
    final strings = AppStrings.of(context);
    final content = [
      _buildSectionHeaderWithButton(strings.get('skills'), _showPericiasDialog),
      ..._periciasExibidas.map((pericia) => _buildAttributeRow(pericia, _periciasControllers[pericia]!)),
    ];

    if (isCollapsible) {
      return Column(children: content);
    }

    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: content,
    );
  }

  Widget _buildCombatTab({bool isCollapsible = false}) {
    final content = _buildCombatTabContent();
    if (isCollapsible) {
      return content;
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: content,
    );
  }

 Widget _buildCombatTabContent() {
    final equippedWeapons = _inventory.whereType<Weapon>().where((w) => w.isEquipped).toList();
    final maxDiceForParry = _parryDiceLimits[_parryType] ?? 4;
    final strings = AppStrings.of(context);
    final theme = Theme.of(context);

    return Column(
      children: [
        _buildArmorSection(),
        const SizedBox(height: 16),
        _buildSectionHeaderWithImport(strings.get('weapons'), () => _openEntityForm<Weapon>(), () => _importEntity(EntityType.weapon)),
        ...equippedWeapons.map((weapon) => Card(
              color: theme.cardColor,
              child: ListTile(
                title: Text(weapon.name, style: TextStyle(color: theme.textTheme.bodyLarge?.color)),
                subtitle: Text("${weapon.dice.map((d) => '${d.quantity}d${d.sides}').join(' + ')} + ${weapon.modifier}",
                    style: TextStyle(color: theme.textTheme.bodySmall?.color)),
                onTap: () => _useWeapon(weapon),
                trailing: PopupMenuButton<String>(
                  icon: Icon(Icons.more_vert, color: theme.iconTheme.color),
                  onSelected: (value) {
                    if (value == 'edit') {
                      _openEntityForm<Weapon>(entity: weapon);
                    } else if (value == 'use') {
                      _useWeapon(weapon);
                    } else if (value == 'export') {
                      _exportEntity(weapon);
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(value: 'use', child: Text('Usar')),
                    const PopupMenuItem(value: 'edit', child: Text('Editar')),
                    const PopupMenuItem(value: 'export', child: Text('Exportar')),
                  ],
                ),
              ),
            )),
        const SizedBox(height: 16),
        _buildBlockSection(),
        const SizedBox(height: 16),
        _buildSectionHeader(strings.get('parry')),
        Row(
          children: [
            Expanded(
              flex: 2,
              child: DropdownButtonFormField<String>(
                initialValue: _parryType,
                items: ['Comum', 'Avançado', 'Super', 'God']
                    .map((String value) =>
                        DropdownMenuItem<String>(value: value, child: Text(value, style: TextStyle(color: theme.colorScheme.onSurface))))
                    .toList(),
                onChanged: (newValue) {
                  setState(() {
                    _parryType = newValue!;
                    _validateParryDiceCount();
                  });
                },
                decoration:
                    InputDecoration(filled: true, fillColor: theme.scaffoldBackgroundColor, border: OutlineInputBorder(borderRadius: BorderRadius.circular(8))),
                dropdownColor: Colors.grey[800],
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              flex: 1,
              child: _buildTextField(
                _parryDiceCountController,
                strings.get('dice'),
                keyboardType: TextInputType.number,
                helperText: null,
              ),
            ),
            IconButton(
              icon: Icon(Icons.casino, size: 28, color: theme.iconTheme.color), // <--- LINHA ATUALIZADA
              onPressed: _performParryRoll,
              color: Colors.white,
            )
          ],
        ),
        Padding(
           padding: const EdgeInsets.only(right: 48.0), 
           child: Align(
             alignment: Alignment.centerRight,
             child: Text('${strings.get('max')}: $maxDiceForParry', style: const TextStyle(color: Colors.grey, fontSize: 12)),
           ),
        ),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red[900], 
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            icon: const SwordsIcon(size: 28, color: Colors.white), 
            label: const Text("ABRIR MODO CLASH", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
            onPressed: () {
              Navigator.of(context).push(MaterialPageRoute(builder: (context) => const ClashScreen()));
            },
          ),
        ),
        const SizedBox(height: 16),
        _buildSectionHeader(strings.get('actions')),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            ElevatedButton(onPressed: _nextRound, child: Text(strings.get('round_plus'))),
            ElevatedButton(onPressed: _rest, child: Text(strings.get('rest'))),
            ElevatedButton(
                onPressed: _endCombat,
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red[800]),
                child: Text(strings.get('combat_end'))),
          ],
        ),
      ],
    );
  }

  Widget _buildAbilitiesTab({bool isCollapsible = false}) {
    final strings = AppStrings.of(context);
    final theme = Theme.of(context);

    final content = _abilities.isEmpty
        ? Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Text(strings.get('no_abilities'), style: const TextStyle(color: Colors.grey)),
            ),
          )
        : ReorderableListView.builder(
            buildDefaultDragHandles: false,
            shrinkWrap: isCollapsible,
            physics: isCollapsible ? const NeverScrollableScrollPhysics() : null,
            itemCount: _abilities.length,
            onReorder: (oldIndex, newIndex) {
              setState(() {
                if (newIndex > oldIndex) {
                  newIndex -= 1;
                }
                final ability = _abilities.removeAt(oldIndex);
                _abilities.insert(newIndex, ability);
              });
            },
            itemBuilder: (context, index) {
              final ability = _abilities[index];
              final bool canBeActive = ability.abilityType == 'Buff/Transformação';
              return ReorderableDelayedDragStartListener(
                key: ValueKey(ability.id),
                index: index,
                child: Card(
                  color: theme.cardColor,
                  child: ListTile(
                    title: Text(ability.name, style: TextStyle(color: canBeActive && ability.isActive ? Colors.cyanAccent : Colors.white)),
                    subtitle: Text(ability.currentCooldown > 0 ? 'Cooldown: ${ability.currentCooldown}' : ability.description,
                        style: const TextStyle(color: Colors.grey), maxLines: 1, overflow: TextOverflow.ellipsis),
                    onTap: () => _useAbility(ability),
                    trailing: PopupMenuButton<String>(
                      icon: Icon(Icons.more_vert, color: theme.iconTheme.color),
                      onSelected: (value) {
                        if (value == 'edit') {
                          _openEntityForm<Ability>(entity: ability);
                        } else if (value == 'delete') {
                          _deleteAbility(ability);
                        } else if (value == 'use') {
                          _useAbility(ability);
                        } else if (value == 'export') {
                          _exportEntity(ability);
                        }
                      },
                      itemBuilder: (context) => [
                        const PopupMenuItem(value: 'use', child: Text('Usar')),
                        const PopupMenuItem(value: 'edit', child: Text('Editar')),
                        const PopupMenuItem(value: 'delete', child: Text('Excluir')),
                        const PopupMenuItem(value: 'export', child: Text('Exportar')),
                      ],
                    ),
                  ),
                ),
              );
            },
          );

    final listWithHeader = Column(
      children: [
        _buildSectionHeaderWithImport(strings.get('abilities'), () => _openEntityForm<Ability>(), () => _importEntity(EntityType.ability)),
        isCollapsible ? content : Expanded(child: content),
      ],
    );

    if (isCollapsible) {
      return listWithHeader;
    }

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: listWithHeader,
    );
  }

  Widget _buildRitualsTab({bool isCollapsible = false}) {
    final theme = Theme.of(context);

    final content = _rituals.isEmpty
        ? const Center(
            child: Padding(
              padding: EdgeInsets.all(24.0),
              child: Text("Nenhum ritual adicionado.", style: TextStyle(color: Colors.grey)),
            ),
          )
        : ReorderableListView.builder(
            buildDefaultDragHandles: false,
            shrinkWrap: isCollapsible,
            physics: isCollapsible ? const NeverScrollableScrollPhysics() : null,
            itemCount: _rituals.length,
            onReorder: (oldIndex, newIndex) {
              setState(() {
                if (newIndex > oldIndex) {
                  newIndex -= 1;
                }
                final ritual = _rituals.removeAt(oldIndex);
                _rituals.insert(newIndex, ritual);
              });
            },
            itemBuilder: (context, index) {
              final ritual = _rituals[index];
              final bool canBeActive = ritual.abilityType == 'Buff/Transformação';
              return ReorderableDelayedDragStartListener(
                key: ValueKey(ritual.id),
                index: index,
                child: Card(
                  color: theme.cardColor,
                  child: ListTile(
                    title: Text(ritual.name, style: TextStyle(color: canBeActive && ritual.isActive ? Colors.purpleAccent : Colors.white)),
                    subtitle: Text(ritual.currentCooldown > 0 ? 'Cooldown: ${ritual.currentCooldown}' : ritual.description,
                        style: const TextStyle(color: Colors.grey), maxLines: 1, overflow: TextOverflow.ellipsis),
                    onTap: () => _useAbility(ritual),
                    trailing: PopupMenuButton<String>(
                      icon: Icon(Icons.more_vert, color: theme.iconTheme.color),
                      onSelected: (value) {
                        if (value == 'edit') {
                          _openEntityForm<Ability>(entity: ritual, isRitual: true);
                        } else if (value == 'delete') {
                          setState(() => _rituals.removeWhere((r) => r.id == ritual.id));
                        } else if (value == 'use') {
                          _useAbility(ritual);
                        } else if (value == 'export') {
                          _exportEntity(ritual);
                        }
                      },
                      itemBuilder: (context) => [
                        const PopupMenuItem(value: 'use', child: Text('Usar')),
                        const PopupMenuItem(value: 'edit', child: Text('Editar')),
                        const PopupMenuItem(value: 'delete', child: Text('Excluir')),
                        const PopupMenuItem(value: 'export', child: Text('Exportar')),
                      ],
                    ),
                  ),
                ),
              );
            },
          );

    final listWithHeader = Column(
      children: [
        _buildSectionHeaderWithImport('Rituais', () => _showRitualDialog(), () => _importEntity(EntityType.ritual)),
        isCollapsible ? content : Expanded(child: content),
      ],
    );

    if (isCollapsible) {
      return listWithHeader;
    }

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: listWithHeader,
    );
  }

  Widget _buildPassivesTab({bool isCollapsible = false}) {
    final strings = AppStrings.of(context);
    final theme = Theme.of(context);

    final content = _passives.isEmpty
        ? const Center(
            child: Padding(
              padding: EdgeInsets.all(24.0),
              child: Text("Nenhuma passiva adicionada.", style: TextStyle(color: Colors.grey)),
            ),
          )
        : ReorderableListView.builder(
            buildDefaultDragHandles: false,
            shrinkWrap: isCollapsible,
            physics: isCollapsible ? const NeverScrollableScrollPhysics() : null,
            itemCount: _passives.length,
            onReorder: (oldIndex, newIndex) {
              setState(() {
                if (newIndex > oldIndex) {
                  newIndex -= 1;
                }
                final passive = _passives.removeAt(oldIndex);
                _passives.insert(newIndex, passive);
              });
            },
            itemBuilder: (context, index) {
              final passive = _passives[index];
              final bool isStackable = passive.triggerFrequency == 'Acumulável';
              final bool isManualToggle = passive.triggerType == 'Ativável' || passive.triggerType == 'Manual (Apenas Botão)';

              return ReorderableDelayedDragStartListener(
                key: ValueKey(passive.id),
                index: index,
                child: Card(
                  color: theme.cardColor,
                  child: ListTile(
                    contentPadding: const EdgeInsets.only(left: 16, right: 4), // Dá mais espaço pro nome
                    title: Text(passive.name, style: TextStyle(color: (passive.isActive || passive.stacks > 0) ? Colors.cyanAccent : Colors.white)),
                    subtitle: Text(
                      passive.currentCooldown > 0 ? 'Cooldown: ${passive.currentCooldown}' : passive.description,
                      style: const TextStyle(color: Colors.grey),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    onTap: () => _openEntityForm<Passive>(entity: passive),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // CONTROLES DE ACÚMULO (COMPACTOS)
                        if (isStackable) ...[
                          IconButton(
                            icon: const Icon(Icons.remove, color: Colors.redAccent, size: 20),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                            onPressed: () {
                              if (passive.stacks > 0) {
                                setState(() {
                                  passive.stacks--;
                                  // Se zerou os acúmulos, desativa a passiva
                                  if (passive.stacks == 0) passive.isActive = false;
                                  _onFieldChanged();
                                });
                              }
                            },
                          ),
                          Text(
                            '${passive.stacks}/${passive.maxStacks > 90 ? "∞" : passive.maxStacks}', 
                            style: TextStyle(
                              color: passive.stacks > 0 ? Colors.greenAccent : Colors.white54, 
                              fontWeight: FontWeight.bold,
                              fontSize: 14
                            )
                          ),
                          IconButton(
                            icon: const Icon(Icons.add, color: Colors.greenAccent, size: 20),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                            onPressed: () {
                              if (passive.stacks < passive.maxStacks) {
                                setState(() {
                                  passive.stacks++;
                                  // Se ganhou acúmulo, ativa a passiva automaticamente
                                  passive.isActive = true;
                                  _onFieldChanged();
                                });
                              } else {
                                widget.showToast("Limite atingido!");
                              }
                            },
                          ),
                        ] 
                        // SE NÃO FOR ACUMULÁVEL MAS FOR ATIVÁVEL (Mostra um Switch pequeno)
                        else if (isManualToggle) ...[
                          Transform.scale(
                            scale: 0.8, // Deixa o Switch um pouco menor pra não espremer a tela
                            child: Switch(
                              value: passive.isActive,
                              activeThumbColor: Colors.cyanAccent,
                              onChanged: (value) => setState(() { 
                                passive.isActive = value; 
                                passive.stacks = value ? 1 : 0;
                                _onFieldChanged(); 
                              }),
                            ),
                          ),
                        ],
                          
                        // MENU ORIGINAL DE OPÇÕES
                        PopupMenuButton<String>(
                          icon: Icon(Icons.more_vert, color: theme.iconTheme.color),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                          onSelected: (value) {
                            if (value == 'edit') {
                              _openEntityForm<Passive>(entity: passive);
                            } else if (value == 'delete') {
                              _deletePassive(passive);
                            } else if (value == 'export') {
                              _exportEntity(passive);
                            }
                          },
                          itemBuilder: (context) => [
                            const PopupMenuItem(value: 'edit', child: Text('Editar')),
                            const PopupMenuItem(value: 'delete', child: Text('Excluir')),
                            const PopupMenuItem(value: 'export', child: Text('Exportar')),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );

    final listWithHeader = Column(
      children: [
        _buildSectionHeaderWithImport(strings.get('passives'), () => _openEntityForm<Passive>(), () => _importEntity(EntityType.passive)),
        isCollapsible ? content : Expanded(child: content),
      ],
    );

    if (isCollapsible) {
      return listWithHeader;
    }

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: listWithHeader,
    );
  }

  IconData _getDefaultItemIcon(Item item) {
    if (item is Weapon) return Icons.gavel; 
    if (item is Armor) return Icons.shield; 
    return Icons.help_outline;              
  }

  void _showItemDetailsModal(Item item) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return Container(
              decoration: BoxDecoration(
                color: Colors.grey[900],
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              ),
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min, 
                children: [
                  GestureDetector(
                    onTap: () async {
                       final picker = ImagePicker();
                       final pickedFile = await picker.pickImage(source: ImageSource.gallery);
                       if (pickedFile != null) {
                         setState(() {
                           item.imagePath = pickedFile.path;
                           _onFieldChanged(); 
                         });
                         setModalState(() {}); 
                       }
                    },
                    child: Container(
                      width: 100, height: 100,
                      decoration: BoxDecoration(
                        color: Colors.black45,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: item.isEquipped ? Colors.amber : Colors.grey, width: 2),
                        image: item.imagePath != null && File(item.imagePath!).existsSync()
                            ? DecorationImage(image: FileImage(File(item.imagePath!)), fit: BoxFit.cover)
                            : null,
                      ),
                      child: item.imagePath == null || !File(item.imagePath!).existsSync()
                          ? Icon(_getDefaultItemIcon(item), size: 50, color: Colors.white54)
                          : null,
                    ),
                  ),
                  const SizedBox(height: 12),
                  
                  Text(item.name, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
                  if (item is Weapon)
                    Text("Dano: ${item.dice.map((d) => '${d.quantity}d${d.sides}').join('+')} + ${item.modifier}", style: const TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
                  
                  if (item is Armor) ...[
                    Text("Redução Fixa: ${item.reductionValue}", style: const TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          decoration: BoxDecoration(color: Colors.redAccent.withOpacity(0.15), borderRadius: BorderRadius.circular(8)),
                          child: IconButton(
                            icon: const Icon(Icons.remove, color: Colors.redAccent),
                            onPressed: () {
                              if (item.currentHits > 0) {
                                setState(() {
                                  item.currentHits--;
                                  _onFieldChanged();
                                });
                                setModalState(() {});
                              }
                            },
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: Text(
                            "Hits: ${item.currentHits} / ${item.maxHits}", 
                            style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)
                          ),
                        ),
                        Container(
                          decoration: BoxDecoration(color: Colors.greenAccent.withOpacity(0.15), borderRadius: BorderRadius.circular(8)),
                          child: IconButton(
                            icon: const Icon(Icons.add, color: Colors.greenAccent),
                            onPressed: () {
                              if (item.currentHits < item.maxHits) {
                                setState(() {
                                  item.currentHits++;
                                  _onFieldChanged();
                                });
                                setModalState(() {});
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                  
                  Container(
                    constraints: const BoxConstraints(maxHeight: 150),
                    child: SingleChildScrollView(
                      child: Text(item.description.isNotEmpty ? item.description : "Sem descrição.", textAlign: TextAlign.center, style: const TextStyle(color: Colors.white70)),
                    ),
                  ),
                  const SizedBox(height: 20),
                  
                  Wrap(
                    alignment: WrapAlignment.center,
                    spacing: 8, runSpacing: 8,
                    children: [
                      ElevatedButton.icon(
                        onPressed: () {
                          setState(() {
                            item.isEquipped = !item.isEquipped;
                            _onFieldChanged();
                          });
                          setModalState((){});
                        },
                        icon: Icon(item.isEquipped ? Icons.remove_circle : Icons.check_circle),
                        label: Text(item.isEquipped ? "Desequipar" : "Equipar"),
                        style: ElevatedButton.styleFrom(backgroundColor: item.isEquipped ? Colors.grey[700] : Colors.green[700]),
                      ),
                      if (item is Weapon)
                        ElevatedButton.icon(
                          onPressed: () {
                            Navigator.pop(ctx); 
                            _useWeapon(item);   
                          },
                          icon: const Icon(Icons.casino),
                          label: const Text("Atacar"),
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.red[800]),
                        ),
                      ElevatedButton.icon(
                        onPressed: () {
                          Navigator.pop(ctx);
                          if (item is Weapon) {
                            _openEntityForm<Weapon>(entity: item);
                          } else if (item is Armor) _openEntityForm<Armor>(entity: item);
                          else _openEntityForm<Item>(entity: item);
                        },
                        icon: const Icon(Icons.edit),
                        label: const Text("Editar"),
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.blue[800]),
                      ),
                      ElevatedButton.icon(
                        onPressed: () {
                          setState(() {
                            _inventory.remove(item);
                            _onFieldChanged();
                          });
                          Navigator.pop(ctx);
                        },
                        icon: const Icon(Icons.delete),
                        label: const Text("Apagar"),
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.red[900]),
                      ),
                    ],
                  ),
                ],
              ),
            );
          }
        );
      }
    );
  }

  Widget _buildEquipmentTab({bool isCollapsible = false}) {
    final strings = AppStrings.of(context);
    final theme = Theme.of(context);

    final header = Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildSectionHeader(strings.get('backpack')),
        Row(
          children: [
            IconButton(
              icon: const Icon(Icons.download, color: Colors.grey), 
              onPressed: () => _importEntity(EntityType.item), 
              tooltip: "Importar Item"
            ),
            PopupMenuButton<String>(
              icon: Icon(Icons.add_circle, color: theme.colorScheme.primary),
              onSelected: (value) {
                if (value == 'item') _openEntityForm<Item>();
                if (value == 'weapon') _openEntityForm<Weapon>();
                if (value == 'armor') _openEntityForm<Armor>();
              },
              itemBuilder: (context) => [
                const PopupMenuItem(value: 'item', child: Text('Novo Item')),
                const PopupMenuItem(value: 'weapon', child: Text('Nova Arma')),
                const PopupMenuItem(value: 'armor', child: Text('Nova Armadura')),
              ],
            ),
          ],
        )
      ],
    );

    final content = _inventory.isEmpty
        ? Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Text(strings.get('backpack_empty'), style: const TextStyle(color: Colors.grey)),
            ),
          )
        : Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: ReorderableGridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,      
                crossAxisSpacing: 10,   
                mainAxisSpacing: 10,
                childAspectRatio: 0.85, 
              ),
              itemCount: _inventory.length,
              onReorder: (oldIndex, newIndex) {
                setState(() {
                  final item = _inventory.removeAt(oldIndex);
                  _inventory.insert(newIndex, item);
                  _onFieldChanged(); 
                });
              },
              itemBuilder: (context, index) {
                final item = _inventory[index];
                return GestureDetector(
                  key: ValueKey(item.id),
                  onTap: () => _showItemDetailsModal(item),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[850],
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: item.isEquipped ? Colors.amber : Colors.transparent,
                        width: 2
                      ),
                      boxShadow: [
                         if(item.isEquipped) BoxShadow(color: Colors.amber.withOpacity(0.3), blurRadius: 4, spreadRadius: 1)
                      ]
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(
                          child: ClipRRect(
                            borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
                            child: item.imagePath != null && File(item.imagePath!).existsSync()
                                ? Image.file(File(item.imagePath!), fit: BoxFit.cover)
                                : Container(
                                    color: Colors.black45,
                                    child: Icon(_getDefaultItemIcon(item), size: 40, color: Colors.white54),
                                  ),
                          ),
                        ),
                        Container(
                          height: 36,
                          padding: const EdgeInsets.all(4.0),
                          alignment: Alignment.center,
                          child: Text(
                            item.name,
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          );

    final listWithHeader = Column(
      children: [
        header,
        isCollapsible ? SizedBox(height: 300, child: content) : Expanded(child: content),
      ],
    );

    if (isCollapsible) return listWithHeader;
    return Padding(padding: const EdgeInsets.all(16.0), child: listWithHeader);
  }

  List<Armor> _getEquippedArmors() {
    return _inventory.whereType<Armor>().where((item) => item.isEquipped).toList();
  }

  Widget _buildItemIcon(Item item) {
    final theme = Theme.of(context);
    return SizedBox(
      width: 40,
      height: 40,
      child: Stack(
        alignment: Alignment.center,
        children: [
          if (item.imagePath != null && item.imagePath!.isNotEmpty && File(item.imagePath!).existsSync())
            CircleAvatar(
              backgroundImage: FileImage(File(item.imagePath!)),
              radius: 20,
            )
          else
            Icon(
              item is Weapon ? Icons.gavel : (item is Armor ? Icons.shield : Icons.backpack),
              color: theme.iconTheme.color,
            ),
          if (item.isEquipped)
            Positioned(
              bottom: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.all(2),
                decoration: const BoxDecoration(
                  color: Colors.black,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check_circle, color: Colors.greenAccent, size: 14),
              ),
            ),
        ],
      ),
    );
  }

 Widget _buildBuffsTab({bool isCollapsible = false}) {
    final activeEffects = _getActiveEffects();
    final strings = AppStrings.of(context);
    final theme = Theme.of(context);

    final content = Column(
      children: [
        _buildSectionHeaderWithButton(strings.get('effects'), () => _openEntityForm<StatusEffect>()),
        if (activeEffects.isEmpty)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(24.0),
              child: Text("Nenhum efeito ativo.", style: TextStyle(color: Colors.grey)),
            ),
          )
        else
          ...activeEffects.map((effect) => Card(
                color: theme.cardColor,
                shape: RoundedRectangleBorder(
                  side: BorderSide(color: effect.color.withOpacity(0.3), width: 1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: effect.color.withOpacity(0.2),
                    child: Icon(effect.icon, color: effect.color),
                  ),
                  title: Row(
                    children: [
                      Expanded(
                        child: Text(effect.name, style: TextStyle(color: effect.color, fontWeight: FontWeight.bold)),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: effect.color.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: effect.color.withOpacity(0.3)),
                        ),
                        child: Text(
                          effect.category.toUpperCase(),
                          style: TextStyle(color: effect.color, fontSize: 9, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                  subtitle: Text(effect.sourceTypeDescription, style: const TextStyle(color: Colors.grey)),
                  onTap: () => _navigateToEffectSource(effect),
                  trailing: effect.sourceType == 'Manual'
                      ? IconButton(
                          icon: const Icon(Icons.delete, color: Colors.redAccent),
                          tooltip: 'Apagar Efeito Especial',
                          onPressed: () {
                            setState(() {
                              _statusEffects.removeWhere((e) => e.id == effect.sourceId);
                              _onFieldChanged(); 
                            });
                            widget.showToast("Efeito removido.");
                          },
                        )
                      : IconButton(
                          icon: const Icon(Icons.power_settings_new, color: Colors.grey),
                          tooltip: 'Desativar / Desequipar',
                          onPressed: () {
                            setState(() {
                              if (effect.sourceType == 'Ability') {
                                _abilities.firstWhere((a) => a.id == effect.sourceId).isActive = false;
                              } else if (effect.sourceType == 'Ritual') {
                                _rituals.firstWhere((r) => r.id == effect.sourceId).isActive = false;
                              } else if (effect.sourceType == 'Item') {
                                _inventory.firstWhere((i) => i.id == effect.sourceId).isEquipped = false;
                              } else if (effect.sourceType == 'Passive') {
                                final p = _passives.firstWhere((p) => p.id == effect.sourceId);
                                p.isActive = false;
                                p.stacks = 0;
                              }
                              _onFieldChanged();
                            });
                          },
                        ),
                ),
              )),
      ],
    );

    if (isCollapsible) {
      return content;
    }

    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [content],
    );
  }

  List<ActiveEffect> _getActiveEffects() {
    final List<ActiveEffect> effects = [];

    for (var ability in _abilities.where((a) => a.isActive)) {
      effects.add(ActiveEffect(
        id: ability.id, name: ability.name, sourceTypeDescription: 'Habilidade Ativa',
        color: Colors.cyanAccent, sourceId: ability.id, sourceType: 'Ability',
        category: 'Habilidade', icon: Icons.flash_on,
      ));
    }
    
    for (var ritual in _rituals.where((r) => r.isActive)) {
      effects.add(ActiveEffect(
        id: ritual.id, name: ritual.name, sourceTypeDescription: 'Ritual Ativo',
        color: Colors.cyanAccent, sourceId: ritual.id, sourceType: 'Ritual',
        category: 'Habilidade', icon: Icons.star, 
      ));
    }

    for (var item in _inventory.where((i) => i.isEquipped && i.effects.isNotEmpty)) {
      effects.add(ActiveEffect(
        id: item.id, name: item.name, sourceTypeDescription: 'Item Equipado',
        color: Colors.amberAccent, sourceId: item.id, sourceType: 'Item',
        category: 'Item', icon: Icons.shield,
      ));
    }

    for (var passive in _passives.where((p) => p.isActive || p.triggerType == 'Sempre Ativo' || p.stacks > 0)) {
      effects.add(ActiveEffect(
        id: passive.id, name: passive.name,
        sourceTypeDescription: 'Passiva Ativa${passive.stacks > 0 ? ' (x${passive.stacks})' : ''}',
        color: Colors.blueAccent, sourceId: passive.id, sourceType: 'Passive',
        category: 'Passiva', icon: Icons.all_inclusive,
      ));
    }

    for (var effect in _statusEffects) {
      effects.add(ActiveEffect(
        id: effect.id, name: effect.name,
        sourceTypeDescription: 'Duração: ${effect.durationInRounds == -1 ? 'Permanente' : '${effect.durationInRounds} turnos'}',
        color: Colors.purpleAccent, sourceId: effect.id, sourceType: 'Manual',
        category: 'Especial', icon: Icons.auto_awesome,
      ));
    }
    return effects;
  }

  void _navigateToEffectSource(ActiveEffect effect) {
     dynamic entity;
     switch (effect.sourceType) {
      case 'Ability': entity = _abilities.firstWhere((a) => a.id == effect.sourceId); _openEntityForm<Ability>(entity: entity); break;
      case 'Ritual': entity = _rituals.firstWhere((r) => r.id == effect.sourceId); _openEntityForm<Ability>(entity: entity, isRitual: true); break; 
      case 'Item':
         entity = _inventory.firstWhere((i) => i.id == effect.sourceId);
         if (entity is Weapon) {
           _openEntityForm<Weapon>(entity: entity); 
         } else if (entity is Armor) {
           _openEntityForm<Armor>(entity: entity); 
         } else {
           _openEntityForm<Item>(entity: entity);
         }
        break;
      case 'Passive': entity = _passives.firstWhere((p) => p.id == effect.sourceId); _openEntityForm<Passive>(entity: entity); break;
      case 'Manual': entity = _statusEffects.firstWhere((e) => e.id == effect.sourceId); _openEntityForm<StatusEffect>(entity: entity); break;
    }
  }

  Widget _buildTextField(TextEditingController controller, String label, {TextInputType? keyboardType, String? helperText, ValueChanged<String>? onSubmitted, VoidCallback? onTapOutside}) {
    return TextField(
      controller: controller,
      style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
      keyboardType: keyboardType,
      onSubmitted: onSubmitted,
      onTapOutside: (_) {
        FocusManager.instance.primaryFocus?.unfocus();
        onTapOutside?.call();
      },
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7)),
        helperText: helperText,
        helperStyle: const TextStyle(color: Colors.grey),
        filled: true,
        fillColor: Theme.of(context).scaffoldBackgroundColor,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  Future<void> _showAllocationConfirmDialog(String skillName, VoidCallback onConfirm) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Theme.of(context).cardColor,
          title: const Text('Confirmar Evolução', style: TextStyle(color: Colors.white)),
          content: Text(
            'Deseja aumentar "$skillName"?\n\n'
            'ATENÇÃO: Esta ação é definitiva e os pontos NÃO poderão ser removidos depois.',
            style: const TextStyle(color: Colors.redAccent),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancelar'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text('Confirmar', style: TextStyle(color: Colors.white)),
              onPressed: () {
                Navigator.of(context).pop();
                onConfirm(); 
              },
            ),
          ],
        );
      },
    );
  }

  void _addPericiaPoints(String pericia, int points) {
    if (!_periciasExibidas.contains(pericia)) {
      _periciasExibidas.add(pericia);
      _periciasControllers[pericia] = TextEditingController(text: '0');
      _periciasControllers[pericia]!.addListener(_onFieldChanged);
    }
    int current = int.tryParse(_periciasControllers[pericia]!.text) ?? 0;
    _periciasControllers[pericia]!.text = (current + points).toString();
  }

  void _applyMilestone(String stat, int tier) {
    if (stat == "DES") {
      if (tier == 100) {
        _addPericiaPoints("Acrobacia", 10);
        _addPericiaPoints("Atletismo", 10);
        _addPericiaPoints("Reflexo", 10);
      } else if (tier == 150) {
        _addPericiaPoints("Atletismo", 15);
        _addPericiaPoints("Reflexo", 15);
        _addPericiaPoints("Ladinagem", 10);
        _addPericiaPoints("Esgrima", 20);
      } else if (tier == 200) {
        _addPericiaPoints("Acrobacia", 10);
        _addPericiaPoints("Atletismo", 10);
        _addPericiaPoints("Artes-marciais", 10);
        _addPericiaPoints("Reflexo", 10);
        _addPericiaPoints("Furtividade", 10);
        _addPericiaPoints("Ladinagem", 10);
        _addPericiaPoints("Esgrima", 10);
        _addPericiaPoints("Pontaria", 10);
      } else if (tier == 250) {
        _passives.add(Passive(name: "Aceleração Neural", description: "+20% de Chance de Crítico.", triggerType: "Sempre Ativo"));
        _passives.add(Passive(name: "Intocável", description: "+15% de Esquiva/Defesa Final.", triggerType: "Sempre Ativo"));
        _passives.add(Passive(name: "Velocidade", description: "+30% de Deslocamento Base.", triggerType: "Sempre Ativo"));
      }
    } else if (stat == "FOR") {
      if (tier == 100) {
        _addPericiaPoints("Atletismo", 10);
        _addPericiaPoints("Intimidação", 10);
        _addPericiaPoints("Artes-marciais", 10);
      } else if (tier == 150) {
        _addPericiaPoints("Atletismo", 20);
        _addPericiaPoints("Intimidação", 15);
        _addPericiaPoints("Artes-marciais", 20);
        int conValue = int.tryParse(_attributesControllers["CON"]?.text ?? '0') ?? 0;
        if (_attributesControllers.containsKey("CON")) {
          _attributesControllers["CON"]!.text = (conValue + 10).toString();
        }
      } else if (tier == 200) {
        _addPericiaPoints("Acrobacia", 10);
        _addPericiaPoints("Atletismo", 10);
        _addPericiaPoints("Artes-marciais", 10);
        _addPericiaPoints("Reflexo", 10);
        _addPericiaPoints("Esgrima", 10);
      } else if (tier == 250) {
        _passives.add(Passive(name: "Devastação", description: "+25% de Dano Físico Final.", triggerType: "Sempre Ativo"));
        _passives.add(Passive(name: "Rompimento", description: "Ignora 50% da RD do alvo.", triggerType: "Sempre Ativo"));
        _passives.add(Passive(name: "Demolição", description: "Dano Dobrado a estruturas.", triggerType: "Sempre Ativo"));
      }
    } else if (stat == "CON") {
      if (tier == 100) {
        _addPericiaPoints("Sobrevivencia", 10);
        _addPericiaPoints("Vontade", 10);
        _passives.add(Passive(name: "Pele de Ferro", description: "+10% Defesas Físicas.", triggerType: "Sempre Ativo"));
      } else if (tier == 150) {
        _addPericiaPoints("Iniciativa", 20);
        _addPericiaPoints("Vontade", 15);
        _addPericiaPoints("Percepção", 15);
      } else if (tier == 200) {
        _statusControllers['Esforço']!['total']!.text = ((int.tryParse(_statusControllers['Esforço']!['total']!.text) ?? 0) + 400).toString();
        _passives.add(Passive(name: "Mestre Imortal", description: "Redução Física: -20% de Dano Físico recebido.", triggerType: "Sempre Ativo"));
      } else if (tier == 250) {
        _passives.add(Passive(name: "Vitalidade Transcendente", description: "Escudo de 30% da Vida Máxima no combate.", triggerType: "Início do Turno"));
        _passives.add(Passive(name: "Regeneração Eterna", description: "Recupera 5% da Vida Máxima por turno.", triggerType: "Início do Turno"));
        _passives.add(Passive(name: "Imunidade Parcial", description: "+50% de resistência a Venenos e Sangramentos.", triggerType: "Sempre Ativo"));
      }
    } else if (stat == "SAB") {
      if (tier == 100) {
        _addPericiaPoints("Percepção", 10);
        _addPericiaPoints("Intuição", 10);
        _addPericiaPoints("Conhecimento ParaNormal", 15);
      } else if (tier == 150) {
        _addPericiaPoints("Percepção", 20);
        _addPericiaPoints("Intuição", 15);
        _addPericiaPoints("Primeiros socorros", 15);
        _addPericiaPoints("Conhecimento ParaNormal", 20);
      } else if (tier == 200) {
        _addPericiaPoints("Vontade", 10);
        _addPericiaPoints("Percepção", 10);
        _addPericiaPoints("Intuição", 10);
        _addPericiaPoints("Atualidades", 10);
        _addPericiaPoints("Guerra", 20);
        _addPericiaPoints("Tatico", 20);
      } else if (tier == 250) {
        _passives.add(Passive(name: "Eficiência Mística", description: "Custo de PE reduzido em 25%.", triggerType: "Sempre Ativo"));
        _passives.add(Passive(name: "Potência Mental", description: "+20% em Dano de Rituais e Cura.", triggerType: "Sempre Ativo"));
        _passives.add(Passive(name: "Clareza", description: "+15% de acerto contra ilusões.", triggerType: "Sempre Ativo"));
      }
    }
    
    _passives.add(Passive(name: "[Bênção] $stat $tier", description: "Marca de patamar.", triggerType: "Oculto"));
    setState(() {});
  }

  void _showMilestoneDialog(String stat, int tier, String title, String bonuses, int currentValue) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: const Text("Parabéns!", style: TextStyle(color: Colors.amber, fontWeight: FontWeight.bold, fontSize: 22)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("Você alcançou o patamar $tier em $stat!", style: const TextStyle(color: Colors.white, fontSize: 16)),
            const SizedBox(height: 16),
            Text("🏆 $title", style: const TextStyle(color: Colors.amberAccent, fontSize: 20, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
            const SizedBox(height: 16),
            Text(bonuses, style: const TextStyle(color: Colors.greenAccent, fontSize: 14), textAlign: TextAlign.center),
            const SizedBox(height: 16),
            const Text("Caso o personagem escale com este atributo, receba sua bênção.", style: TextStyle(color: Colors.white54, fontSize: 12, fontStyle: FontStyle.italic), textAlign: TextAlign.center),
          ]
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              setState(() {
                _passives.add(Passive(name: "[Bênção Recusada] $stat $tier", description: "O jogador recusou este poder.", triggerType: "Oculto"));
              });
              _checkMilestones(stat, currentValue);
            }, 
            child: const Text("Negar", style: TextStyle(color: Colors.red))
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green[800]),
            onPressed: () {
              Navigator.pop(ctx);
              _applyMilestone(stat, tier);
              _checkMilestones(stat, currentValue);
            },
            child: const Text("Aceitar", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))
          )
        ]
      )
    );
  }

  void _checkMilestones(String label, int newValue) {
    if (!['FOR', 'DES', 'CON', 'SAB'].contains(label)) return;

    List<int> thresholds = [100, 150, 200, 250];
    
    for (int t in thresholds) {
      if (newValue >= t) {
        bool alreadyClaimed = _passives.any((p) => p.name == "[Bênção] $label $t" || p.name == "[Bênção Recusada] $label $t");
        
        if (!alreadyClaimed) {
          String title = "Desperto";
          String bonuses = "Novos poderes adquiridos";
          
          if (label == 'DES') {
            if (t == 100) { title = "Veloz"; bonuses = "Bônus em Acrobacia, Atletismo e Reflexo"; }
            if (t == 150) { title = "Especialista Ágil"; bonuses = "Bônus em Atletismo, Reflexo, Ladinagem e Esgrima"; }
            if (t == 200) { title = "Mestre Ágil"; bonuses = "Bônus passivo em Todos os Testes Físicos"; }
            if (t == 250) { title = "Estado de Fluxo Absoluto"; bonuses = "Aceleração Neural, Intocável e Velocidade Absoluta"; }
          } else if (label == 'FOR') {
            if (t == 100) { title = "Brutamontes"; bonuses = "Bônus em Atletismo, Intimidação e Luta"; }
            if (t == 150) { title = "Esmagador"; bonuses = "Bônus em Atletismo, Intimidação, Luta e CON"; }
            if (t == 200) { title = "Mestre Titânico"; bonuses = "Bônus passivo em Todos os Testes Físicos"; }
            if (t == 250) { title = "Hegemonia do Titã"; bonuses = "Devastação, Rompimento e Demolição Estrutural"; }
          } else if (label == 'CON') {
            if (t == 100) { title = "Inabalável"; bonuses = "Bônus de Defesa, Sobrevivência e Vontade"; }
            if (t == 150) { title = "Muralha"; bonuses = "Bônus em Iniciativa, Vontade e Percepção"; }
            if (t == 200) { title = "Mestre Imortal"; bonuses = "Aumento de PE e Redução de Dano Físico Fixo"; }
            if (t == 250) { title = "Soberania Biológica"; bonuses = "Vitalidade Transcendente, Regeneração e Imunidade"; }
          } else if (label == 'SAB') {
            if (t == 100) { title = "Vidente"; bonuses = "Bônus em Percepção, Intuição e Ocultismo"; }
            if (t == 150) { title = "Oráculo"; bonuses = "Bônus em Percepção, Ocultismo, Intuição e Socorros"; }
            if (t == 200) { title = "Mestre da Mente"; bonuses = "Bônus em Testes Mentais, Guerra e Tática"; }
            if (t == 250) { title = "Onisciência Tática"; bonuses = "Eficiência Mística, Potência Mental e Clareza"; }
          }
          
          _showMilestoneDialog(label, t, title, bonuses, newValue);
          return; 
        }
      }
    }
  }

  void _showLimitBreakDialog(String label, VoidCallback onConfirm) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: const Text("⚠️ AVISO DO SISTEMA", style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
        content: const Text(
          "Você Está Prestes a Superar o Seu Limite.\n\nVocê Consegue?",
          style: TextStyle(color: Colors.white, fontSize: 16),
          textAlign: TextAlign.center,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancelar", style: TextStyle(color: Colors.grey))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red[900]),
            onPressed: () {
              Navigator.pop(ctx);
              onConfirm();
            },
            child: const Text("Superar", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          )
        ],
      )
    );
  }

 void _showEditAttributeDialog(String label, TextEditingController controller) {
    final tempController = TextEditingController(text: controller.text);
    final theme = Theme.of(context);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: theme.cardColor,
        title: Text("Editar $label", style: TextStyle(color: theme.colorScheme.onSurface)),
        content: TextField(
          controller: tempController,
          keyboardType: TextInputType.number,
          autofocus: true, 
          style: TextStyle(color: theme.colorScheme.onSurface),
          decoration: InputDecoration(
            labelText: "Novo Valor",
            labelStyle: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.7)),
            helperText: "O valor só pode ser aumentado.",
            helperStyle: const TextStyle(color: Colors.grey),
            enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: theme.dividerColor)),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancelar"),
          ),
          ElevatedButton(
            onPressed: () {
              final int oldValue = int.tryParse(controller.text) ?? 0;
              final int newValue = int.tryParse(tempController.text) ?? 0;
              final int characterLevel = int.tryParse(_levelController.text) ?? 1;

              if (newValue < oldValue) {
                widget.showToast("Não é possível reduzir este valor (Mínimo: $oldValue).");
              } else if (newValue > oldValue) {
                Navigator.pop(context); 
                
                if (newValue > characterLevel && oldValue <= characterLevel) {
                  _showLimitBreakDialog(label, () {
                     controller.text = newValue.toString();
                     _checkMilestones(label, newValue); 
                  });
                } else {
                  _showAllocationConfirmDialog(label, () {
                    controller.text = newValue.toString(); 
                    _checkMilestones(label, newValue); 
                  });
                }
              } else {
                Navigator.pop(context);
              }
            },
            child: const Text("Aplicar"),
          ),
        ],
      ),
    );
  }  

  Widget _buildAttributeRow(String label, TextEditingController controller) {
    final strings = AppStrings.of(context);
    final theme = Theme.of(context);
    final displayLabel = strings.translateTerm(label);
    
    final Map<String, Color> attrColors = {
      'FOR': const Color(0xFFFF1744), 
      'CON': const Color(0xFFEEEEEE), 
      'DES': const Color(0xFF00E676), 
      'INT': const Color(0xFF2979FF), 
      'SAB': const Color(0xFFFFD600), 
      'CAR': const Color(0xFFFF9100), 
    };

    Color neonColor = attrColors[label] ?? theme.colorScheme.onSurface;
    
    int currentValue = int.tryParse(controller.text) ?? 0;
    int characterLevel = int.tryParse(_levelController.text) ?? 1;
    bool isLimitBroken = currentValue > characterLevel;

    TextStyle neonTextStyle = TextStyle(
      color: neonColor,
      fontWeight: (attrColors.containsKey(label) || isLimitBroken) ? FontWeight.bold : FontWeight.normal,
      shadows: [
        Shadow(color: neonColor.withOpacity(0.8), blurRadius: 8),
        if (isLimitBroken)
          Shadow(color: neonColor, blurRadius: 15),
      ],
    );

    // --- CÁLCULO VISUAL DE BÔNUS (Dados, Modificadores e Multiplicadores) ---
    final bonuses = _getBonusesFor([label]);
    final extraDiceList = _getDiceFromPoints(bonuses.bonusPoints, isAttribute: true);
    final totalMod = bonuses.modifier + _getModifierFromPoints(bonuses.bonusPoints);
    
    List<String> bonusParts = [];
    
    // Adiciona os Dados bônus (ex: +10d20)
    if (extraDiceList.isNotEmpty) {
      bonusParts.add('+${extraDiceList.map((d) => '${d.quantity}d${d.sides}').join('+')}');
    }
    // Adiciona os Modificadores fixos (ex: +100 ou -5)
    if (totalMod != 0) {
      bonusParts.add('${totalMod > 0 ? '+' : ''}$totalMod');
    }
    // Adiciona os Multiplicadores (ex: x1.2 ou x1.55)
    if (bonuses.multiplier != 1.0) {
      String multStr = bonuses.multiplier.toStringAsFixed(2);
      if (multStr.endsWith('0')) multStr = multStr.substring(0, multStr.length - 1);
      if (multStr.endsWith('.0')) multStr = multStr.substring(0, multStr.length - 2);
      bonusParts.add('x$multStr');
    }
    
    String bonusText = bonusParts.join(' ');
    // ------------------------------------------------------------------------
    
    return Card(
      color: Colors.transparent,
      elevation: 0,
      margin: const EdgeInsets.symmetric(vertical: 2), 
      child: InkWell(
        onLongPress: () {
          HapticFeedback.vibrate();
          if (_periciasExibidas.contains(label)) {
            _showSkillDetailsDialog(label); // Agora abre o menu elegante!
          } else {
            // Se for um Atributo (FOR, DES...), mostra a escala de poder!
            _showAttributeDescriptions(); 
          }
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 2.0),
          child: Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => _rollAttributeOrPericia(label, controller.text),
                  child: Container(
                    color: Colors.transparent,
                    padding: const EdgeInsets.symmetric(vertical: 10.0),
                    child: RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(text: displayLabel, style: neonTextStyle),
                          if (bonusText.isNotEmpty)
                            TextSpan(
                              text: '  $bonusText', 
                              style: const TextStyle(
                                color: Colors.amberAccent, 
                                fontSize: 13, 
                                fontWeight: FontWeight.bold, 
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                        ]
                      ),
                    ),
                  ),
                ),
              ),
              
              GestureDetector(
                onTap: () => _showEditAttributeDialog(displayLabel, controller),
                child: Container(
                  width: 80,
                  padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                  decoration: BoxDecoration(
                    color: neonColor.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: neonColor.withOpacity(isLimitBroken ? 0.9 : 0.4), 
                      width: isLimitBroken ? 2 : 1,
                    ),
                    boxShadow: isLimitBroken ? [
                       BoxShadow(color: neonColor.withOpacity(0.3), blurRadius: 8, spreadRadius: 1)
                    ] : [],
                  ),
                  child: Center(
                    child: Text(
                      controller.text.isEmpty ? '0' : controller.text,
                      style: neonTextStyle.copyWith(fontSize: 16), 
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusRow(String label, Map<String, TextEditingController> controllers) {
    return Row(
      children: [
        Expanded(
          child: Focus(
            onFocusChange: (hasFocus) {
              if (!hasFocus) _onStatusChange(label); 
            },
            child: _buildTextField(
              controllers['atual']!, 
              AppStrings.of(context).get('ok'), 
              keyboardType: TextInputType.number,
              onSubmitted: (_) => _onStatusChange(label),
              onTapOutside: () => _onStatusChange(label),
            ),
          ),
        ),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 8.0),
          child: Text("/", style: TextStyle(color: Colors.grey, fontSize: 18)),
        ),
        Expanded(
          child: Focus(
            onFocusChange: (hasFocus) {
              if (!hasFocus) _onStatusChange(label); 
            },
            child: _buildTextField(
              controllers['total']!, 
              AppStrings.of(context).get('max'), 
              keyboardType: TextInputType.number,
              onSubmitted: (_) => _onStatusChange(label),
              onTapOutside: () => _onStatusChange(label),
            ),
          ),
        ),
      ],
    );
  }
}

class AttributeRadarChart extends StatelessWidget {
  final Map<String, int> attributes;
  final String? selectedAttribute;
  final Function(String?) onTapAttribute;
  final VoidCallback onDoubleTap;

  const AttributeRadarChart({
    super.key, 
    required this.attributes, 
    this.selectedAttribute,
    required this.onTapAttribute,
    required this.onDoubleTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque, 
      onTapUp: (details) {
        final RenderBox box = context.findRenderObject() as RenderBox;
        final size = box.size;
        final center = Offset(size.width / 2, size.height / 2);
        final dx = details.localPosition.dx - center.dx;
        final dy = details.localPosition.dy - center.dy;
        
        double tapAngle = atan2(dy, dx);
        if (tapAngle < 0) tapAngle += 2 * pi;
        
        final List<String> attrKeys = ['FOR', 'INT', 'DES', 'CON', 'CAR', 'SAB'];
        String? closestAttr;
        double minDiff = double.infinity;
        
        for (int i = 0; i < 6; i++) {
          double attrAngle = i * pi / 3 - pi / 2;
          if (attrAngle < 0) attrAngle += 2 * pi;
          
          double diff = (tapAngle - attrAngle).abs();
          if (diff > pi) diff = 2 * pi - diff;
          
          if (diff < minDiff) {
            minDiff = diff;
            closestAttr = attrKeys[i];
          }
        }
        
        final distance = sqrt(dx * dx + dy * dy);
        if (distance < size.width / 5) {
          onTapAttribute(null); 
        } else {
          onTapAttribute(closestAttr);
        }
      },
      onDoubleTap: onDoubleTap, 
      child: Container(
        // AUMENTAMOS A ALTURA E O PADDING PARA A SOMBRA NÃO SER CORTADA
        height: 300, 
        width: double.infinity,
        color: Colors.transparent,
        padding: const EdgeInsets.all(28),
        child: CustomPaint(
          painter: RadarPainter(attributes: attributes, selectedAttribute: selectedAttribute),
        ),
      ),
    );
  }
}

class RadarPainter extends CustomPainter {
  final Map<String, int> attributes;
  final String? selectedAttribute;
  
  RadarPainter({required this.attributes, this.selectedAttribute});

  final Map<String, Color> attrColors = {
    'FOR': const Color(0xFFFF1744), 
    'CON': const Color(0xFFEEEEEE), 
    'DES': const Color(0xFF00E676), 
    'INT': const Color(0xFF2979FF), 
    'SAB': const Color(0xFFFFD600), 
    'CAR': const Color(0xFFFF9100), 
  };

  final List<String> attrKeys = ['FOR', 'INT', 'DES', 'CON', 'CAR', 'SAB'];

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = min(size.width, size.height) / 2.2;

    int maxStat = attributes.values.fold(10, max);
    int visualCap = 100; 
    int currentCap = min(maxStat, visualCap);
    int maxScale = ((currentCap + 9) ~/ 10) * 10; 
    if (maxScale < 10) maxScale = 10;
    int numRings = maxScale ~/ 10;

    final bgPaint = Paint()
      ..color = Colors.grey.withOpacity(0.15)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    for (int i = 1; i <= numRings; i++) {
      double r = radius * (i / numRings);
      Path path = Path();
      for (int j = 0; j < 6; j++) {
        double angle = j * pi / 3 - pi / 2;
        Offset p = Offset(center.dx + r * cos(angle), center.dy + r * sin(angle));
        if (j == 0) {
          path.moveTo(p.dx, p.dy);
        } else {
          path.lineTo(p.dx, p.dy);
        }
      }
      path.close();
      canvas.drawPath(path, bgPaint);
    }

    for (int i = 0; i < 6; i++) {
      double angle = i * pi / 3 - pi / 2;
      String key = attrKeys[i];
      Color color = attrColors[key] ?? Colors.white;

      // Se há um atributo selecionado, apaga os eixos não selecionados
      double lineOpacity = (selectedAttribute == null || selectedAttribute == key) ? 0.6 : 0.1;

      final axisPaint = Paint()
        ..color = color.withOpacity(lineOpacity) 
        ..style = PaintingStyle.stroke
        ..strokeWidth = (selectedAttribute == key) ? 2.5 : 1.5;

      Offset endPoint = Offset(center.dx + radius * cos(angle), center.dy + radius * sin(angle));
      canvas.drawLine(center, endPoint, axisPaint);
    }

    final textPainter = TextPainter(textDirection: TextDirection.ltr);
    List<Offset> statPoints = [];
    
    for (int i = 0; i < 6; i++) {
      double angle = i * pi / 3 - pi / 2;
      String key = attrKeys[i];
      Color color = attrColors[key] ?? Colors.white;

      double textOpacity = (selectedAttribute == null || selectedAttribute == key) ? 1.0 : 0.4;

      textPainter.text = TextSpan(text: key, style: TextStyle(color: color.withOpacity(textOpacity), fontWeight: FontWeight.bold, fontSize: (selectedAttribute == key) ? 16 : 14));
      textPainter.layout();
      Offset textOffset = Offset(
        center.dx + (radius + 20) * cos(angle) - textPainter.width / 2,
        center.dy + (radius + 15) * sin(angle) - textPainter.height / 2,
      );
      textPainter.paint(canvas, textOffset);

      int rawValue = attributes[key] ?? 0;
      double percentage = (rawValue / maxScale).clamp(0.0, 1.0);
      statPoints.add(Offset(center.dx + (radius * percentage) * cos(angle), center.dy + (radius * percentage) * sin(angle)));
    }

    final fillPath = Path();
    fillPath.moveTo(statPoints[0].dx, statPoints[0].dy);
    for (int i = 1; i < statPoints.length; i++) {
      fillPath.lineTo(statPoints[i].dx, statPoints[i].dy);
    }
    fillPath.close();

    // Muda a cor principal do gráfico para a cor do atributo focado
    Color dominantColor = selectedAttribute != null 
        ? attrColors[selectedAttribute]! 
        : Colors.purpleAccent;

    final fillPaint = Paint()
      ..color = dominantColor.withOpacity(selectedAttribute != null ? 0.35 : 0.2)
      ..style = PaintingStyle.fill;
    canvas.drawPath(fillPath, fillPaint);

    final borderPaint = Paint()
      ..color = dominantColor.withOpacity(0.8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = selectedAttribute != null ? 3 : 2;
    canvas.drawPath(fillPath, borderPaint);

    // Efeito de sombra externa intensa (Brilho) se selecionado
    if (selectedAttribute != null) {
      // Cria múltiplas camadas de linhas cada vez mais grossas (Glow Manual Forçado)
      for(int glow = 6; glow > 0; glow--) {
        final glowPaint = Paint()
          ..color = dominantColor.withOpacity(0.2)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.0 + (glow * 4);
        canvas.drawPath(fillPath, glowPaint);
      }
      
      // Linha principal Branca e Grossa (Miolo do Neon)
      final coreBorderPaint = Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3;
      canvas.drawPath(fillPath, coreBorderPaint);
    }

    for (int i = 0; i < 6; i++) {
      String key = attrKeys[i];
      int rawValue = attributes[key] ?? 0;
      Color color = attrColors[key] ?? Colors.white;

      double dotOpacity = (selectedAttribute == null || selectedAttribute == key) ? 1.0 : 0.3;

      if (rawValue >= visualCap && (selectedAttribute == null || selectedAttribute == key)) {
        final glowPaint = Paint()
          ..color = color.withOpacity(0.9)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10); 
        canvas.drawCircle(statPoints[i], 14, glowPaint);
        
        final corePaint = Paint()
          ..color = Colors.white
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2); 
        canvas.drawCircle(statPoints[i], 6, corePaint);
      }

      final dotPaint = Paint()..color = color.withOpacity(dotOpacity)..style = PaintingStyle.fill;
      canvas.drawCircle(statPoints[i], selectedAttribute == key ? 7 : 5, dotPaint);
    }
  }

  @override
  bool shouldRepaint(covariant RadarPainter oldDelegate) {
    return oldDelegate.attributes != attributes || oldDelegate.selectedAttribute != selectedAttribute;
  }
}