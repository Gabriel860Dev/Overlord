// lib/models/requiem_class.dart

class RequiemClass {
  final String name;
  final String description;
  
  // Vida (PV)
  final int baseHp;
  final int hpPerLevel;
  
  // Recurso Principal (Mana, Vigor ou Nenhum)
  final String resourceType; 
  final int baseResource;
  final int resourcePerLevel;
  
  // Estamina (Usada para habilidades de esforço/reação)
  final int baseStamina;
  final int staminaPerLevel; 

  // Habilidades e Passivas da Classe
  final List<String> passives;
  final List<String> initialAbilities;

  const RequiemClass({
    required this.name,
    required this.description,
    required this.baseHp,
    required this.hpPerLevel,
    required this.resourceType,
    required this.baseResource,
    required this.resourcePerLevel,
    this.baseStamina = 0,
    this.staminaPerLevel = 0,
    this.passives = const [],
    this.initialAbilities = const [],
  });
}