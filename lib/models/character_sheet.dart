// lib/models/character_sheet.dart

import 'package:overlord/models/status_effect.dart';
import 'package:overlord/models/weapon.dart';
import 'package:overlord/models/ability.dart';
import 'package:overlord/models/passive.dart';
import 'package:overlord/models/item.dart';
import 'package:overlord/models/armor.dart';
import 'package:uuid/uuid.dart';

class CharacterSheet {
  final String id;
  final String name;
  final String? classe;
  final int? level;
  final List<Item> backpack;
  final String? abilitiesNotes;
  final Map<String, int?> attributes;
  final Map<String, int?> pericias;
  final List<Weapon> weapons;
  final List<Ability> abilities;
  final List<Ability> rituals; 
  final List<Passive> passives;
  final Map<String, Map<String, int?>> status;
  final List<StatusEffect> statusEffects;
  final int esforcoExtra;
  final String? imagePath;
  final int effortColor;
  final int hpPerLevel;
  final int effortPerLevel;
  final int sanityPerLevel;
  final String parryType;
  final int parryDiceCount;
  final List<Armor> armors;
  Armor? equippedArmor;
  final int blockConPercentage;
  final int blockForPercentage;
  final int blockSabPercentage;
  final int pontosAtributoPorNivel;
  final int pontosPericiaPorNivel;
  final int vidaPorCon;
  final int esforcoPorSab;
  final int esforcoPorDes;
  final List<String> elements;
  
  String? folderId; // ID da pasta a que a ficha pertence
  String systemType; // NOVO: Define qual é o sistema do RPG (Overlord ou Requiem)

