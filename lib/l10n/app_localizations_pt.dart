// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Portuguese (`pt`).
class AppLocalizationsPt extends AppLocalizations {
  AppLocalizationsPt([String locale = 'pt']) : super(locale);

  @override
  String get appName => 'Dark Age';

  @override
  String get diceRollerSubtitle => 'Toque no dado e boa sorte!';

  @override
  String get historySubtitle => 'Histórico de Rolagens';

  @override
  String get characterSheetsSubtitle => 'Fichas de Personagem';

  @override
  String get noSheets => 'Nenhuma ficha criada.\nToque em + para adicionar uma nova.';

  @override
  String get deleteSheetTitle => 'Excluir Ficha?';

  @override
  String deleteSheetContent(Object sheetName) {
    return 'Tem certeza que deseja excluir a ficha de $sheetName?';
  }

  @override
  String get cancel => 'Cancelar';

  @override
  String get delete => 'Excluir';

  @override
  String get newSheetTitle => 'Nova Ficha';

  @override
  String get tabGeneral => 'Geral';

  @override
  String get tabSkills => 'Perícias';

  @override
  String get tabCombat => 'Combate';

  @override
  String get tabAbilities => 'Habilidades';

  @override
  String get tabPassives => 'Passivas';

  @override
  String get tabBackpack => 'Mochila';

  @override
  String get tabBuffs => 'Buffs/Debuffs';

  @override
  String get helpTitle => 'Guia Completo';

  @override
  String get helpSectionCoreTitle => 'Mecânicas Principais: Sistema Dark Age';

  @override
  String get helpCoreLogicTitle => 'Lógica de Dados (Maestria e Proficiência)';

  @override
  String get helpCoreLogicDesc => 'Em vez de somar pontos aos dados, o nível de perícia do personagem (Novato, Treinado, Mestre) e o nível de Proficiência (I, II, III...) determinam o *tipo* de dado rolado. Cada 5 pontos num atributo ou perícia concedem um dado, cujo tipo é determinado pelo nível mais alto alcançado (Novato -> d12, Treinado/Mestre -> d20, PI -> d30, etc.). Os pontos 1-4 concedem dados progressivamente melhores dentro dessa escala.';

  @override
  String get helpMaestriaTitle => 'Maestria de Perícia (Novato, Treinado, Mestre)';

  @override
  String get helpMaestriaDesc => '• Novato: Nível base, rola d4-d10, fecha um d12 a cada 5 pontos.\n• Treinado (T): Escala de dados aumentada (d6-d12), fecha um d20 a cada 5 pontos.\n• Mestre (M): Mesmos dados do Treinado, mas adiciona um bónus fixo massivo igual ao valor da perícia/atributo à rolagem E desbloqueia a Proficiência.';

  @override
  String get helpProficienciaTitle => 'Proficiência (I, II, III...)';

  @override
  String get helpProficienciaDesc => 'Uma melhoria avançada comprada com \'Pontos de Proficiência\' (P) após atingir Mestre. Cada nível (I, II, III...) aumenta ainda mais a escala de dados (fechando d30, d40, d50...) e fornece um pequeno bónus percentual passivo (+10% por nível) ao valor base.';

  @override
  String get helpSectionCombatTitle => 'Combate: Maestria de Armas & Ferimentos Graves';

  @override
  String get helpWeaponMaestriaTitle => 'Maestria de Arma (Nível 0-4)';

  @override
  String get helpWeaponMaestriaDesc => 'Cada tipo de arma tem uma árvore de maestria única (Nível 0-4) que melhora os seus stats (Acerto, Chance/Dano Crítico, Scaling) e concede uma habilidade especial poderosa no Nível 4, frequentemente melhorando o sistema de Ferimentos Graves.';

  @override
  String get helpFerimentosTitle => 'Ferimentos Graves';

  @override
  String get helpFerimentosDesc => 'Acertos críticos (baseados numa rolagem de d100 vs a base crítica da arma) que excedem uma certa percentagem da vida atual ou total do alvo despoletam um efeito devastador baseado no tipo de dano. O alvo deve ter sucesso num teste de Vigor (CD = Dano Recebido) para mitigar o efeito.';

  @override
  String get helpFerimentosCortante => 'Cortante (Amputação)';

  @override
  String get helpFerimentosCortanteDesc => 'Limiar: >50% vida atual ou >40% vida total. Falha no teste de Vigor resulta em amputação do membro.';

  @override
  String get helpFerimentosPerfurante => 'Perfurante (Dano a Órgãos)';

