import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_pt.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('pt')
  ];

  /// No description provided for @appName.
  ///
  /// In en, this message translates to:
  /// **'Dark Age'**
  String get appName;

  /// No description provided for @diceRollerSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Tap the die and good luck!'**
  String get diceRollerSubtitle;

  /// No description provided for @historySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Roll History'**
  String get historySubtitle;

  /// No description provided for @characterSheetsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Character Sheets'**
  String get characterSheetsSubtitle;

  /// No description provided for @noSheets.
  ///
  /// In en, this message translates to:
  /// **'No sheets created.\nTap + to add a new one.'**
  String get noSheets;

  /// No description provided for @deleteSheetTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete Sheet?'**
  String get deleteSheetTitle;

  /// No description provided for @deleteSheetContent.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete {sheetName}\'s sheet?'**
  String deleteSheetContent(Object sheetName);

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @newSheetTitle.
  ///
  /// In en, this message translates to:
  /// **'New Sheet'**
  String get newSheetTitle;

  /// No description provided for @tabGeneral.
  ///
  /// In en, this message translates to:
  /// **'General'**
  String get tabGeneral;

  /// No description provided for @tabSkills.
  ///
  /// In en, this message translates to:
  /// **'Skills'**
  String get tabSkills;

  /// No description provided for @tabCombat.
  ///
  /// In en, this message translates to:
  /// **'Combat'**
  String get tabCombat;

  /// No description provided for @tabAbilities.
  ///
  /// In en, this message translates to:
  /// **'Abilities'**
  String get tabAbilities;

  /// No description provided for @tabPassives.
  ///
  /// In en, this message translates to:
  /// **'Passives'**
  String get tabPassives;

  /// No description provided for @tabBackpack.
  ///
  /// In en, this message translates to:
  /// **'Backpack'**
  String get tabBackpack;

  /// No description provided for @tabBuffs.
  ///
  /// In en, this message translates to:
  /// **'Buffs/Debuffs'**
  String get tabBuffs;

  /// No description provided for @helpTitle.
  ///
  /// In en, this message translates to:
  /// **'Complete Guide'**
  String get helpTitle;

  /// No description provided for @helpSectionCoreTitle.
  ///
  /// In en, this message translates to:
  /// **'Core Mechanics: Dark Age System'**
  String get helpSectionCoreTitle;

  /// No description provided for @helpCoreLogicTitle.
  ///
  /// In en, this message translates to:
  /// **'Dice Logic (Mastery and Proficiency)'**
  String get helpCoreLogicTitle;

  /// No description provided for @helpCoreLogicDesc.
  ///
  /// In en, this message translates to:
  /// **'Instead of adding points to dice, the character\'s skill level (Novice, Trained, Master) and Proficiency level (I, II, III...) determine the *type* of dice rolled. Every 5 points in an attribute or skill grants one die, with the type determined by the highest achieved level (Novice -> d12, Trained/Master -> d20, PI -> d30, etc.). Points 1-4 grant progressively better dice within that scale.'**
  String get helpCoreLogicDesc;

  /// No description provided for @helpMaestriaTitle.
  ///
  /// In en, this message translates to:
  /// **'Skill Mastery (Novice, Trained, Master)'**
  String get helpMaestriaTitle;

  /// No description provided for @helpMaestriaDesc.
  ///
  /// In en, this message translates to:
  /// **'• Novice: Base level, rolls d4-d10, closes a d12 every 5 points.\n• Trained (T): Increased dice scale (d6-d12), closes a d20 every 5 points.\n• Master (M): Same dice as Trained, but adds a massive fixed bonus equal to the skill/attribute value to the roll AND unlocks Proficiency.'**
  String get helpMaestriaDesc;

  /// No description provided for @helpProficienciaTitle.
  ///
  /// In en, this message translates to:
  /// **'Proficiency (I, II, III...)'**
  String get helpProficienciaTitle;

  /// No description provided for @helpProficienciaDesc.
  ///
  /// In en, this message translates to:
  /// **'An advanced upgrade purchased with \'Proficiency Points\' (P) after reaching Master. Each level (I, II, III...) increases the dice scale further (closing d30, d40, d50...) and provides a small passive percentage bonus (+10% per level) to the base value.'**
  String get helpProficienciaDesc;

  /// No description provided for @helpSectionCombatTitle.
  ///
  /// In en, this message translates to:
  /// **'Combat: Weapon Mastery & Critical Injuries'**
  String get helpSectionCombatTitle;

  /// No description provided for @helpWeaponMaestriaTitle.
  ///
  /// In en, this message translates to:
  /// **'Weapon Mastery (Level 0-4)'**
  String get helpWeaponMaestriaTitle;

  /// No description provided for @helpWeaponMaestriaDesc.
  ///
  /// In en, this message translates to:
  /// **'Each weapon type has a unique mastery tree (Level 0-4) that improves its stats (Hit Chance, Critical Chance/Damage, Scaling) and grants a powerful special ability at Level 4, often enhancing the Critical Injury system.'**
  String get helpWeaponMaestriaDesc;

  /// No description provided for @helpFerimentosTitle.
  ///
  /// In en, this message translates to:
  /// **'Critical Injuries'**
  String get helpFerimentosTitle;

  /// No description provided for @helpFerimentosDesc.
  ///
  /// In en, this message translates to:
  /// **'Critical hits (based on a d100 roll vs the weapon\'s critical base) that exceed a certain percentage of the target\'s current or total HP trigger a devastating effect based on the damage type. The target must succeed on a Vigor check (DC = Damage Received) to mitigate the effect.'**
  String get helpFerimentosDesc;

  /// No description provided for @helpFerimentosCortante.
  ///
  /// In en, this message translates to:
  /// **'Cutting (Amputation)'**
  String get helpFerimentosCortante;

  /// No description provided for @helpFerimentosCortanteDesc.
  ///
  /// In en, this message translates to:
  /// **'Threshold: >50% current HP or >40% total HP. Failure on Vigor check results in limb amputation.'**
  String get helpFerimentosCortanteDesc;

  /// No description provided for @helpFerimentosPerfurante.
  ///
  /// In en, this message translates to:
  /// **'Piercing (Organ Damage)'**
  String get helpFerimentosPerfurante;

  /// No description provided for @helpFerimentosPerfuranteDesc.
  ///
  /// In en, this message translates to:
  /// **'Threshold: >40% current HP or >25% total HP. Failure on Vigor check results in specific organ damage (lung, heart, etc.).'**
  String get helpFerimentosPerfuranteDesc;

  /// No description provided for @helpFerimentosImpacto.
  ///
  /// In en, this message translates to:
  /// **'Impact (Fractures/Trauma)'**
  String get helpFerimentosImpacto;

  /// No description provided for @helpFerimentosImpactoDesc.
  ///
  /// In en, this message translates to:
  /// **'Threshold: >60% current HP or >25% total HP. Failure on Vigor check results in broken bones, concussion, or paralysis.'**
  String get helpFerimentosImpactoDesc;

  /// No description provided for @helpFerimentosDilacerante.
  ///
  /// In en, this message translates to:
  /// **'Tearing (Mutilation)'**
  String get helpFerimentosDilacerante;

  /// No description provided for @helpFerimentosDilaceranteDesc.
  ///
  /// In en, this message translates to:
  /// **'Threshold: >50% current HP or >20% total HP. Failure on Vigor check results in severe bleeding, torn tendons, or mutilation.'**
  String get helpFerimentosDilaceranteDesc;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @theme.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get theme;

  /// No description provided for @themeSystem.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get themeSystem;

  /// No description provided for @themeLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get themeLight;

  /// No description provided for @themeDark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get themeDark;

  /// No description provided for @aboutTitle.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get aboutTitle;

  /// No description provided for @aboutContent.
  ///
  /// In en, this message translates to:
  /// **'Dark Age Character & Dice Manager'**
  String get aboutContent;

  /// No description provided for @ok.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get ok;

  /// No description provided for @clearHistory.
  ///
  /// In en, this message translates to:
  /// **'Clear History'**
  String get clearHistory;

  /// No description provided for @addNewDie.
  ///
  /// In en, this message translates to:
  /// **'Add New Die'**
  String get addNewDie;

  /// No description provided for @help.
  ///
  /// In en, this message translates to:
  /// **'Help'**
  String get help;

  /// No description provided for @about.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get about;

  /// No description provided for @rateApp.
  ///
  /// In en, this message translates to:
  /// **'Rate App'**
  String get rateApp;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @confirmClearHistoryTitle.
  ///
  /// In en, this message translates to:
  /// **'Clear history?'**
  String get confirmClearHistoryTitle;

  /// No description provided for @confirmClearHistoryContent.
  ///
  /// In en, this message translates to:
  /// **'This action cannot be undone.'**
  String get confirmClearHistoryContent;

  /// No description provided for @finalConfirmClearHistoryTitle.
  ///
  /// In en, this message translates to:
  /// **'ARE YOU SURE?'**
  String get finalConfirmClearHistoryTitle;

  /// No description provided for @finalConfirmClearHistoryContent.
  ///
  /// In en, this message translates to:
  /// **'This action is truly irreversible.'**
  String get finalConfirmClearHistoryContent;

  /// No description provided for @addNewDieTitle.
  ///
  /// In en, this message translates to:
  /// **'Add New Die'**
  String get addNewDieTitle;

  /// No description provided for @addNewDieLabel.
  ///
  /// In en, this message translates to:
  /// **'Number of Faces'**
  String get addNewDieLabel;

  /// No description provided for @add.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get add;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @name.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get name;

  /// No description provided for @description.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get description;

  /// No description provided for @level.
  ///
  /// In en, this message translates to:
  /// **'Level'**
  String get level;

  /// No description provided for @class.
  ///
  /// In en, this message translates to:
  /// **'Class'**
  String get class;

  /// No description provided for @attributePointsPerLevel.
  ///
  /// In en, this message translates to:
  /// **'Attribute Points per Level'**
  String get attributePointsPerLevel;

  /// No description provided for @skillPointsPerLevel.
  ///
  /// In en, this message translates to:
  /// **'Skill Points per Level'**
  String get skillPointsPerLevel;

  /// No description provided for @hpPerCon.
  ///
  /// In en, this message translates to:
  /// **'HP per CON point'**
  String get hpPerCon;

  /// No description provided for @effortPerWis.
  ///
  /// In en, this message translates to:
  /// **'Effort per WIS point'**
  String get effortPerWis;

  /// No description provided for @effortPerDex.
  ///
  /// In en, this message translates to:
  /// **'Effort per DEX point'**
  String get effortPerDex;

  /// No description provided for @apply.
  ///
  /// In en, this message translates to:
  /// **'Apply'**
  String get apply;

  /// No description provided for @levelGainsTitle.
  ///
  /// In en, this message translates to:
  /// **'Gains per Level'**
  String get levelGainsTitle;

  /// No description provided for @totalAttributePoints.
  ///
  /// In en, this message translates to:
  /// **'Total Attribute Points to distribute: {points}'**
  String totalAttributePoints(Object points);

  /// No description provided for @totalSkillPoints.
  ///
  /// In en, this message translates to:
  /// **'Total Skill Points to distribute: {points}'**
  String totalSkillPoints(Object points);

  /// No description provided for @hpPerLevel.
  ///
  /// In en, this message translates to:
  /// **'HP per Level'**
  String get hpPerLevel;

  /// No description provided for @effortPerLevel.
  ///
  /// In en, this message translates to:
  /// **'Effort per Level'**
  String get effortPerLevel;

  /// No description provided for @sanityPerLevel.
  ///
  /// In en, this message translates to:
  /// **'Sanity per Level'**
  String get sanityPerLevel;

  /// No description provided for @status.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get status;

  /// No description provided for @current.
  ///
  /// In en, this message translates to:
  /// **'Current'**
  String get current;

  /// No description provided for @total.
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get total;

  /// No description provided for @attributes.
  ///
  /// In en, this message translates to:
  /// **'Attributes'**
  String get attributes;

  /// No description provided for @skills.
  ///
  /// In en, this message translates to:
  /// **'Skills'**
  String get skills;

  /// No description provided for @combatActions.
  ///
  /// In en, this message translates to:
  /// **'Combat Actions'**
  String get combatActions;

  /// No description provided for @nextRound.
  ///
  /// In en, this message translates to:
  /// **'+ Round'**
  String get nextRound;

  /// No description provided for @rest.
  ///
  /// In en, this message translates to:
  /// **'Rest'**
  String get rest;

  /// No description provided for @endCombat.
  ///
  /// In en, this message translates to:
  /// **'End Combat'**
  String get endCombat;

  /// No description provided for @combatEndedToast.
  ///
  /// In en, this message translates to:
  /// **'Combat ended. Buffs and armor restored.'**
  String get combatEndedToast;

  /// No description provided for @armorSectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Total Armor: {total}'**
  String armorSectionTitle(Object total);

  /// No description provided for @noArmor.
  ///
  /// In en, this message translates to:
  /// **'No armor equipped or active.'**
  String get noArmor;

  /// No description provided for @temporary.
  ///
  /// In en, this message translates to:
  /// **'Temporary'**
  String get temporary;

  /// No description provided for @passive.
  ///
  /// In en, this message translates to:
  /// **'Passive'**
  String get passive;

  /// No description provided for @equippedWeapons.
  ///
  /// In en, this message translates to:
  /// **'Equipped Weapons'**
  String get equippedWeapons;

  /// No description provided for @block.
  ///
  /// In en, this message translates to:
  /// **'Block'**
  String get block;

  /// No description provided for @parry.
  ///
  /// In en, this message translates to:
  /// **'Parry'**
  String get parry;

  /// No description provided for @diceCount.
  ///
  /// In en, this message translates to:
  /// **'Dice'**
  String get diceCount;

  /// No description provided for @maxDice.
  ///
  /// In en, this message translates to:
  /// **'Max: {max}'**
  String maxDice(Object max);

  /// No description provided for @use.
  ///
  /// In en, this message translates to:
  /// **'Use'**
  String get use;

  /// No description provided for @editMaestriaTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit Mastery for {skill}'**
  String editMaestriaTitle(Object skill);

  /// No description provided for @maestriaLevel.
  ///
  /// In en, this message translates to:
  /// **'Mastery Level'**
  String get maestriaLevel;

  /// No description provided for @proficienciaLevel.
  ///
  /// In en, this message translates to:
  /// **'Proficiency Level (if applicable)'**
  String get proficienciaLevel;

  /// No description provided for @novice.
  ///
  /// In en, this message translates to:
  /// **'Novice'**
  String get novice;

  /// No description provided for @trained.
  ///
  /// In en, this message translates to:
  /// **'Trained'**
  String get trained;

  /// No description provided for @master.
  ///
  /// In en, this message translates to:
  /// **'Master'**
  String get master;

  /// No description provided for @proficiency.
  ///
  /// In en, this message translates to:
  /// **'Proficiency'**
  String get proficiency;

  /// No description provided for @saveChanges.
  ///
  /// In en, this message translates to:
  /// **'Save Changes'**
  String get saveChanges;

  /// No description provided for @addSkill.
  ///
  /// In en, this message translates to:
  /// **'Add Skill'**
  String get addSkill;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @backpack.
  ///
  /// In en, this message translates to:
  /// **'Backpack'**
  String get backpack;

  /// No description provided for @addItem.
  ///
  /// In en, this message translates to:
  /// **'New Item'**
  String get addItem;

  /// No description provided for @addWeapon.
  ///
  /// In en, this message translates to:
  /// **'New Weapon'**
  String get addWeapon;

  /// No description provided for @addArmor.
  ///
  /// In en, this message translates to:
  /// **'New Armor'**
  String get addArmor;

  /// No description provided for @emptyBackpack.
  ///
  /// In en, this message translates to:
  /// **'Backpack empty.'**
  String get emptyBackpack;

  /// No description provided for @editItem.
  ///
  /// In en, this message translates to:
  /// **'Edit Item'**
  String get editItem;

  /// No description provided for @newItem.
  ///
  /// In en, this message translates to:
  /// **'New Item'**
  String get newItem;

  /// No description provided for @editWeapon.
  ///
  /// In en, this message translates to:
  /// **'Edit Weapon'**
  String get editWeapon;

  /// No description provided for @newWeapon.
  ///
  /// In en, this message translates to:
  /// **'New Weapon'**
  String get newWeapon;

  /// No description provided for @editArmor.
  ///
  /// In en, this message translates to:
  /// **'Edit Armor'**
  String get editArmor;

  /// No description provided for @newArmor.
  ///
  /// In en, this message translates to:
  /// **'New Armor'**
  String get newArmor;

  /// No description provided for @editAbility.
  ///
  /// In en, this message translates to:
  /// **'Edit Ability'**
  String get editAbility;

  /// No description provided for @newAbility.
  ///
  /// In en, this message translates to:
  /// **'New Ability'**
  String get newAbility;

  /// No description provided for @editPassive.
  ///
  /// In en, this message translates to:
  /// **'Edit Passive'**
  String get editPassive;

  /// No description provided for @newPassive.
  ///
  /// In en, this message translates to:
  /// **'New Passive'**
  String get newPassive;

  /// No description provided for @editEffect.
  ///
  /// In en, this message translates to:
  /// **'Edit Effect'**
  String get editEffect;

  /// No description provided for @newEffect.
  ///
  /// In en, this message translates to:
  /// **'New Effect'**
  String get newEffect;

  /// No description provided for @dice.
  ///
  /// In en, this message translates to:
  /// **'Dice'**
  String get dice;

  /// No description provided for @modifierBonus.
  ///
  /// In en, this message translates to:
  /// **'Modifier (Bonus)'**
  String get modifierBonus;

  /// No description provided for @durability.
  ///
  /// In en, this message translates to:
  /// **'Durability'**
  String get durability;

  /// No description provided for @multiplier.
  ///
  /// In en, this message translates to:
  /// **'Multiplier (Ex: 1.5)'**
  String get multiplier;

  /// No description provided for @triggers.
  ///
  /// In en, this message translates to:
  /// **'Triggers'**
  String get triggers;

  /// No description provided for @armorValue.
  ///
  /// In en, this message translates to:
  /// **'Armor Value'**
  String get armorValue;

  /// No description provided for @resistancesVulnerabilities.
  ///
  /// In en, this message translates to:
  /// **'Resistances/Vulnerabilities'**
  String get resistancesVulnerabilities;

  /// No description provided for @newResistance.
  ///
  /// In en, this message translates to:
  /// **'New Resistance'**
  String get newResistance;

  /// No description provided for @editResistance.
  ///
  /// In en, this message translates to:
  /// **'Edit Resistance'**
  String get editResistance;

  /// No description provided for @damageType.
  ///
  /// In en, this message translates to:
  /// **'Damage Type'**
  String get damageType;

  /// No description provided for @resistanceValuePercent.
  ///
  /// In en, this message translates to:
  /// **'Value (% Resistance/Vulnerability)'**
  String get resistanceValuePercent;

  /// No description provided for @resistanceHint.
  ///
  /// In en, this message translates to:
  /// **'Positive values are resistance (50% = half damage). Negative values are vulnerability (-50% = 50% more damage).'**
  String get resistanceHint;

  /// No description provided for @abilityType.
  ///
  /// In en, this message translates to:
  /// **'Ability Type'**
  String get abilityType;

  /// No description provided for @damage.
  ///
  /// In en, this message translates to:
  /// **'Damage'**
  String get damage;

  /// No description provided for @defense.
  ///
  /// In en, this message translates to:
  /// **'Defense'**
  String get defense;

  /// No description provided for @buffTransform.
  ///
  /// In en, this message translates to:
  /// **'Buff/Transformation'**
  String get buffTransform;

  /// No description provided for @restoreHealth.
  ///
  /// In en, this message translates to:
  /// **'Restore Health'**
  String get restoreHealth;

  /// No description provided for @restoreEffort.
  ///
  /// In en, this message translates to:
  /// **'Restore Effort'**
  String get restoreEffort;

  /// No description provided for @createArmor.
  ///
  /// In en, this message translates to:
  /// **'Create Armor'**
  String get createArmor;

  /// No description provided for @armorDefined.
  ///
  /// In en, this message translates to:
  /// **'{armorName}'**
  String armorDefined(Object armorName);

  /// No description provided for @noArmorDefined.
  ///
  /// In en, this message translates to:
  /// **'No armor defined'**
  String get noArmorDefined;

  /// No description provided for @defineArmorTap.
  ///
  /// In en, this message translates to:
  /// **'Tap to define the armor created by this ability.'**
  String get defineArmorTap;

  /// No description provided for @costTypeInstant.
  ///
  /// In en, this message translates to:
  /// **'Cost Type (Instant)'**
  String get costTypeInstant;

  /// No description provided for @none.
  ///
  /// In en, this message translates to:
  /// **'None'**
  String get none;

  /// No description provided for @health.
  ///
  /// In en, this message translates to:
  /// **'Health'**
  String get health;

  /// No description provided for @effort.
  ///
  /// In en, this message translates to:
  /// **'Effort'**
  String get effort;

  /// No description provided for @sanity.
  ///
  /// In en, this message translates to:
  /// **'Sanity'**
  String get sanity;

  /// No description provided for @costSource.
  ///
  /// In en, this message translates to:
  /// **'Cost Source'**
  String get costSource;

  /// No description provided for @standard.
  ///
  /// In en, this message translates to:
  /// **'Standard'**
  String get standard;

  /// No description provided for @temporaryOnly.
  ///
  /// In en, this message translates to:
  /// **'Temporary Only'**
  String get temporaryOnly;

  /// No description provided for @hybridTempStandard.
  ///
  /// In en, this message translates to:
  /// **'Hybrid (Temp. > Standard)'**
  String get hybridTempStandard;

  /// No description provided for @costValue.
  ///
  /// In en, this message translates to:
  /// **'Cost Value'**
  String get costValue;

  /// No description provided for @valueToRestore.
  ///
  /// In en, this message translates to:
  /// **'Value to Restore'**
  String get valueToRestore;

  /// No description provided for @cooldownRounds.
  ///
  /// In en, this message translates to:
  /// **'Cooldown (in rounds)'**
  String get cooldownRounds;

  /// No description provided for @abilityDice.
  ///
  /// In en, this message translates to:
  /// **'Ability Dice:'**
  String get abilityDice;

  /// No description provided for @abilityBases.
  ///
  /// In en, this message translates to:
  /// **'Ability Bases (Dice Bonus):'**
  String get abilityBases;

  /// No description provided for @addBase.
  ///
  /// In en, this message translates to:
  /// **'Add Base'**
  String get addBase;

  /// No description provided for @bonusModifier.
  ///
  /// In en, this message translates to:
  /// **'Bonus Modifier (Ex: 5, -2)'**
  String get bonusModifier;

  /// No description provided for @conditionalEffects.
  ///
  /// In en, this message translates to:
  /// **'Triggers (Conditional Effects):'**
  String get conditionalEffects;

  /// No description provided for @trigger.
  ///
  /// In en, this message translates to:
  /// **'Trigger'**
  String get trigger;

  /// No description provided for @triggerType.
  ///
  /// In en, this message translates to:
  /// **'Trigger Type'**
  String get triggerType;

  /// No description provided for @alwaysActive.
  ///
  /// In en, this message translates to:
  /// **'Always Active'**
  String get alwaysActive;

  /// No description provided for @activatable.
  ///
  /// In en, this message translates to:
  /// **'Activatable'**
  String get activatable;

  /// No description provided for @onCooldown.
  ///
  /// In en, this message translates to:
  /// **'Cooldown'**
  String get onCooldown;

  /// No description provided for @healthLost.
  ///
  /// In en, this message translates to:
  /// **'Health Lost'**
  String get healthLost;

  /// No description provided for @effortSpent.
  ///
  /// In en, this message translates to:
  /// **'Effort Spent'**
  String get effortSpent;

  /// No description provided for @sanityLost.
  ///
  /// In en, this message translates to:
  /// **'Sanity Lost'**
  String get sanityLost;

  /// No description provided for @madnessSpent.
  ///
  /// In en, this message translates to:
  /// **'Madness Spent'**
  String get madnessSpent;

  /// No description provided for @damageTaken.
  ///
  /// In en, this message translates to:
  /// **'Damage Taken'**
  String get damageTaken;

  /// No description provided for @triggerFrequency.
  ///
  /// In en, this message translates to:
  /// **'Trigger Frequency'**
  String get triggerFrequency;

  /// No description provided for @stackable.
  ///
  /// In en, this message translates to:
  /// **'Stackable'**
  String get stackable;

  /// No description provided for @oncePerCooldown.
  ///
  /// In en, this message translates to:
  /// **'Once per Cooldown'**
  String get oncePerCooldown;

  /// No description provided for @proportionalToTotal.
  ///
  /// In en, this message translates to:
  /// **'Inversely Proportional to Total Status'**
  String get proportionalToTotal;

  /// No description provided for @triggerValueType.
  ///
  /// In en, this message translates to:
  /// **'Trigger Value Type'**
  String get triggerValueType;

  /// No description provided for @fixedValue.
  ///
  /// In en, this message translates to:
  /// **'Fixed Value'**
  String get fixedValue;

  /// No description provided for @percentage.
  ///
  /// In en, this message translates to:
  /// **'Percentage'**
  String get percentage;

  /// No description provided for @triggerEvery.
  ///
  /// In en, this message translates to:
  /// **'Trigger every... ({valueType})'**
  String triggerEvery(Object valueType);

  /// No description provided for @effects.
  ///
  /// In en, this message translates to:
  /// **'Effects'**
  String get effects;

  /// No description provided for @durationTurns.
  ///
  /// In en, this message translates to:
  /// **'Duration in Turns (-1 for permanent)'**
  String get durationTurns;

  /// No description provided for @effectValue.
  ///
  /// In en, this message translates to:
  /// **'Effect Value'**
  String get effectValue;

  /// No description provided for @bonusType.
  ///
  /// In en, this message translates to:
  /// **'Bonus Type'**
  String get bonusType;

  /// No description provided for @bonusPoints.
  ///
  /// In en, this message translates to:
  /// **'Bonus Points'**
  String get bonusPoints;

  /// No description provided for @modifier.
  ///
  /// In en, this message translates to:
  /// **'Modifier'**
  String get modifier;

  /// No description provided for @percentual.
  ///
  /// In en, this message translates to:
  /// **'Percentual'**
  String get percentual;

  /// No description provided for @grantArmor.
  ///
  /// In en, this message translates to:
  /// **'Grant Armor'**
  String get grantArmor;

  /// No description provided for @defineArmor.
  ///
  /// In en, this message translates to:
  /// **'Define Armor'**
  String get defineArmor;

  /// No description provided for @selectTargets.
  ///
  /// In en, this message translates to:
  /// **'Select Targets'**
  String get selectTargets;

  /// No description provided for @addBonusDie.
  ///
  /// In en, this message translates to:
  /// **'Add Bonus Die'**
  String get addBonusDie;

  /// No description provided for @addTrigger.
  ///
  /// In en, this message translates to:
  /// **'New Trigger'**
  String get addTrigger;

  /// No description provided for @editTrigger.
  ///
  /// In en, this message translates to:
  /// **'Edit Trigger'**
  String get editTrigger;

  /// No description provided for @triggerNameDesc.
  ///
  /// In en, this message translates to:
  /// **'Trigger Name/Description'**
  String get triggerNameDesc;

  /// No description provided for @condition.
  ///
  /// In en, this message translates to:
  /// **'Condition'**
  String get condition;

  /// No description provided for @conditionSource.
  ///
  /// In en, this message translates to:
  /// **'Condition Source'**
  String get conditionSource;

  /// No description provided for @roll.
  ///
  /// In en, this message translates to:
  /// **'ROLL'**
  String get roll;

  /// No description provided for @extraDie.
  ///
  /// In en, this message translates to:
  /// **'EXTRA DIE'**
  String get extraDie;

  /// No description provided for @successesNeeded.
  ///
  /// In en, this message translates to:
  /// **'Successes Needed'**
  String get successesNeeded;

  /// No description provided for @extraDieSides.
  ///
  /// In en, this message translates to:
  /// **'Extra Die Sides'**
  String get extraDieSides;

  /// No description provided for @targetValue.
  ///
  /// In en, this message translates to:
  /// **'Target Value'**
  String get targetValue;

  /// No description provided for @effect.
  ///
  /// In en, this message translates to:
  /// **'Effect'**
  String get effect;

  /// No description provided for @effectType.
  ///
  /// In en, this message translates to:
  /// **'Effect Type'**
  String get effectType;

  /// No description provided for @damageMultiplier.
  ///
  /// In en, this message translates to:
  /// **'Damage Multiplier'**
  String get damageMultiplier;

  /// No description provided for @addDice.
  ///
  /// In en, this message translates to:
  /// **'Add Dice'**
  String get addDice;

  /// No description provided for @addModifier.
  ///
  /// In en, this message translates to:
  /// **'Add Modifier'**
  String get addModifier;

  /// No description provided for @multiplierValue.
  ///
  /// In en, this message translates to:
  /// **'Multiplier (Ex: 1.5)'**
  String get multiplierValue;

  /// No description provided for @bonusModifierValue.
  ///
  /// In en, this message translates to:
  /// **'Bonus Modifier'**
  String get bonusModifierValue;

  /// No description provided for @selectTargetsButton.
  ///
  /// In en, this message translates to:
  /// **'Select Targets'**
  String get selectTargetsButton;

  /// No description provided for @youFellToast.
  ///
  /// In en, this message translates to:
  /// **'You fell'**
  String get youFellToast;

  /// No description provided for @passiveAccumulatedToast.
  ///
  /// In en, this message translates to:
  /// **'{passiveName} accumulated {count} time(s)!'**
  String passiveAccumulatedToast(Object count, Object passiveName);

  /// No description provided for @passiveActivatedToast.
  ///
  /// In en, this message translates to:
  /// **'{passiveName} activated!'**
  String passiveActivatedToast(Object passiveName);

  /// No description provided for @passiveReadyToast.
  ///
  /// In en, this message translates to:
  /// **'{passiveName} is ready to be used again.'**
  String passiveReadyToast(Object passiveName);

  /// No description provided for @cooldownToast.
  ///
  /// In en, this message translates to:
  /// **'{abilityName} is on cooldown for {rounds} more round(s).'**
  String cooldownToast(Object abilityName, Object rounds);

  /// No description provided for @insufficientResourcesToast.
  ///
  /// In en, this message translates to:
  /// **'Insufficient resources to use the ability.'**
  String get insufficientResourcesToast;

  /// No description provided for @effortTempConsumedToast.
  ///
  /// In en, this message translates to:
  /// **'{amount} Temporary Effort consumed.'**
  String effortTempConsumedToast(Object amount);

  /// No description provided for @abilityActiveToast.
  ///
  /// In en, this message translates to:
  /// **'{abilityName} activated.'**
  String abilityActiveToast(Object abilityName);

  /// No description provided for @abilityDeactiveToast.
  ///
  /// In en, this message translates to:
  /// **'{abilityName} deactivated.'**
  String abilityDeactiveToast(Object abilityName);

  /// No description provided for @armorCreatedToast.
  ///
  /// In en, this message translates to:
  /// **'{armorName} was created.'**
  String armorCreatedToast(Object armorName);

  /// No description provided for @abilityNotImplementedToast.
  ///
  /// In en, this message translates to:
  /// **'Use for \"{abilityType}\" not yet implemented.'**
  String abilityNotImplementedToast(Object abilityType);

  /// No description provided for @finalDamageToast.
  ///
  /// In en, this message translates to:
  /// **'Final damage: {damage} | Armor absorbed: {absorbed}'**
  String finalDamageToast(Object absorbed, Object damage);

  /// No description provided for @sheetSavedToast.
  ///
  /// In en, this message translates to:
  /// **'Sheet saved automatically!'**
  String get sheetSavedToast;

  /// No description provided for @selectColorTitle.
  ///
  /// In en, this message translates to:
  /// **'Choose a color'**
  String get selectColorTitle;

  /// No description provided for @setPercentTitle.
  ///
  /// In en, this message translates to:
  /// **'Set % of {statusName}'**
  String setPercentTitle(Object statusName);

  /// No description provided for @percentLabel.
  ///
  /// In en, this message translates to:
  /// **'Percentage (%)'**
  String get percentLabel;

  /// No description provided for @setButton.
  ///
  /// In en, this message translates to:
  /// **'Set'**
  String get setButton;

  /// No description provided for @repair.
  ///
  /// In en, this message translates to:
  /// **'Repair'**
  String get repair;

  /// No description provided for @armorRepairedToast.
  ///
  /// In en, this message translates to:
  /// **'{armorName} was repaired.'**
  String armorRepairedToast(Object armorName);
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['en', 'pt'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {


  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en': return AppLocalizationsEn();
    case 'pt': return AppLocalizationsPt();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}
