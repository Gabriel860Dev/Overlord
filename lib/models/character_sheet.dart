// lib/models/character_sheet.dart

import 'package:dark_age/models/status_effect.dart';
import 'package:dark_age/models/weapon.dart';
import 'package:dark_age/models/ability.dart';
import 'package:dark_age/models/passive.dart';
import 'package:dark_age/models/item.dart';
import 'package:dark_age/models/armor.dart';
import 'package:uuid/uuid.dart';

// NOVO: Enum para Maestria
enum MaestriaLevel {
  Novato,
  Treinado,
  Mestre,
  Proficiencia; // Estado especial para quando a proficiência é comprada

  /// Converte uma string (ex: "Mestre") para o enum correspondente.
  static MaestriaLevel fromString(String? level) {
    switch (level?.toLowerCase()) { // Usa toLowerCase para segurança
      case 'treinado':
        return MaestriaLevel.Treinado;
      case 'mestre':
        return MaestriaLevel.Mestre;
      case 'proficiencia':
        return MaestriaLevel.Proficiencia;
      case 'novato':
      default:
        return MaestriaLevel.Novato;
    }
  }

  /// Converte o enum de volta para uma string para salvar.
  String toJsonString() {
    switch (this) {
      case MaestriaLevel.Treinado:
        return 'Treinado';
      case MaestriaLevel.Mestre:
        return 'Mestre';
      case MaestriaLevel.Proficiencia:
        return 'Proficiencia';
      case MaestriaLevel.Novato:
      default:
        return 'Novato';
    }
  }
}

class CharacterSheet {
  final String id;
  final String name;
  final String? classe;
  final int? level;
  final List<Item> backpack;
  final String? abilitiesNotes;
  final Map<String, int?> attributes;
  final Map<String, int?> pericias;
  final List<Ability> abilities;
  final List<Passive> passives;
  final Map<String, Map<String, int?>> status;
  final List<StatusEffect> statusEffects;
  final int esforcoExtra; // Renomeado para manaExtra na UI, mas variável mantida
  final String? imagePath;
  final int effortColor; // Renomeado para manaColor na UI
  final int hpPerLevel;
  final int manaPerLevel; // Renomeado de effortPerLevel
  final int staminaPerLevel; // Renomeado de sanityPerLevel
  final String parryType;
  final int parryDiceCount;
  final int blockConPercentage;
  final int blockForPercentage;
  final int blockSabPercentage;
  final int pontosAtributoPorNivel;
  final int pontosPericiaPorNivel;
  final int vidaPorCon;
  final int manaPerSab; // Renomeado de esforcoPorSab
  final int manaPerDes; // Renomeado de esforcoPorDes

  // NOVO: Pontos de Bônus (Treino)
  final int bonusAttributePoints;
  final int bonusSkillPoints;

  // NOVO: Campos para o sistema Dark Age
  final Map<String, String> periciaMaestria; // Ex: "Atletismo": "Mestre" (Usa a string do enum)
  final Map<String, int> periciaProficiencia; // Ex: "Atletismo": 3 (P III)
  final Map<String, int> armaMaestria; // Ex: "Espada": 4 (Nível 4)