  @override
  String get helpFerimentosPerfuranteDesc => 'Limiar: >40% vida atual ou >25% vida total. Falha no teste de Vigor resulta em dano a um órgão específico (pulmão, coração, etc.).';

  @override
  String get helpFerimentosImpacto => 'Impacto (Fraturas/Trauma)';

  @override
  String get helpFerimentosImpactoDesc => 'Limiar: >60% vida atual ou >25% vida total. Falha no teste de Vigor resulta em ossos partidos, concussão ou paralisia.';

  @override
  String get helpFerimentosDilacerante => 'Dilacerante (Mutilação)';

  @override
  String get helpFerimentosDilaceranteDesc => 'Limiar: >50% vida atual ou >20% vida total. Falha no teste de Vigor resulta em sangramento severo, tendões rasgados ou mutilação.';

  @override
  String get settingsTitle => 'Configurações';

  @override
  String get language => 'Idioma';

  @override
  String get theme => 'Tema';

  @override
  String get themeSystem => 'Sistema';

  @override
  String get themeLight => 'Claro';

  @override
  String get themeDark => 'Escuro';

  @override
  String get aboutTitle => 'Sobre';

  @override
  String get aboutContent => 'Dark Age Gestor de Fichas & Dados';

  @override
  String get ok => 'OK';

  @override
  String get clearHistory => 'Limpar Histórico';

  @override
  String get addNewDie => 'Adicionar Novo Dado';

  @override
  String get help => 'Ajuda';

  @override
  String get about => 'Sobre';

  @override
  String get rateApp => 'Avaliar App';

  @override
  String get settings => 'Configurações';

  @override
  String get confirmClearHistoryTitle => 'Limpar histórico?';

  @override
  String get confirmClearHistoryContent => 'Esta ação não pode ser desfeita.';

  @override
  String get finalConfirmClearHistoryTitle => 'TEM A CERTEZA?';

  @override
  String get finalConfirmClearHistoryContent => 'Esta ação é realmente irreversível.';

  @override
  String get addNewDieTitle => 'Adicionar Novo Dado';

  @override
  String get addNewDieLabel => 'Número de Faces';

  @override
  String get add => 'Adicionar';

  @override
  String get edit => 'Editar';

  @override
  String get save => 'Salvar';

  @override
  String get name => 'Nome';

  @override
  String get description => 'Descrição';

  @override
  String get level => 'Nível';

  @override
  String get class => 'Classe';

  @override
  String get attributePointsPerLevel => 'Pontos de Atributo por Nível';

  @override
  String get skillPointsPerLevel => 'Pontos de Perícia por Nível';

  @override
  String get hpPerCon => 'Vida por ponto de CON';

  @override
  String get effortPerWis => 'Esforço por ponto de SAB';

  @override
  String get effortPerDex => 'Esforço por ponto de DES';

  @override
  String get apply => 'Aplicar';

  @override
  String get levelGainsTitle => 'Ganhos por Nível';

  @override
  String totalAttributePoints(Object points) {
    return 'Total de Pontos de Atributo a distribuir: $points';
  }

  @override
  String totalSkillPoints(Object points) {
    return 'Total de Pontos de Perícia a distribuir: $points';
  }

  @override
  String get hpPerLevel => 'Vida por Nível';

  @override
  String get effortPerLevel => 'Esforço por Nível';

  @override
  String get sanityPerLevel => 'Sanidade por Nível';

  @override
  String get status => 'Status';

  @override
  String get current => 'Atual';

  @override
  String get total => 'Total';

  @override
  String get attributes => 'Atributos';

  @override
  String get skills => 'Perícias';

  @override
  String get combatActions => 'Ações de Combate';

  @override
  String get nextRound => '+ Round';

  @override
  String get rest => 'Descansar';

  @override
  String get endCombat => 'Fim de Combate';

  @override
  String get combatEndedToast => 'Combate finalizado. Buffs e armadura restaurados.';

  @override
  String armorSectionTitle(Object total) {
    return 'Armadura Total: $total';
  }

  @override
  String get noArmor => 'Nenhuma armadura equipada ou ativa.';

  @override
  String get temporary => 'Temporária';

  @override
  String get passive => 'Passiva';

  @override
  String get equippedWeapons => 'Armas Equipadas';

  @override
  String get block => 'Bloqueio';

  @override
  String get parry => 'Parry';

  @override
  String get diceCount => 'Dados';

  @override
  String maxDice(Object max) {
    return 'Máx: $max';
  }

  @override
  String get use => 'Usar';

  @override
  String editMaestriaTitle(Object skill) {
    return 'Editar Maestria para $skill';
  }

