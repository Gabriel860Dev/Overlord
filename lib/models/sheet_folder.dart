// lib/models/sheet_folder.dart

import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

class SheetFolder {
  final String id;
  String name;
  String? imagePath;

  SheetFolder({String? id, required this.name, this.imagePath}) : id = id ?? const Uuid().v4();

  Map<String, dynamic> toJson() => {'id': id, 'name': name, 'imagePath': imagePath};
  
  factory SheetFolder.fromJson(Map<String, dynamic> json) => SheetFolder(
    id: json['id'], name: json['name'], imagePath: json['imagePath']
  );
}

class SheetFolderManager {
  static const String _key = 'character_sheet_folders_v1';
  
  static Future<List<SheetFolder>> load() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString(_key);
    if (data == null) return [];
    try {
      return (jsonDecode(data) as List).map((e) => SheetFolder.fromJson(e)).toList();
    } catch (e) { return []; }
  }
  
  static Future<void> save(List<SheetFolder> folders) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, jsonEncode(folders.map((e) => e.toJson()).toList()));
  }
}