// lib/models/ability.dart

import 'package:uuid/uuid.dart';
import 'package:overlord/models/die_specification.dart';
import 'package:overlord/models/armor.dart';
import 'package:overlord/models/passive.dart'; 
import 'package:overlord/models/weapon.dart';  
import 'package:overlord/models/status_effect.dart'; 

class BaseComponent {
  final String type; 
  final String value; 
  BaseComponent({required this.type, required this.value});
  
  Map<String, dynamic> toJson() => {'type': type, 'value': value};
  factory BaseComponent.fromJson(Map<String, dynamic> json) => 
      BaseComponent(type: json['type'], value: json['value']);
}

// Este aliás garante que tanto o código antigo quanto o novo formulário funcionem juntos!
typedef AbilityBaseComponent = BaseComponent;

class Ability {
  String id;
  String name;
  String description;
  String? imagePath;
  
  String abilityType; 
  String actionType; 
  
  int costPerRound; 
  String costType; 
  String costSource; 
  int costAmount;
  int cooldown;
  int currentCooldown; 
  Map<String, int> extraCosts; 

  List<PassiveEffect> effects; 
  List<BaseComponent> baseComponents;
  double multiplier;
  List<DieSpecification> bonusDice;
  int bonusModifier;
  
  String targetType; 
  double areaRadius; 
  int maxTargets;    

  Armor? armorToCreate; 
  List<StatusEffect> statusEffectsToApply; 
  List<ConditionalEffect> conditionalEffects; 
  
  // --- NOVOS CAMPOS PARA SUPORTE AVANÇADO (Legado da Nevasca) ---
  List<StatusEffect> selfStatusEffectsToApply; // Debuffs aplicados em si mesmo (Ex: Rigidez do Arauto)
  String? dynamicHealingStat; // Atributo base para cura dinâmica (Ex: "Vontade")
  double dynamicHealingPercentage; // Porcentagem do atributo usado para cura (Ex: 10.0)
  
  bool isActive;
  int usesInCombat;
  String? attackSkill;
  int attackBonus;
  double attackMultiplier;
  bool useWeaponDamage;

  int dotDamage;
  int dotTurns;
  String dotElement;
  String? stunDuration; 

  // --- NOVOS ATRIBUTOS AVANÇADOS ---
  int targetCount;
  String range;
  String areaOfEffect;
  bool hasBurn;
  String burnDamage;
  int burnDuration;

