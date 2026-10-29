// lib/models/elemental_system.dart

import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

// Enum para os Tiers
enum ElementTier { glitch, aura, fisico, especial, combinacao, comum, subtipo }

// Classe auxiliar para as informações
class ElementalInfo {
  final String name;
  final int tier;
  final Color color;
  final List<String> advantages;
  final List<String> disadvantages;
  final String narrativeLogic;

  const ElementalInfo({
    required this.name,
    required this.tier,
    required this.color,
    required this.advantages,
    required this.disadvantages,
    required this.narrativeLogic,
  });

  Map<String, dynamic> toJson() => {
    'name': name,
    'tier': tier,
    'colorValue': color.value,
    'advantages': advantages,
    'disadvantages': disadvantages,
    'narrativeLogic': narrativeLogic,
  };

  factory ElementalInfo.fromJson(Map<String, dynamic> json) => ElementalInfo(
    name: json['name'],
    tier: json['tier'] ?? 3,
    color: Color(json['colorValue'] ?? 0xFFFFFFFF),
    advantages: List<String>.from(json['advantages'] ?? []),
    disadvantages: List<String>.from(json['disadvantages'] ?? []),
    narrativeLogic: json['narrativeLogic'] ?? '',
  );
}

class ElementalSystem {
  // --- 1. DADOS UNIFICADOS ---
  static const Map<String, ElementalInfo> data = {
    // TIER 0
    'Aura': ElementalInfo(
      name: 'Aura',
      tier: 0,
      color: Color(0xFFFFFFFF), // Branco/Luz
      advantages: ['TODOS OS EXISTENTES'],
      disadvantages: ['NENHUMA'],
      narrativeLogic: 'A pressão psicológica quebra a mente antes de atingir o corpo. Ignora defesas.',
    ),
    
    // TIER 1
    'Físico': ElementalInfo(
      name: 'Físico',
      tier: 1,
      color: Color(0xFF8D6E63), // Castanho
      advantages: ['TODOS (Especiais e Comuns)'],
      disadvantages: ['NENHUMA'],
      narrativeLogic: 'Violência física absoluta. Rápido demais para ser conjurado, forte demais para ser bloqueado.',
    ),

    // TIER 2
    'Conhecimento': ElementalInfo(
      name: 'Conhecimento',
      tier: 2,
      color: Color(0xFF9C27B0), // Roxo
      advantages: ['NENHUMA (Neutro)'],
      disadvantages: ['NENHUMA (Neutro)'],
      narrativeLogic: 'A compreensão da realidade observa tudo, sem interferir.',
    ),
    'Gravidade': ElementalInfo(
      name: 'Gravidade',
      tier: 2,
      color: Color(0xFF311B92), // Indigo Escuro
      advantages: ['Espaço', 'Vento', 'Terra'],
      disadvantages: ['Energia', 'Morte'],
      narrativeLogic: 'A gravidade dobra o espaço e esmaga a matéria.',
    ),
    'Espaço': ElementalInfo(
      name: 'Espaço',
      tier: 2,
      color: Color(0xFF006064), // Cyan Escuro
      advantages: ['Fogo', 'Vento'],
      disadvantages: ['Gravidade'],
      narrativeLogic: 'O espaço cria distância infinita, mas colapsa sob gravidade.',
    ),

    // TIER 3
    'Sangue': ElementalInfo(
      name: 'Sangue',
      tier: 3,
      color: Color(0xFFB71C1C), // Vermelho Sangue
      advantages: ['Morte', 'Lodo'],
      disadvantages: ['Fogo', 'Gelo', 'Terra'],
      narrativeLogic: 'Vitalidade nega a morte, mas carne sofre com fogo e gelo.',
    ),
    'Morte': ElementalInfo(
      name: 'Morte',
      tier: 3,
      color: Color(0xFF212121), // Preto/Cinza
      advantages: ['Natureza', 'Lodo'],
      disadvantages: ['Espaço', 'Energia', 'Sangue'],
      narrativeLogic: 'Entropia apodrece a natureza, mas a vida (Sangue) resiste.',
    ),
    'Energia': ElementalInfo(
      name: 'Energia',
      tier: 3,
      color: Color(0xFFFFAB00), // Âmbar Neon
      advantages: ['Morte', 'Terra', 'Gravidade'],
      disadvantages: ['Água'],
      narrativeLogic: 'Caos vence a inércia, mas se perde na água ou vácuo.',
    ),
    'Fogo': ElementalInfo(
      name: 'Fogo',
      tier: 3,
      color: Color(0xFFFF5722), // Laranja Fogo
      advantages: ['Natureza', 'Gelo', 'Sangue'],
      disadvantages: ['Água', 'Vento', 'Terra'],
      narrativeLogic: 'Queima a vida e derrete o gelo. Apagado pela água.',
    ),
    'Água': ElementalInfo(
      name: 'Água',
      tier: 3,
      color: Color(0xFF2196F3), // Azul
      advantages: ['Fogo', 'Terra'],
      disadvantages: ['Gelo', 'Natureza', 'Raio'],
      narrativeLogic: 'Apaga fogo e erode terra, mas conduz raio e congela.',
    ),
    'Vento': ElementalInfo(
      name: 'Vento',
      tier: 3,
      color: Color(0xFFB2DFDB), // Verde Claro
      advantages: ['Lodo', 'Fogo'],
      disadvantages: ['Espaço', 'Gelo', 'Terra'],
      narrativeLogic: 'Dispersa o lodo, mas não move gelo nem rocha.',
    ),
    'Raio': ElementalInfo(
      name: 'Raio',
      tier: 3,
      color: Color(0xFFFFEB3B), // Amarelo Elétrico
      advantages: ['Água', 'Morte'],
      disadvantages: ['Terra'],
      narrativeLogic: 'Eletrocuta água, mas é aterrado pela terra.',
    ),
    'Lodo': ElementalInfo(
      name: 'Lodo',
      tier: 3,
      color: Color(0xFF558B2F), // Verde Lodo
      advantages: ['Natureza', 'Fogo'],
      disadvantages: ['Vento', 'Água', 'Sangue'],
      narrativeLogic: 'Sufoca natureza, mas é lavado por sangue e água.',
    ),
    'Gelo': ElementalInfo(
      name: 'Gelo',
      tier: 3,
      color: Color(0xFF00BCD4), // Ciano
      advantages: ['Natureza', 'Água', 'Sangue'],
      disadvantages: ['Fogo', 'Morte', 'Lodo'],
      narrativeLogic: 'Congela tudo, mas derrete no fogo.',
    ),
    'Natureza': ElementalInfo(
      name: 'Natureza',
      tier: 3,
      color: Color(0xFF4CAF50), // Verde
      advantages: ['Água', 'Terra'],
      disadvantages: ['Fogo', 'Morte', 'Lodo'],
      narrativeLogic: 'Consome água, mas morre para fogo e podridão.',
    ),
    'Terra': ElementalInfo(
      name: 'Terra',
      tier: 3,
      color: Color(0xFF795548), // Marrom
      advantages: ['Raio', 'Fogo', 'Sangue'],
      disadvantages: ['Água', 'Gravidade', 'Vento'],
      narrativeLogic: 'Dura demais para sangrar, mas sofre erosão.',
    ),

    // TIER 4 (SUBTIPOS FÍSICOS)
    'Corte': ElementalInfo(
      name: 'Corte',
      tier: 4,
      color: Color(0xFFB0BEC5), // Prata/Aço
      advantages: ['Sangue', 'Natureza'],
      disadvantages: ['Terra', 'Impacto'],
      narrativeLogic: 'Lâminas afiadas dilaceram tecidos e matéria orgânica, mas perdem o fio contra rocha e impacto pesado.',
    ),
    'Impacto': ElementalInfo(
      name: 'Impacto',
      tier: 4,
      color: Color(0xFF78909C), // Cinza Metálico Escuro
      advantages: ['Terra', 'Gelo', 'Corte'],
      disadvantages: ['Lodo', 'Água'],
      narrativeLogic: 'A força contundente esmaga blindagens, ossos e quebra o corte, mas é amortecida por fluidos e massas flexíveis.',
    ),
    'Perfurante': ElementalInfo(
      name: 'Perfurante',
      tier: 4,
      color: Color(0xFFCFD8DC), // Aço Claro Pontiagudo
      advantages: ['Sangue', 'Água'],
      disadvantages: ['Lodo', 'Terra'],
      narrativeLogic: 'Concentração de força que transpassa defesas e atinge órgãos vitais, mas dissipa em matéria disforme ou rochas sólidas.',
    ),
  };

