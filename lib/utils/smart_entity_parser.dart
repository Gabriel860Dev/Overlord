// lib/utils/smart_entity_parser.dart

import 'package:overlord/models/ability.dart';
import 'package:overlord/models/passive.dart';
import 'package:overlord/models/weapon.dart';
import 'package:overlord/models/armor.dart';
import 'package:overlord/models/item.dart';
import 'package:overlord/models/die_specification.dart';
import 'package:uuid/uuid.dart';

class SmartEntityParser {
  
  /// Analisa um texto e tenta construir a Entidade solicitada
  static dynamic parseTextToEntity(String text, String entityType) {
    // 1. PRESERVAÇÃO TOTAL DA DESCRIÇÃO ORIGINAL
    String description = text.trim();
    String name = _extractName(description) ?? "Nova Entidade";

    // 2. EXTRAÇÃO HÍBRIDA DE CUSTOS (Agora lê "Custo 40 de VIGOR", "35 de EST")
    int costAmount = 0;
    String costType = 'Esforço';
    
    final costMatchA = RegExp(r'(?:Custo|Custa|Gasta|Gastando|Invocação|Esforço)\s*[:=]?\s*(\d+)(?:\s*(?:de\s*)?([a-zA-Zç]+))?', caseSensitive: false).firstMatch(description);
    final costMatchB = RegExp(r'(\d+)\s*(?:de\s*)?(esforço|esf|pe|vida|hp|sanidade|san|estamina|est|vigor|vig|mana)', caseSensitive: false).firstMatch(description);

    if (costMatchA != null && costMatchA.group(1) != null) {
      costAmount = int.tryParse(costMatchA.group(1)!) ?? 0;
      if (costMatchA.group(2) != null) costType = _normalizeCostType(costMatchA.group(2)!);
    } else if (costMatchB != null && costMatchB.group(1) != null) {
      costAmount = int.tryParse(costMatchB.group(1)!) ?? 0;
      if (costMatchB.group(2) != null) costType = _normalizeCostType(costMatchB.group(2)!);
    }

    // 3. AUTO-DETECÇÃO DE TIPO
    bool isExplicitPassive = RegExp(r'\bpassiva\b', caseSensitive: false).hasMatch(description);
    String actualEntityType = entityType;
    if (entityType == 'Habilidade' && isExplicitPassive) {
      actualEntityType = 'Passiva';
    }

    // 4. EXTRAÇÃO INTELIGENTE DE DADOS (Pula tempo de duração, como Efeito: 1d5)
    List<DieSpecification> diceList = [];
    String probableElement = _detectElement(description);
    final lines = description.split('\n');
    
    for (var line in lines) {
      if (line.toLowerCase().contains('efeito:') || line.toLowerCase().contains('duração:')) {
        continue;
      }
      final diceMatches = RegExp(r'(\d+)\s*[dD]\s*(\d+)').allMatches(line);
      for (var m in diceMatches) {
        int q = int.tryParse(m.group(1) ?? '0') ?? 0;
        int s = int.tryParse(m.group(2) ?? '0') ?? 0;
        if (q > 0 && s > 0) {
          diceList.add(DieSpecification(quantity: q, sides: s, damageType: probableElement));
        }
      }
    }

    // 5. RESTAURAÇÃO DAS FUNÇÕES GERAIS E MULTIPLICADORES
    int flatDamage = _extractFlatDamage(description);
    double extractedMultiplier = _extractMultiplier(description);
    List<AbilityBaseComponent> baseComponents = _extractBaseComponents(description);
    bool usesWeapon = _detectWeaponUse(description);

    final id = const Uuid().v4();

    switch (actualEntityType) {
      case 'Habilidade':
      case 'Ritual':
        return Ability(
          id: id,
          name: name,
          description: description,
          costType: costType,
          costAmount: costAmount, 
          abilityType: usesWeapon ? 'Ataque Armado' : 'Ataque',
          useWeaponDamage: usesWeapon,
          baseComponents: baseComponents, 
          bonusDice: diceList, 
          bonusModifier: flatDamage,
          multiplier: extractedMultiplier,
          conditionalEffects: [], 
        );
      case 'Passiva':
        return Passive(
          id: id,
          name: name,
          description: description,
          triggerType: 'Sempre Ativo',
          effects: [],
        );
      case 'Arma':
        return Weapon(
          id: id,
          name: name,
          description: description,
          dice: diceList.isNotEmpty ? diceList : [DieSpecification(quantity: 1, sides: 4, damageType: probableElement)], 
          modifier: flatDamage,
        );
      case 'Armadura':
        return Armor(
          id: id,
          name: name,
          description: description,
        );
      case 'Item':
        return Item(
          id: id,
          name: name,
          description: description,
        );
      default:
        return null;
    }
  }

