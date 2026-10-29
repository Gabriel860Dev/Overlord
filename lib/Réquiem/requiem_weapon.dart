// lib/Réquiem/requiem_weapon.dart

import 'package:uuid/uuid.dart';

class RequiemWeapon {
  String id;
  String name;
  String description; // NOVO: Descrição customizada da arma
  String? imagePath;   // NOVO: Caminho da imagem da arma no dispositivo

  // --- BASE DA ARMA ---
  int baseDiceCount; 
  int diceSides;     
  int bonusPerDie;   
  int extraFlatBonus; 

  // --- SCALING (FORÇA, DESTREZA, PUNHO...) ---
  String scalingAttribute; 

  // --- MAESTRIA E CRÍTICO ---
  int masteryPercentage; 
  int criticalMargin;    

  // --- ELEMENTOS ---
  String? elementName; 
  int elementPercentage; 

  // --- GATILHOS DE EFEITO (MECÂNICA NOVO) ---
  bool hasTrigger;             // Se a arma possui um gatilho ativo
  int triggerDiceSides;        // Qual dado rolar no gatilho (padrão: 20 para 1d20)
  int triggerTargetValue;      // Valor alvo para ativar (ex: 15)
  String triggerEffectType;    // 'Flat' (Dano Fixo) ou 'Percent' (Dano por %)
  int triggerEffectValue;      // Quantidade do bônus (ex: 10 para +10 ou 25 para +25%)
  String triggerDescription;   // Descrição em texto do que o gatilho faz

  RequiemWeapon({
    String? id,
    required this.name,
    this.description = '',
    this.imagePath,
    this.baseDiceCount = 1,
    this.diceSides = 6,
    this.bonusPerDie = 0,
    this.extraFlatBonus = 0,
    this.scalingAttribute = 'Força',
    this.masteryPercentage = 0,
    this.criticalMargin = 20,
    this.elementName,
    this.elementPercentage = 0,
    this.hasTrigger = false,
    this.triggerDiceSides = 20,
    this.triggerTargetValue = 15,
    this.triggerEffectType = 'Flat',
    this.triggerEffectValue = 0,
    this.triggerDescription = '',
  }) : id = id ?? const Uuid().v4();

  // ==========================================
  // SERIALIZAÇÃO PARA O BANCO DE DADOS (JSON)
  // ==========================================
  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'description': description,
    'imagePath': imagePath,
    'baseDiceCount': baseDiceCount,
    'diceSides': diceSides,
    'bonusPerDie': bonusPerDie,
    'extraFlatBonus': extraFlatBonus,
    'scalingAttribute': scalingAttribute,
    'masteryPercentage': masteryPercentage,
    'criticalMargin': criticalMargin,
    'elementName': elementName,
    'elementPercentage': elementPercentage,
    'hasTrigger': hasTrigger,
    'triggerDiceSides': triggerDiceSides,
    'triggerTargetValue': triggerTargetValue,
    'triggerEffectType': triggerEffectType,
    'triggerEffectValue': triggerEffectValue,
    'triggerDescription': triggerDescription,
  };

  factory RequiemWeapon.fromJson(Map<String, dynamic> json) => RequiemWeapon(
    id: json['id'],
    name: json['name'] ?? 'Arma Desconhecida',
    description: json['description'] ?? '',
    imagePath: json['imagePath'],
    baseDiceCount: json['baseDiceCount'] ?? 1,
    diceSides: json['diceSides'] ?? 6,
    bonusPerDie: json['bonusPerDie'] ?? 0,
    extraFlatBonus: json['extraFlatBonus'] ?? 0,
    scalingAttribute: json['scalingAttribute'] ?? 'Força',
    masteryPercentage: json['masteryPercentage'] ?? 0,
    criticalMargin: json['criticalMargin'] ?? 20,
    elementName: json['elementName'],
    elementPercentage: json['elementPercentage'] ?? 0,
    hasTrigger: json['hasTrigger'] ?? false,
    triggerDiceSides: json['triggerDiceSides'] ?? 20,
    triggerTargetValue: json['triggerTargetValue'] ?? 15,
    triggerEffectType: json['triggerEffectType'] ?? 'Flat',
    triggerEffectValue: json['triggerEffectValue'] ?? 0,
    triggerDescription: json['triggerDescription'] ?? '',
  );

  // ==========================================
  // INTELIGÊNCIA MATEMÁTICA
  // ==========================================
  
  int calculateTotalDice(Map<String, int> totalAttributes) {
    int extraDice = 0;
    if (scalingAttribute == 'Punho') {
      int forca = totalAttributes['Força'] ?? 0;
      int con = totalAttributes['Constituição'] ?? 0;
      extraDice = (forca ~/ 5) + (con ~/ 5);
    } else {
      int attrValue = totalAttributes[scalingAttribute] ?? 0;
      if (attrValue >= 30) extraDice = 4;
      else if (attrValue >= 20) extraDice = 3;
      else if (attrValue >= 10) extraDice = 2;
      else if (attrValue >= 5) extraDice = 1;
    }
    return baseDiceCount + extraDice;
  }

  int calculateTotalBonus(int totalDice) {
    return (totalDice * bonusPerDie) + extraFlatBonus;
  }

  String getDamageFormula(Map<String, int> totalAttributes) {
    int d = calculateTotalDice(totalAttributes);
    int b = calculateTotalBonus(d);
    
    if (b > 0) return "${d}d$diceSides+$b";
    if (b < 0) return "${d}d$diceSides$b";
    return "${d}d$diceSides";
  }

  String getCriticalDescription() {
    int critDamageBonus = masteryPercentage >= 50 ? 50 : 25;
    return "Margem Crítica: >= $criticalMargin\n(Aplica +$critDamageBonus% de Dano Físico)";
  }

  String getExtraEffectsDescription() {
    List<String> effects = [];
    if (masteryPercentage > 0) {
      effects.add("$masteryPercentage% de dano a mais de maestria");
    }
    if (elementPercentage > 0 && elementName != null && elementName!.isNotEmpty) {
      effects.add("$elementPercentage% de dano a mais de $elementName");
    }
    // NOVO: Adiciona o texto do gatilho ao card informativo
    if (hasTrigger && triggerDescription.isNotEmpty) {
      effects.add("Gatilho: $triggerDescription");
    }
    
    if (effects.isEmpty) return "Nenhum efeito passivo.";
    return effects.join("\n");
  }
}