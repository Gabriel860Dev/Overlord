// lib/models/status_effect.dart
import 'package:uuid/uuid.dart';

class StatusEffect {
  final String id;
  final String name;
  final String description;
  int durationInRounds; // -1 para permanente até o fim do combate.
  final String? imagePath;
  final List<String> targets;
  final String bonusType;
  final double value;

  StatusEffect({
    String? id,
    required this.name,
    this.description = '',
    this.durationInRounds = -1,
    this.imagePath,
    this.targets = const [],
    this.bonusType = 'Modificador',
    this.value = 0,
  }) : id = id ?? const Uuid().v4();

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'description': description,
        'durationInRounds': durationInRounds,
        'imagePath': imagePath,
        'targets': targets,
        'bonusType': bonusType,
        'value': value,
      };

  factory StatusEffect.fromJson(Map<String, dynamic> json) => StatusEffect(
        id: json['id'],
        name: json['name'],
        description: json['description'] ?? '',
        durationInRounds: json['durationInRounds'] ?? -1,
        imagePath: json['imagePath'],
        targets: List<String>.from(json['targets'] ?? []),
        bonusType: json['bonusType'] ?? 'Modificador',
        value: (json['value'] as num?)?.toDouble() ?? 0,
      );
}