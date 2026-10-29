// lib/Réquiem/requiem_character_sheet.dart

import 'package:overlord/Réquiem/requiem_races_db.dart';
import 'package:overlord/Réquiem/requiem_classes_db.dart';
import 'package:overlord/Réquiem/requiem_weapon.dart'; // NOVO: Import das armas
import 'package:uuid/uuid.dart';

class RequiemCharacterSheet {
  final String id;
  String name;
  int level;
  String raceName;
  String className;
  
  // --- PONTOS DE NÍVEL ---
  Map<String, int> baseAttributes;
  Map<String, int> baseSkills;
  
  // --- PONTOS À PARTE (TREINOS) ---
  Map<String, int> extraAttributes;
  Map<String, int> extraSkills;
  
  // Status Extras Manuais (Ganhos por Treinos)
  int extraMaxHp;
  int extraMaxMana; 
  int extraMaxStamina;
  int extraMaxSanity;

  // Escolhas de Raça (Bônus flutuantes)
  Map<String, int> raceChosenAttributes; 
  
  // Status Atuais (Controle durante o combate)
  int currentHp;
  int currentMana; 
  int currentStamina;
  int currentSanity;

  String systemType;

  // ==========================================
  // INVENTÁRIO E COMBATE (NOVO)
  // ==========================================
  List<RequiemWeapon> weapons; // A lista oficial de armas equipadas da ficha

  RequiemCharacterSheet({
    String? id,
    required this.name,
    this.level = 1,
    this.raceName = 'Humano',
    this.className = 'Sem Classe',
    Map<String, int>? baseAttributes,
    Map<String, int>? extraAttributes,
    Map<String, int>? baseSkills,
    Map<String, int>? extraSkills,
    this.raceChosenAttributes = const {},
    this.extraMaxHp = 0,
    this.extraMaxMana = 0,
    this.extraMaxStamina = 0,
    this.extraMaxSanity = 0,
    this.currentHp = 0,
    this.currentMana = 0,
    this.currentStamina = 0,
    this.currentSanity = 30, 
    this.systemType = 'Requiem',
    List<RequiemWeapon>? weapons, // Aceita as armas ao criar a ficha
  }) : 
    id = id ?? const Uuid().v4(),
    baseAttributes = baseAttributes ?? _initAttributes(),
    extraAttributes = extraAttributes ?? _initAttributes(),
    baseSkills = baseSkills ?? _initSkills(),
    extraSkills = extraSkills ?? _initSkills(),
    weapons = weapons ?? []; // Inicia a lista vazia se não vier nenhuma

  static Map<String, int> _initAttributes() {
    return {
      'Força': 0, 'Destreza': 0, 'Constituição': 0, 
      'Intelecto': 0, 'Arcanismo': 0, 'Sabedoria': 0, 'Carisma': 0
    };
  }

  static Map<String, int> _initSkills() {
    return {
      'Luta': 0, 'Sobrevivência': 0, 'Sorte': 0, 'Percepção': 0,
      'Atuação': 0, 'Reflexo': 0, 'Enganação': 0, 'Vontade': 0, 
      'Intuição': 0, 'Montaria': 0, 'Acrobacia': 0, 'Pontaria': 0,
      'Iniciativa': 0, 'Diplomacia': 0, 'Investigação': 0, 
      'Primeiros socorros': 0, 'Adestramento': 0, 'Tático': 0,
      'Apresentação': 0, 'Intimidação': 0
    };
  }

  // ==========================================
  // MATEMÁTICA E SCALLING (V 0.46)
  // ==========================================

  Map<String, int> get totalAttributes {
    final totals = _initAttributes();
    
    // 1. Base (Nível) + Extras (Treino à parte)
    for (var key in totals.keys) {
      totals[key] = (baseAttributes[key] ?? 0) + (extraAttributes[key] ?? 0);
    }

    // 2. Soma atributos fixos da Raça
    final race = RequiemRacesDB.getRaceByName(raceName);
    if (race != null) {
      for (var entry in race.attributeBonuses.entries) {
        totals[entry.key] = (totals[entry.key] ?? 0) + entry.value;
      }
    }
    
    // 3. Soma atributos flutuantes da Raça
    for (var entry in raceChosenAttributes.entries) {
      totals[entry.key] = (totals[entry.key] ?? 0) + entry.value;
    }
    
    return totals;
  }