  Ability({
    String? id,
    required this.name,
    required this.description,
    this.imagePath,
    this.abilityType = 'Dano',
    this.actionType = 'MAG',
    this.effects = const [],
    this.costPerRound = 0,
    this.costType = 'Esforço',
    this.costSource = 'Padrão',
    this.costAmount = 0,
    this.cooldown = 0,
    this.currentCooldown = 0,
    this.extraCosts = const {},
    this.baseComponents = const [],
    this.multiplier = 1.0,
    this.bonusDice = const [],
    this.bonusModifier = 0,
    this.armorToCreate,
    this.statusEffectsToApply = const [],
    this.conditionalEffects = const [],
    this.selfStatusEffectsToApply = const [], // NOVO
    this.dynamicHealingStat, // NOVO
    this.dynamicHealingPercentage = 0.0, // NOVO
    this.isActive = false,
    this.usesInCombat = 0,
    this.attackSkill,
    this.attackBonus = 0,
    this.attackMultiplier = 1.0,
    this.useWeaponDamage = false,
    this.dotDamage = 0,
    this.dotTurns = 0,
    this.dotElement = 'Fogo',
    this.stunDuration,
    this.targetType = 'Alvo Único',
    this.areaRadius = 0.0,
    this.maxTargets = 1,
    
    // Defaults dos novos atributos
    this.targetCount = 1,
    this.range = 'Corpo-a-Corpo',
    this.areaOfEffect = 'Nenhuma',
    this.hasBurn = false,
    this.burnDamage = '',
    this.burnDuration = 0,
  }) : id = id ?? const Uuid().v4();

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'imagePath': imagePath,
      'abilityType': abilityType,
      'actionType': actionType,
      'costPerRound': costPerRound,
      'costType': costType,
      'costSource': costSource,
      'costAmount': costAmount,
      'cooldown': cooldown,
      'currentCooldown': currentCooldown,
      'extraCosts': extraCosts,
      'baseComponents': baseComponents.map((c) => c.toJson()).toList(),
      'multiplier': multiplier,
      'bonusDice': bonusDice.map((d) => d.toJson()).toList(),
      'bonusModifier': bonusModifier,
      'armorToCreate': armorToCreate?.toJson(),
      'effects': effects.map((e) => e.toJson()).toList(),
      'statusEffectsToApply': statusEffectsToApply.map((e) => e.toJson()).toList(),
      'conditionalEffects': conditionalEffects.map((e) => e.toJson()).toList(),
      'selfStatusEffectsToApply': selfStatusEffectsToApply.map((e) => e.toJson()).toList(), // NOVO
      'dynamicHealingStat': dynamicHealingStat, // NOVO
      'dynamicHealingPercentage': dynamicHealingPercentage, // NOVO
      'isActive': isActive,
      'usesInCombat': usesInCombat,
      'attackSkill': attackSkill,
      'attackBonus': attackBonus,
      'attackMultiplier': attackMultiplier,
      'useWeaponDamage': useWeaponDamage,
      'dotDamage': dotDamage,
      'dotTurns': dotTurns,
      'dotElement': dotElement,
      'stunDuration': stunDuration,
      'targetType': targetType,
      'areaRadius': areaRadius,
      'maxTargets': maxTargets,
      'targetCount': targetCount,
      'range': range,
      'areaOfEffect': areaOfEffect,
      'hasBurn': hasBurn,
      'burnDamage': burnDamage,
      'burnDuration': burnDuration,
    };
  }

  factory Ability.fromJson(Map<String, dynamic> json) {
    return Ability(
      id: json['id'],
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      imagePath: json['imagePath'],
      abilityType: json['abilityType'] ?? 'Dano',
      actionType: json['actionType'] ?? 'MAG',
      costPerRound: json['costPerRound'] ?? 0,
      costType: json['costType'] ?? 'Esforço',
      costSource: json['costSource'] ?? 'Padrão',
      costAmount: json['costAmount'] ?? 0,
      cooldown: json['cooldown'] ?? 0,
      currentCooldown: json['currentCooldown'] ?? 0,
      extraCosts: Map<String, int>.from(json['extraCosts'] ?? {}),
      baseComponents: (json['baseComponents'] as List?)?.map((c) => BaseComponent.fromJson(c)).toList() ?? [],
      multiplier: (json['multiplier'] as num?)?.toDouble() ?? 1.0,
      bonusDice: (json['bonusDice'] as List?)?.map((d) => DieSpecification.fromJson(d)).toList() ?? [],
      bonusModifier: json['bonusModifier'] ?? 0,
      armorToCreate: json['armorToCreate'] != null ? Armor.fromJson(Map<String, dynamic>.from(json['armorToCreate'])) : null,
      effects: (json['effects'] as List?)?.map((e) => PassiveEffect.fromJson(e)).toList() ?? [],
      statusEffectsToApply: (json['statusEffectsToApply'] as List?)?.map((e) => StatusEffect.fromJson(e)).toList() ?? [],
      conditionalEffects: (json['conditionalEffects'] as List?)?.map((e) => ConditionalEffect.fromJson(e)).toList() ?? [],
      selfStatusEffectsToApply: (json['selfStatusEffectsToApply'] as List?)?.map((e) => StatusEffect.fromJson(e)).toList() ?? [], // NOVO
      dynamicHealingStat: json['dynamicHealingStat'], // NOVO
      dynamicHealingPercentage: (json['dynamicHealingPercentage'] as num?)?.toDouble() ?? 0.0, // NOVO
      isActive: json['isActive'] ?? false,
      usesInCombat: json['usesInCombat'] ?? 0,
      attackSkill: json['attackSkill'],
      attackBonus: json['attackBonus'] ?? 0,
      attackMultiplier: (json['attackMultiplier'] as num?)?.toDouble() ?? 1.0,
      useWeaponDamage: json['useWeaponDamage'] ?? false,
      dotDamage: json['dotDamage'] ?? 0,
      dotTurns: json['dotTurns'] ?? 0,
      dotElement: json['dotElement'] ?? 'Fogo',
      stunDuration: json['stunDuration'],
      targetType: json['targetType'] ?? 'Alvo Único',
      areaRadius: (json['areaRadius'] as num?)?.toDouble() ?? 0.0,
      maxTargets: json['maxTargets'] ?? 1,
      targetCount: json['targetCount'] ?? 1,
      range: json['range'] ?? 'Corpo-a-Corpo',
      areaOfEffect: json['areaOfEffect'] ?? 'Nenhuma',
      hasBurn: json['hasBurn'] ?? false,
      burnDamage: json['burnDamage'] ?? '',
      burnDuration: json['burnDuration'] ?? 0,
    );
  }
}