  @override
  String get maestriaLevel => 'Nível de Maestria';

  @override
  String get proficienciaLevel => 'Nível de Proficiência (se aplicável)';

  @override
  String get novice => 'Novato';

  @override
  String get trained => 'Treinado';

  @override
  String get master => 'Mestre';

  @override
  String get proficiency => 'Proficiência';

  @override
  String get saveChanges => 'Salvar Alterações';

  @override
  String get addSkill => 'Adicionar Perícia';

  @override
  String get close => 'Fechar';

  @override
  String get backpack => 'Mochila';

  @override
  String get addItem => 'Novo Item';

  @override
  String get addWeapon => 'Nova Arma';

  @override
  String get addArmor => 'Nova Armadura';

  @override
  String get emptyBackpack => 'Mochila vazia.';

  @override
  String get editItem => 'Editar Item';

  @override
  String get newItem => 'Novo Item';

  @override
  String get editWeapon => 'Editar Arma';

  @override
  String get newWeapon => 'Nova Arma';

  @override
  String get editArmor => 'Editar Armadura';

  @override
  String get newArmor => 'Nova Armadura';

  @override
  String get editAbility => 'Editar Habilidade';

  @override
  String get newAbility => 'Nova Habilidade';

  @override
  String get editPassive => 'Editar Passiva';

  @override
  String get newPassive => 'Nova Passiva';

  @override
  String get editEffect => 'Editar Efeito';

  @override
  String get newEffect => 'Novo Efeito';

  @override
  String get dice => 'Dados';

  @override
  String get modifierBonus => 'Modificador (Bónus)';

  @override
  String get durability => 'Resistência';

  @override
  String get multiplier => 'Multiplicador (Ex: 1.5)';

  @override
  String get triggers => 'Gatilhos';

  @override
  String get armorValue => 'Valor de Armadura';

  @override
  String get resistancesVulnerabilities => 'Resistências/Vulnerabilidades';

  @override
  String get newResistance => 'Nova Resistência';

  @override
  String get editResistance => 'Editar Resistência';

  @override
  String get damageType => 'Tipo de Dano';

  @override
  String get resistanceValuePercent => 'Valor (% de Resistência/Vulnerabilidade)';

  @override
  String get resistanceHint => 'Valores positivos são resistência (50% = metade do dano). Valores negativos são vulnerabilidade (-50% = 50% a mais de dano).';

  @override
  String get abilityType => 'Tipo de Habilidade';

  @override
  String get damage => 'Dano';

  @override
  String get defense => 'Defesa';

  @override
  String get buffTransform => 'Buff/Transformação';

  @override
  String get restoreHealth => 'Restaurar Vida';

  @override
  String get restoreEffort => 'Restaurar Esforço';

  @override
  String get createArmor => 'Criar Armadura';

  @override
  String armorDefined(Object armorName) {
    return '$armorName';
  }

  @override
  String get noArmorDefined => 'Nenhuma armadura definida';

  @override
  String get defineArmorTap => 'Toque para definir a armadura criada por esta habilidade.';

  @override
  String get costTypeInstant => 'Tipo de Custo (Instantâneo)';

  @override
  String get none => 'Nenhum';

  @override
  String get health => 'Vida';

  @override
  String get effort => 'Esforço';

  @override
  String get sanity => 'Sanidade';

  @override
  String get costSource => 'Fonte do Custo';

  @override
  String get standard => 'Padrão';

  @override
  String get temporaryOnly => 'Apenas Temporário';

  @override
  String get hybridTempStandard => 'Híbrido (Temp. > Padrão)';

  @override
  String get costValue => 'Valor do Custo';

  @override
  String get valueToRestore => 'Valor a Restaurar';

  @override
  String get cooldownRounds => 'Cooldown (em rounds)';

  @override
  String get abilityDice => 'Dados da Habilidade:';

  @override
  String get abilityBases => 'Bases da Habilidade (Bónus de Dados):';

  @override
  String get addBase => 'Adicionar Base';

  @override
  String get bonusModifier => 'Modificador de Bónus (Ex: 5, -2)';

  @override
  String get conditionalEffects => 'Gatilhos (Efeitos Condicionais):';

  @override
  String get trigger => 'Gatilho';

  @override
  String get triggerType => 'Tipo de Gatilho';

  @override
  String get alwaysActive => 'Sempre Ativo';

  @override
  String get activatable => 'Ativável';

  @override
  String get onCooldown => 'Cooldown';

  @override
  String get healthLost => 'Vida Perdida';

  @override
  String get effortSpent => 'Esforço Gasto';