  // --- GERENCIADOR DE ELEMENTOS CUSTOMIZADOS ---
  static Map<String, ElementalInfo> customData = {};

  static Map<String, ElementalInfo> get allElementsMap {
    return {...data, ...customData};
  }

  static Future<void> loadCustomElements() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString('custom_elements_v2');
    if (jsonStr != null) {
      final List decoded = jsonDecode(jsonStr);
      customData.clear();
      for (var item in decoded) {
        final el = ElementalInfo.fromJson(item);
        customData[el.name] = el;
      }
    }
  }

  static Future<void> saveCustomElement(ElementalInfo element) async {
    customData[element.name] = element;
    final prefs = await SharedPreferences.getInstance();
    final list = customData.values.map((e) => e.toJson()).toList();
    await prefs.setString('custom_elements_v2', jsonEncode(list));
  }

  // --- GETTERS ---
  static List<String> get allElements => allElementsMap.keys.toList()..sort();

  static Map<String, Color> get elementColors {
    return allElementsMap.map((key, value) => MapEntry(key, value.color));
  }

  // --- LÓGICA DE JOGO ---
  static const List<String> specialElements = ['Gravidade', 'Espaço', 'Tempo', 'Realidade', 'Conhecimento'];
  static const List<String> physicalSubtypes = ['Corte', 'Cortante', 'Impacto', 'Perfurante'];

  static ElementTier getTier(List<String> elements) {
    if (elements.isEmpty) return ElementTier.comum;

    if (elements.length >= 4) return ElementTier.glitch;
    if (elements.contains('Aura')) return ElementTier.aura;
    if (elements.contains('Físico')) return ElementTier.fisico;

    for (var el in elements) {
      if (specialElements.contains(el)) return ElementTier.especial;
    }

    if (elements.length == 1 && physicalSubtypes.contains(elements.first)) {
      return ElementTier.subtipo;
    }

    if (elements.length > 1) return ElementTier.combinacao;

    return ElementTier.comum;
  }

  static double calculateClashMultiplier(List<String> atkElements, List<String> defElements) {
    final atkTier = getTier(atkElements);
    final defTier = getTier(defElements);

    if (atkTier == ElementTier.glitch) return 999.0;
    if (defTier == ElementTier.glitch) return 0.0;

    if (atkTier == ElementTier.aura) {
      if (defTier != ElementTier.aura) return 1.3; 
    }

    if (atkTier == ElementTier.combinacao) {
      if (defTier == ElementTier.comum || defTier == ElementTier.subtipo) {
        return 1.3; 
      } else if (defTier == ElementTier.fisico || defTier == ElementTier.aura || defTier == ElementTier.especial || defTier == ElementTier.combinacao) {
        return 1.0; 
      }
    }

    if (atkTier == ElementTier.fisico) {
       if (defTier == ElementTier.combinacao) return 1.0;
       if (defTier == ElementTier.comum || defTier == ElementTier.especial || defTier == ElementTier.subtipo) return 1.3;
    }

    if ((atkTier == ElementTier.comum || atkTier == ElementTier.subtipo) && 
        (defTier == ElementTier.comum || defTier == ElementTier.subtipo) && 
        atkElements.isNotEmpty && defElements.isNotEmpty) {
      String atk = atkElements.first;
      String def = defElements.first;
      
      if (allElementsMap[atk]?.advantages.contains(def) ?? false) return 1.3;
      if (allElementsMap[def]?.advantages.contains(atk) ?? false) return 0.7;
    }

    return 1.0;
  }

  static String getTierName(ElementTier tier) {
    switch(tier) {
      case ElementTier.glitch: return "GLITCH (UNIVERSAL)";
      case ElementTier.aura: return "AURA (TIER 0)";
      case ElementTier.fisico: return "FÍSICO (TIER 1)";
      case ElementTier.especial: return "ESPECIAL (TIER 2)";
      case ElementTier.combinacao: return "COMBINAÇÃO";
      case ElementTier.comum: return "COMUM (TIER 3)";
      case ElementTier.subtipo: return "SUBTIPO FÍSICO (TIER 4)";
    }
  }

  // --- NOMEADOR DE FUSÕES ---
  static String getFusionName(Set<String> elements) {
    if (elements.isEmpty) return 'Físico';
    if (elements.length >= 4) return 'GLITCH';

    final sorted = elements.toList()..sort();
    final key = sorted.join('+');

    const fusions = {
      'Fogo+Água': 'Névoa Escaldante',
      'Raio+Terra': 'Canhão Railgun',
      'Fogo+Terra': 'Magma Vivo',
      'Gelo+Vento': 'Tempestade de Estilhaços',
      'Água+Raio': 'Condução Fatal',
      'Terra+Vento': 'Tempestade de Areia',
      'Físico+Vento': 'Canhão de Vácuo',
      'Conhecimento+Vento': 'Ecos do Passado',
      'Fogo+Natureza': 'Pólen Incendiário',
      'Conhecimento+Sangue': 'Acupuntura Hemática',
      'Água+Energia': 'Hidrólise Explosiva',
      'Espaço+Terra': 'Labirinto Fractal',
      'Gelo+Lodo': 'Gel de Permafrost',
      'Gravidade+Sangue': 'Hipertensão Gravitacional',
      'Energia+Gelo': 'Prisma de Cristal',
      'Água+Fogo+Terra': 'Lança de Obsidiana',
      'Água+Gelo': 'Tsunami Congelante',
    };

    if (fusions.containsKey(key)) return fusions[key]!;
    return elements.length > 1 ? 'Fusão: ${sorted.join("-")}' : sorted.first;
  }
}