// lib/models/passive_bonuses.dart

// Uma classe para guardar a fonte de um bônus para exibição no histórico.
class BonusSource {
  final String sourceName;
  final String value;
  final String type;

  BonusSource({required this.sourceName, required this.value, required this.type});
}

class PassiveBonuses {
  final int modifier;
  final double multiplier;
  final int bonusPoints;
  final List<BonusSource> sources; // Lista para rastrear a origem dos bônus

  PassiveBonuses({
    required this.modifier,
    required this.multiplier,
    required this.bonusPoints,
    required this.sources,
  });
}