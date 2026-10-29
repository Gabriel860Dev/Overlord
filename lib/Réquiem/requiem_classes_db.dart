// lib/Réquiem/requiem_classes_db.dart

import 'package:overlord/Réquiem/requiem_class.dart';

class RequiemClassesDB {
  static const List<RequiemClass> classes = [
    RequiemClass(
      name: 'Sem Classe',
      description: 'Um aventureiro iniciante que ainda não escolheu o seu caminho ou despertou seus poderes.',
      baseHp: 10, 
      hpPerLevel: 2,
      resourceType: 'Nenhum', 
      baseResource: 0, 
      resourcePerLevel: 0,
      baseStamina: 1,
      passives: [],
      initialAbilities: [],
    ),
    RequiemClass(
      name: 'Guerreiro',
      description: 'Mestres do combate físico e corpo a corpo. Dependem de vigor e força bruta para executar manobras destrutivas e suportar grandes danos.',
      baseHp: 30, 
      hpPerLevel: 10,
      resourceType: 'Vigor', 
      baseResource: 15, 
      resourcePerLevel: 5,
      baseStamina: 5,
      passives: [
        'Cólera: Ao chegar a 30% da sua vida total, você recebe +2 pontos em Força, +2d6 de dano extra em seus ataques, e +2 nas perícias Luta e Esquiva.',
        'Postura de Combate: Pode alternar entre Postura Agressiva (+2 de dano, mas -2 de defesa) ou Postura Defensiva (+2 de defesa, mas -2 de dano).'
      ],
      initialAbilities: [
        'Ataque Feroz (Vigor): Um golpe desferido com força máxima para quebrar as defesas inimigas.'
      ],
    ),
    RequiemClass(
      name: 'Bárbaro',
      description: 'Guerreiros primitivos alimentados por fúria incontrolável. Trocam táticas e armaduras pesadas por ataques avassaladores e resistência brutal.',
      baseHp: 40, 
      hpPerLevel: 12,
      resourceType: 'Vigor', 
      baseResource: 10, 
      resourcePerLevel: 4,
      baseStamina: 6,
      passives: [
        'Fúria Implacável: Ao entrar em fúria, recebe resistência a danos físicos (corte, impacto, perfuração) e +2 de dano em ataques corpo a corpo.',
        'Instinto Selvagem: Você possui Vantagem em testes de Percepção para evitar surpresas.'
      ],
      initialAbilities: [
        'Ataque Temerário (Vigor): Você abre a própria guarda para desferir um ataque extremamente poderoso com Vantagem.'
      ],
    ),
    RequiemClass(
      name: 'Lutador',
      description: 'Especialistas focados no combate corpo a corpo extremo usando os punhos. Condicionamento físico absurdo e golpes destrutivos.',
      baseHp: 25, 
      hpPerLevel: 9, 
      resourceType: 'Vigor', 
      baseResource: 10, 
      resourcePerLevel: 10, 
      baseStamina: 5,
      staminaPerLevel: 9, 
      passives: [
        'Corpo Curtido: Seus punhos são armas letais. Você pode causar danos equivalentes a armas marciais usando apenas os punhos.',
        'Fôlego Inesgotável: Uma vez por combate, você pode recuperar uma parte do seu Vigor e Estamina rapidamente.'
      ],
      initialAbilities: [
        'Soco Cruzado (Vigor): Um golpe desarmado devastador focado no ponto vital do inimigo.'
      ],
    ),
    RequiemClass(
      name: 'Paladino',
      description: 'Combatentes divinos e resilientes, focados em proteger aliados, suporte mágico e canalizar milagres através da Mana.',
      baseHp: 35, 
      hpPerLevel: 10,
      resourceType: 'Mana', 
      baseResource: 15, 
      resourcePerLevel: 5,
      baseStamina: 3,
      passives: [
        'Aura Punitiva: Qualquer inimigo que o atacar corpo a corpo recebe 2d6 de dano mágico instantâneo (Requer ter pelo menos 4 de Mana disponíveis).',
        'Campeão de uma Divindade: Recebe um bônus constante de +2 em Atuação e Intuição.'
      ],
      initialAbilities: [
        'Smite/Golpe Divino (Mana): Imbui sua arma com poder sagrado causando dano explosivo.'
      ],
    ),
    RequiemClass(
      name: 'Clérigo',
      description: 'Os principais curandeiros e guias espirituais. Conduzem milagres poderosos e magias de proteção, vestindo armaduras e punindo os mortos-vivos.',
      baseHp: 25, 
      hpPerLevel: 8,
      resourceType: 'Mana', 
      baseResource: 15, 
      resourcePerLevel: 6,
      baseStamina: 3,
      passives: [
        'Domínio Divino: Suas magias de cura restauram 1d6 extra a cada 3 níveis de Clérigo.',
        'Expulsar as Sombras: Pode utilizar sua Ação para causar medo ou afastar criaturas corrompidas e mortos-vivos.'
      ],
      initialAbilities: [
        'Santa Mão (Mana): Uma cura direta ou canalização punitiva contra os impuros.'
      ],
    ),
    RequiemClass(
      name: 'Feiticeiro',
      description: 'Usuários inatos de magia e feitiços arcanos. Possuem uma vida extremamente frágil, mas compensam com estoques absurdos de Mana e feitiçaria rápida.',
      baseHp: 15, 
      hpPerLevel: 5,
      resourceType: 'Mana', 
      baseResource: 25, 
      resourcePerLevel: 10,
      baseStamina: 3,
      passives: [
        'Fluxo de Mana: Quando rolar qualquer dado para utilizar um feitiço, você recebe um bônus absoluto igual a metade do seu atributo ARC (Arcanismo) ou SAB (Sabedoria).'
      ],
      initialAbilities: [
        'Míssil Mágico (Mana): Conjura e dispara projéteis teleguiados de pura energia arcana.'
      ],
    ),
    RequiemClass(
      name: 'Mago',
      description: 'Estudiosos arcanos incansáveis. Utilizam tomos e grimórios para moldar a própria realidade, possuindo uma gama gigantesca de magias complexas.',
      baseHp: 12, 
      hpPerLevel: 4,
      resourceType: 'Mana', 
      baseResource: 30, 
      resourcePerLevel: 12,
      baseStamina: 2,
      passives: [
        'Grimório Estudado: O Mago pode aprender magias copiando-as de pergaminhos para o seu grimório, não se limitando apenas às ganhas por nível.',
        'Recuperação Arcana: Uma vez por dia, recupera metade da sua Mana máxima após um descanso curto.'
      ],
      initialAbilities: [
        'Raio Elemental (Mana): Dispara um raio fulminante do elemento que você escolher sintonizar.'
      ],
    ),
    RequiemClass(
      name: 'Bruxo',
      description: 'Indivíduos que fizeram pactos sombrios ou selaram contratos com entidades de outros planos em troca de poderes exóticos e magias restritas.',
      baseHp: 20, 
      hpPerLevel: 6,
      resourceType: 'Mana', 
      baseResource: 15, 
      resourcePerLevel: 5,
      baseStamina: 4,
      passives: [
        'Pacto de Sangue: Quando você reduz a vida de um inimigo a 0, você drena sua essência e ganha Pontos de Vida temporários.',
        'Rajada Oculta: O seu ataque mágico básico pode empurrar ou puxar o inimigo dependendo da sua sintonia.'
      ],
      initialAbilities: [
        'Maldição Sombria (Mana): Amaldiçoa um alvo, reduzindo sua defesa e fazendo-o receber dano contínuo de todos os seus ataques.'
      ],
    ),
    RequiemClass(
      name: 'Druida',
      description: 'Guardiões conectados à natureza e aos elementos primordiais. Capazes de manipular o ambiente a seu favor ou se transformar em bestas.',
      baseHp: 20, 
      hpPerLevel: 6,
      resourceType: 'Mana', 
      baseResource: 20, 
      resourcePerLevel: 6,
      baseStamina: 3,
      passives: [
        'Conexão com a Natureza: Todas as suas magias do tipo Planta/Terra custam -5 de mana. O dano que você recebe de ataques de Ar/Fogo é reduzido em 5 pontos.'
      ],
      initialAbilities: [
        'Mudar Forma (Mana): Permite assumir características ou a forma completa de animais selvagens.'
      ],
    ),
    RequiemClass(
      name: 'Caçador',
      description: 'Especialistas focados em alvejar fraquezas. Se destacam em nunca perder sua presa de vista, seja com arco a longa distância ou com lâminas rápidas.',
      baseHp: 20, 
      hpPerLevel: 8,
      resourceType: 'Vigor', 
      baseResource: 15, 
      resourcePerLevel: 4,
      baseStamina: 4,
      passives: [
        'Marca do Caçador: Uma vez por combate, você pode marcar um alvo. Você ganha Vantagem contra ele, +1d6 de dano extra em todos os ataques, e ele não pode ficar furtivo contra você.'
      ],
      initialAbilities: [
        'Tiro Preciso (Vigor): Um disparo focado nos pontos vitais do inimigo, que ignora parte da defesa.'
      ],
    ),
    RequiemClass(
      name: 'Ladino',
      description: 'Rápidos, mortais e sorrateiros. Se aproveitam de vantagens no campo de batalha para eliminar alvos com ataques furtivos e evitar receber danos.',
      baseHp: 20, 
      hpPerLevel: 6,
      resourceType: 'Vigor', 
      baseResource: 10, 
      resourcePerLevel: 3,
      baseStamina: 5,
      passives: [
        'Ataque Furtivo: Ao atacar com vantagem ou pegar o alvo flanqueado, causa +2d6 de dano extra. O dano aumenta em +1d6 a cada 2 níveis.',
        'Evasão: Ao fazer testes de reflexo para receber "metade do dano", em caso de sucesso você recebe 0 de dano. Em caso de falha, sofre apenas metade.'
      ],
      initialAbilities: [
        'Ataque Surpresa (Vigor): Um ataque rápido e furtivo saindo das sombras que foca no desequilíbrio.'
      ],
    ),
    RequiemClass(
      name: 'Monge',
      description: 'Especialistas absolutos em ataques desarmados contínuos, disciplina espiritual e evasão rápida sem depender de armaduras pesadas.',
      baseHp: 25, 
      hpPerLevel: 8,
      resourceType: 'Vigor', 
      baseResource: 10, 
      resourcePerLevel: 4,
      baseStamina: 6,
      passives: [
        'Rajada de Golpes: Sempre que realizar um ataque desarmado na sua ação padrão, você pode realizar um outro ataque desarmado usando uma ação bônus.',
        'Movimento sem Armadura: Seu deslocamento aumenta em +3m. Além disso, se não estiver usando armadura, sua Defesa passa a ser 10 + Destreza + Sabedoria.'
      ],
      initialAbilities: [
        'Passos do Vento (Vigor/Estamina): Permite desviar de ataques ou se mover em campo aberto sem gerar ataques de oportunidade.'
      ],
    ),
    RequiemClass(
      name: 'Bardo',
      description: 'Artistas e músicos mágicos. Focam em inspirar aliados e aplicar suportes fundamentais no meio do combate utilizando de suas atuações e alto carisma.',
      baseHp: 15, 
      hpPerLevel: 6,
      resourceType: 'Mana', 
      baseResource: 20, 
      resourcePerLevel: 5,
      baseStamina: 3,
      passives: [
        'Inspiração Bárdica: Pode conceder 1d6 extra a um aliado, que ele poderá somar em qualquer rolagem nos próximos 10 minutos.',
        'Versatilidade: O seu vasto conhecimento garante um bônus constante de +1 em todas as perícias nas quais você não possui proficiência.'
      ],
      initialAbilities: [
        'Canção de Descanso (Mana): Melhora ativamente a recuperação de pontos de vida e status dos aliados durante os períodos de descanso.'
      ],
    ),
  ];

  static RequiemClass? getClassByName(String name) {
    try {
      return classes.firstWhere((c) => c.name == name);
    } catch (e) {
      return null;
    }
  }

  static List<String> get classNames => classes.map((c) => c.name).toList();
}