  CharacterSheet({
    String? id,
    required this.name,
    this.classe,
    this.level,
    this.backpack = const [],
    this.abilitiesNotes,
    required this.attributes,
    required this.pericias,
    required this.weapons,
    required this.abilities,
    this.rituals = const [], 
    required this.passives,
    required this.status,
    this.statusEffects = const [],
    this.esforcoExtra = 0,
    this.imagePath,
    this.effortColor = 0xFFFFFF00,
    this.hpPerLevel = 0,
    this.effortPerLevel = 0,
    this.sanityPerLevel = 0,
    this.parryType = 'Comum',
    this.parryDiceCount = 4,
    this.armors = const [],
    this.equippedArmor,
    this.blockConPercentage = 100,
    this.blockForPercentage = 0,
    this.blockSabPercentage = 0,
    this.pontosAtributoPorNivel = 0,
    this.pontosPericiaPorNivel = 0,
    this.vidaPorCon = 0,
    this.esforcoPorSab = 0,
    this.esforcoPorDes = 0,
    this.elements = const [],
    this.folderId, 
    this.systemType = 'Overlord', // Define Overlord como padrão para fichas existentes
  }) : id = id ?? const Uuid().v4();

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'classe': classe,
      'level': level,
      'backpack': backpack.map((item) => item.toJson()).toList(),
      'abilitiesNotes': abilitiesNotes,
      'attributes': attributes,
      'pericias': pericias,
      'weapons': weapons.map((w) => w.toJson()).toList(),
      'abilities': abilities.map((a) => a.toJson()).toList(),
      'rituals': rituals.map((r) => r.toJson()).toList(), 
      'passives': passives.map((p) => p.toJson()).toList(),
      'status': status,
      'statusEffects': statusEffects.map((e) => e.toJson()).toList(),
      'esforcoExtra': esforcoExtra,
      'imagePath': imagePath,
      'effortColor': effortColor,
      'hpPerLevel': hpPerLevel,
      'effortPerLevel': effortPerLevel,
      'sanityPerLevel': sanityPerLevel,
      'parryType': parryType,
      'parryDiceCount': parryDiceCount,
      'armors': armors.map((a) => a.toJson()).toList(),
      'equippedArmor': equippedArmor?.toJson(),
      'blockConPercentage': blockConPercentage,
      'blockForPercentage': blockForPercentage,
      'blockSabPercentage': blockSabPercentage,
      'pontosAtributoPorNivel': pontosAtributoPorNivel,
      'pontosPericiaPorNivel': pontosPericiaPorNivel,
      'vidaPorCon': vidaPorCon,
      'esforcoPorSab': esforcoPorSab,
      'esforcoPorDes': esforcoPorDes,
      'elements': elements,
      'folderId': folderId, 
      'systemType': systemType, // Salva o tipo do sistema
    };
  }

  factory CharacterSheet.fromJson(Map<String, dynamic> json) {
    List<Item>? loadedBackpack = [];
    if (json['backpack'] is List) {
      loadedBackpack = ((json['backpack'] as List<dynamic>?)
              ?.map((i) {
                final itemJson = i as Map<String, dynamic>;
                switch (itemJson['type']) {
                  case 'Weapon': return Weapon.fromJson(itemJson);
                  case 'Armor': return Armor.fromJson(itemJson);
                  case 'Item': default: return Item.fromJson(itemJson);
                }
              })
              .toList() ?? []).cast<Item>();
    }

    var loadedStatus = (json['status'] as Map<String, dynamic>)
        .map((key, value) => MapEntry(key, Map<String, int?>.from(value)));
    
    if (!loadedStatus.containsKey('Loucura')) loadedStatus['Loucura'] = {'atual': 0, 'total': 100};
    if (!loadedStatus.containsKey('Esforço Temporário')) loadedStatus['Esforço Temporário'] = {'atual': 0, 'total': 0};

    return CharacterSheet(
      id: json['id'],
      name: json['name'],
      classe: json['classe'],
      level: json['level'],
      backpack: loadedBackpack,
      abilitiesNotes: json['abilitiesNotes'],
      attributes: Map<String, int?>.from(json['attributes']),
      pericias: Map<String, int?>.from(json['pericias']),
      weapons: (json['weapons'] as List?)?.map((w) => Weapon.fromJson(w)).toList() ?? [],
      abilities: (json['abilities'] as List?)?.map((a) => Ability.fromJson(a)).toList() ?? [],
      rituals: (json['rituals'] as List?)?.map((r) => Ability.fromJson(r)).toList() ?? [],
      passives: (json['passives'] as List?)?.map((p) => Passive.fromJson(p)).toList() ?? [],
      status: loadedStatus,
      statusEffects: (json['statusEffects'] as List?)?.map((e) => StatusEffect.fromJson(e)).toList() ?? [],
      esforcoExtra: json['esforcoExtra'] ?? 0,
      imagePath: json['imagePath'],
      effortColor: json['effortColor'] ?? 0xFFFFFF00,
      hpPerLevel: json['hpPerLevel'] ?? 0,
      effortPerLevel: json['effortPerLevel'] ?? 0,
      sanityPerLevel: json['sanityPerLevel'] ?? 0,
      parryType: json['parryType'] ?? 'Comum',
      parryDiceCount: json['parryDiceCount'] ?? 4,
      armors: (json['armors'] as List?)?.map((a) => Armor.fromJson(a)).toList() ?? [],
      equippedArmor: json['equippedArmor'] != null ? Armor.fromJson(json['equippedArmor']) : null,
      blockConPercentage: json['blockConPercentage'] ?? 100,
      blockForPercentage: json['blockForPercentage'] ?? 0,
      blockSabPercentage: json['blockSabPercentage'] ?? 0,
      pontosAtributoPorNivel: json['pontosAtributoPorNivel'] ?? 0,
      pontosPericiaPorNivel: json['pontosPericiaPorNivel'] ?? 0,
      vidaPorCon: json['vidaPorCon'] ?? 0,
      esforcoPorSab: json['esforcoPorSab'] ?? 0,
      esforcoPorDes: json['esforcoPorDes'] ?? 0,
      elements: List<String>.from(json['elements'] ?? []),
      folderId: json['folderId'], 
      systemType: json['systemType'] ?? 'Overlord', // Resgata o tipo (ou assume Overlord se nulo)
    );
  }
}