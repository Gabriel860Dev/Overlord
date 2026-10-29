// lib/models/passive.dart

import 'package:overlord/models/armor.dart';
import 'package:overlord/models/status_effect.dart'; // NOVO IMPORT NECESSÁRIO

class PassiveEffect {
  final List<String> targets;
  final String bonusType;
  final double value;
  final double perRoundValue;
  final String? bonusDamageType;
  final Armor? grantsArmor;

  PassiveEffect({
    required this.targets,
    required this.bonusType,
    required this.value,
    this.perRoundValue = 0,
    this.bonusDamageType,
    this.grantsArmor,
  });

  Map<String, dynamic> toJson() => {
    'targets': targets,
    'bonusType': bonusType,
    'value': value,
    'perRoundValue': perRoundValue,
    'bonusDamageType': bonusDamageType,
    'grantsArmor': grantsArmor?.toJson(),
  };

  factory PassiveEffect.fromJson(Map<String, dynamic> json) {
    Armor? parsedArmor;
    
    // A MÁGICA ESTÁ AQUI: Transforma o texto (Map) de volta em Armadura
    if (json['grantsArmor'] != null) {
      try {
        parsedArmor = Armor.fromJson(Map<String, dynamic>.from(json['grantsArmor']));
      } catch (e) {
        print("Erro ao converter grantsArmor: $e");
      }
    }

    return PassiveEffect(
      targets: List<String>.from(json['targets'] ?? []),
      bonusType: json['bonusType'] ?? 'Modificador',
      value: (json['value'] ?? 0).toDouble(),
      perRoundValue: (json['perRoundValue'] ?? 0).toDouble(),
      bonusDamageType: json['bonusDamageType'],
      grantsArmor: parsedArmor,
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
  final bool basedOnTotal;
  final int cooldown;
  final List<PassiveEffect> effects;
  
  // --- NOVOS CAMPOS PARA SUPORTE AVANÇADO (Legado da Nevasca) ---
  final int costAmount; // Custo para ativar (Ex: 80)
  final String costType; // Recurso (Ex: "Esforço")
  final String costSource; // Padrão, Temporário, etc.
  final List<StatusEffect> selfStatusEffectsToApply; // Debuffs aplicados a si mesmo (Ex: Rigidez do Arauto)
  final String? dynamicHealingStat; // Atributo para cura dinâmica (Ex: "Vontade")
  final double dynamicHealingPercentage; // Porcentagem de cura (Ex: 10.0)

  bool isActive;
  int stacks;
  int currentCooldown;
  int maxStacks;

  Passive({
    String? id,
    required this.name,
    required this.description,
    this.triggerType = 'Sempre Ativo',
    this.triggerValueType = 'Fixo',
    this.triggerValue = 0,
    this.triggerFrequency = 'Sempre',
    this.basedOnTotal = false,
    this.cooldown = 0,
    this.effects = const [],
    this.costAmount = 0, // NOVO
    this.costType = 'Esforço', // NOVO
    this.costSource = 'Padrão', // NOVO
    this.selfStatusEffectsToApply = const [], // NOVO
    this.dynamicHealingStat, // NOVO
    this.dynamicHealingPercentage = 0.0, // NOVO
    this.isActive = false,
    this.stacks = 0,
    this.currentCooldown = 0,
    this.maxStacks = 99,
  }) : id = id ?? DateTime.now().millisecondsSinceEpoch.toString();

  Map<String, dynamic> toJson() => {
    'id': id, 'name': name, 'description': description,
    'triggerType': triggerType, 'triggerValueType': triggerValueType,
    'triggerValue': triggerValue, 'triggerFrequency': triggerFrequency,
    'basedOnTotal': basedOnTotal, 'cooldown': cooldown,
    'effects': effects.map((e) => e.toJson()).toList(),
    'costAmount': costAmount, // NOVO
    'costType': costType, // NOVO
    'costSource': costSource, // NOVO
    'selfStatusEffectsToApply': selfStatusEffectsToApply.map((e) => e.toJson()).toList(), // NOVO
    'dynamicHealingStat': dynamicHealingStat, // NOVO
    'dynamicHealingPercentage': dynamicHealingPercentage, // NOVO
    'isActive': isActive, 'stacks': stacks, 
    'currentCooldown': currentCooldown, 'maxStacks': maxStacks,
  };

  factory Passive.fromJson(Map<String, dynamic> json) => Passive(
    id: json['id'], name: json['name'], description: json['description'],
    triggerType: json['triggerType'] ?? 'Sempre Ativo', 
    triggerValueType: json['triggerValueType'] ?? 'Fixo',
    triggerValue: json['triggerValue'] ?? 0, 
    triggerFrequency: json['triggerFrequency'] ?? 'Sempre',
    basedOnTotal: json['basedOnTotal'] ?? false, 
    cooldown: json['cooldown'] ?? 0,
    effects: json['effects'] != null 
        ? (json['effects'] as List).map((e) => PassiveEffect.fromJson(Map<String, dynamic>.from(e))).toList() 
        : [],
    costAmount: json['costAmount'] ?? 0, // NOVO
    costType: json['costType'] ?? 'Esforço', // NOVO
    costSource: json['costSource'] ?? 'Padrão', // NOVO
    selfStatusEffectsToApply: (json['selfStatusEffectsToApply'] as List?)?.map((e) => StatusEffect.fromJson(e)).toList() ?? [], // NOVO
    dynamicHealingStat: json['dynamicHealingStat'], // NOVO
    dynamicHealingPercentage: (json['dynamicHealingPercentage'] as num?)?.toDouble() ?? 0.0, // NOVO
    isActive: json['isActive'] ?? false, 
    stacks: json['stacks'] ?? 0,
    currentCooldown: json['currentCooldown'] ?? 0,
    maxStacks: json['maxStacks'] ?? 99,
  );
}