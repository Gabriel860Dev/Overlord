// lib/data/requiem_races_db.dart

import 'package:overlord/Réquiem/requiem_race.dart';

class RequiemRacesDB {
  static const List<RequiemRace> races = [
    // --- RAÇAS COMUNS ---
    RequiemRace(
      name: 'Humano',
      description: 'Os humanos são os mais adaptáveis. É possível encontrar povoados humanos em quase todo lugar, e a moral, costumes e interesses dessa raça variam amplamente.',
      attributeBonuses: {'Intelecto': 3},
      skillBonuses: {'Sorte': 6},
      specialTraits: [
        'Passiva (Esforço Aplicado): Você poderá criar uma habilidade de estamina a mais na criação da ficha.'
      ],
    ),
    RequiemRace(
      name: 'Tiefling',
      description: 'Os Tieflings são uma raça de aparência bem variada, possuindo tonalidades de pele comuns aos humanos, mas também podendo assumir um tom avermelhado.',
      attributeBonuses: {'Arcanismo': 2}, // Nota: Arc ou Sab. +2 em qualquer um à escolha do jogador.
      skillBonuses: {'Sobrevivência': 3},
      specialTraits: [
        '+2 Pontos em qualquer Atributo à sua escolha (além do bônus base).',
        'Passiva (Herança Elemental): Escolha Fogo, Terra, Vento ou Água. Você pode criar uma habilidade a mais com base no elemento.'
      ],
    ),
    RequiemRace(
      name: 'Elfo',
      description: 'Raça antiga e mágica. São graciosos e sagazes, mas excessivamente orgulhosos — sempre acreditaram ser melhores que os outros povos.',
      attributeBonuses: {'Destreza': 3},
      skillBonuses: {'Sobrevivência': 6},
      specialTraits: [
        'Passiva (Amigo da Floresta): Facilidade em encontrar plantas. Para detectar perigo ou plantas raras, roda Sobrevivência com +5 de bônus.'
      ],
    ),
    RequiemRace(
      name: 'Elfo Negro',
      description: 'Semelhantes aos elfos, mas de pele negra como ébano e cabelos brancos/prateados. Mantêm uma relação de dominação com a floresta.',
      attributeBonuses: {'Arcanismo': 3, 'Intelecto': 2, 'Carisma': -1}, // Arc ou Sab
      skillBonuses: {},
      specialTraits: [
        'Passiva (Visão Obscura): Ignoram camuflagem. Detectam mana com facilidade (+5 de bônus no dado de Arc ou Sab).'
      ],
    ),
    RequiemRace(
      name: 'Dríade',
      description: 'Ninfas ou espíritos naturais femininos, a perfeita personificação da fertilidade da natureza.',
      attributeBonuses: {'Intelecto': 2, 'Arcanismo': 2, 'Constituição': 1}, // Arc ou Sab
      skillBonuses: {},
      specialTraits: [
        'Passiva (Regeneração Plantae): Pode regenerar ferimentos (ou perda total de membro) 3x por sessão. Cura escala a cada 2 Níveis.'
      ],
    ),
    RequiemRace(
      name: 'Anão',
      description: 'Seres de estatura baixa e barbudos. Mestres na mineração e forja, odeiam o sol e têm alta resistência mágica.',
      attributeBonuses: {'Constituição': 3, 'Força': 3, 'Carisma': -1},
      skillBonuses: {},
      specialTraits: [
        'Passiva (Resistência Mágica): A proficiência arcana não os afeta eficazmente. Todo dano arcano recebido é reduzido pela metade.'
      ],
    ),
    RequiemRace(
      name: 'Golias',
      description: 'Humanoides extremamente altos e fortes (2,30m a 3m), pesando em média 150kg.',
      attributeBonuses: {'Constituição': 2, 'Força': 2, 'Intelecto': -1},
      skillBonuses: {'Luta': 5},
      specialTraits: [
        'Passiva (Duro como Pedra): Resistência a danos cortantes. Recebem -25% de dano de corte tomado.'
      ],
    ),
    RequiemRace(
      name: 'Vampiro',
      description: 'Criaturas mortas-vivas noturnas que subsistem de sangue para se manterem vivos.',
      attributeBonuses: {'Força': 2, 'Destreza': 3},
      skillBonuses: {},
      specialTraits: [
        'Habilidade (Olhar Apavorante): Custa 25 Mana/Vigor. Causa medo em área (5m). Alvos precisam passar em teste de Vontade.'
      ],
    ),
    RequiemRace(
      name: 'Draconato',
      description: 'Dragões humanoides altos e fortes, cobertos de escamas, mas sem cauda.',
      attributeBonuses: {'Constituição': 2, 'Arcanismo': 2}, // Arc ou Sab, e +1 em For, Des ou Con
      skillBonuses: {},
      specialTraits: [
        '+1 ponto em Força, Destreza ou Constituição à sua escolha.',
        'Passiva (Visão na Penumbra): Enxergam 2x mais longe no escuro, distinguindo cores e detalhes.'
      ],
    ),
    RequiemRace(
      name: 'Kobold',
      description: 'Seres fracos, pequenos e inúteis em força, mas extremamente ágeis.',
      attributeBonuses: {'Destreza': 4, 'Intelecto': -1, 'Força': -1},
      skillBonuses: {},
      specialTraits: [
        'Habilidade (Bajulação Distrativa): Custo 0. Ação padrão para implorar, distraindo inimigos. Aliados ganham vantagem nos ataques próximos.'
      ],
    ),
    RequiemRace(
      name: 'Tritão',
      description: 'Sereias e tritões de torso humano e cauda de peixe. Podem adotar forma bípede em terra.',
      attributeBonuses: {'Destreza': 3, 'Intelecto': 2},
      skillBonuses: {},
      specialTraits: [
        '+10 pontos de dano ao usar lanças, azagaias ou tridentes.',
        'Passiva (Transformação Anfíbia): Respiram debaixo d\'água. Podem passar essa habilidade por 1 hora a quem os beijar ou engolir fio de cabelo.'
      ],
    ),
    RequiemRace(
      name: 'Githyanki',
      description: 'Conquistadores implacáveis de tom verde e orelhas pontiagudas, parecidos com orcs.',
      attributeBonuses: {'Arcanismo': 3}, // Sab ou Arc
      skillBonuses: {},
      specialTraits: [
        '+2 pontos extras baseados no elemento escolhido: Fogo(CAR), Água(INT), Terra(FOR) ou Vento(DES).',
        'Passiva (Resistência Ancestral): Nasce com um de 4 elementos e mitiga metade do dano recebido dele.'
      ],
    ),
    RequiemRace(
      name: 'Etergênito',
      description: 'Seres leves e etéreos. Seu peso diminui com a idade até retornarem à aethersphere.',
      attributeBonuses: {'Carisma': 2, 'Intelecto': 2, 'Arcanismo': 1}, // Arc ou Sab
      skillBonuses: {},
      specialTraits: [
        'Passiva (Além da Morte): Recebe só metade do dano necrótico. Retorna da morte se tirar 20 no dado ou 100 no teste de sorte.'
      ],
    ),
    RequiemRace(
      name: 'Replicante',
      description: 'Metamorfos sutis que viram espiões ao adotar a forma de outras criaturas.',
      attributeBonuses: {'Carisma': 2, 'Intelecto': 2},
      skillBonuses: {'Atuação': 3},
      specialTraits: [
        'Habilidade (Mudança de Forma): Custo 0. Assume a forma de qualquer humanoide já visto (equipamentos não mudam).'
      ],
    ),
    RequiemRace(
      name: 'Homem-Fera (Lobo)',
      description: 'Reserva e neutra. Humanoides com orelhas e cauda de lobo.',
      attributeBonuses: {'Força': 3},
      skillBonuses: {'Percepção': 3, 'Luta': 3},
      specialTraits: [
        'Passiva (Audição Apurada): Ouve a longas distâncias e através de paredes sem precisar rolar dados.'
      ],
    ),
    RequiemRace(
      name: 'Homem-Fera (Felino)',
      description: 'Humanoides com orelhas, cauda de felino e unhas como garras.',
      attributeBonuses: {'Destreza': 3},
      skillBonuses: {'Reflexo': 3, 'Sorte': 3},
      specialTraits: [
        'Passiva (Presas de Caça): Garras causam (2d6+2 de dano). A cada 5 pontos em DES o dano aumenta em +1d6.'
      ],
    ),
    RequiemRace(
      name: 'Homem-Fera (Boaz)',
      description: 'Humanoides com características de javali. Fortes e altamente resistentes.',
      attributeBonuses: {'Força': 2, 'Constituição': 3},
      skillBonuses: {},
      specialTraits: [
        'Passiva (Corpo de Ferro): Suas habilidades físicas garantem +10 pontos de vida por nível.'
      ],
    ),
    RequiemRace(
      name: 'Kenku',
      description: 'Humanoides semelhantes a corvos sem asas. Caóticos e focados em salvar as próprias peles.',
      attributeBonuses: {'Intelecto': 2, 'Arcanismo': 2}, // Arc ou Sab
      skillBonuses: {'Enganação': 3},
      specialTraits: [
        'Recebe um bônus de +10 absoluto em rolagens de Enganação.',
        'Passiva (Grasnar Chamativo): Imita vozes perfeitamente. Inimigos fazem Intuição vs Enganação para identificar.'
      ],
    ),
    RequiemRace(
      name: 'Naga',
      description: 'Metade humanos, metade serpentes/animais marinhos. Podem respirar ar e água.',
      attributeBonuses: {'Destreza': 2, 'Carisma': 3},
      skillBonuses: {},
      specialTraits: [
        'Habilidade (Olhar do Predador): Custa 25 Mana/Vigor. Paralisa a mente do alvo por 2 turnos ou até ele tomar dano.'
      ],
    ),

    // --- RAÇAS EXÓTICAS (Raridade extrema: requer 20 no d20) ---
    RequiemRace(
      name: 'Anjo (Exótica)',
      description: 'Seres angelicais com asas, olhos dourados e cabelos brancos. Possuem uma forma original e uma moldada a seu favor.',
      attributeBonuses: {'Arcanismo': 3, 'Intelecto': 3, 'Destreza': 2, 'Carisma': -1}, // Arc ou Sab
      skillBonuses: {},
      specialTraits: [
        'Passiva (Asas Divinas): Não voam, mas mitigam metade do dano sofrido 1x a cada 3 turnos (usando dado Arc/Sab).',
        'Habilidade (Reino Divino): Custa 50 M/V. Cria área de 5m que buffa (+25%) todas as suas ações (exceto dano) e de um aliado por 1d6 turnos.'
      ],
    ),
    RequiemRace(
      name: 'Demônio (Exótica)',
      description: 'Seres de tom avermelhado/cinza com chifres e cauda. O completo oposto do anjo.',
      attributeBonuses: {'Arcanismo': 3, 'Força': 3, 'Constituição': 2, 'Carisma': -1}, // Arc ou Sab
      skillBonuses: {},
      specialTraits: [
        'Passiva (Visão do Outro Lado): Sente magia no ar. Rola Arc/Sab + Percepção +20% para identificar aprofundado.',
        'Habilidade (Benção das Sombras): Custa 50 M/V. Área de 7m que buffa você (+4 Atributo/+6 Perícia) e debuffa inimigos (-2/-3).'
      ],
    ),
    RequiemRace(
      name: 'Anjo Corrompido (Exótica)',
      description: 'Um anjo que consumiu carne mortal, agora com aparência demoníaca e asas definhadas. Precisa consumir sangue.',
      attributeBonuses: {'Arcanismo': 4, 'Intelecto': 2, 'Destreza': 3, 'Carisma': -2}, // Arc ou Sab
      skillBonuses: {},
      specialTraits: [
        'Passiva (Asas do Agouro): Lança espinhos de osso 1x a cada 3 turnos causando 1d20 de dano perfurante de sangue.',
        'Habilidade (Memórias da Antiga Glória): Custa 35 M/V. Imbui a arma para dar 3d6+8 de dano sombrio (+1d6 a cada 3 Níveis).'
      ],
    ),
    RequiemRace(
      name: 'Demônio Corrompido (Exótica)',
      description: 'Extremamente parecido com o demônio, apenas com uma aura diferente. Precisa consumir sangue mortal.',
      attributeBonuses: {'Arcanismo': 4, 'Força': 4, 'Constituição': 1, 'Carisma': -2}, // Arc ou Sab
      skillBonuses: {},
      specialTraits: [
        'Passiva (Combo Breaker): O terceiro acerto bem sucedido causa 30% a mais de dano, ignorando passivas do oponente.',
        'Habilidade (Retaliação Abissal): Custa 35 M/V. Lança cortes ignorando direção, causando 2d8+4 de dano mágico (+1d8 a cada 3 Níveis).'
      ],
    ),
  ];

  static RequiemRace? getRaceByName(String name) {
    try {
      return races.firstWhere((r) => r.name == name);
    } catch (e) {
      return null;
    }
  }

  static List<String> get raceNames => races.map((r) => r.name).toList();
}