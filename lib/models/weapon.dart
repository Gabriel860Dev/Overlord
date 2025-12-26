// lib/models/weapon.dart

import 'package:dark_age/models/die_specification.dart';
import 'package:dark_age/models/ability.dart' show ConditionalEffect;
import 'package:dark_age/models/item.dart';
import 'package:uuid/uuid.dart';

class Weapon extends Item {
  final List<DieSpecification> dice; // Dados base da arma (antes do scaling)
  final int modifier; // Modificador fixo de dano
  final double multiplier; // Multiplicador fixo de dano
  final List<ConditionalEffect> triggers; // Efeitos condicionais (críticos, etc.)
  final int resistencia; // Durabilidade máxima da arma
  int resistenciaAtual; // Durabilidade atual

  // NOVO: Campos para sistema Dark Age
  final String attributeScaling; // 'Força', 'Destreza', 'Força/Destreza', etc.
  final int pointsPerDie; // Quantos pontos do atributo para ganhar 1 dado (ex: 4)
  final double criticalMultiplier; // Multiplicador de dano em acerto crítico (ex: 1.5 para +50%)
  final int criticalThreshold; // Valor mínimo no D100 para crítico (ex: 91 para 91+)
  final List<String> damageTypes; // Tipos de dano primário e secundário (ex: ['Cortante', 'Perfurante'])
  final List<double> damageTypePercentages; // Percentagens correspondentes (ex: [1.0, 0.4] para 100% e 40%)
  final double hitModifierPercent; // Modificador percentual no acerto (ex: -0.25 para -25%)


  Weapon({
    String? id,
    required super.name,
    super.description,
    super.imagePath,
    super.effects, // Efeitos de item (bônus passivos)
    super.isEquipped,
    this.dice = const [], // Dados base fixos (raro em Dark Age, mais para armas míticas)
    this.modifier = 0,
    this.multiplier = 1.0,
    this.triggers = const [],
    this.resistencia = 100,
    int? resistenciaAtual,
    // NOVO
    this.attributeScaling = 'Força', // Padrão
    this.pointsPerDie = 5, // Padrão
    this.criticalMultiplier = 1.2, // Padrão +20%
    this.criticalThreshold = 91, // Padrão 91+
    this.damageTypes = const ['Impacto'], // Padrão
    this.damageTypePercentages = const [1.0], // Padrão 100%
    this.hitModifierPercent = 0.0, // Padrão 0%
  }) : resistenciaAtual = resistenciaAtual ?? resistencia,
       super(id: id ?? const Uuid().v4());

  @override
  Map<String, dynamic> toJson() {
    final json = super.toJson();
    json.addAll({
      'dice': dice.map((d) => d.toJson()).toList(),
      'modifier': modifier,
      'multiplier': multiplier,
      'triggers': triggers.map((t) => t.toJson()).toList(),
      'resistencia': resistencia,
      'resistenciaAtual': resistenciaAtual,
      // NOVO
      'attributeScaling': attributeScaling,
      'pointsPerDie': pointsPerDie,
      'criticalMultiplier': criticalMultiplier,
      'criticalThreshold': criticalThreshold,
      'damageTypes': damageTypes,
      'damageTypePercentages': damageTypePercentages,
      'hitModifierPercent': hitModifierPercent,
      // FIM NOVO
      'type': 'Weapon', // Sobrescreve o tipo
    });
    return json;
  }

  factory Weapon.fromJson(Map<String, dynamic> json) {
     // Tratamento para damageTypePercentages que podem ser int
    List<double> percentages = [];
    if (json['damageTypePercentages'] is List) {
      percentages = (json['damageTypePercentages'] as List)
          .map((p) => (p is num) ? p.toDouble() : 0.0) // Converte num para double
          .toList();
    }


    return Weapon(
      id: json['id'],
      name: json['name'],
      description: json['description'] ?? '',
      imagePath: json['imagePath'],
      effects: (json['effects'] as List?)
              ?.map((e) => ItemEffect.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      isEquipped: json['isEquipped'] ?? false,
      dice: (json['dice'] as List?) // Permite lista nula ou vazia
              ?.map((i) => DieSpecification.fromJson(i as Map<String, dynamic>))
              .toList() ??
          const [], // Valor padrão
      modifier: json['modifier'] ?? 0,
      multiplier: (json['multiplier'] as num?)?.toDouble() ?? 1.0,
      triggers: (json['triggers'] as List?)
              ?.map((c) => ConditionalEffect.fromJson(c as Map<String, dynamic>))
              .toList() ??
          [],
      resistencia: json['resistencia'] ?? 100,
      resistenciaAtual: json['resistenciaAtual'],
      // NOVO
      attributeScaling: json['attributeScaling'] ?? 'Força',
      pointsPerDie: json['pointsPerDie'] ?? 5,
      criticalMultiplier: (json['criticalMultiplier'] as num?)?.toDouble() ?? 1.2,
      criticalThreshold: json['criticalThreshold'] ?? 91,
      damageTypes: List<String>.from(json['damageTypes'] ?? ['Impacto']),
      damageTypePercentages: percentages.isNotEmpty ? percentages : [1.0], // Usa a lista tratada
      hitModifierPercent: (json['hitModifierPercent'] as num?)?.toDouble() ?? 0.0,
      // FIM NOVO
    );
  }
}
