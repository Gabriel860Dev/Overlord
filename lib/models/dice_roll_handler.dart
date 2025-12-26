// lib/models/dice_roll_handler.dart

import 'package:dark_age/models/ability.dart';
import 'package:dark_age/models/die_specification.dart';
import 'package:dark_age/models/passive_bonuses.dart';
import 'package:dark_age/models/roll_result.dart';

/// Define a assinatura padrão para funções que realizam rolagens de dados.
typedef DiceRollHandler = RollResult Function(
  String description, // Nome da rolagem (ex: "Ataque Espada", "Atletismo")
  List<DieSpecification> dice, { // Lista de dados a serem rolados
  int modifier, // Modificador adicional (de itens, buffs, etc.)
  double multiplier, // Multiplicador final do resultado
  String extraDescription, // Texto adicional para exibir no popup/histórico
  int? defenseTarget, // Valor a ser subtraído (para rolagens de Defesa/Bloqueio)
  List<ConditionalEffect> triggers, // Efeitos condicionais (ex: crítico)
  List<BonusSource> bonusSources, // Detalhamento da origem dos bônus
  int fixedBonus, // Bônus fixo de Maestria/Proficiência (Sistema Dark Age)
});
