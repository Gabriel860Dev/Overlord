// lib/main.dart

import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'dart:math';
import 'package:provider/provider.dart'; // NOVO
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fluttertoast/fluttertoast.dart';
// ATUALIZAÇÃO: Importando novos modelos e lógica de internacionalização
import 'package:dark_age/models/ability.dart';
import 'package:dark_age/models/passive_bonuses.dart';
import 'package:dark_age/models/roll_result.dart';
import 'package:dark_age/models/die_specification.dart';
import 'package:dark_age/models/character_sheet.dart';
import 'package:dark_age/screens/dice_roller_screen.dart';
import 'package:dark_age/screens/roll_history_screen.dart' as roll_history;
import 'package:dark_age/screens/character_sheets_screen.dart';
import 'package:dark_age/screens/help_screen.dart';
import 'package:dark_age/widgets/custom_bottom_navigation_bar.dart';
import 'package:dark_age/models/dark_age_logic.dart'; // NOVA LÓGICA DE DADOS
import 'package:dark_age/services/localization_service.dart'; // NOVO
import 'package:dark_age/services/theme_service.dart'; // NOVO
import 'package:dark_age/generated/l10n.dart'; // NOVO - Gerado pelo Flutter Intl

void main() {
  // ATUALIZAÇÃO: Envolvendo o App com os Provedores de Tema e Localização
  runApp(
    MultiProvider( // Usando MultiProvider para múltiplos providers
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeService()),
        ChangeNotifierProvider(create: (_) => LocalizationService()),
      ],
      child: const RPGDiceApp(),
    ),
  );
}

class RPGDiceApp extends StatelessWidget {
  const RPGDiceApp({super.key});

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);

    // ATUALIZAÇÃO: Consumindo os Provedores de Tema e Localização
    final themeService = Provider.of<ThemeService>(context);
    final localizationService = Provider.of<LocalizationService>(context);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Dark Age', // REBRAND
      theme: AppThemes.lightTheme, // NOVO
      darkTheme: AppThemes.darkTheme, // NOVO
      themeMode: themeService.themeMode, // NOVO
      locale: localizationService.locale, // NOVO
      supportedLocales: LocalizationService.supportedLocales, // NOVO
      localizationsDelegates: LocalizationService.localizationsDelegates, // NOVO
      home: const DiceHomePage(),
    );
  }
}

class DiceHomePage extends StatefulWidget {
  const DiceHomePage({super.key});

  @override
  State<DiceHomePage> createState() => _DiceHomePageState();
}

class _DiceHomePageState extends State<DiceHomePage> {
  int _selectedIndex = 0;
  List<String> _rollHistory = [];
  List<CharacterSheet> _characterSheets = [];
  List<int> _customDice = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    // NOVO: Carregar tema e idioma salvos
    await Provider.of<ThemeService>(context, listen: false)._loadThemeMode();
    await Provider.of<LocalizationService>(context, listen: false)._loadLocale();

