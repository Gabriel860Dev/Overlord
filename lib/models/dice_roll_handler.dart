// lib/models/dice_roll_handler.dart

import 'package:overlord/models/die_specification.dart';
import 'package:overlord/models/passive_bonuses.dart';
import 'package:overlord/models/roll_result.dart';
import 'package:overlord/models/weapon.dart';

// Este typedef garante que a função de rolagem de dados tenha sempre a mesma assinatura.
// ATUALIZADO: Adicionado o parâmetro 'bonusSources'.
typedef DiceRollHandler = RollResult Function(
  String description,
  List<DieSpecification> dice, {
  int modifier,
  double multiplier,
  String extraDescription,
  int? defenseTarget,
  List<ConditionalEffect> triggers,
  List<BonusSource> bonusSources,
});