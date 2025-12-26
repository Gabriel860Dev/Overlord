// lib/models/roll_result.dart

import 'package:dark_age/models/die_specification.dart';
import 'package:dark_age/models/passive_bonuses.dart';

class RollResult {
  final int total;
  final String details;
  final List<DieSpecification> individualRolls;
  final int modifier; // Modificador total (inclui fixo + outros)
  final double multiplier;
  final int preMultipliedTotal;
  final int? incomingDamage;
  final int? mitigationResult;
  final List<BonusSource> bonusSources;
  final int fixedBonus; // NOVO: Guarda o bônus fixo de Mestre/Proficiência separadamente

  RollResult({
    required this.total,
    required this.details,
    required this.individualRolls,
    this.modifier = 0,
    this.multiplier = 1.0,
    this.preMultipliedTotal = 0,
    this.incomingDamage,
    this.mitigationResult,
    this.bonusSources = const [],
    this.fixedBonus = 0, // Adicionado ao construtor
  });
}