  // ===========================================================================
  // ========================== FUNÇÕES AUXILIARES =============================
  // ===========================================================================

  static String? _extractName(String text) {
    List<String> lines = text.split('\n');
    for (String line in lines) {
      // Limpa marcações estranhas como *D, *, _, e quebra no primeiro ponto final ou dois pontos
      String cleanLine = line.trim().replaceAll(RegExp(r'^\*|\*$|^_|_$|^\*D\s*'), '');
      
      // Se a linha for como "Acerto Garantido. Custo 40...", ele pega só "Acerto Garantido"
      if (cleanLine.contains('.') || cleanLine.contains(':')) {
        cleanLine = cleanLine.split(RegExp(r'[:\.]')).first.trim();
      }

      if (cleanLine.isNotEmpty && cleanLine.length < 45 && !RegExp(r'\d+[dD]\d+').hasMatch(cleanLine)) {
        return cleanLine;
      }
    }
    return null;
  }

  static String _normalizeCostType(String raw) {
    String lower = raw.toLowerCase();
    if (lower.contains('esfor') || lower == 'esf' || lower == 'pe') return 'Esforço';
    if (lower.contains('vida') || lower == 'hp') return 'Vida';
    if (lower.contains('san')) return 'Sanidade';
    if (lower.contains('man') || lower == 'mp') return 'Mana';
    if (lower.contains('vig')) return 'Vigor';
    if (lower.contains('est')) return 'Estamina';
    return 'Esforço';
  }

  static String _detectElement(String text) {
    String lower = text.toLowerCase();
    
    // Mágicos e Paranormais
    if (lower.contains('gelo') || lower.contains('congel') || lower.contains('frio') || lower.contains('criocinese')) return 'Gelo';
    if (lower.contains('fogo') || lower.contains('chama') || lower.contains('queima')) return 'Fogo';
    if (lower.contains('sangue') || lower.contains('hemátic')) return 'Sangue';
    if (lower.contains('morte') || lower.contains('sombrio')) return 'Morte';
    if (lower.contains('energia') || lower.contains('raio') || lower.contains('eletri')) return 'Energia';
    if (lower.contains('conhecimento') || lower.contains('mente')) return 'Conhecimento';
    if (lower.contains('terra') || lower.contains('rocha') || lower.contains('areia')) return 'Terra';
    if (lower.contains('lodo') || lower.contains('ácido') || lower.contains('veneno')) return 'Lodo';
    if (lower.contains('natureza') || lower.contains('planta')) return 'Natureza';
    if (lower.contains('vento') || lower.contains('ar') || lower.contains('vácuo')) return 'Vento';
    if (lower.contains('espaço') || lower.contains('gravidade')) return 'Espaço';
    
    // Tipos Físicos Específicos
    if (lower.contains('corte') || lower.contains('cortante') || lower.contains('lâmina') || lower.contains('espada')) return 'Corte';
    if (lower.contains('impacto') || lower.contains('contusão') || lower.contains('esmagamento') || lower.contains('porrada')) return 'Impacto';
    if (lower.contains('perfurante') || lower.contains('perfuração') || lower.contains('furo') || lower.contains('flecha')) return 'Perfurante';
    
    return 'Físico';
  }

  static int _extractFlatDamage(String text) {
    // Garante que não vai capturar valores com "%" (ex: evita pegar o 25 de "+25% de dano")
    final match = RegExp(r'(?:\+|\bganha um bônus de\b)\s*(\d+)(?!\s*%)', caseSensitive: false).firstMatch(text);
    if (match != null) return int.tryParse(match.group(1) ?? '0') ?? 0;
    
    final match2 = RegExp(r'(?:Causa|Dano)[:=]?\s*(\d+)\s*(?:de dano)?(?!d|D|%)', caseSensitive: false).firstMatch(text);
    if (match2 != null) return int.tryParse(match2.group(1) ?? '0') ?? 0;
    
    return 0;
  }

  static double _extractMultiplier(String text) {
    double maxMultiplier = 1.0;
    final matches = RegExp(r'(\d+)%').allMatches(text);
    for (var match in matches) {
      double val = double.tryParse(match.group(1) ?? '0') ?? 0;
      double mult = 1.0 + (val / 100);
      if (mult > maxMultiplier) maxMultiplier = mult;
    }
    return maxMultiplier;
  }

  static bool _detectWeaponUse(String text) {
    String lower = text.toLowerCase();
    return lower.contains('arma') || lower.contains('ataque') || lower.contains('golpe') || lower.contains('acerte');
  }

