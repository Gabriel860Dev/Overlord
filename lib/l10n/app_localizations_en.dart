// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'Dark Age';

  @override
  String get diceRollerSubtitle => 'Tap the die and good luck!';

  @override
  String get historySubtitle => 'Roll History';

  @override
  String get characterSheetsSubtitle => 'Character Sheets';

  @override
  String get noSheets => 'No sheets created.\nTap + to add a new one.';

  @override
  String get deleteSheetTitle => 'Delete Sheet?';

  @override
  String deleteSheetContent(Object sheetName) {
    return 'Are you sure you want to delete $sheetName\'s sheet?';
  }

  @override
  String get cancel => 'Cancel';

  @override
  String get delete => 'Delete';

  @override
  String get newSheetTitle => 'New Sheet';

  @override
  String get tabGeneral => 'General';

  @override
  String get tabSkills => 'Skills';

  @override
  String get tabCombat => 'Combat';

  @override
  String get tabAbilities => 'Abilities';

  @override
  String get tabPassives => 'Passives';

  @override
  String get tabBackpack => 'Backpack';

  @override
  String get tabBuffs => 'Buffs/Debuffs';

  @override
  String get helpTitle => 'Complete Guide';

  @override
  String get helpSectionCoreTitle => 'Core Mechanics: Dark Age System';

  @override
  String get helpCoreLogicTitle => 'Dice Logic (Mastery and Proficiency)';

  @override
  String get helpCoreLogicDesc => 'Instead of adding points to dice, the character\'s skill level (Novice, Trained, Master) and Proficiency level (I, II, III...) determine the *type* of dice rolled. Every 5 points in an attribute or skill grants one die, with the type determined by the highest achieved level (Novice -> d12, Trained/Master -> d20, PI -> d30, etc.). Points 1-4 grant progressively better dice within that scale.';

  @override
  String get helpMaestriaTitle => 'Skill Mastery (Novice, Trained, Master)';

  @override
  String get helpMaestriaDesc => '• Novice: Base level, rolls d4-d10, closes a d12 every 5 points.\n• Trained (T): Increased dice scale (d6-d12), closes a d20 every 5 points.\n• Master (M): Same dice as Trained, but adds a massive fixed bonus equal to the skill/attribute value to the roll AND unlocks Proficiency.';

  @override
  String get helpProficienciaTitle => 'Proficiency (I, II, III...)';

  @override
  String get helpProficienciaDesc => 'An advanced upgrade purchased with \'Proficiency Points\' (P) after reaching Master. Each level (I, II, III...) increases the dice scale further (closing d30, d40, d50...) and provides a small passive percentage bonus (+10% per level) to the base value.';

  @override
  String get helpSectionCombatTitle => 'Combat: Weapon Mastery & Critical Injuries';

  @override
  String get helpWeaponMaestriaTitle => 'Weapon Mastery (Level 0-4)';

  @override
  String get helpWeaponMaestriaDesc => 'Each weapon type has a unique mastery tree (Level 0-4) that improves its stats (Hit Chance, Critical Chance/Damage, Scaling) and grants a powerful special ability at Level 4, often enhancing the Critical Injury system.';

  @override
  String get helpFerimentosTitle => 'Critical Injuries';

  @override
  String get helpFerimentosDesc => 'Critical hits (based on a d100 roll vs the weapon\'s critical base) that exceed a certain percentage of the target\'s current or total HP trigger a devastating effect based on the damage type. The target must succeed on a Vigor check (DC = Damage Received) to mitigate the effect.';

  @override
  String get helpFerimentosCortante => 'Cutting (Amputation)';

  @override
  String get helpFerimentosCortanteDesc => 'Threshold: >50% current HP or >40% total HP. Failure on Vigor check results in limb amputation.';

  @override
  String get helpFerimentosPerfurante => 'Piercing (Organ Damage)';

  @override
  String get helpFerimentosPerfuranteDesc => 'Threshold: >40% current HP or >25% total HP. Failure on Vigor check results in specific organ damage (lung, heart, etc.).';

  @override
  String get helpFerimentosImpacto => 'Impact (Fractures/Trauma)';

  @override
  String get helpFerimentosImpactoDesc => 'Threshold: >60% current HP or >25% total HP. Failure on Vigor check results in broken bones, concussion, or paralysis.';

  @override
  String get helpFerimentosDilacerante => 'Tearing (Mutilation)';

  @override
  String get helpFerimentosDilaceranteDesc => 'Threshold: >50% current HP or >20% total HP. Failure on Vigor check results in severe bleeding, torn tendons, or mutilation.';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get language => 'Language';

  @override
  String get theme => 'Theme';

  @override
  String get themeSystem => 'System';

  @override
  String get themeLight => 'Light';

  @override
  String get themeDark => 'Dark';

  @override
  String get aboutTitle => 'About';

  @override
  String get aboutContent => 'Dark Age Character & Dice Manager';

  @override
  String get ok => 'OK';

  @override
  String get clearHistory => 'Clear History';

  @override
  String get addNewDie => 'Add New Die';

  @override
  String get help => 'Help';

  @override
  String get about => 'About';

  @override
  String get rateApp => 'Rate App';

  @override
  String get settings => 'Settings';

  @override
  String get confirmClearHistoryTitle => 'Clear history?';

  @override
  String get confirmClearHistoryContent => 'This action cannot be undone.';

  @override
  String get finalConfirmClearHistoryTitle => 'ARE YOU SURE?';

  @override
  String get finalConfirmClearHistoryContent => 'This action is truly irreversible.';

  @override
  String get addNewDieTitle => 'Add New Die';

  @override
  String get addNewDieLabel => 'Number of Faces';

  @override
  String get add => 'Add';

  @override
  String get edit => 'Edit';

  @override
  String get save => 'Save';

  @override
  String get name => 'Name';

  @override
  String get description => 'Description';

  @override
  String get level => 'Level';

  @override
  String get class => 'Class';

  @override
  String get attributePointsPerLevel => 'Attribute Points per Level';

  @override
  String get skillPointsPerLevel => 'Skill Points per Level';

  @override
  String get hpPerCon => 'HP per CON point';

  @override
  String get effortPerWis => 'Effort per WIS point';

  @override
  String get effortPerDex => 'Effort per DEX point';

  @override
  String get apply => 'Apply';

  @override
  String get levelGainsTitle => 'Gains per Level';

  @override
  String totalAttributePoints(Object points) {
    return 'Total Attribute Points to distribute: $points';
  }

  @override
  String totalSkillPoints(Object points) {
    return 'Total Skill Points to distribute: $points';
  }

  @override
  String get hpPerLevel => 'HP per Level';

  @override
  String get effortPerLevel => 'Effort per Level';

  @override
  String get sanityPerLevel => 'Sanity per Level';

  @override
  String get status => 'Status';

  @override
  String get current => 'Current';

  @override
  String get total => 'Total';

  @override
  String get attributes => 'Attributes';

  @override
  String get skills => 'Skills';

  @override
  String get combatActions => 'Combat Actions';

  @override
  String get nextRound => '+ Round';

  @override
  String get rest => 'Rest';

  @override
  String get endCombat => 'End Combat';

  @override
  String get combatEndedToast => 'Combat ended. Buffs and armor restored.';

  @override
  String armorSectionTitle(Object total) {
    return 'Total Armor: $total';
  }

  @override
  String get noArmor => 'No armor equipped or active.';

  @override
  String get temporary => 'Temporary';

  @override
  String get passive => 'Passive';

  @override
  String get equippedWeapons => 'Equipped Weapons';

  @override
  String get block => 'Block';

  @override
  String get parry => 'Parry';

  @override
  String get diceCount => 'Dice';

  @override
  String maxDice(Object max) {
    return 'Max: $max';
  }

  @override
  String get use => 'Use';

  @override
  String editMaestriaTitle(Object skill) {
    return 'Edit Mastery for $skill';
  }

  @override
  String get maestriaLevel => 'Mastery Level';

  @override
  String get proficienciaLevel => 'Proficiency Level (if applicable)';

  @override
  String get novice => 'Novice';

  @override
  String get trained => 'Trained';

  @override
  String get master => 'Master';

  @override
  String get proficiency => 'Proficiency';

  @override
  String get saveChanges => 'Save Changes';

  @override
  String get addSkill => 'Add Skill';

  @override
  String get close => 'Close';

  @override
  String get backpack => 'Backpack';

  @override
  String get addItem => 'New Item';

  @override
  String get addWeapon => 'New Weapon';

  @override
  String get addArmor => 'New Armor';

  @override
  String get emptyBackpack => 'Backpack empty.';

  @override
  String get editItem => 'Edit Item';

  @override
  String get newItem => 'New Item';

  @override
  String get editWeapon => 'Edit Weapon';

  @override
  String get newWeapon => 'New Weapon';

  @override
  String get editArmor => 'Edit Armor';

  @override
  String get newArmor => 'New Armor';

  @override
  String get editAbility => 'Edit Ability';

  @override
  String get newAbility => 'New Ability';

  @override
  String get editPassive => 'Edit Passive';

  @override
  String get newPassive => 'New Passive';

  @override
  String get editEffect => 'Edit Effect';

  @override
  String get newEffect => 'New Effect';

  @override
  String get dice => 'Dice';

  @override
  String get modifierBonus => 'Modifier (Bonus)';

  @override
  String get durability => 'Durability';

  @override
  String get multiplier => 'Multiplier (Ex: 1.5)';

  @override
  String get triggers => 'Triggers';

  @override
  String get armorValue => 'Armor Value';

  @override
  String get resistancesVulnerabilities => 'Resistances/Vulnerabilities';

  @override
  String get newResistance => 'New Resistance';

  @override
  String get editResistance => 'Edit Resistance';

  @override
  String get damageType => 'Damage Type';

  @override
  String get resistanceValuePercent => 'Value (% Resistance/Vulnerability)';

  @override
  String get resistanceHint => 'Positive values are resistance (50% = half damage). Negative values are vulnerability (-50% = 50% more damage).';

  @override
  String get abilityType => 'Ability Type';

  @override
  String get damage => 'Damage';

  @override
  String get defense => 'Defense';

  @override
  String get buffTransform => 'Buff/Transformation';

  @override
  String get restoreHealth => 'Restore Health';

  @override
  String get restoreEffort => 'Restore Effort';

  @override
  String get createArmor => 'Create Armor';

  @override
  String armorDefined(Object armorName) {
    return '$armorName';
  }

  @override
  String get noArmorDefined => 'No armor defined';

  @override
  String get defineArmorTap => 'Tap to define the armor created by this ability.';

  @override
  String get costTypeInstant => 'Cost Type (Instant)';

  @override
  String get none => 'None';

  @override
  String get health => 'Health';

  @override
  String get effort => 'Effort';

  @override
  String get sanity => 'Sanity';

  @override
  String get costSource => 'Cost Source';

  @override
  String get standard => 'Standard';

  @override
  String get temporaryOnly => 'Temporary Only';

  @override
  String get hybridTempStandard => 'Hybrid (Temp. > Standard)';

  @override
  String get costValue => 'Cost Value';

  @override
  String get valueToRestore => 'Value to Restore';

  @override
  String get cooldownRounds => 'Cooldown (in rounds)';

  @override
  String get abilityDice => 'Ability Dice:';

  @override
  String get abilityBases => 'Ability Bases (Dice Bonus):';

  @override
  String get addBase => 'Add Base';

  @override
  String get bonusModifier => 'Bonus Modifier (Ex: 5, -2)';

  @override
  String get conditionalEffects => 'Triggers (Conditional Effects):';

  @override
  String get trigger => 'Trigger';

  @override
  String get triggerType => 'Trigger Type';

  @override
  String get alwaysActive => 'Always Active';

  @override
  String get activatable => 'Activatable';

  @override
  String get onCooldown => 'Cooldown';

  @override
  String get healthLost => 'Health Lost';

  @override
  String get effortSpent => 'Effort Spent';

  @override
  String get sanityLost => 'Sanity Lost';

  @override
  String get madnessSpent => 'Madness Spent';

  @override
  String get damageTaken => 'Damage Taken';

  @override
  String get triggerFrequency => 'Trigger Frequency';

  @override
  String get stackable => 'Stackable';

  @override
  String get oncePerCooldown => 'Once per Cooldown';

  @override
  String get proportionalToTotal => 'Inversely Proportional to Total Status';

  @override
  String get triggerValueType => 'Trigger Value Type';

  @override
  String get fixedValue => 'Fixed Value';

  @override
  String get percentage => 'Percentage';

  @override
  String triggerEvery(Object valueType) {
    return 'Trigger every... ($valueType)';
  }

  @override
  String get effects => 'Effects';

  @override
  String get durationTurns => 'Duration in Turns (-1 for permanent)';

  @override
  String get effectValue => 'Effect Value';

  @override
  String get bonusType => 'Bonus Type';

  @override
  String get bonusPoints => 'Bonus Points';

  @override
  String get modifier => 'Modifier';

  @override
  String get percentual => 'Percentual';

  @override
  String get grantArmor => 'Grant Armor';

  @override
  String get defineArmor => 'Define Armor';

  @override
  String get selectTargets => 'Select Targets';

  @override
  String get addBonusDie => 'Add Bonus Die';

  @override
  String get addTrigger => 'New Trigger';

  @override
  String get editTrigger => 'Edit Trigger';

  @override
  String get triggerNameDesc => 'Trigger Name/Description';

  @override
  String get condition => 'Condition';

  @override
  String get conditionSource => 'Condition Source';

  @override
  String get roll => 'ROLL';

  @override
  String get extraDie => 'EXTRA DIE';

  @override
  String get successesNeeded => 'Successes Needed';

  @override
  String get extraDieSides => 'Extra Die Sides';

  @override
  String get targetValue => 'Target Value';

  @override
  String get effect => 'Effect';

  @override
  String get effectType => 'Effect Type';

  @override
  String get damageMultiplier => 'Damage Multiplier';

  @override
  String get addDice => 'Add Dice';

  @override
  String get addModifier => 'Add Modifier';

  @override
  String get multiplierValue => 'Multiplier (Ex: 1.5)';

  @override
  String get bonusModifierValue => 'Bonus Modifier';

  @override
  String get selectTargetsButton => 'Select Targets';

  @override
  String get youFellToast => 'You fell';

  @override
  String passiveAccumulatedToast(Object count, Object passiveName) {
    return '$passiveName accumulated $count time(s)!';
  }

  @override
  String passiveActivatedToast(Object passiveName) {
    return '$passiveName activated!';
  }

  @override
  String passiveReadyToast(Object passiveName) {
    return '$passiveName is ready to be used again.';
  }

  @override
  String cooldownToast(Object abilityName, Object rounds) {
    return '$abilityName is on cooldown for $rounds more round(s).';
  }

  @override
  String get insufficientResourcesToast => 'Insufficient resources to use the ability.';

  @override
  String effortTempConsumedToast(Object amount) {
    return '$amount Temporary Effort consumed.';
  }

  @override
  String abilityActiveToast(Object abilityName) {
    return '$abilityName activated.';
  }

  @override
  String abilityDeactiveToast(Object abilityName) {
    return '$abilityName deactivated.';
  }

  @override
  String armorCreatedToast(Object armorName) {
    return '$armorName was created.';
  }

  @override
  String abilityNotImplementedToast(Object abilityType) {
    return 'Use for \"$abilityType\" not yet implemented.';
  }

  @override
  String finalDamageToast(Object absorbed, Object damage) {
    return 'Final damage: $damage | Armor absorbed: $absorbed';
  }

  @override
  String get sheetSavedToast => 'Sheet saved automatically!';

  @override
  String get selectColorTitle => 'Choose a color';

  @override
  String setPercentTitle(Object statusName) {
    return 'Set % of $statusName';
  }

  @override
  String get percentLabel => 'Percentage (%)';

  @override
  String get setButton => 'Set';

  @override
  String get repair => 'Repair';

  @override
  String armorRepairedToast(Object armorName) {
    return '$armorName was repaired.';
  }
}