    try {
      final sheetsData = prefs.getString('character_sheets');
      final historyData = prefs.getStringList('roll_history');
      final diceData = prefs.getStringList('custom_dice');

      setState(() {
        if (sheetsData != null) {
          _characterSheets = (jsonDecode(sheetsData) as List)
              .map((data) => CharacterSheet.fromJson(data))
              .toList();
        } else {
          _characterSheets = []; // Garante que a lista não seja nula
        }
        if (historyData != null) {
          _rollHistory = historyData;
        } else {
          _rollHistory = []; // Garante que a lista não seja nula
        }
        if (diceData != null) {
          _customDice = diceData.map(int.parse).toList();
        } else {
          _customDice = []; // Garante que a lista não seja nula
        }
      });
    } catch (e, stacktrace) { // Captura stacktrace para debugging
      debugPrint("Erro ao carregar os dados guardados: $e");
      debugPrint("Stacktrace: $stacktrace"); // Ajuda a identificar a origem do erro
      debugPrint("A iniciar com dados limpos para evitar o encravamento.");
      setState(() {
        _characterSheets = [];
        _rollHistory = [];
        _customDice = [];
      });
       // Opcional: Limpar dados corrompidos
      // await prefs.remove('character_sheets');
      // await prefs.remove('roll_history');
      // await prefs.remove('custom_dice');
    }
  }

  Future<void> _saveCustomDice() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('custom_dice', _customDice.map((d) => d.toString()).toList());
  }

  Future<void> _saveRollHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('roll_history', _rollHistory);
  }

  Future<void> _saveCharacterSheets() async {
    final prefs = await SharedPreferences.getInstance();
    try {
      final String sheetsJson = jsonEncode(_characterSheets.map((sheet) => sheet.toJson()).toList());
      await prefs.setString('character_sheets', sheetsJson);
    } catch (e) {
      debugPrint("Erro ao salvar fichas: $e");
      _showToast("Erro ao salvar fichas!");
    }
  }

  void _saveCharacterSheet(CharacterSheet sheet) {
    setState(() {
      final index = _characterSheets.indexWhere((s) => s.id == sheet.id);
      if (index != -1) {
        _characterSheets[index] = sheet;
      } else {
        _characterSheets.add(sheet);
      }
    });
    _saveCharacterSheets();
  }

  void _deleteCharacterSheet(String sheetId) {
    setState(() {
      _characterSheets.removeWhere((sheet) => sheet.id == sheetId);
    });
    _saveCharacterSheets();
  }

  void _showToast(String message) {
    if (!kIsWeb && (Platform.isAndroid || Platform.isIOS)) {
      Fluttertoast.showToast(
          msg: message,
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          // Adaptação para temas
          backgroundColor: Theme.of(context).colorScheme.primary,
          textColor: Theme.of(context).colorScheme.onPrimary,
          fontSize: 16.0);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
      debugPrint("Toast: $message");
    }
  }

  RollResult _performRoll({
    required String name,
    required List<DieSpecification> dice,
    int modifier = 0,
    double multiplier = 1.0,
    String extraDescription = '',
    int? defenseTarget, // Usado para Bloqueio/Defesa
    List<ConditionalEffect> triggers = const [],
    List<BonusSource> bonusSources = const [],
    // ATUALIZAÇÃO DARK AGE: Recebe o bônus fixo da maestria (M ou P)
    int fixedBonus = 0,
  }) {
    final random = Random();
    int totalRollResult = 0;
    final List<DieSpecification> individualRolls = [];
    String triggerDetails = '';

    List<DieSpecification> currentDice = List.from(dice);
    int currentModifier = modifier + fixedBonus; // Bônus fixo de Mestre/Proficiência é somado aqui

    for (final spec in currentDice) {
      // Evita rolar 0 dados
      if (spec.quantity <= 0) continue;
      int groupTotal = 0;
      final List<int> groupResults = [];
      for (int i = 0; i < spec.quantity; i++) {
         // Garante que os lados sejam pelo menos 1
        int sides = max(1, spec.sides);
        // Evita erro com nextInt(0)
        int singleRoll = sides == 1 ? 1 : random.nextInt(sides) + 1;
        groupTotal += singleRoll;
        groupResults.add(singleRoll);
      }
      totalRollResult += groupTotal;
      individualRolls.add(DieSpecification(
          quantity: spec.quantity,
          sides: spec.sides,
          damageType: spec.damageType,
          rollResult: groupTotal,
          individualResults: groupResults));
    }

    double finalMultiplier = multiplier;
    final allDiceResults = individualRolls.expand((spec) => spec.individualResults ?? []).toList();

    // Trigger Logic (mantida, mas verifica condições)
    for (final trigger in triggers) {
        bool conditionMet = false;
        String conditionLog = '';

        try { // Adiciona try-catch para segurança
            if (trigger.conditionSource == 'ROLAGEM') {
                if (allDiceResults.isNotEmpty) { // Só verifica se houve rolagens
                    int successCount = allDiceResults.where((roll) {
                        return (trigger.conditionOperator == '>=' && roll >= trigger.conditionTargetValue) ||
                            (trigger.conditionOperator == '<=' && roll <= trigger.conditionTargetValue);
                    }).length;

                    if (successCount >= trigger.requiredSuccesses) {
                        conditionMet = true;
                    }
                    conditionLog = '$successCount de ${allDiceResults.length} dados bateram a condição.';
                } else {
                    conditionLog = 'Nenhum dado rolado para verificar condição.';
                }
            } else { // DADO_EXTRA
                int sides = max(1, trigger.conditionDieSides);
                final extraDieRoll = sides == 1 ? 1 : random.nextInt(sides) + 1;
                conditionLog = 'Dado extra (1d${trigger.conditionDieSides}) rolou $extraDieRoll.';
                if ((trigger.conditionOperator == '>=' && extraDieRoll >= trigger.conditionTargetValue) ||
                    (trigger.conditionOperator == '<=' && extraDieRoll <= trigger.conditionTargetValue)) {
                    conditionMet = true;
                }
            }

            if (conditionMet) {
                switch (trigger.effectType) {
                    case 'Multiplicador de Dano':
                        finalMultiplier *= trigger.multiplier;
                        triggerDetails += '\nATIVADO: ${trigger.description} (x${trigger.multiplier}). $conditionLog';
                        break;
                    case 'Adicionar Dados':
                        for (final spec in trigger.bonusDice) {
                            if (spec.quantity <= 0) continue;
                            int groupTotal = 0;
                            final List<int> groupResults = [];
                            for (int i = 0; i < spec.quantity; i++) {
                                int sides = max(1, spec.sides);
                                int singleRoll = sides == 1 ? 1 : random.nextInt(sides) + 1;
                                groupTotal += singleRoll;
                                groupResults.add(singleRoll);
                            }
                            totalRollResult += groupTotal;
                            individualRolls.add(DieSpecification(
                                quantity: spec.quantity,
                                sides: spec.sides,
                                damageType: 'Gatilho',
                                rollResult: groupTotal,
                                individualResults: groupResults));
                        }
                        triggerDetails +=
                            '\nATIVADO: ${trigger.description} (+${trigger.bonusDice.map((d) => "${d.quantity}d${d.sides}").join('+')}). $conditionLog';
                        break;
                    case 'Adicionar Modificador':
                        currentModifier += trigger.bonusModifier;
                        triggerDetails += '\nATIVADO: ${trigger.description} (+${trigger.bonusModifier} MOD). $conditionLog';
                        break;
                }
            }
        } catch (e) {
            debugPrint("Erro ao processar gatilho ${trigger.description}: $e");
            triggerDetails += '\nERRO: Falha ao processar gatilho ${trigger.description}.';
        }
    }


    final int preMultipliedTotal = totalRollResult + currentModifier;
    // Garante que o multiplicador não seja negativo ou zero
    final safeMultiplier = max(0.0, finalMultiplier);
    final int finalTotal = (preMultipliedTotal * safeMultiplier).round();

    int finalResult = finalTotal;
    String historyResultString;
    RollResult result;

    if (defenseTarget != null) {
      finalResult = finalTotal - defenseTarget;
      historyResultString = '$finalTotal (mitigado) - $defenseTarget (dano) = $finalResult';
      result = RollResult(
        total: finalResult,
        details: context.loc.block, // Usando localização
        individualRolls: individualRolls,
        modifier: currentModifier,
        preMultipliedTotal: preMultipliedTotal,
        multiplier: safeMultiplier,
        incomingDamage: defenseTarget,
        mitigationResult: finalTotal,
        bonusSources: bonusSources,
        fixedBonus: fixedBonus, // NOVO
      );
    } else {
      historyResultString = finalTotal.toString();
      result = RollResult(
        total: finalResult,
        details: dice.map((d) => '${d.quantity}d${d.sides}').join(' + '),
        individualRolls: individualRolls,
        modifier: currentModifier,
        preMultipliedTotal: preMultipliedTotal,
        multiplier: safeMultiplier,
        bonusSources: bonusSources,
        fixedBonus: fixedBonus, // NOVO
      );
    }

    // ATUALIZAÇÃO: O formato dos dados mudou, a string de histórico deve refletir isso
    final rollString = dice.map((d) => '${d.quantity}d${d.sides}').join(' + ');
    final now = DateTime.now();
    final timeString =
        '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')}';

    final multiplierString = safeMultiplier != 1.0 ? 'x${safeMultiplier.toStringAsFixed(2)} ' : '';

    // ATUALIZAÇÃO: Simplificando o modificador para mostrar o bônus fixo
    String modifierString;
    final otherModifier = currentModifier - fixedBonus; // Modificador vindo de outras fontes

    if (fixedBonus > 0 && otherModifier > 0) {
      modifierString = '+ ($fixedBonus Fixo + $otherModifier)';
    } else if (fixedBonus > 0 && otherModifier < 0) {
      modifierString = '+ ($fixedBonus Fixo $otherModifier)'; // Ex: + (100 Fixo - 5)
    } else if (fixedBonus > 0) {
      modifierString = '+ ($fixedBonus Fixo)';
    } else if (otherModifier != 0) { // Mostra apenas se houver modificador não-fixo
      modifierString = '${otherModifier > 0 ? '+' : ''}($otherModifier)';
    } else {
      modifierString = ''; // Nenhum modificador
    }


    final individualRollsString = individualRolls.map((d) {
      final summary = '${d.quantity}d${d.sides} (${d.damageType}) = ${d.rollResult ?? 'N/A'}';
      final details = d.individualResults != null && d.individualResults!.isNotEmpty
                      ? ' -> [${d.individualResults!.join(', ')}]' : '';
      return summary + details;
    }).join('; ');

    final bonusString = bonusSources.map((b) => '${b.sourceName} (${b.type} ${b.value})').join(', ');

    final historyEntry =
        '$timeString - $name: $rollString $multiplierString $modifierString = $historyResultString | $individualRollsString | Bônus: $bonusString | ${triggerDetails.trim().replaceAll('\n', ' ')}';

    setState(() => _rollHistory.add(historyEntry));
    _saveRollHistory();

    _showRollDialog(result, name, extraDescription: extraDescription + triggerDetails);
    return result;
  }

  void _onDiceRolledOnMesa({required int sides, int quantity = 1, int modifier = 0}) {
    final rollName = '${quantity}d$sides';
    _performRoll(
      name: rollName,
      dice: [DieSpecification(quantity: quantity, sides: sides)],
      modifier: modifier,
      triggers: const [],
    );
  }

  // ATUALIZAÇÃO: Handler da Ficha foi modificado para aceitar o bônus fixo
  RollResult _onDiceRolledFromSheet(
    String description,
    List<DieSpecification> dice, {
    int modifier = 0,
    double multiplier = 1.0,
    String extraDescription = '',
    int? defenseTarget,
    List<ConditionalEffect> triggers = const [],
    List<BonusSource> bonusSources = const [],
    int fixedBonus = 0, // NOVO
  }) {
    return _performRoll(
      name: description,
      dice: dice,
      modifier: modifier,
      multiplier: multiplier,
      extraDescription: extraDescription,
      defenseTarget: defenseTarget,
      triggers: triggers,
      bonusSources: bonusSources,
      fixedBonus: fixedBonus, // NOVO
    );
  }

  void _showRollDialog(RollResult result, String description, {String extraDescription = ''}) {
    final isBlockRoll = result.incomingDamage != null;
    final localization = AppLocalizations.of(context)!; // Para traduções

    // ATUALIZAÇÃO: Lógica de modificador para incluir bônus fixo
    String modifierString = '';
    final otherModifier = result.modifier - result.fixedBonus;

    if (result.fixedBonus > 0 && otherModifier > 0) {
      modifierString = '${localization.modifier}: +${result.modifier} (${result.fixedBonus} Fixo + $otherModifier)';
    } else if (result.fixedBonus > 0 && otherModifier < 0) {
       modifierString = '${localization.modifier}: +${result.modifier} (${result.fixedBonus} Fixo $otherModifier)';
    } else if (result.fixedBonus > 0) {
      modifierString = '${localization.modifier}: +${result.modifier} (${result.fixedBonus} Fixo)';
    } else if (otherModifier != 0) {
       modifierString = '${localization.modifier}: ${otherModifier > 0 ? '+$otherModifier' : otherModifier}';
    }


    showDialog(
      context: context,
      barrierColor: Colors.transparent,
      builder: (context) => GestureDetector(
        onTap: () => Navigator.of(context).pop(),
        child: Scaffold(
          backgroundColor: Colors.black.withAlpha(204),
          body: Center(
            child: IntrinsicHeight(
              child: Container(
                width: 250,
                constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.7),
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor, // Adapta ao tema
                  borderRadius: BorderRadius.circular(12)
                ),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(description, style: Theme.of(context).textTheme.titleMedium, textAlign: TextAlign.center),
                      if (isBlockRoll) ...[
                        Text('${localization.damageTaken}: ${result.incomingDamage}',
                            style: TextStyle(fontSize: 14, color: Theme.of(context).colorScheme.error)),
                        const SizedBox(height: 4),
                        Text('Mitigação: ${result.mitigationResult}',
                            style: const TextStyle(fontSize: 16, color: Colors.greenAccent)), // Manter verde/vermelho?
                      ],
                      const SizedBox(height: 10),
                      Text(result.total.toString(),
                          style: Theme.of(context).textTheme.displayLarge?.copyWith(fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center),
                      if (isBlockRoll)
                        Text(result.total >= 0 ? 'Dano Evitado' : 'Dano Sofrido', // TODO: Localize
                            style: TextStyle(fontSize: 16, color: result.total >= 0 ? Colors.greenAccent : Colors.redAccent)),
                      const SizedBox(height: 10),
                      ...result.individualRolls.map((spec) {
                         // Garante que individualResults não seja nulo
                        final resultsString = spec.individualResults?.join(', ') ?? localization.translate('notApplicable');
                        return Text(
                          '${spec.quantity}d${spec.sides}: [$resultsString]',
                           style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7)),
                          textAlign: TextAlign.center,
                        );
                      }),
                      const SizedBox(height: 10),
                      if (result.bonusSources.isNotEmpty) ...[
                        Text(localization.translate('bonusApplied'), // TODO: Localize
                            style: TextStyle(fontSize: 14, color: Theme.of(context).colorScheme.secondary, fontWeight: FontWeight.bold)),
                        ...result.bonusSources.map((b) => Text(
                              '${b.sourceName} (${b.type} ${b.value})',
                              style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.secondary),
                              textAlign: TextAlign.center,
                            )),
                        const SizedBox(height: 10),
                      ],
                      if (extraDescription.isNotEmpty) ...[
                        Text(extraDescription.trim(),
                            style: const TextStyle(fontSize: 14, color: Colors.amberAccent), // Manter âmbar?
                            textAlign: TextAlign.center),
                        const SizedBox(height: 10),
                      ],
                      // ATUALIZAÇÃO: String do modificador
                      if (modifierString.isNotEmpty)
                        Text(modifierString,
                            style: Theme.of(context).textTheme.titleSmall,
                            textAlign: TextAlign.center),
                      if (result.multiplier != 1.0) ...[
                        const SizedBox(height: 4),
                        Text('${localization.translate('totalWithoutMultiplier')}: ${result.preMultipliedTotal} (x${result.multiplier.toStringAsFixed(2)})', // TODO: Localize
                             style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7)),
                            textAlign: TextAlign.center),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _onTabTapped(int index) => setState(() => _selectedIndex = index);

  void _clearHistory() {
    final localization = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(localization.confirmClearHistoryTitle),
        content: Text(localization.confirmClearHistoryContent),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(localization.cancel),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _showFinalConfirmationDialog();
            },
            child: Text(localization.delete),
          ),
        ],
      ),
    );
  }

  void _showFinalConfirmationDialog() {
    final localization = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        // backgroundColor: Colors.grey[850], // Usa o tema
        title: Text(localization.finalConfirmClearHistoryTitle, style: TextStyle(color: Theme.of(context).colorScheme.error, fontWeight: FontWeight.bold)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.warning_amber_rounded, color: Theme.of(context).colorScheme.error, size: 60),
              const SizedBox(height: 16),
              Text(localization.finalConfirmClearHistoryContent),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(localization.cancel),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                _rollHistory.clear();
                _saveRollHistory();
              });
              Navigator.of(context).pop();
            },
            child: Text('SIM, APAGAR TUDO', style: TextStyle(color: Theme.of(context).colorScheme.error, fontWeight: FontWeight.bold)), // TODO: Localize
          ),
        ],
      ),
    );
  }

  void _addNewDie() {
    final sidesController = TextEditingController();
    final localization = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(localization.addNewDieTitle),
        content: TextField(
            controller: sidesController,
            autofocus: true,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(labelText: localization.addNewDieLabel)),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(), child: Text(localization.cancel)),
          TextButton(
            onPressed: () {
              final sides = int.tryParse(sidesController.text) ?? 0;
              if (sides > 0) {
                setState(() {
                  if (!_customDice.contains(sides)) {
                    _customDice.add(sides);
                    _customDice.sort();
                    _saveCustomDice();
                  }
                });
              }
              Navigator.of(context).pop();
            },
            child: Text(localization.add),
          ),
        ],
      ),
    );
  }

  void _deleteCustomDie(int sides) {
    setState(() {
      _customDice.remove(sides);
      _saveCustomDice();
    });
  }

  void _showHelp() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const HelpScreen()),
    );
  }

  // ATUALIZAÇÃO: Menu 'Sobre' e 'Avaliar'
  void _showAbout() { // Removido BuildContext como parâmetro desnecessário
    final localization = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(localization.aboutTitle),
        content: Text(localization.aboutContent),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(localization.ok),
          )
        ],
      ),
    );
  }

  void _rateApp() => debugPrint('Abrir loja para avaliação'); // Manter como debug por enquanto

  // NOVO: Menu de Configurações para Tema e Idioma
  void _showSettingsMenu() { // Removido BuildContext como parâmetro desnecessário
    final themeService = Provider.of<ThemeService>(context, listen: false);
    final localizationService = Provider.of<LocalizationService>(context, listen: false);
    final localization = AppLocalizations.of(context)!;

    showModalBottomSheet(
      context: context,
      builder: (context) {
        // Usa o tema do BottomSheet
        return Container(
          padding: const EdgeInsets.all(16),
          child: Wrap(
            children: [
              Text(localization.settingsTitle, style: Theme.of(context).textTheme.titleLarge),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.language),
                title: Text(localization.language),
                trailing: DropdownButton<Locale>(
                  value: localizationService.locale,
                  onChanged: (Locale? newLocale) {
                    if (newLocale != null) {
                      localizationService.setLocale(newLocale);
                    }
                    Navigator.of(context).pop();
                  },
                  items: LocalizationService.supportedLocales
                      .map((locale) => DropdownMenuItem(
                            value: locale,
                            child: Text(locale.languageCode.toUpperCase()),
                          ))
                      .toList(),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.brightness_6),
                title: Text(localization.theme),
                trailing: DropdownButton<ThemeMode>(
                  value: themeService.themeMode,
                  onChanged: (ThemeMode? newMode) {
                    if (newMode != null) {
                      themeService.setThemeMode(newMode);
                    }
                    Navigator.of(context).pop();
                  },
                  items: [
                    DropdownMenuItem(
                      value: ThemeMode.system,
                      child: Text(localization.themeSystem),
                    ),
                    DropdownMenuItem(
                      value: ThemeMode.light,
                      child: Text(localization.themeLight),
                    ),
                    DropdownMenuItem(
                      value: ThemeMode.dark,
                      child: Text(localization.themeDark),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // É importante obter o localization aqui para passar para as telas filhas
    // que não reconstroem automaticamente com a mudança de locale.
    final localization = AppLocalizations.of(context)!;

    final List<Widget> screensList = [
      DiceRollerScreen(
        customDice: _customDice,
        onRoll: _onDiceRolledOnMesa,
        onClearHistory: _clearHistory,
        onAddNewDie: _addNewDie,
        onHelp: _showHelp,
        onAbout: _showAbout, // Passa a função diretamente
        onRateApp: _rateApp,
        onDeleteCustomDie: _deleteCustomDie,
        onSettings: _showSettingsMenu, // Passa a função diretamente
      ),
      roll_history.RollHistoryScreen(
        rollHistory: _rollHistory,
        onClearHistory: _clearHistory,
        onAddNewDie: _addNewDie,
        onHelp: _showHelp,
        onAbout: _showAbout,
        onRateApp: _rateApp,
        onSettings: _showSettingsMenu,
      ),
      CharacterSheetsScreen(
        onSaveSheet: _saveCharacterSheet,
        onDeleteSheet: _deleteCharacterSheet,
        characterSheets: _characterSheets,
        onClearHistory: _clearHistory,
        onAddNewDie: _addNewDie,
        onHelp: _showHelp,
        onAbout: _showAbout,
        onRateApp: _rateApp,
        onDiceRolledFromSheet: _onDiceRolledFromSheet,
        showToast: _showToast,
        onSettings: _showSettingsMenu,
      ),
    ];

    return Scaffold(
      // Body consome o tema automaticamente
      body: IndexedStack(index: _selectedIndex, children: screensList),
      // BottomNavigationBar precisa ser estilizado manualmente ou usar tema
      bottomNavigationBar: CustomBottomNavigationBar(
         selectedIndex: _selectedIndex,
         onTabTapped: _onTabTapped
       ),
    );
  }
}
