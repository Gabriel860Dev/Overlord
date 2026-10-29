// lib/models/item.dart

import 'package:uuid/uuid.dart';
import 'package:overlord/models/weapon.dart';
import 'package:overlord/models/armor.dart';

class ItemEffect {
  final List<String> targets; 
  final String bonusType;
  final double value;
  final String? bonusDamageType; 
  final double perRoundValue; 

  ItemEffect({
    required this.targets,
    required this.bonusType,
    required this.value,
    this.bonusDamageType,
    this.perRoundValue = 0,
  });

  Map<String, dynamic> toJson() => {
        'targets': targets,
        'bonusType': bonusType,
        'value': value,
        'bonusDamageType': bonusDamageType,
        'perRoundValue': perRoundValue,
      };

  factory ItemEffect.fromJson(Map<String, dynamic> json) {
    List<String> loadedTargets = [];
    if (json['targets'] is List) {
      loadedTargets = List<String>.from(json['targets']);
    } else if (json['target'] is String) {
      loadedTargets.add(json['target']);
    }

    return ItemEffect(
      targets: loadedTargets,
      bonusType: json['bonusType'],
      value: (json['value'] as num?)?.toDouble() ?? 0,
      bonusDamageType: json['bonusDamageType'],
      perRoundValue: (json['perRoundValue'] as num?)?.toDouble() ?? 0,
    );
  }
}

class Item {
  final String id;
  final String name;
  final String description;
  String? imagePath;
  final List<ItemEffect> effects;
  bool isEquipped;

  Item({
    String? id,
    required this.name,
    this.description = '',
    this.imagePath,
    this.effects = const [],
    this.isEquipped = false,
  }) : id = id ?? const Uuid().v4();

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'description': description,
        'imagePath': imagePath,
        'effects': effects.map((e) => e.toJson()).toList(),
        'isEquipped': isEquipped,
        'type': 'Item',
      };

  factory Item.fromJson(Map<String, dynamic> json) {
    // Fábrica inteligente: Verifica o tipo e retorna a subclasse correta
    if (json['type'] == 'Weapon') {
      return Weapon.fromJson(json);
    }
    if (json['type'] == 'Armor') {
      return Armor.fromJson(json);
    }

    return Item(
      id: json['id'],
      name: json['name'],
      description: json['description'] ?? '',
      imagePath: json['imagePath'],
      effects: (json['effects'] as List?)
              ?.map((e) => ItemEffect.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      isEquipped: json['isEquipped'] ?? false,
    );
  }
}