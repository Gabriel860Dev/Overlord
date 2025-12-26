// lib/models/armor.dart

import 'package:dark_age/models/item.dart';
import 'package:uuid/uuid.dart';

class Armor extends Item {
  final int defenseValue;
  int currentDefenseValue;
  final Map<String, double> resistances; // Ex: {'Fogo': 0.5, 'Gelo': 1.5} (50% de resistência, 50% de vulnerabilidade)

  Armor({
    String? id,
    required super.name,
    super.description,
    super.imagePath,
    super.effects,
    super.isEquipped,
    this.defenseValue = 0,
    int? currentDefenseValue,
    Map<String, double>? resistances,
  })  : currentDefenseValue = currentDefenseValue ?? defenseValue,
        resistances = resistances ?? {},
        super(
          id: id ?? const Uuid().v4(),
        );

  @override
  Map<String, dynamic> toJson() {
    final json = super.toJson();
    json.addAll({
      'defenseValue': defenseValue,
      'currentDefenseValue': currentDefenseValue,
      'resistances': resistances,
      'type': 'Armor', // Adiciona o tipo para a deserialização correta
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
      defenseValue: json['defenseValue'] ?? 0,
      // CORREÇÃO 4: Garante que o valor atual seja carregado corretamente.
      currentDefenseValue: json['currentDefenseValue'] ?? json['defenseValue'] ?? 0,
      resistances: Map<String, double>.from(json['resistances'] ?? {}),
    );
  }
}