  // Novo Cérebro de Componentes Base (Lê as dezenas de Perícias do Réquiem e Atributos novos)
  static List<AbilityBaseComponent> _extractBaseComponents(String text) {
    List<AbilityBaseComponent> components = [];
    String lower = text.toLowerCase();
    
    if (lower.contains('velocidade') || lower.contains('rápido') || lower.contains('rapidez')) {
       _addComponentSafe(components, 'Atributo', 'DES');
       _addComponentSafe(components, 'Perícia', 'Atletismo');
       _addComponentSafe(components, 'Perícia', 'Reflexo');
    }
    if (lower.contains('força bruta') || lower.contains('esmaga')) {
       _addComponentSafe(components, 'Atributo', 'FOR');
       _addComponentSafe(components, 'Perícia', 'Artes-marciais');
    }
    if (lower.contains('mira') || lower.contains('precisão')) {
       _addComponentSafe(components, 'Atributo', 'DES');
       _addComponentSafe(components, 'Perícia', 'Pontaria');
    }

    // Busca de Atributos (Incluindo ARC do Réquiem)
    final attrRegex = RegExp(r'\b(for|con|des|agi|int|sab|pre|car|arc)\b');
    for (var match in attrRegex.allMatches(lower)) {
      String attr = _normalizeAttribute(match.group(1)!);
      _addComponentSafe(components, 'Atributo', attr);
    }

    // Busca de Perícias (Todas as do Overlord + Réquiem)
    final skillRegex = RegExp(r'\b(luta|pontaria|atletismo|acrobacia|oculto|vontade|reflexo|investigação|sobrevivência|adestramento|percep[cç][aã]o|diplomacia|guerra|t[aá]tico|engana[cç][aã]o|atua[cç][aã]o|ladinagem|artes-marciais|ecl[eé]tico|dire[cç][aã]o|atualidades|montaria|primeiros socorros|tecnologia|intimida[cç][aã]o|sorte|furtividade|poder de fogo|mente|mem[oó]ria|iniciativa|intui[cç][aã]o)\b');
    for (var match in skillRegex.allMatches(lower)) {
       String skill = _normalizeSkill(match.group(1)!);
       _addComponentSafe(components, 'Perícia', skill);
    }

    return components;
  }

  static void _addComponentSafe(List<AbilityBaseComponent> list, String type, String value) {
    if (!list.any((c) => c.value == value)) {
      list.add(AbilityBaseComponent(type: type, value: value));
    }
  }

  static String _normalizeAttribute(String raw) {
    if (raw == 'for') return 'FOR';
    if (raw == 'con') return 'CON';
    if (raw == 'des' || raw == 'agi') return 'DES'; 
    if (raw == 'int') return 'INT';
    if (raw == 'sab') return 'SAB';
    if (raw == 'pre' || raw == 'car') return 'CAR';
    if (raw == 'arc') return 'ARC';
    return raw.toUpperCase();
  }

  static String _normalizeSkill(String raw) {
    String r = raw.toLowerCase();
    if (r == 'luta') return 'Artes-marciais';
    if (r == 'pontaria') return 'Pontaria';
    if (r == 'atletismo') return 'Atletismo';
    if (r == 'acrobacia') return 'Acrobacia';
    if (r == 'oculto') return 'Oculto';
    if (r == 'vontade') return 'Vontade';
    if (r == 'reflexo') return 'Reflexo';
    if (r == 'sobrevivência') return 'Sobrevivência';
    if (r == 'investigação') return 'Investigação';
    if (r == 'adestramento') return 'Adestramento';
    if (r == 'percepção' || r == 'percepcao') return 'Percepção';
    if (r == 'diplomacia') return 'Diplomacia';
    if (r == 'guerra') return 'Guerra';
    if (r == 'tático' || r == 'tatico') return 'Tático';
    if (r == 'enganação' || r == 'enganacao') return 'Enganação';
    if (r == 'atuação' || r == 'atuacao') return 'Atuação';
    if (r == 'ladinagem') return 'Ladinagem';
    if (r == 'eclético' || r == 'ecletico') return 'Eclético';
    if (r == 'direção' || r == 'direcao') return 'Direção';
    if (r == 'atualidades') return 'Atualidades';
    if (r == 'montaria') return 'Montaria';
    if (r == 'primeiros socorros') return 'Primeiros socorros';
    if (r == 'tecnologia') return 'Tecnologia';
    if (r == 'intimidação' || r == 'intimidacao') return 'Intimidação';
    if (r == 'sorte') return 'Sorte';
    if (r == 'furtividade') return 'Furtividade';
    if (r == 'poder de fogo') return 'Poder de fogo';
    if (r == 'mente') return 'Mente';
    if (r == 'memória' || r == 'memoria') return 'Memória';
    if (r == 'iniciativa') return 'Iniciativa';
    if (r == 'intuição' || r == 'intuicao') return 'Intuição';
    
    return raw.substring(0, 1).toUpperCase() + raw.substring(1);
  }
}