  CharacterSheet({
    String? id,
    required this.name,
    this.classe,
    this.level,
    this.backpack = const [],
    this.abilitiesNotes,
    required this.attributes,
    required this.pericias,
    required this.abilities,
    required this.passives,
    required this.status,
    this.statusEffects = const [],
    this.esforcoExtra = 0,
    this.imagePath,
    this.effortColor = 0xFFFFFF00,
    this.hpPerLevel = 0,
    this.manaPerLevel = 0, // Renomeado
    this.staminaPerLevel = 0, // Renomeado
    this.parryType = 'Comum',
    this.parryDiceCount = 4,
    this.blockConPercentage = 100,
    this.blockForPercentage = 0,
    this.blockSabPercentage = 0,
    this.pontosAtributoPorNivel = 0,
    this.pontosPericiaPorNivel = 0,
    this.vidaPorCon = 0,
    this.manaPerSab = 0, // Renomeado
    this.manaPerDes = 0, // Renomeado
    this.bonusAttributePoints = 0, // NOVO
    this.bonusSkillPoints = 0, // NOVO
    this.periciaMaestria = const {},
    this.periciaProficiencia = const {},
    this.armaMaestria = const {},
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
      'abilities': abilities.map((a) => a.toJson()).toList(),
      'passives': passives.map((p) => p.toJson()).toList(),
      'status': status,
      'statusEffects': statusEffects.map((e) => e.toJson()).toList(),
      'esforcoExtra': esforcoExtra,
      'imagePath': imagePath,
      'effortColor': effortColor,
      'hpPerLevel': hpPerLevel,
      'manaPerLevel': manaPerLevel, // Renomeado
      'staminaPerLevel': staminaPerLevel, // Renomeado
      'parryType': parryType,
      'parryDiceCount': parryDiceCount,
      'blockConPercentage': blockConPercentage,
      'blockForPercentage': blockForPercentage,
      'blockSabPercentage': blockSabPercentage,
      'pontosAtributoPorNivel': pontosAtributoPorNivel,
      'pontosPericiaPorNivel': pontosPericiaPorNivel,
      'vidaPorCon': vidaPorCon,
      'manaPerSab': manaPerSab, // Renomeado
      'manaPerDes': manaPerDes, // Renomeado
      'bonusAttributePoints': bonusAttributePoints, // NOVO
      'bonusSkillPoints': bonusSkillPoints, // NOVO
      'periciaMaestria': periciaMaestria,
      'periciaProficiencia': periciaProficiencia,
      'armaMaestria': armaMaestria,
    };
  }

