// lib/data/saved_rolls_manager.dart
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/saved_roll.dart';

class SavedRollsManager {
  static const String _storageKey = 'overlord_saved_rolls';

  // Salva uma nova rolagem na memória
  static Future<void> saveRoll(SavedRoll roll) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> savedRollsJson = prefs.getStringList(_storageKey) ?? [];
    
    savedRollsJson.add(jsonEncode(roll.toJson()));
    await prefs.setStringList(_storageKey, savedRollsJson);
  }

  // Carrega todas as rolagens salvas
  static Future<List<SavedRoll>> loadSavedRolls() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> savedRollsJson = prefs.getStringList(_storageKey) ?? [];
    
    return savedRollsJson.map((json) => SavedRoll.fromJson(jsonDecode(json))).toList();
  }

  // Apaga uma rolagem do mural
  static Future<void> deleteRoll(String id) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> savedRollsJson = prefs.getStringList(_storageKey) ?? [];
    
    List<SavedRoll> rolls = savedRollsJson.map((json) => SavedRoll.fromJson(jsonDecode(json))).toList();
    rolls.removeWhere((r) => r.id == id);
    
    List<String> updatedJson = rolls.map((r) => jsonEncode(r.toJson())).toList();
    await prefs.setStringList(_storageKey, updatedJson);
  }

  // NOVO: Atualiza o nome de uma rolagem existente
  static Future<void> updateRoll(SavedRoll updatedRoll) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> savedRollsJson = prefs.getStringList(_storageKey) ?? [];
    List<SavedRoll> rolls = savedRollsJson.map((json) => SavedRoll.fromJson(jsonDecode(json))).toList();
    
    // Procura a rolagem antiga pelo ID e substitui pela versão com o nome novo
    int index = rolls.indexWhere((r) => r.id == updatedRoll.id);
    if (index != -1) {
      rolls[index] = updatedRoll;
      List<String> updatedJson = rolls.map((r) => jsonEncode(r.toJson())).toList();
      await prefs.setStringList(_storageKey, updatedJson);
    }
  }
}