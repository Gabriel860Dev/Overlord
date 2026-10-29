// lib/localization.dart

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

class AppStrings {
  final Locale locale;

  AppStrings(this.locale);

  static AppStrings of(BuildContext context) {
    return Localizations.of<AppStrings>(context, AppStrings) ?? AppStrings(const Locale('pt'));
  }

  // Mapa de tradução para termos técnicos (Status, Atributos, Perícias)
  static const Map<String, String> _ptToEnTerms = {
    // Status
    'Vida': 'Health',
    'Esforço': 'Effort',
    'Sanidade': 'Sanity',
    'Loucura': 'Madness',
    'Esforço Temporário': 'Temp. Effort',
    
    // Atributos
    'FOR': 'STR', 'CON': 'CON', 'DES': 'DEX', 
    'INT': 'INT', 'SAB': 'WIS', 'CAR': 'CHA',
    
    // Perícias
    'Acrobacia': 'Acrobatics', 'Atletismo': 'Athletics', 'Adestramento': 'Animal Handling',
    'Guerra': 'Warfare', 'Pontaria': 'Marksmanship', 'Oculto': 'Occultism',
    'Presença': 'Presence', 'Percepção': 'Perception', 'Pilotagem': 'Piloting',
    'Diplomacia': 'Diplomacy', 'Tatico': 'Tactics', 'Enganação': 'Deception',
    'Atuação': 'Performance', 'Ladinagem': 'Thievery', 'Artes-marciais': 'Martial Arts',
    'Sobrevivencia': 'Survival', 'Eclético': 'Eclectic', 'Direção': 'Driving',
    'Atualidades': 'Current Affairs', 'Montaria': 'Riding', 'Primeiros socorros': 'First Aid',
    'Tecnologia': 'Technology', 'Intimidação': 'Intimidation', 'Sorte': 'Luck',
    'Furtividade': 'Stealth', 'Poder de fogo': 'Firepower', 'Investigação': 'Investigation',
    'Reflexo': 'Reflex', 'Conhecimento ParaNormal': 'Paranormal Knowledge', 'Mente': 'Mind',
    'Memoria': 'Memory', 'Iniciativa': 'Initiative', 'Intuição': 'Intuition',
    'Vontade': 'Willpower', 'Esgrima': 'Fencing', 'Antiguidade': 'Antiquity',
  };

