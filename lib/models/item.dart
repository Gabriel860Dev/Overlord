// lib/models/item.dart

import 'package:uuid/uuid.dart';

class ItemEffect {
  final List<String> targets;
  final String bonusType;
  final double value;

  ItemEffect({
    required this.targets,
    required this.bonusType,
    required this.value,
  });

  Map<String, dynamic> toJson() => {
        'targets': targets,
        'bonusType': bonusType,
        'value': value,
      };

  factory ItemEffect.fromJson(Map<String, dynamic> json) {
    List<String> loadedTargets = [];
    if (json['targets'] is List) {
      loadedTargets = List<String>.from(json['targets']);
    } else if (json['target'] is String) {
      // Compatibilidade com o formato antigo que usava 'target'
      loadedTargets.add(json['target']);
    }

    return ItemEffect(
      targets: loadedTargets,
      bonusType: json['bonusType'],
      value: (json['value'] as num?)?.toDouble() ?? 0,
    );
  }
}

class Item {
  final String id;
  final String name;
  final String description;
  final String? imagePath;
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
        'type': 'Item', // Adiciona o tipo para a deserialização correta
      };

  factory Item.fromJson(Map<String, dynamic> json) => Item(
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
