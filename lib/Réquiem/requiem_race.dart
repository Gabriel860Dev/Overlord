// lib/models/requiem_race.dart

class RequiemRace {
  final String name;
  final String description;
  final Map<String, int> attributeBonuses; 
  final Map<String, int> skillBonuses;     
  final List<String> specialTraits;       

  const RequiemRace({
    required this.name,
    required this.description,
    this.attributeBonuses = const {},
    this.skillBonuses = const {},
    this.specialTraits = const [],
  });
}