  static const Map<String, Map<String, String>> _localizedValues = {
    'en': {
      // --- Geral ---
      'app_title': 'Overlord',
      'cancel': 'Cancel',
      'save': 'Save',
      'delete': 'Delete',
      'confirm': 'Confirm',
      'close': 'Close',
      'apply': 'Apply',
      'ok': 'OK',
      'yes': 'Yes',
      'no': 'No',
      'edit': 'Edit',
      'remove': 'Remove',
      'modify': 'Modify',

      // --- Import/Export ---
      'import_sheet': 'Import Sheet',
      'export_sheet': 'Export Sheet',
      'share_sheet': 'Share / Export',
      'paste_code': 'Paste the sheet code here:',
      'invalid_code': 'Invalid code.',
      'import_success': 'Sheet imported successfully!',
      'export_error': 'Error exporting:',

      // --- Menu & Navegação ---
      'table': 'Table',
      'history': 'History',
      'sheets': 'Sheets',
      'settings': 'Settings',
      'help': 'Help',
      'about': 'About',
      'rate_app': 'Rate App',
      'clear_history': 'Clear History',
      'add_custom_die': 'Add Custom Die',
      'new_sheet': 'New Sheet',
      'dice_roller_subtitle': 'Tap the die and good luck!',
      'history_subtitle': 'Roll History',
      'sheets_subtitle': 'Character Sheets',
      'backpack_subtitle': 'Backpack & Equipment',

      // --- Ficha ---
      'general': 'General',
      'skills': 'Skills',
      'combat': 'Combat',
      'abilities': 'Abilities',
      'passives': 'Passives',
      'backpack': 'Backpack',
      'effects': 'Effects',
      'name': 'Name',
      'class': 'Class',
      'level': 'Level',
      'status': 'Status',
      'attributes': 'Attributes',
      'armor': 'Armor',
      'total_armor': 'Total Armor',
      'equipped_weapons': 'Equipped Weapons',
      'block': 'Block',
      'parry': 'Parry',
      'actions': 'Actions',
      'round_plus': '+ Round',
      'rest': 'Rest',
      'combat_end': 'End Combat',
      'block_damage': 'Block Damage',
      'damage_received': 'Damage Received',
      'damage_type': 'Damage Type',
      'roll_dice': 'Roll Dice',
      'quantity': 'QTY',
      'modifier': 'MOD',
      'dice': 'Dice',
      'max': 'Max',
      'life': 'Health',
      'effort': 'Effort',
      'sanity': 'Sanity',
      'madness': 'Madness',
      'temp_effort': 'Temp. Effort',

      // --- Mensagens ---
      'fallen_message': 'You have fallen!',
      'insufficient_resources': 'Insufficient resources.',
      'combat_end_msg': 'Combat ended. Reset complete.',
      'rest_msg': 'Rested. HP/Effort restored.',
      'round_msg': 'Round advanced.',
      'armor_repaired': 'repaired.',
      'item_created': 'created.',
      'cooldown_msg': 'is on cooldown for',
      'ready_msg': 'is ready.',
      'delete_sheet_title': 'Delete Sheet?',
      'delete_sheet_confirm': 'Delete sheet for',
      'irreversible_action': 'This action is irreversible.',
      'backpack_empty': 'Backpack is empty.',
      'history_empty': 'History is empty.',
      'no_sheets': 'No sheets created.',
      'no_abilities': 'No abilities added.',
      'no_effects': 'No active effects.',

      // --- Configurações ---
      'language': 'Language',
      'theme_visuals': 'Theme & Visuals',
      'select_theme': 'Select Theme',
      'custom_colors': 'Custom Colors',
      'primary_color': 'Primary',
      'accent_color': 'Accent',
      'text_color': 'Text',

      // --- Diálogos ---
      'gains_per_level': 'Gains per Level',
      'life_per_level': 'Health/Level',
      'effort_per_level': 'Effort/Level',
      'sanity_per_level': 'Sanity/Level',
      'attr_points_level': 'Attr Points/Level',
      'skill_points_level': 'Skill Points/Level',
      'life_per_con': 'Health/CON',
      'effort_per_wis': 'Effort/WIS',
      'effort_per_dex': 'Effort/DEX',
      'total_attr_distribute': 'Total Attr Points',
      'total_skill_distribute': 'Total Skill Points',
      'add_image': 'Add Image',
      'select_gallery': 'Select from Gallery',
      'remove_image': 'Remove Image',
      'add_skills': 'Add Skills',
      'select_skills': 'Select Skills',

      // --- AJUDA (HELP) ---
      'help_guide_title': 'Application Guide',
      'help_table_title': 'Dice Table',
      'help_table_desc': 'Tap any die to roll. Use QTY and MOD buttons below to adjust quantity and modifiers.',
      'help_custom_die_title': 'Custom Dice',
      'help_custom_die_desc': 'In the menu (three dots), select "Add Custom Die". To delete a custom die, long press it.',
      'help_sheets_title': 'Character Sheets',
      'help_sheets_desc': 'Manage attributes, inventory and abilities. Toggle between Tab view and Classic view using the top icon. Share/Export sheets via the 3-dot menu on the sheet card.',
      'help_history_title': 'History',
      'help_history_desc': 'All rolls are saved. View details like individual dice, bonuses, and triggers.',
      
      'help_fatigue_title': 'System: Fatigue',
      'help_fatigue_desc': 'Prevents ability spam. Cost increases with each use in the same combat.\n\n• 1st Use: Normal Cost\n• 2nd Use (Fatigue 1): Cost + 30%\n• 3rd Use (Fatigue 2): Cost + 60%\n• 4th Use (Fatigue 3): Cost x 2\n• 5th Use (Fatigue 4): Cost x 2.5\n• 6th Use (Fatigue 5): Cost x 3\n• 7th Use (Fatigue 6): Cost x 4\n• 8th Use (Fatigue 7): Cost x 5\n• 9th+ Use (Fatigue 8): Cost x 7\n\nFatigue resets when using "End Combat" or "Rest".',
      
      'help_parry_title': 'System: Parry (Counter-Attack)',
      'help_parry_desc': 'Special action to cancel the opponent\'s attack and reflect damage. Victory is based on CRITS (max die value), not sum. Cooldown: 1 turn (Use on T1 -> Available T3).',
      'help_parry_mech_title': 'General Mechanics',
      'help_parry_mech_desc': '• Contest: Decided by amount of CRITICALS (max die value).\n• Example: 4d2 rolling "3, 4" (1 crit) beats 4d2 rolling "3, 3" (0 crits).\n• Win: Reflect damage +20%.\n• Loss: Take damage +20%, lose turn, weakness (lose 1 parry die for 2 rounds).\n• Draw: Split damage 50/50.',
      'help_parry_c_title': 'Common Parry (d4)',
      'help_parry_c_desc': '• Start: 4d2.\n• Evolution: +1 die per 4 Attributes + 4 Skills sacrificed.\n• Limit: 4d6.\n• Draw: 50% vs 50%.',
      'help_parry_a_title': 'Advanced Parry (d8)',
      'help_parry_a_desc': '• Unlock: At 4d6 Common.\n• Start: 8d2.\n• Evolution: +1 die per 6 Attributes + 6 Skills sacrificed.\n• Vs Lower: Opponent (Common) needs 1 mandatory crit to contest.\n• Win: Reflect +40%.\n• Loss: Take +40%, Exposure (+20% incoming dmg next 2 attacks).\n• Draw: 40% (Adv) vs 60% (Com).',
      'help_parry_s_title': 'Super Parry (d12)',
      'help_parry_s_desc': '• Unlock: At 8d6 Advanced.\n• Start: 12d4.\n• Evolution: +1 die per 8 Attributes + 8 Skills sacrificed.\n• Vs Lower: Your crits count as 1.5x. Opponent needs 1 mandatory crit.\n• Draw: 35% (Sup) vs 65% (Adv).',
      'help_parry_g_title': 'God Parry (d20)',
      'help_parry_g_desc': '• Unlock: At 12d8 Super.\n• Start: 20d3.\n• Evolution: 12 ATR/13 SKL (20d6) -> 15/15 (20d8) -> 20/20 (20d10).\n• Vs Lower: Opponent needs 2 mandatory crits. Your crits count as 2x.\n• Win: Reflect 80%, +25% to all tests (2 rounds). Opponent loses 25% attributes/magic.\n• Special: Can parry Skills/Rituals (except mental).\n• Draw: 20% (God) vs 80% (Sup).',
      
      'help_actions_title': 'Action Types',
      'help_action_move_title': 'Movement',
      'help_action_move_desc': 'Run, climb, draw/switch weapons.',
      'help_action_attack_title': 'Attack',
      'help_action_attack_desc': 'Direct attacks with weapons or offensive skills.',
      'help_action_free_title': 'Free Action',
      'help_action_free_desc': 'Social tests (Deception, Diplomacy), using consumables (potions), throwing items.',
      'help_action_skill_title': 'Skill/Ability',
      'help_action_skill_desc': 'Depends on description. May consume attack or other actions.',
      'help_action_passive_title': 'Passives',
      'help_action_passive_desc': 'No cost, but may have activation conditions.',
      'help_action_reaction_title': 'Reaction',
      'help_action_reaction_desc': '"Jão never defined a limit so I didn\'t know what to put here". Includes Block, Parry, Dodge. "I repeat, Jão never said if parry can be used as a team".',
      'help_action_joint_title': 'Joint Actions',
      'help_action_joint_desc': 'Hold your round to act with an ally. You only act on your ally\'s turn (except reactions).',

      'help_other_title': 'Other Rules',
      'help_fallen_title': 'Fallen State',
      'help_fallen_desc': 'When Health reaches 0 or less, you fall. A red X marks your avatar.',
      'help_dmg_type_title': 'Damage Types',
      'help_dmg_type_desc': 'Items/Passives can boost specific damage types (Fire, Ice). Select the type when creating the item.',
      'help_confirm_title': 'Confirm Values',
      'help_confirm_desc': 'When manually editing Health/Sanity, the value only updates (and triggers passives) when you confirm (OK on keyboard) or tap outside.',
    },
    'pt': {
      // Geral
      'app_title': 'Overlord',
      'cancel': 'Cancelar',
      'save': 'Salvar',
      'delete': 'Excluir',
      'confirm': 'Confirmar',
      'close': 'Fechar',
      'apply': 'Aplicar',
      'ok': 'OK',
      'yes': 'Sim',
      'no': 'Não',
      'edit': 'Editar',
      'remove': 'Remover',
      'modify': 'Modificar',

      // Import/Export
      'import_sheet': 'Importar Ficha',
      'export_sheet': 'Exportar Ficha',
      'share_sheet': 'Partilhar / Exportar',
      'paste_code': 'Cole o código da ficha aqui:',
      'invalid_code': 'Código inválido.',
      'import_success': 'Ficha importada com sucesso!',
      'export_error': 'Erro ao exportar:',

      // Menu & Navegação
      'table': 'Mesa',
      'history': 'Histórico',
      'sheets': 'Fichas',
      'settings': 'Configurações',
      'help': 'Ajuda',
      'about': 'Sobre',
      'rate_app': 'Avaliar App',
      'clear_history': 'Apagar Histórico',
      'add_custom_die': 'Adicionar Novo Dado',
      'new_sheet': 'Nova Ficha',
      'dice_roller_subtitle': 'Toque no dado e boa sorte!',
      'history_subtitle': 'Histórico de Rolagens',
      'sheets_subtitle': 'Fichas de Personagem',
      'backpack_subtitle': 'Mochila e Equipamentos',

      // Ficha
      'general': 'Geral',
      'skills': 'Perícias',
      'combat': 'Combate',
      'abilities': 'Habilidades',
      'passives': 'Passivas',
      'backpack': 'Mochila',
      'effects': 'Efeitos',
      'name': 'Nome',
      'class': 'Classe',
      'level': 'Nível',
      'status': 'Status',
      'attributes': 'Atributos',
      'armor': 'Armadura',
      'total_armor': 'Armadura Total',
      'equipped_weapons': 'Armas Equipadas',
      'block': 'Bloqueio',
      'parry': 'Parry',
      'actions': 'Ações',
      'round_plus': '+ Round',
      'rest': 'Descansar',
      'combat_end': 'Fim de Combate',
      'block_damage': 'Bloquear Dano',
      'damage_received': 'Dano Recebido',
      'damage_type': 'Tipo de Dano',
      'roll_dice': 'Rolar Dados',
      'quantity': 'QTD',
      'modifier': 'MOD',
      'dice': 'Dados',
      'max': 'Máx',
      'life': 'Vida',
      'effort': 'Esforço',
      'sanity': 'Sanidade',
      'madness': 'Loucura',
      'temp_effort': 'Esforço Temp.',

      // Mensagens
      'fallen_message': 'Você caiu!',
      'insufficient_resources': 'Recursos insuficientes.',
      'combat_end_msg': 'Combate finalizado. Reset completo.',
      'rest_msg': 'Descansou. Vida/Esforço restaurados.',
      'round_msg': 'Round avançado.',
      'armor_repaired': 'foi reparada.',
      'item_created': 'foi criada.',
      'cooldown_msg': 'está em cooldown.',
      'ready_msg': 'está pronta.',
      'delete_sheet_title': 'Excluir Ficha?',
      'delete_sheet_confirm': 'Tem certeza que deseja excluir a ficha de',
      'irreversible_action': 'Esta ação é irreversível.',
      'backpack_empty': 'Mochila vazia.',
      'history_empty': 'Histórico vazio.',
      'no_sheets': 'Nenhuma ficha criada.',
      'no_abilities': 'Nenhuma habilidade adicionada.',
      'no_effects': 'Nenhum efeito ativo.',

      // Configurações
      'language': 'Idioma',
      'theme_visuals': 'Tema e Visual',
      'select_theme': 'Selecionar Tema',
      'custom_colors': 'Cores Personalizadas',
      'primary_color': 'Cor Primária',
      'accent_color': 'Cor de Destaque',
      'text_color': 'Cor do Texto',

      // Diálogos
      'gains_per_level': 'Ganhos por Nível',
      'life_per_level': 'Vida por Nível',
      'effort_per_level': 'Esforço por Nível',
      'sanity_per_level': 'Sanidade por Nível',
      'attr_points_level': 'Pontos de Atributo por Nível',
      'skill_points_level': 'Pontos de Perícia por Nível',
      'life_per_con': 'Vida por ponto de CON',
      'effort_per_wis': 'Esforço por ponto de SAB',
      'effort_per_dex': 'Esforço por ponto de DES',
      'total_attr_distribute': 'Total de Pontos de Atributo a distribuir',
      'total_skill_distribute': 'Total de Pontos de Perícia a distribuir',
      'add_image': 'Adicionar Imagem',
      'select_gallery': 'Selecionar da Galeria',
      'remove_image': 'Remover Imagem',
      'add_skills': 'Adicionar Perícias',
      'select_skills': 'Selecionar Perícias',

      // --- AJUDA COMPLETA ---
      'help_guide_title': 'Guia da Aplicação',
      'help_table_title': 'Mesa de Dados',
      'help_table_desc': 'Toque num dado para rolar. Use os botões QTD e MOD abaixo para ajustar a quantidade e os modificadores.',
      'help_custom_die_title': 'Dados Personalizados',
      'help_custom_die_desc': 'No menu (três pontos), escolha "Adicionar novo dado". Para apagar um dado personalizado, mantenha o dedo pressionado sobre ele.',
      'help_sheets_title': 'Fichas de Personagem',
      'help_sheets_desc': 'Gerencie atributos, inventário e habilidades. Alterne entre abas e visual "Clássico" no ícone do topo. Use o menu da ficha para Importar/Exportar.',
      'help_history_title': 'Histórico',
      'help_history_desc': 'Registo detalhado de todas as rolagens, incluindo dados individuais, bónus aplicados e gatilhos ativados.',
      
      'help_fatigue_title': 'Sistema: Fadiga',
      'help_fatigue_desc': 'Aumenta o custo de habilidades repetidas no combate. Zera ao Descansar.\n\n• 1º Uso: Normal\n• 2º Uso (Fadiga 1): Custo + 30%\n• 3º Uso (Fadiga 2): Custo + 60%\n• 4º Uso (Fadiga 3): Custo x 2\n• 5º Uso (Fadiga 4): Custo x 2.5\n• 6º Uso (Fadiga 5): Custo x 3\n• 7º Uso (Fadiga 6): Custo x 4\n• 8º Uso (Fadiga 7): Custo x 5\n• 9º+ Uso (Fadiga 8): Custo x 7\n\nUse a ação "Fim de Combate" ou "Descansar" para zerar a fadiga.',
      
      'help_parry_title': 'Sistema: Parry (Aparar)',
      'help_parry_desc': 'Cancela ataque e devolve dano. Vitória decidida por quantidade de CRÍTICOS (valor máximo), não soma. Cooldown: 1 turno.',
      'help_parry_mech_title': 'Mecânicas Gerais',
      'help_parry_mech_desc': '• Sistema de Disputa: A vitória é decidida pela quantidade de CRÍTICOS (valor máximo do dado), não pela soma total.\n• Exemplo: 4d2 com "3, 4" (1 crítico) vence 4d2 com "3, 3" (0 críticos).\n• Empate: Dano dividido 50/50.',
      
      'help_parry_c_title': 'Parry Comum (d4)',
      'help_parry_c_desc': '• Início: 4d2 (Dados de 2 lados).\n• Evolução: Ganha +1 dado (4d3...) a cada 4 Atributos + 4 Perícias sacrificadas.\n• Limite: 4d6.\n• Vitória: Devolve o dano + 20%.\n• Derrota: Recebe o dano + 20%, perde o turno e fica com fraqueza (perde 1 dado de parry por 2 rounds).',
      
      'help_parry_a_title': 'Parry Avançado (d8)',
      'help_parry_a_desc': '• Desbloqueio: Ao atingir 4d6 no Parry Comum.\n• Início: 8d2.\n• Evolução: Ganha +1 dado a cada 6 Atributos + 6 Perícias sacrificadas.\n• Regra vs Inferior: Oponente com Parry Comum precisa de 1 crítico obrigatório apenas para começar a disputar.\n• Vitória: Devolve o dano + 40%.\n• Derrota: Recebe o dano + 40% e ganha "Exposição" (próximos 2 ataques recebidos têm bónus de 20%).\n• Empate: 40% (Avançado) vs 60% (Comum).',
      
      'help_parry_s_title': 'Parry Super (d12)',
      'help_parry_s_desc': '• Desbloqueio: Ao acumular 8d6 no Parry Avançado.\n• Início: 12d4.\n• Evolução: Ganha +1 dado a cada 8 Atributos + 8 Perícias sacrificadas.\n• Regra vs Inferior: Cada crítico seu conta como 1.5 críticos normais. Oponente precisa de 1 crítico obrigatório.\n• Empate: 35% (Super) vs 65% (Avançado).',
      
      'help_parry_g_title': 'Parry God (d20)',
      'help_parry_g_desc': '• Desbloqueio: Ao acumular 12d8 no Parry Super.\n• Início: 20d3.\n• Evolução: 12 ATR/13 PER (20d6) -> 15/15 (20d8) -> 20/20 (20d10).\n• Regra vs Inferior: Oponente precisa de 2 críticos obrigatórios. Cada crítico do God vale por 2 críticos normais.\n• Vitória: Devolve 80% do dano. O usuário ganha +25% em todos os testes por 2 rounds. Oponente perde 25% em todos os atributos e perde a ação mágica por 2 rounds.\n• Especial: Pode aparar Habilidades e Rituais (exceto mentais).\n• Empate: 20% (God) vs 80% (Super).',
      
      'help_actions_title': 'Tipos de Ações',
      'help_action_move_title': 'Movimento',
      'help_action_move_desc': 'Correr, escalar, e mudar/sacar a sua arma são ações de movimento.',
      'help_action_attack_title': 'Ataque',
      'help_action_attack_desc': 'Utilizada para ataques diretos com a sua arma e/ou habilidade ofensiva.',
      'help_action_free_title': 'Livre',
      'help_action_free_desc': 'Testes de enganação, carisma, diplomacia e outras não relacionadas diretamente ao combate. Uso de consumíveis (poções) e arremesso de itens.',
      'help_action_skill_title': 'Habilidade',
      'help_action_skill_desc': 'Depende da descrição da habilidade. Pode consumir uma ação de habilidade e uma de outro tipo.',
      'help_action_passive_title': 'Passivas',
      'help_action_passive_desc': 'Não consomem ação alguma, mas podem ter condições específicas de ativação.',
      'help_action_reaction_title': 'Reação',
      'help_action_reaction_desc': '"O maldito do jão nunca definiu um limite então não sabia o que colocar aqui". Pode usar Block, Parry, Esquiva, seja sozinho ou em equipe. "Volto a dizer que o maldito do Jão nunca disse se o parry pode ser utilizado em equipe".',
      'help_action_joint_title': 'Ações Conjuntas',
      'help_action_joint_desc': 'Para usar ações conjuntas é necessário guardar o seu round. Se ganhar na iniciativa e quiser agir com um aliado, precisa guardar o round. Só voltará a agir no round do seu aliado (exceto ações de reação).',

      'help_other_title': 'Outras Regras',
      'help_fallen_title': 'Estado "Caído"',
      'help_fallen_desc': 'Quando a vida chega a 0, o aviso "Você caiu" aparece e a foto do personagem fica marcada com um X vermelho.',
      'help_dmg_type_title': 'Tipos de Dano',
      'help_dmg_type_desc': 'Itens e Passivas podem aumentar especificamente um tipo de dano (ex: +20% Fogo). Ao criar um item, selecione o tipo de dano na lista de alvos.',
      'help_confirm_title': 'Confirmação de Valores',
      'help_confirm_desc': 'Ao alterar Vida, Sanidade ou Esforço manualmente, o valor só é atualizado (e as passivas disparadas) quando você confirma no teclado (Ok) ou clica fora do campo.',
    },
  };

  String get(String key) {
    return _localizedValues[locale.languageCode]?[key] ?? key;
  }

  String translateTerm(String term) {
    if (locale.languageCode == 'en') {
      return _ptToEnTerms[term] ?? term;
    }
    return term;
  }
}

class AppLocalizationsDelegate extends LocalizationsDelegate<AppStrings> {
  const AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => ['pt', 'en'].contains(locale.languageCode);

  @override
  Future<AppStrings> load(Locale locale) {
    return SynchronousFuture<AppStrings>(AppStrings(locale));
  }

  @override
  bool shouldReload(AppLocalizationsDelegate old) => false;
}