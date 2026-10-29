// lib/models/status_effect.dart
import 'package:uuid/uuid.dart';

enum EffectTrigger {
  instant,      // Acontece na hora (Dano, Cura imediata)
  passive,      // Sempre ativo (Buff de atributo, Armadura passiva)
  onHit,        // Ao acertar um ataque (Debuff no inimigo)
  onTurnStart,  // No inicio do turno (Regeneração, Dano contínuo)
  onTurnEnd,    // No fim do turno
}

enum EffectType {
  statChange,   // Altera Força, Agilidade, etc.
  armor,        // Concede/Reduz Armadura
  stun,         // Atordoamento
  damageOverTime, // Sangramento, Veneno
  healOverTime,   // Regeneração
  custom,       // Outros
}

class StatusEffect {
  final String id;
  final String name;
  final String description;
  final String? imagePath;
  
  // Novos Campos Flexíveis
  final EffectType type;
  final EffectTrigger trigger;
  final String valueFormula; // Aceita "10", "1d4", "1d6+2"
  final String durationFormula; // Aceita "0" (Instant/Perm), "1d4" (Turnos)
  final String targetStat; // Qual atributo afeta (se for statChange)
  final bool isPercentage; // Se true, reduz/aumenta em %
  
  // NOVO: Origem do efeito (Passiva, Habilidade, Item, Especial)
  final String category; 
  
  // Mantidos para compatibilidade com lógica antiga se necessário
  final int durationInRounds; 
  final List<String> targets; 
  final String bonusType;
  final double value;
  final double perRoundValue;

  StatusEffect({
    String? id,
    required this.name,
    this.description = '',
    this.imagePath,
    this.type = EffectType.statChange,
    this.trigger = EffectTrigger.instant,
    this.valueFormula = '0',
    this.durationFormula = '0',
    this.targetStat = '',
    this.isPercentage = false,
    this.category = 'Especial', // Padrão seguro para efeitos antigos
    // Defaults legacy
    this.durationInRounds = -1,
    this.targets = const [],
    this.bonusType = 'Modificador',
    this.value = 0,
    this.perRoundValue = 0,
  }) : id = id ?? const Uuid().v4();

  Map<String, dynamic> toJson() => {
    'id': id, 'name': name, 'description': description, 'imagePath': imagePath,
    'type': type.index, 'trigger': trigger.index,
    'valueFormula': valueFormula, 'durationFormula': durationFormula,
    'targetStat': targetStat, 'isPercentage': isPercentage,
    'category': category, // Salvando a origem
    'durationInRounds': durationInRounds, 'targets': targets, 
    'bonusType': bonusType, 'value': value, 'perRoundValue': perRoundValue,
  };

  factory StatusEffect.fromJson(Map<String, dynamic> json) => StatusEffect(
    id: json['id'], name: json['name'], description: json['description'] ?? '', imagePath: json['imagePath'],
    type: EffectType.values[json['type'] ?? 0],
    trigger: EffectTrigger.values[json['trigger'] ?? 0],
    valueFormula: json['valueFormula']?.toString() ?? '0',
    durationFormula: json['durationFormula']?.toString() ?? '0',
    targetStat: json['targetStat'] ?? '',
    isPercentage: json['isPercentage'] ?? false,
    category: json['category'] ?? 'Especial', // Lendo a origem com fallback
    durationInRounds: json['durationInRounds'] ?? -1,
    targets: List<String>.from(json['targets'] ?? []),
    bonusType: json['bonusType'] ?? 'Modificador',
    value: (json['value'] as num?)?.toDouble() ?? 0,
    perRoundValue: (json['perRoundValue'] as num?)?.toDouble() ?? 0,
  );
}