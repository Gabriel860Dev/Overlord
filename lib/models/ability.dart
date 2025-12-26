// lib/models/ability.dart

import 'package:dark_age/models/die_specification.dart';
import 'package:dark_age/models/armor.dart';
import 'package:uuid/uuid.dart';
import 'package:dark_age/models/item.dart'; // Import ItemEffect

class ConditionalEffect {
  final String conditionSource;
  final int requiredSuccesses;
  final int conditionDieSides;
  final int conditionTargetValue;
  final String conditionOperator;
  final String effectType;
  final double multiplier;
  final List<DieSpecification> bonusDice;
  final int bonusModifier;
  final String description;

  ConditionalEffect({
    this.conditionSource = 'DADO_EXTRA',
    this.requiredSuccesses = 1,
    this.conditionDieSides = 20,
    this.conditionTargetValue = 18,
    this.conditionOperator = '>=',
    this.effectType = 'Multiplicador de Dano',
    this.multiplier = 1.0,
    this.bonusDice = const [],
    this.bonusModifier = 0,
    this.description = '',
  });

  Map<String, dynamic> toJson() => {
        'conditionSource': conditionSource,
        'requiredSuccesses': requiredSuccesses,
        'conditionDieSides': conditionDieSides,
        'conditionTargetValue': conditionTargetValue,
        'conditionOperator': conditionOperator,
        'effectType': effectType,
        'multiplier': multiplier,
        'bonusDice': bonusDice.map((d) => d.toJson()).toList(),
        'bonusModifier': bonusModifier,
        'description': description,
      };

  factory ConditionalEffect.fromJson(Map<String, dynamic> json) =>
      ConditionalEffect(
        conditionSource: json['conditionSource'] ?? 'DADO_EXTRA',
        requiredSuccesses: json['requiredSuccesses'] ?? 1,
        conditionDieSides: json['conditionDieSides'] ?? 20,
        conditionTargetValue: json['conditionTargetValue'] ?? 18,
        conditionOperator: json['conditionOperator'] ?? '>=',
        effectType: json['effectType'] ?? 'Multiplicador de Dano',
        multiplier: (json['multiplier'] as num?)?.toDouble() ?? 1.0,
        bonusDice: (json['bonusDice'] as List?)
                ?.map((i) => DieSpecification.fromJson(i as Map<String, dynamic>))
                .toList() ?? [],
        bonusModifier: json['bonusModifier'] ?? 0,
        description: json['description'] ?? '',
      );
}

class BaseComponent {
  final String type; // 'Atributo' ou 'Perícia'
  final String value;

  BaseComponent({required this.type, required this.value});

  Map<String, dynamic> toJson() => {'type': type, 'value': value};

  factory BaseComponent.fromJson(Map<String, dynamic> json) =>
      BaseComponent(type: json['type'], value: json['value']);
}

class Ability {
  final String id;
  final String name;
  final String description;
  final String? imagePath;

  final String abilityType;
  final int costPerRound;
  bool isActive;
  int uses;
  int usesInCombat; // Para o sistema de Fadiga

  final String costType;
  final String costSource;
  final int costAmount;
  final int cooldown;
  int currentCooldown;

  final List<ItemEffect> effects;
  final List<BaseComponent> baseComponents;
  final double multiplier;
  final List<DieSpecification> bonusDice; // Dados fixos da habilidade
  final int bonusModifier;
  final List<ConditionalEffect> conditionalEffects;
  final List<String> defenseAttributes;
  final List<int> defensePercentages;
  final int flatDamageReduction;
  final double percentageDamageReduction;
  final Armor? armorToCreate;

  Ability({
    String? id,
    required this.name,
    this.description = '',
    this.imagePath,
    this.abilityType = 'Dano',
    this.costPerRound = 0,
    this.isActive = false,
    this.uses = 0,
    this.usesInCombat = 0,
    this.costType = 'Nenhum',
    this.costSource = 'Padrão',
    this.costAmount = 0,
    this.cooldown = 0,
    this.currentCooldown = 0,
    this.effects = const [],
    this.baseComponents = const [],
    this.multiplier = 1.0,
    this.bonusDice = const [],
    this.bonusModifier = 0,
    this.conditionalEffects = const [],
    this.defenseAttributes = const [],
    this.defensePercentages = const [],
    this.flatDamageReduction = 0,
    this.percentageDamageReduction = 0.0,
    this.armorToCreate,
  }) : id = id ?? const Uuid().v4();

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'imagePath': imagePath,
      'abilityType': abilityType,
      'costPerRound': costPerRound,
      'isActive': isActive,
      'uses': uses,
      'usesInCombat': usesInCombat,
      'costType': costType,
      'costSource': costSource,
      'costAmount': costAmount,
      'cooldown': cooldown,
      'currentCooldown': currentCooldown,
      'effects': effects.map((e) => e.toJson()).toList(),
      'baseComponents': baseComponents.map((c) => c.toJson()).toList(),
      'multiplier': multiplier,
      'bonusDice': bonusDice.map((d) => d.toJson()).toList(),
      'bonusModifier': bonusModifier,
      'conditionalEffects':
          conditionalEffects.map((c) => c.toJson()).toList(),
      'defenseAttributes': defenseAttributes,
      'defensePercentages': defensePercentages,
      'flatDamageReduction': flatDamageReduction,
      'percentageDamageReduction': percentageDamageReduction,
      'armorToCreate': armorToCreate?.toJson(),
    };
  }

  factory Ability.fromJson(Map<String, dynamic> json) {
    return Ability(
      id: json['id'],
      name: json['name'],
      description: json['description'] ?? '',
      imagePath: json['imagePath'],
      abilityType: json['abilityType'] ?? 'Dano',
      costPerRound: json['costPerRound'] ?? 0,
      isActive: json['isActive'] ?? false,
      uses: json['uses'] ?? 0,
      usesInCombat: json['usesInCombat'] ?? 0,
      costType: json['costType'] ?? 'Nenhum',
      costSource: json['costSource'] ?? 'Padrão',
      costAmount: json['costAmount'] ?? 0,
      cooldown: json['cooldown'] ?? 0,
      currentCooldown: json['currentCooldown'] ?? 0,
      effects: (json['effects'] as List?)
              ?.map((e) => ItemEffect.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      baseComponents: (json['baseComponents'] as List?)
              ?.map((c) => BaseComponent.fromJson(c as Map<String, dynamic>))
              .toList() ??
          [],
      multiplier: (json['multiplier'] as num?)?.toDouble() ?? 1.0,
      bonusDice: (json['bonusDice'] as List?)
              ?.map((i) =>
                  DieSpecification.fromJson(i as Map<String, dynamic>))
              .toList() ??
          [],
      bonusModifier: json['bonusModifier'] ?? 0,
      conditionalEffects: (json['conditionalEffects'] as List?)
              ?.map((c) =>
                  ConditionalEffect.fromJson(c as Map<String, dynamic>))
              .toList() ??
          [],
      defenseAttributes: List<String>.from(json['defenseAttributes'] ?? []),
      defensePercentages: List<int>.from(json['defensePercentages'] ?? []),
      flatDamageReduction: json['flatDamageReduction'] ?? 0,
      percentageDamageReduction:
          (json['percentageDamageReduction'] as num?)?.toDouble() ?? 0.0,
      armorToCreate: json['armorToCreate'] != null
          ? Armor.fromJson(json['armorToCreate'])
          : null,
    );
  }
}