  factory CharacterSheet.fromJson(Map<String, dynamic> json) {
    List<Item> loadedBackpack = [];
    if (json['backpack'] is List) {
      loadedBackpack = (json['backpack'] as List<dynamic>?)
              ?.map((i) {
                final itemJson = i as Map<String, dynamic>;
                switch (itemJson['type']) {
                  case 'Weapon':
                    return Weapon.fromJson(itemJson);
                  case 'Armor':
                    return Armor.fromJson(itemJson);
                  case 'Item':
                  default:
                    try {
                      return Item.fromJson(itemJson);
                    } catch (e) {
                      print(
                          "Erro ao deserializar item: $e. Item JSON: $itemJson");
                      return Item(
                          name: 'Erro ao Carregar Item',
                          description: e.toString());
                    }
                }
              })
              .where((item) => item.name != 'Erro ao Carregar Item')
              .toList() ??
          [];
    } else if (json['backpack'] is String) {
      loadedBackpack
          .add(Item(name: 'Notas da Mochila Antiga', description: json['backpack']));
    }

    var loadedStatus = (json['status'] as Map<String, dynamic>? ?? {})
        .map((key, value) {
      if (value is Map) {
        return MapEntry(
            key,
            Map<String, int?>.from(value.map((k, v) =>
                MapEntry(k.toString(), v is int ? v : int.tryParse(v.toString())))));
      } else {
        print(
            "Status inválido encontrado para a chave '$key': $value. Usando valor padrão.");
        return MapEntry(key, {'atual': 0, 'total': 0});
      }
    });

    // Migração dos nomes antigos para os novos
    if (json.containsKey('Esforço')) {
      loadedStatus['Mana'] = loadedStatus['Esforço']!;
      loadedStatus.remove('Esforço');
    }
    if (json.containsKey('Esforço Temporário')) {
      loadedStatus['Mana Temporária'] = loadedStatus['Esforço Temporário']!;
      loadedStatus.remove('Esforço Temporário');
    }
    if (json.containsKey('Sanidade')) {
      loadedStatus['Estamina'] = loadedStatus['Sanidade']!;
      loadedStatus.remove('Sanidade');
    }
    loadedStatus.remove('Loucura'); // Remove 'Loucura' conforme solicitado

    // Garante a existência dos status padrão novos
    if (!loadedStatus.containsKey('Vida')) {
      loadedStatus['Vida'] = {'atual': 1, 'total': 1};
    }
    if (!loadedStatus.containsKey('Mana')) {
      loadedStatus['Mana'] = {'atual': 1, 'total': 1};
    }
    if (!loadedStatus.containsKey('Mana Temporária')) {
      loadedStatus['Mana Temporária'] = {'atual': 0, 'total': 0};
    }
    if (!loadedStatus.containsKey('Estamina')) {
      loadedStatus['Estamina'] = {'atual': 1, 'total': 1};
    }

    // Garante que os totais não sejam nulos ou zero (exceto Temp)
    loadedStatus.forEach((key, value) {
      if (key != 'Mana Temporária') {
        if (value['total'] == null || value['total']! <= 0) value['total'] = 1;
        if (value['atual'] == null) value['atual'] = value['total'];
        value['atual'] = value['atual']!.clamp(0, value['total']!);
      } else {
        if (value['total'] == null || value['total']! < 0) value['total'] = 0;
        if (value['atual'] == null || value['atual']! < 0) value['atual'] = 0;
        value['atual'] = value['atual']!.clamp(0, value['total']!);
      }
    });

    List<Ability> loadedAbilities = [];
    if (json['abilities'] is List) {
      for (var a in (json['abilities'] as List)) {
        try {
          if (a is Map<String, dynamic>) {
            loadedAbilities.add(Ability.fromJson(a));
          }
        } catch (e) {
          print("Erro ao carregar habilidade: $e. JSON: $a");
        }
      }
    }

    List<Passive> loadedPassives = [];
    if (json['passives'] is List) {
      for (var p in (json['passives'] as List)) {
        try {
          if (p is Map<String, dynamic>) {
            loadedPassives.add(Passive.fromJson(p));
          }
        } catch (e) {
          print("Erro ao carregar passiva: $e. JSON: $p");
        }
      }
    }

    List<StatusEffect> loadedStatusEffects = [];
    if (json['statusEffects'] is List) {
      for (var e_ in (json['statusEffects'] as List)) {
        try {
          if (e_ is Map<String, dynamic>) {
            loadedStatusEffects.add(StatusEffect.fromJson(e_));
          }
        } catch (e) {
          print("Erro ao carregar efeito de status: $e. JSON: $e_");
        }
      }
    }

    return CharacterSheet(
      id: json['id'] ?? const Uuid().v4(),
      name: json['name'] ?? 'Sem Nome',
      classe: json['classe'],
      level: json['level'],
      backpack: loadedBackpack,
      abilitiesNotes: json['abilitiesNotes'],
      attributes: Map<String, int?>.from(json['attributes'] ?? {}),
      pericias: Map<String, int?>.from(json['pericias'] ?? {}),
      abilities: loadedAbilities,
      passives: loadedPassives,
      status: loadedStatus,
      statusEffects: loadedStatusEffects,
      esforcoExtra: json['esforcoExtra'] ?? 0,
      imagePath: json['imagePath'],
      effortColor: json['effortColor'] ?? 0xFFFFFF00,
      hpPerLevel: json['hpPerLevel'] ?? 0,
      // Migra nomes antigos para os novos
      manaPerLevel: json['manaPerLevel'] ?? json['effortPerLevel'] ?? 0,
      staminaPerLevel: json['staminaPerLevel'] ?? json['sanityPerLevel'] ?? 0,
      parryType: json['parryType'] ?? 'Comum',
      parryDiceCount: json['parryDiceCount'] ?? 4,
      blockConPercentage: json['blockConPercentage'] ?? 100,
      blockForPercentage: json['blockForPercentage'] ?? 0,
      blockSabPercentage: json['blockSabPercentage'] ?? 0,
      pontosAtributoPorNivel: json['pontosAtributoPorNivel'] ?? 0,
      pontosPericiaPorNivel: json['pontosPericiaPorNivel'] ?? 0,
      vidaPorCon: json['vidaPorCon'] ?? 0,
      // Migra nomes antigos para os novos
      manaPerSab: json['manaPerSab'] ?? json['esforcoPorSab'] ?? 0,
      manaPerDes: json['manaPerDes'] ?? json['esforcoPorDex'] ?? 0,
      // NOVO
      bonusAttributePoints: json['bonusAttributePoints'] ?? 0,
      bonusSkillPoints: json['bonusSkillPoints'] ?? 0,
      // Fim NOVO
      periciaMaestria: Map<String, String>.from(json['periciaMaestria'] ?? {}),
      periciaProficiencia: Map<String, int>.from(json['periciaProficiencia'] ?? {}),
      armaMaestria: Map<String, int>.from(json['armaMaestria'] ?? {}),
    );
  }

  // Helper para obter a armadura equipada (se houver)
  Armor? get equippedArmor {
    try {
      return backpack.firstWhere((item) => item is Armor && item.isEquipped)
          as Armor?;
    } catch (e) {
      return null; // Retorna nulo se nenhuma armadura estiver equipada
    }
  }

  // Helper para obter as armas equipadas
  List<Weapon> get equippedWeapons {
    return backpack.whereType<Weapon>().where((w) => w.isEquipped).toList();
  }
}
