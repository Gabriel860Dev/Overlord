// lib/models/passive.dart

import 'package:dark_age/models/armor.dart';
import 'package:uuid/uuid.dart';

class PassiveEffect {
  final List<String> targets;
  final String bonusType; // 'Modificador', 'Percentual', 'Pontos de Bônus', 'Conceder Armadura'
  final double value;
  final Armor? grantsArmor;

  PassiveEffect({
    required this.targets,
    required this.bonusType,
    this.value = 0,
    this.grantsArmor,
  });

  Map<String, dynamic> toJson() {
    return {
      'targets': targets,
      'bonusType': bonusType,
      'value': value,
      'grantsArmor': grantsArmor?.toJson(),
    };
  }

  factory PassiveEffect.fromJson(Map<String, dynamic> json) {
    List<String> loadedTargets = [];
    if (json['targets'] is List) {
      loadedTargets = List<String>.from(json['targets']);
    } else if (json['target'] is String) {
      loadedTargets.add(json['target']);
    }

    return PassiveEffect(
      targets: loadedTargets,
      bonusType: json['bonusType'],
      value: (json['value'] as num?)?.toDouble() ?? 0,
      grantsArmor: json['grantsArmor'] != null ? Armor.fromJson(json['grantsArmor']) : null,
    );
  }
}

class Passive {
  final String id;
  final String name;
  final String description;

  final String triggerType;
  final String triggerValueType;
  final int triggerValue;
  final String triggerFrequency;
  final int cooldown;
  final bool basedOnTotal; // TRUE = Inversamente Proporcional

  final List<PassiveEffect> effects;

  bool isActive;
  int stacks;
  int currentCooldown;

  Passive({
    String? id,
    required this.name,
    required this.description,
    this.triggerType = 'Sempre Ativo',
    this.triggerValueType = 'Valor Fixo',
    this.triggerValue = 0,
    this.triggerFrequency = 'Acumulável',
    this.cooldown = 0,
    this.basedOnTotal = false,
    this.effects = const [],
    this.isActive = false,
    this.stacks = 0,
    this.currentCooldown = 0,
  }) : id = id ?? const Uuid().v4();

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'triggerType': triggerType,
      'triggerValueType': triggerValueType,
      'triggerValue': triggerValue,
      'triggerFrequency': triggerFrequency,
      'cooldown': cooldown,
      'basedOnTotal': basedOnTotal,
      'effects': effects.map((e) => e.toJson()).toList(),
      'isActive': isActive,
      'stacks': stacks,
      'currentCooldown': currentCooldown,
    };
  }

  factory Passive.fromJson(Map<String, dynamic> json) {
    return Passive(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      triggerType: json['triggerType'] ?? 'Sempre Ativo',
      triggerValueType: json['triggerValueType'] ?? 'Valor Fixo',
      triggerValue: json['triggerValue'] ?? 0,
      triggerFrequency: json['triggerFrequency'] ?? 'Acumulável',
      cooldown: json['cooldown'] ?? 0,
      basedOnTotal: json['basedOnTotal'] ?? false,
      effects: (json['effects'] as List?)
              ?.map((e) => PassiveEffect.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      isActive: json['isActive'] ?? false,
      stacks: json['stacks'] ?? 0,
      currentCooldown: json['currentCooldown'] ?? 0,
    );
  }
}