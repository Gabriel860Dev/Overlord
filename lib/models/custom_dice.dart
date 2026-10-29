// lib/models/custom_dice.dart

import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class DiceConfig {
  final int sides;
  String? name;
  String? imagePath;      // Imagem personalizada do dado
  String? critImagePath;  // GIF ou Imagem que pisca no crítico
  String? critAudioPath;  // Áudio de crítico (para futura implementação)

  DiceConfig({
    required this.sides,
    this.name,
    this.imagePath,
    this.critImagePath,
    this.critAudioPath,
  });

  Map<String, dynamic> toJson() => {
    'sides': sides,
    'name': name,
    'imagePath': imagePath,
    'critImagePath': critImagePath,
    'critAudioPath': critAudioPath,
  };

  factory DiceConfig.fromJson(Map<String, dynamic> json) => DiceConfig(
    sides: json['sides'],
    name: json['name'],
    imagePath: json['imagePath'],
    critImagePath: json['critImagePath'],
    critAudioPath: json['critAudioPath'],
  );
}

class DiceConfigManager {
  static const String _key = 'dice_configs';

  static Future<void> saveConfig(DiceConfig config) async {
    final prefs = await SharedPreferences.getInstance();
    final configs = await loadConfigs();
    configs[config.sides] = config;

    final String jsonStr = jsonEncode(configs.map((key, value) => MapEntry(key.toString(), value.toJson())));
    await prefs.setString(_key, jsonStr);
  }

  static Future<Map<int, DiceConfig>> loadConfigs() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString(_key);
    if (jsonStr == null) return {};

    final Map<String, dynamic> decoded = jsonDecode(jsonStr);
    return decoded.map((key, value) => MapEntry(int.parse(key), DiceConfig.fromJson(value)));
  }

  static Future<void> deleteConfig(int sides) async {
    final prefs = await SharedPreferences.getInstance();
    final configs = await loadConfigs();
    configs.remove(sides);
    
    final String jsonStr = jsonEncode(configs.map((key, value) => MapEntry(key.toString(), value.toJson())));
    await prefs.setString(_key, jsonStr);
  }
}