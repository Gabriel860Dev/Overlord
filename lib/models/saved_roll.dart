// lib/models/saved_roll.dart
import 'package:uuid/uuid.dart';

class SavedRoll {
  final String id;
  String customName;       // REMOVIDO O 'final' AQUI PARA PERMITIR EDIÇÃO
  final String rollName;
  final int total;
  final String details;
  final DateTime timestamp;

  SavedRoll({
    String? id,
    required this.customName,
    required this.rollName,
    required this.total,
    required this.details,
    required this.timestamp,
  }) : id = id ?? const Uuid().v4();

  Map<String, dynamic> toJson() => {
    'id': id,
    'customName': customName,
    'rollName': rollName,
    'total': total,
    'details': details,
    'timestamp': timestamp.toIso8601String(),
  };

  factory SavedRoll.fromJson(Map<String, dynamic> json) => SavedRoll(
    id: json['id'],
    customName: json['customName'],
    rollName: json['rollName'],
    total: json['total'],
    details: json['details'],
    timestamp: DateTime.parse(json['timestamp']),
  );
}