  @override
  String get sanityLost => 'Sanidade Perdida';

  @override
  String get madnessSpent => 'Loucura Gasta';

  @override
  String get damageTaken => 'Dano Sofrido';

  @override
  String get triggerFrequency => 'Frequência do Gatilho';

  @override
  String get stackable => 'Acumulável';

  @override
  String get oncePerCooldown => 'Uma Vez por Cooldown';

  @override
  String get proportionalToTotal => 'Inversamente Proporcional ao Status Total';

  @override
  String get triggerValueType => 'Tipo de Valor do Gatilho';

  @override
  String get fixedValue => 'Valor Fixo';

  @override
  String get percentage => 'Percentual';

  @override
  String triggerEvery(Object valueType) {
    return 'Disparar a cada... ($valueType)';
  }

  @override
  String get effects => 'Efeitos';

  @override
  String get durationTurns => 'Duração em Turnos (-1 para permanente)';

  @override
  String get effectValue => 'Valor do Efeito';

  @override
  String get bonusType => 'Tipo de Bónus';

  @override
  String get bonusPoints => 'Pontos de Bónus';

  @override
  String get modifier => 'Modificador';

  @override
  String get percentual => 'Percentual';

  @override
  String get grantArmor => 'Conceder Armadura';

  @override
  String get defineArmor => 'Definir Armadura';

  @override
  String get selectTargets => 'Selecionar Alvos';

  @override
  String get addBonusDie => 'Adicionar Dado Bónus';

  @override
  String get addTrigger => 'Novo Gatilho';

  @override
  String get editTrigger => 'Editar Gatilho';

  @override
  String get triggerNameDesc => 'Nome/Descrição do Gatilho';

  @override
  String get condition => 'Condição';

  @override
  String get conditionSource => 'Fonte da Condição';

  @override
  String get roll => 'ROLAGEM';

  @override
  String get extraDie => 'DADO EXTRA';

  @override
  String get successesNeeded => 'Sucessos Necessários';

  @override
  String get extraDieSides => 'Lados do Dado Extra';

  @override
  String get targetValue => 'Valor Alvo';

  @override
  String get effect => 'Efeito';

  @override
  String get effectType => 'Tipo de Efeito';

  @override
  String get damageMultiplier => 'Multiplicador de Dano';

  @override
  String get addDice => 'Adicionar Dados';

  @override
  String get addModifier => 'Adicionar Modificador';

  @override
  String get multiplierValue => 'Multiplicador (Ex: 1.5)';

  @override
  String get bonusModifierValue => 'Modificador Bónus';

  @override
  String get selectTargetsButton => 'Selecionar Alvos';

  @override
  String get youFellToast => 'Você caiu';

  @override
  String passiveAccumulatedToast(Object count, Object passiveName) {
    return '$passiveName acumulou $count vez(es)!';
  }

  @override
  String passiveActivatedToast(Object passiveName) {
    return '$passiveName ativada!';
  }

  @override
  String passiveReadyToast(Object passiveName) {
    return '$passiveName está pronta para ser usada novamente.';
  }

  @override
  String cooldownToast(Object abilityName, Object rounds) {
    return '$abilityName está em cooldown por mais $rounds round(s).';
  }

  @override
  String get insufficientResourcesToast => 'Recursos insuficientes para utilizar a habilidade.';

  @override
  String effortTempConsumedToast(Object amount) {
    return '$amount de Esforço Temporário consumido.';
  }

  @override
  String abilityActiveToast(Object abilityName) {
    return '$abilityName ativada.';
  }

  @override
  String abilityDeactiveToast(Object abilityName) {
    return '$abilityName desativada.';
  }

  @override
  String armorCreatedToast(Object armorName) {
    return '$armorName foi criada.';
  }

  @override
  String abilityNotImplementedToast(Object abilityType) {
    return 'Uso para \"$abilityType\" ainda não implementado.';
  }

  @override
  String finalDamageToast(Object absorbed, Object damage) {
    return 'Dano final: $damage | Armadura absorveu: $absorbed';
  }

  @override
  String get sheetSavedToast => 'Ficha salva automaticamente!';

  @override
  String get selectColorTitle => 'Escolha uma cor';

  @override
  String setPercentTitle(Object statusName) {
    return 'Definir % de $statusName';
  }

  @override
  String get percentLabel => 'Percentagem (%)';

  @override
  String get setButton => 'Definir';

  @override
  String get repair => 'Reparar';

  @override
  String armorRepairedToast(Object armorName) {
    return '$armorName foi reparada.';
  }
}
