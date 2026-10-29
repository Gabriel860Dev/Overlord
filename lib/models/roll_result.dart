// lib/models/roll_result.dart

import 'package:overlord/models/die_specification.dart';
import 'package:overlord/models/passive_bonuses.dart';

class RollResult {
  final int total;
  final String details;
  final List<DieSpecification> individualRolls;
  final int modifier;
  final double multiplier;
  final int preMultipliedTotal;
  final int? incomingDamage;
  final int? mitigationResult;
  final List<BonusSource> bonusSources; // Adicionado para guardar o detalhamento

  RollResult({
    required this.total,
    required this.details,
    required this.individualRolls,
    this.modifier = 0,
    this.multiplier = 1.0,
    this.preMultipliedTotal = 0,
    this.incomingDamage,
    this.mitigationResult,
    this.bonusSources = const [], // Adicionado ao construtor
  });
}