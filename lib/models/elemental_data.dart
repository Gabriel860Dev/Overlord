// lib/models/elemental_data.dart

import 'package:flutter/material.dart';

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
}

class ElementalSystem {
  static const Map<String, ElementalInfo> data = {
    // --- TIER 0 ---
    'Aura': ElementalInfo(
      name: 'Aura',
      tier: 0,
      color: Color(0xFFFFFFFF), 
      advantages: ['TODOS OS EXISTENTES'],
      disadvantages: ['NENHUMA'],
      narrativeLogic: 'A pressão psicológica quebra a mente antes de atingir o corpo. Ignora defesas.',
    ),
    
    // --- TIER 1 ---
    'Físico': ElementalInfo(
      name: 'Físico',
      tier: 1,
      color: Color(0xFF8D6E63), 
      advantages: ['TODOS (Especiais e Comuns)'],
      disadvantages: ['NENHUMA'],
      narrativeLogic: 'Violência física absoluta. Dano bruto direto.',
    ),

    // --- TIER 2 (Especiais) ---
    'Sangue': ElementalInfo(
      name: 'Sangue', tier: 2, color: Color(0xFFB71C1C),
      advantages: ['Natureza', 'Água'], disadvantages: ['Fogo', 'Raio'],
      narrativeLogic: 'Magia vital, poderosa, mas arriscada.',
    ),
    'Conhecimento': ElementalInfo(
      name: 'Conhecimento', tier: 2, color: Color(0xFFFFD54F),
      advantages: ['Tudo (Com preparo)'], disadvantages: ['Caos', 'Surpresa'],
      narrativeLogic: 'Saber é poder. Prever o inimigo é a chave.',
    ),
    'Energia': ElementalInfo(
      name: 'Energia', tier: 2, color: Color(0xFF9C27B0),
      advantages: ['Fogo', 'Raio'], disadvantages: ['Terra', 'Aura'],
      narrativeLogic: 'Pura energia cinética e vibracional.',
    ),
    'Espaço': ElementalInfo(
      name: 'Espaço', tier: 2, color: Color(0xFF1A237E),
      advantages: ['Físico', 'Vento'], disadvantages: ['Tempo'],
      narrativeLogic: 'Controle de área, portais e gravidade.',
    ),
    'Tempo': ElementalInfo(
      name: 'Tempo', tier: 2, color: Color(0xFF004D40),
      advantages: ['Espaço', 'Comuns'], disadvantages: ['Aura'],
      narrativeLogic: 'O tempo corrói e afeta todas as matérias.',
    ),
    'Luz': ElementalInfo(
      name: 'Luz', tier: 2, color: Color(0xFFFFF59D),
      advantages: ['Trevas'], disadvantages: ['Trevas'],
      narrativeLogic: 'Ilumina a escuridão e purifica o corrompido.',
    ),
    'Trevas': ElementalInfo(
      name: 'Trevas', tier: 2, color: Color(0xFF212121),
      advantages: ['Luz'], disadvantages: ['Luz'],
      narrativeLogic: 'Consome a luz e oculta a presença.',
    ),

    // --- TIER 3 (Comuns) ---
    'Fogo': ElementalInfo(
      name: 'Fogo', tier: 3, color: Color(0xFFF44336),
      advantages: ['Natureza', 'Gelo', 'Lodo'], disadvantages: ['Água', 'Terra'],
      narrativeLogic: 'Queima o que toca, mas é apagado por água ou abafado por terra.',
    ),
    'Água': ElementalInfo(
      name: 'Água', tier: 3, color: Color(0xFF2196F3),
      advantages: ['Fogo', 'Terra'], disadvantages: ['Raio', 'Gelo', 'Natureza'],
      narrativeLogic: 'Apaga o fogo e corrói a terra, mas conduz perfeitamente o raio.',
    ),
    'Terra': ElementalInfo(
      name: 'Terra', tier: 3, color: Color(0xFF795548),
      advantages: ['Raio', 'Vento', 'Ar'], disadvantages: ['Água', 'Natureza'],
      narrativeLogic: 'Pára impactos e absorve eletricidade, mas é perfurada por raízes.',
    ),
    'Vento': ElementalInfo(
      name: 'Vento', tier: 3, color: Color(0xFFB0BEC5),
      advantages: ['Terra', 'Lodo'], disadvantages: ['Fogo'],
      narrativeLogic: 'Erosão constante contra sólidos, mas alimenta o fogo.',
    ),
    'Ar': ElementalInfo(
      name: 'Ar', tier: 3, color: Color(0xFFCFD8DC),
      advantages: ['Fogo'], disadvantages: ['Terra'],
      narrativeLogic: 'Força ágil, aumenta chamas e cria lâminas invisíveis.',
    ),
    'Raio': ElementalInfo(
      name: 'Raio', tier: 3, color: Color(0xFFFFEB3B),
      advantages: ['Água'], disadvantages: ['Terra'],
      narrativeLogic: 'Eletrocuta tudo na água, mas é inútil na terra (aterramento).',
    ),
    'Lodo': ElementalInfo(
      name: 'Lodo', tier: 3, color: Color(0xFF558B2F),
      advantages: ['Natureza', 'Fogo'], disadvantages: ['Vento', 'Água'],
      narrativeLogic: 'Sufoca e aprisiona oponentes e plantas.',
    ),
    'Gelo': ElementalInfo(
      name: 'Gelo', tier: 3, color: Color(0xFF00BCD4),
      advantages: ['Água', 'Natureza'], disadvantages: ['Fogo'],
      narrativeLogic: 'Congela fluidos, mas derrete sob calor extremo.',
    ),
    'Natureza': ElementalInfo(
      name: 'Natureza', tier: 3, color: Color(0xFF4CAF50),
      advantages: ['Água', 'Terra'], disadvantages: ['Fogo', 'Gelo', 'Lodo'],
      narrativeLogic: 'Consome água e terra para crescer livremente.',
    ),

    // --- TIER 4 (Subtipos Físicos) ---
    'Cortante': ElementalInfo(
      name: 'Cortante',
      tier: 4,
      color: Color(0xFF9E9E9E), // Cinza Prateado
      advantages: ['Carne', 'Armaduras Leves', 'Natureza'],
      disadvantages: ['Pedra', 'Armaduras Pesadas'],
      narrativeLogic: 'Cortes limpos causam sangramento contínuo. Excelente contra alvos macios, mas ineficaz contra rochas ou placas de metal grossas.',
    ),
    'Impacto': ElementalInfo(
      name: 'Impacto',
      tier: 4,
      color: Color(0xFF5D4037), // Marrom Escuro
      advantages: ['Armaduras Pesadas', 'Esqueletos', 'Gelo', 'Terra'],
      disadvantages: ['Amortecimento', 'Água', 'Lodo'],
      narrativeLogic: 'Ignora a dureza externa quebrando o alvo por dentro com força concussiva bruta. Muito fraco contra oponentes elásticos ou maleáveis.',
    ),
    'Perfurante': ElementalInfo(
      name: 'Perfurante',
      tier: 4,
      color: Color(0xFF424242), // Cinza Escuro
      advantages: ['Pontos Vitais', 'Escamas', 'Couro'],
      disadvantages: ['Escudos Grandes', 'Placas Grossas'],
      narrativeLogic: 'Concentra toda a força cinética num único ponto minúsculo para atravessar defesas e atingir diretamente os órgãos vitais do oponente.',
    ),
  };
}