  Map<String, int> get totalSkills {
    final totals = _initSkills();
    
    // 1. Base (Nível) + Extras (Treino à parte)
    for (var key in totals.keys) {
      totals[key] = (baseSkills[key] ?? 0) + (extraSkills[key] ?? 0);
    }

    final attrs = totalAttributes;
    
    // 2. Escalonamento: A cada 5 pts de atributo = +2 nas perícias
    int conBonus = ((attrs['Constituição'] ?? 0) ~/ 5) * 2;
    int desBonus = ((attrs['Destreza'] ?? 0) ~/ 5) * 2;
    int intBonus = ((attrs['Intelecto'] ?? 0) ~/ 5) * 2;
    int carBonus = ((attrs['Carisma'] ?? 0) ~/ 5) * 2;
    int sabBonus = ((attrs['Sabedoria'] ?? 0) ~/ 5) * 2;
    int arcBonus = ((attrs['Arcanismo'] ?? 0) ~/ 5) * 2;

    totals['Vontade'] = (totals['Vontade'] ?? 0) + conBonus;
    totals['Montaria'] = (totals['Montaria'] ?? 0) + conBonus;

    for (var p in ['Reflexo', 'Luta', 'Acrobacia', 'Pontaria', 'Iniciativa']) { totals[p] = (totals[p] ?? 0) + desBonus; }
    for (var p in ['Diplomacia', 'Investigação', 'Primeiros socorros', 'Adestramento', 'Tático']) { totals[p] = (totals[p] ?? 0) + intBonus; }
    for (var p in ['Atuação', 'Apresentação', 'Enganação', 'Intimidação']) { totals[p] = (totals[p] ?? 0) + carBonus; }
    for (var p in ['Intuição', 'Percepção', 'Sobrevivência']) { totals[p] = (totals[p] ?? 0) + sabBonus; }

    totals['Sorte'] = (totals['Sorte'] ?? 0) + arcBonus;

    // 3. Soma Perícias Fixas da Raça
    final race = RequiemRacesDB.getRaceByName(raceName);
    if (race != null) {
      for (var entry in race.skillBonuses.entries) {
        totals[entry.key] = (totals[entry.key] ?? 0) + entry.value;
      }
    }
    
    if (raceName == 'Kenku') totals['Enganação'] = (totals['Enganação'] ?? 0) + 10;

    return totals;
  }

  // --- SCALING DINÂMICO DE STATUS ---

  int get maxHp {
    final playerClass = RequiemClassesDB.getClassByName(className);
    int base = playerClass?.baseHp ?? 0;
    int levelScaling = (playerClass?.hpPerLevel ?? 0) * level;
    int conScaling = (totalAttributes['Constituição'] ?? 0) * 5; 
    
    int total = base + levelScaling + conScaling + extraMaxHp; 
    
    if (raceName == 'Homem-Fera (Boaz)') total += (level * 10);
    return total;
  }

  int get maxResource {
    final playerClass = RequiemClassesDB.getClassByName(className);
    int base = playerClass?.baseResource ?? 0;
    int levelScaling = (playerClass?.resourcePerLevel ?? 0) * level;
    
    int attrScaling = 0;
    if (playerClass?.resourceType == 'Vigor') {
      attrScaling = (totalAttributes['Sabedoria'] ?? 0) * 5; 
    } else if (playerClass?.resourceType == 'Mana') {
      attrScaling = (totalAttributes['Arcanismo'] ?? 0) * 5; 
    }

    return base + levelScaling + attrScaling + extraMaxMana; 
  }

  int get maxStamina {
    final playerClass = RequiemClassesDB.getClassByName(className);
    int base = playerClass?.baseStamina ?? 0;
    int levelScaling = (playerClass?.staminaPerLevel ?? 0) * level;
    int desScaling = (totalAttributes['Destreza'] ?? 0) * 5; 

    return base + levelScaling + desScaling + extraMaxStamina; 
  }

  int get maxSanity {
    return 30 + extraMaxSanity; 
  }

  // --- PASSIVAS E EXTRAS ---

  int get strengthDamageDiceBonus {
    int str = totalAttributes['Força'] ?? 0;
    if (str >= 30) return 4;
    if (str >= 20) return 3;
    if (str >= 10) return 2;
    if (str >= 5) return 1;
    return 0; 
  }

  String get felinoClawDamage {
    if (raceName != 'Homem-Fera (Felino)') return 'N/A';
    int des = totalAttributes['Destreza'] ?? 0;
    int bonusD6 = des ~/ 5; 
    int totalD6 = 2 + bonusD6;
    return '${totalD6}d6+2';
  }

  int get dryadHealAmount {
    if (raceName != 'Dríade') return 0;
    if (level <= 2) return 30;
    if (level <= 4) return 45;
    if (level <= 6) return 60;
    int niveisExtras = level - 6;
    return 60 + ((niveisExtras ~/ 2) * 15);
  }
}