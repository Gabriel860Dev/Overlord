// lib/models/armor.dart

import 'package:overlord/models/item.dart';
import 'package:uuid/uuid.dart';

class Armor extends Item {
  final Map<String, double> resistances; // Redução percentual (Ex: {'Fogo': 0.5} para 50%)

  // Sistema de Redução e Durabilidade (Hits)
  final int reductionValue;        // Valor fixo reduzido do dano a cada hit (ex: 5)
  final int maxHits;               // Durabilidade (ex: aguenta 3 ataques)
  int currentHits;                 // Durabilidade atual
  final List<String> reductionTypes; // Tipos de dano que esta redução afeta

  Armor({
    String? id,
    required super.name,
    super.description,
    super.imagePath,
    super.effects,
    super.isEquipped,
    Map<String, double>? resistances,
    this.reductionValue = 0,
    this.maxHits = 0,
    int? currentHits,
    this.reductionTypes = const [],
  })  : resistances = resistances ?? {},
        currentHits = currentHits ?? maxHits,
        super(
          id: id ?? const Uuid().v4(),
        );

  @override
  Map<String, dynamic> toJson() {
    final json = super.toJson();
    json.addAll({
      'resistances': resistances,
      'reductionValue': reductionValue,
      'maxHits': maxHits,
      'currentHits': currentHits,
      'reductionTypes': reductionTypes,
      'type': 'Armor', 
    });
    return json;
  }

  factory Armor.fromJson(Map<String, dynamic> json) {
    return Armor(
      id: json['id'],
      name: json['name'],
      description: json['description'] ?? '',
      imagePath: json['imagePath'],
      effects: (json['effects'] as List?)
              ?.map((e) => ItemEffect.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      isEquipped: json['isEquipped'] ?? false,
      resistances: Map<String, double>.from(json['resistances'] ?? {}),
      reductionValue: json['reductionValue'] ?? 0,
      maxHits: json['maxHits'] ?? 0,
      currentHits: json['currentHits'], // Se nulo, usará maxHits
      reductionTypes: List<String>.from(json['reductionTypes'] ?? []),
    );
  }
}