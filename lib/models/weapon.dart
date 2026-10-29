// lib/models/weapon.dart

import 'package:overlord/models/die_specification.dart';
import 'package:overlord/models/item.dart';

/// Classe que define efeitos condicionais (Gatilhos, Críticos)
class ConditionalEffect {
  String description;
  String conditionSource; // 'ROLAGEM', 'DADO_EXTRA'
  int requiredSuccesses;
  int conditionDieSides;
  int conditionTargetValue; 
  int conditionMaxValue; 
  String conditionOperator; 
  
  String effectType; 
  double multiplier;
  List<DieSpecification> bonusDice;
  int bonusModifier;

  ConditionalEffect({
    required this.description,
    required this.conditionSource,
    required this.requiredSuccesses,
    required this.conditionDieSides,
    required this.conditionTargetValue,
    required this.conditionMaxValue,
    required this.conditionOperator,
    required this.effectType,
    required this.multiplier,
    required this.bonusDice,
    required this.bonusModifier,
  });

  Map<String, dynamic> toJson() => {
    'description': description,
    'conditionSource': conditionSource,
    'requiredSuccesses': requiredSuccesses,
    'conditionDieSides': conditionDieSides,
    'conditionTargetValue': conditionTargetValue,
    'conditionMaxValue': conditionMaxValue,
    'conditionOperator': conditionOperator,
    'effectType': effectType,
    'multiplier': multiplier,
    'bonusDice': bonusDice.map((e) => e.toJson()).toList(),
    'bonusModifier': bonusModifier,
  };

  factory ConditionalEffect.fromJson(Map<String, dynamic> json) => ConditionalEffect(
    description: json['description'] ?? '',
    conditionSource: json['conditionSource'] ?? 'ROLAGEM',
    requiredSuccesses: json['requiredSuccesses'] ?? 1,
    conditionDieSides: json['conditionDieSides'] ?? 20,
    conditionTargetValue: json['conditionTargetValue'] ?? 20,
    conditionMaxValue: json['conditionMaxValue'] ?? 20,
    conditionOperator: json['conditionOperator'] ?? '>=',
    effectType: json['effectType'] ?? 'Multiplicador de Dano',
    multiplier: (json['multiplier'] as num?)?.toDouble() ?? 1.0,
    bonusDice: (json['bonusDice'] as List?)?.map((e) => DieSpecification.fromJson(e)).toList() ?? [],
    bonusModifier: json['bonusModifier'] ?? 0,
  );
}

class Weapon extends Item {
  List<DieSpecification> dice;
  int modifier;
  double multiplier;
  List<ConditionalEffect> triggers;
  String? attackSkill;
  int attackBonus;
  double attackMultiplier;

  Weapon({
    super.id,
    required super.name,
    super.description,
    super.imagePath,
    super.effects,
    super.isEquipped,
    this.dice = const [],
    this.modifier = 0,
    this.multiplier = 1.0,
    this.triggers = const [],
    this.attackSkill,
    this.attackBonus = 0,
    this.attackMultiplier = 1.0,
  });

  @override
  Map<String, dynamic> toJson() {
    final json = super.toJson();
    json.addAll({
      'dice': dice.map((d) => d.toJson()).toList(),
      'modifier': modifier,
      'multiplier': multiplier,
      'triggers': triggers.map((t) => t.toJson()).toList(),
      'attackSkill': attackSkill,
      'attackBonus': attackBonus,
      'attackMultiplier': attackMultiplier,
      'type': 'Weapon', // Identificador para o Item.fromJson saber que é uma arma
    });
    return json;
  }

  factory Weapon.fromJson(Map<String, dynamic> json) => Weapon(
    id: json['id'],
    name: json['name'],
    description: json['description'] ?? '',
    imagePath: json['imagePath'],
    effects: (json['effects'] as List?)?.map((e) => ItemEffect.fromJson(e)).toList() ?? [],
    isEquipped: json['isEquipped'] ?? false,
    dice: (json['dice'] as List?)?.map((d) => DieSpecification.fromJson(d)).toList() ?? [],
    modifier: json['modifier'] ?? 0,
    multiplier: (json['multiplier'] as num?)?.toDouble() ?? 1.0,
    triggers: (json['triggers'] as List?)?.map((t) => ConditionalEffect.fromJson(t)).toList() ?? [],
    attackSkill: json['attackSkill'],
    attackBonus: json['attackBonus'] ?? 0,
    attackMultiplier: (json['attackMultiplier'] as num?)?.toDouble() ?? 1.0,
  );
}