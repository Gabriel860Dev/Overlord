// lib/main.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'dart:convert';
import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:file_picker/file_picker.dart'; 
import 'package:uuid/uuid.dart';

import 'package:overlord/models/ability.dart';
import 'package:overlord/models/passive_bonuses.dart';
import 'package:overlord/models/roll_result.dart';
import 'package:overlord/models/die_specification.dart';
import 'package:overlord/models/character_sheet.dart';
import 'package:overlord/models/weapon.dart'; 
import 'package:overlord/models/armor.dart'; 
import 'package:overlord/models/item.dart'; 
import 'package:overlord/models/passive.dart';

import 'package:overlord/screens/dice_roller_screen.dart';
import 'package:overlord/screens/roll_history_screen.dart' as roll_history;
import 'package:overlord/screens/character_sheets_screen.dart';
import 'package:overlord/screens/help_screen.dart';
import 'package:overlord/screens/connection_screen.dart';
import 'package:overlord/screens/settings_screen.dart';

import 'package:overlord/widgets/custom_bottom_navigation_bar.dart';
import 'package:overlord/widgets/global_menu.dart';
import 'package:overlord/theme_manager.dart';
import 'package:overlord/localization.dart';
import 'package:overlord/services/network_manager.dart';

// Modelo do Elemento Customizado
class CustomElement {
  final String id;
  final String name;
  final String description;
  final List<String> strongAgainst; // Vantagem contra
  final List<String> weakAgainst;   // Desvantagem contra

  CustomElement({required this.id, required this.name, this.description = '', this.strongAgainst = const [], this.weakAgainst = const []});

  Map<String, dynamic> toJson() => {'id': id, 'name': name, 'description': description, 'strongAgainst': strongAgainst, 'weakAgainst': weakAgainst};
  factory CustomElement.fromJson(Map<String, dynamic> json) => CustomElement(
    id: json['id'], name: json['name'], description: json['description'] ?? '',
    strongAgainst: List<String>.from(json['strongAgainst'] ?? []),
    weakAgainst: List<String>.from(json['weakAgainst'] ?? []),
  );
}

// Gerenciador de Elementos do Sistema
class SystemElementsManager {
  static const String _key = 'system_custom_elements';
  static const List<String> defaultElements = [
    'Físico',
    'Cortante',
    'Impacto',
    'Perfurante',
    'Fogo',
    'Gelo',
    'Água',
    'Elétrico',
    'Energia',
    'Terra',
    'Natureza',
    'Lodo',
    'Vento',
    'Sangue',
    'Morte',
    'Conhecimento',
    'Espaço',
    'Gravidade'
  ];

  static Future<List<CustomElement>> load() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString(_key);
    if (data == null) return [];
    return (jsonDecode(data) as List).map((e) => CustomElement.fromJson(e)).toList();
  }

  static Future<List<String>> getAllElementNames() async {
    final custom = await load();
    return [...defaultElements, ...custom.map((e) => e.name)];
  }

  static Future<void> save(CustomElement element) async {
    final list = await load();
    list.removeWhere((e) => e.id == element.id || e.name == element.name);
    list.add(element);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, jsonEncode(list.map((e) => e.toJson()).toList()));
  }
}

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const RPGDiceApp());
}

class RPGDiceApp extends StatelessWidget {
  const RPGDiceApp({super.key});

  @override
  Widget build(BuildContext context) {
    if (Platform.isAndroid || Platform.isIOS) {
      SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    }

    return AnimatedBuilder(
      animation: ThemeManager(),
      builder: (context, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Overlord',
          theme: ThemeManager().getThemeData(),
          locale: ThemeManager().currentLocale,
          localizationsDelegates: const [
            AppLocalizationsDelegate(),
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [Locale('pt', 'BR'), Locale('en', 'US')],
          home: const DiceHomePage(),
        );
      },
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
  bool _isGodMode = false;

  @override
  void initState() {
    super.initState();
    _loadData();
    _setupNetworkListener();
  }

  void _setupNetworkListener() {
    final net = NetworkManager();
    net.onMessageReceived = (String jsonString) {
      if (!mounted) return;
      try {
        final data = jsonDecode(jsonString);
        if (data['type'] == 'ROLL') {
          final log = "REMOTO: ${data['player']} rolou ${data['details']} = ${data['result']}";
          setState(() { _rollHistory.add(log); });
          _saveRollHistory();
          _showToast("${data['player']} tirou ${data['result']}!");
        } else if (data['type'] == 'INFO') {
           _showToast(data['msg']);
        }
      } catch (e) {
        debugPrint("Erro rede: $e");
      }
    };
  }

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    try {
      final sheetsData = prefs.getString('character_sheets');
      final historyData = prefs.getStringList('roll_history');
      final diceData = prefs.getStringList('custom_dice');
      final godModeData = prefs.getBool('god_mode');

      setState(() {
        if (sheetsData != null) {
          _characterSheets = (jsonDecode(sheetsData) as List).map((data) => CharacterSheet.fromJson(data)).toList();
        }
        if (historyData != null) _rollHistory = historyData;
        if (diceData != null) _customDice = diceData.map(int.parse).toList();
        if (godModeData != null) _isGodMode = godModeData;
      });
    } catch (e) {
      debugPrint("Erro load: $e");
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
    final String sheetsJson = jsonEncode(_characterSheets.map((sheet) => sheet.toJson()).toList());
    await prefs.setString('character_sheets', sheetsJson);
  }
  Future<void> _saveGodModeState() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('god_mode', _isGodMode);
  }

  void _saveCharacterSheet(CharacterSheet sheet) {
    setState(() {
      final index = _characterSheets.indexWhere((s) => s.id == sheet.id);
      if (index != -1) { _characterSheets[index] = sheet; } else { _characterSheets.add(sheet); }
    });
    _saveCharacterSheets();
  }

  void _deleteCharacterSheet(String sheetId) {
    setState(() { _characterSheets.removeWhere((sheet) => sheet.id == sheetId); });
    _saveCharacterSheets();
  }

  // NOVO: Permite reordenar fichas e salvar
  void _reorderCharacterSheets(int oldIndex, int newIndex) {
    setState(() {
      if (newIndex > oldIndex) newIndex -= 1;
      final sheet = _characterSheets.removeAt(oldIndex);
      _characterSheets.insert(newIndex, sheet);
    });
    _saveCharacterSheets();
  }

  void _showToast(String message) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating, 
        showCloseIcon: true,
        backgroundColor: Colors.blueGrey[900],
      )
    );
  }
  
  void _toggleGodMode() {
    setState(() => _isGodMode = !_isGodMode);
    _saveGodModeState();
    _showToast(_isGodMode ? "⚡ Sistema Calibrado ⚡" : "Sistema Reiniciado");
  }

  Future<void> _pickImportFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(type: FileType.any);
      if (result != null && result.files.single.path != null) {
        File file = File(result.files.single.path!);
        String content = await file.readAsString();
        _processImport(content);
      }
    } catch (e) {
      _showToast('Erro ao ler arquivo: $e');
    }
  }

  Future<void> _pasteFromClipboard(TextEditingController controller) async {
    final data = await Clipboard.getData(Clipboard.kTextPlain);
    if (data?.text != null) {
      controller.text = data!.text!;
      _showToast("Texto colado!");
    } else {
      _showToast("Área de transferência vazia.");
    }
  }

  // NOVO: Janela de Ajuda/Molde de Importação
  void _showImportTemplateDialog() {
    const String templateText = '''[FICHA]
Nome: Personagem Exemplo
Classe: Guerreiro
Nível: 5

[STATUS]
Vida: 20 / 20
Esforço: 10 / 10
Sanidade: 5 / 5
Loucura: 0

[ATRIBUTOS]
FOR: 10
CON: 10
DES: 10
INT: 5
SAB: 5
CAR: 5

[PERICIAS]
Atletismo: 15
Sobrevivencia: 10

[ARMAS]
Espada Longa: 1d8 + 2
Adaga Magica: 2d4 + 1

[ARMADURAS]
Armadura de Couro: Reduz 2, Hits 5

[HABILIDADES]
# Ataque Feroz (2 Esforço)
Um ataque forte que empurra o inimigo.

[RITUAIS]
# Bola de Fogo (5 Esforço)
Causa explosao em area.

[PASSIVAS]
# Sangue Frio
Imune a medo e terror.

[INVENTARIO]
Pocao de Cura
Corda de 10m
''';

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: const Text('Molde Perfeito', style: TextStyle(color: Colors.amber)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text("O Overlord lê as fichas com base nestas TAGS em maiúsculo (ex: [STATUS]). Copie o modelo abaixo, preencha com seus dados e importe!", style: TextStyle(color: Colors.white70, fontSize: 13)),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                color: Colors.black54,
                child: const SelectableText(templateText, style: TextStyle(color: Colors.greenAccent, fontSize: 12, fontFamily: 'monospace')),
              )
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Fechar")),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.blueAccent),
            onPressed: () {
              Clipboard.setData(const ClipboardData(text: templateText));
              _showToast("Molde copiado!");
              Navigator.pop(ctx);
            },
            icon: const Icon(Icons.copy, color: Colors.white),
            label: const Text("Copiar Molde", style: TextStyle(color: Colors.white)),
          )
        ],
      )
    );
  }

  void _showImportDialog() {
    final textController = TextEditingController();
    final theme = Theme.of(context);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: theme.cardColor,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Importar Ficha', style: TextStyle(color: Colors.white)),
            IconButton(
              icon: const Icon(Icons.help_outline, color: Colors.amber),
              tooltip: "Ver Molde",
              onPressed: _showImportTemplateDialog,
            )
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ElevatedButton.icon(
                onPressed: () { Navigator.pop(context); _pickImportFile(); },
                icon: const Icon(Icons.folder_open),
                label: const Text("Abrir Arquivo .txt"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.primary,
                  foregroundColor: theme.colorScheme.onPrimary,
                ),
              ),
              const SizedBox(height: 16),
              const Text("OU COLE O TEXTO ABAIXO:", style: TextStyle(color: Colors.grey, fontSize: 12), textAlign: TextAlign.center),
              const SizedBox(height: 8),
              TextField(
                controller: textController,
                maxLines: 8,
                style: TextStyle(color: theme.colorScheme.onSurface, fontSize: 12),
                decoration: InputDecoration(
                  hintText: 'Cole o conteúdo formatado aqui...',
                  filled: true,
                  fillColor: theme.scaffoldBackgroundColor,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.paste),
                    onPressed: () => _pasteFromClipboard(textController),
                  ),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
          TextButton(
            onPressed: () {
              _processImport(textController.text);
              Navigator.pop(context);
            },
            child: Text('Importar', style: TextStyle(color: theme.colorScheme.primary, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _processImport(String content) {
    if (content.isEmpty) return;
    if (content.trim() == "CMD::GOD_MODE::ACCESS::777") { _toggleGodMode(); return; }

    try {
      if (content.trim().startsWith('{')) {
        final Map<String, dynamic> jsonMap = jsonDecode(content);
        jsonMap['id'] = null; 
        final newSheet = CharacterSheet.fromJson(jsonMap);
        _saveCharacterSheet(newSheet);
        _showToast('Importado via JSON: ${newSheet.name}');
      } else {
        final newSheet = _parseTextSheet(content);
        _saveCharacterSheet(newSheet);
        _showToast('Ficha Adaptada: ${newSheet.name}');
      }
    } catch (e) {
      _showToast('Erro na importação. Verifique o formato.');
      debugPrint("Import Error: $e");
    }
  }

  // O NOVO MOTOR DE IMPORTAÇÃO DE TEXTO
  CharacterSheet _parseTextSheet(String text) {
    String cleanText = text.replaceAll('\r\n', '\n').replaceAll('\r', '\n');
    List<String> lines = cleanText.split('\n');
    
    String name = 'Herói Desconhecido';
    String? classe;
    int? level;
    Map<String, int> attributes = {'FOR': 0, 'CON': 0, 'DES': 0, 'INT': 0, 'SAB': 0, 'CAR': 0};
    Map<String, Map<String, int>> status = {
      'Vida': {'atual': 0, 'total': 0},
      'Esforço': {'atual': 0, 'total': 0},
      'Sanidade': {'atual': 0, 'total': 0},
      'Loucura': {'atual': 0, 'total': 100},
      'Esforço Temporário': {'atual': 0, 'total': 0},
    };
    Map<String, int> pericias = {};
    List<Weapon> weapons = [];
    List<Armor> armors = [];
    List<Item> backpack = [];
    List<Ability> abilities = [];
    List<Ability> rituals = [];
    List<Passive> passives = [];
    
    String currentSection = 'FICHA'; 
    
    String tempTitle = '';
    String tempCostType = '';
    int tempCostAmount = 0;
    List<String> tempDesc = [];

    // Função de extração numérica
    List<int> extractNumbers(String line) {
      final matches = RegExp(r'\d+').allMatches(line);
      return matches.map((m) => int.parse(m.group(0)!)).toList();
    }

    void saveCurrentAbilityOrPassive() {
      if (tempTitle.isNotEmpty) {
        String finalDesc = tempDesc.join('\n').trim();
        if (currentSection == 'HABILIDADES') {
          abilities.add(Ability(id: const Uuid().v4(), name: tempTitle, description: finalDesc, abilityType: 'Dano', costType: tempCostType.isNotEmpty ? tempCostType : 'Nenhum', costAmount: tempCostAmount));
        } else if (currentSection == 'RITUAIS') {
          rituals.add(Ability(id: const Uuid().v4(), name: tempTitle, description: finalDesc, abilityType: 'Dano', costType: tempCostType.isNotEmpty ? tempCostType : 'Nenhum', costAmount: tempCostAmount));
        } else if (currentSection == 'PASSIVAS') {
          passives.add(Passive(id: const Uuid().v4(), name: tempTitle, description: finalDesc, triggerType: 'Sempre Ativo'));
        }
        tempTitle = ''; tempCostType = ''; tempCostAmount = 0; tempDesc.clear();
      }
    }

    for (int i = 0; i < lines.length; i++) {
      String line = lines[i].trim();
      if (line.isEmpty) continue;
      String upperLine = line.toUpperCase();
      
      // Muda de seção caso encontre a tag [TAG]
      if (line.startsWith('[') && line.endsWith(']')) {
        saveCurrentAbilityOrPassive(); // Salva se tiver algo pendente
        String sectionName = upperLine.replaceAll('[', '').replaceAll(']', '').trim();
        currentSection = sectionName;
        continue;
      }
      
      if (currentSection == 'FICHA' || currentSection == 'HEADER') {
        if (upperLine.startsWith('NOME:')) name = line.substring(5).trim();
        if (upperLine.startsWith('CLASSE:')) classe = line.substring(7).trim();
        if (upperLine.startsWith('NÍVEL:') || upperLine.startsWith('NIVEL:')) level = extractNumbers(line).firstOrNull;
      }
      else if (currentSection == 'STATUS') {
        final statusMap = {'VIDA': 'Vida', 'ESFORÇO': 'Esforço', 'ESFORCO': 'Esforço', 'SANIDADE': 'Sanidade', 'LOUCURA': 'Loucura'};
        statusMap.forEach((key, targetKey) {
          if (upperLine.startsWith(key)) {
            final nums = extractNumbers(line);
            if (nums.isNotEmpty) {
              int atual = nums[0];
              int total = nums.length > 1 ? nums[1] : atual;
              if (targetKey == 'Loucura') { total = 100; }
              status[targetKey] = {'atual': atual, 'total': total};
            }
          }
        });
      }
      else if (currentSection == 'ATRIBUTOS') {
        final attrMap = {'FOR': 'FOR', 'CON': 'CON', 'DES': 'DES', 'INT': 'INT', 'SAB': 'SAB', 'CAR': 'CAR'};
        attrMap.forEach((key, val) {
          if (upperLine.startsWith(key)) { final nums = extractNumbers(line); if (nums.isNotEmpty) attributes[val] = nums.first; }
        });
      }
      else if (currentSection == 'PERICIAS' || currentSection == 'PERÍCIAS') {
        final parts = line.split(':');
        if (parts.length >= 2) {
          String sName = parts[0].trim();
          int sVal = extractNumbers(parts[1]).firstOrNull ?? 0;
          pericias[sName] = sVal;
        }
      }
      else if (currentSection == 'ARMAS') {
        final parts = line.split(':');
        if (parts.length >= 2) {
          String wName = parts[0].trim(); 
          String wDetails = parts[1].trim();
          
          final diceRegex = RegExp(r'(\d+)d(\d+)');
          final match = diceRegex.firstMatch(wDetails);
          List<DieSpecification> diceList = [];
          if (match != null) {
             diceList.add(DieSpecification(quantity: int.parse(match.group(1)!), sides: int.parse(match.group(2)!), damageType: 'Físico'));
          } else {
             diceList.add(DieSpecification(quantity: 1, sides: 20)); // Failsafe
          }
          
          // Extrai o modificador se tiver um '+' (ex: 1d8 + 2)
          int mod = 0;
          if (wDetails.contains('+')) {
             final splitPlus = wDetails.split('+');
             if (splitPlus.length > 1) {
               mod = int.tryParse(splitPlus[1].replaceAll(RegExp(r'[^0-9]'), '').trim()) ?? 0;
             }
          }
          weapons.add(Weapon(id: const Uuid().v4(), name: wName, dice: diceList, modifier: mod, description: ''));
        }
      }
      else if (currentSection == 'ARMADURAS') {
        final parts = line.split(':');
        if (parts.length >= 2) {
          String aName = parts[0].trim();
          final nums = extractNumbers(parts[1]);
          int red = nums.isNotEmpty ? nums[0] : 0;
          int hits = nums.length > 1 ? nums[1] : 0;
          armors.add(Armor(id: const Uuid().v4(), name: aName, reductionValue: red, maxHits: hits, currentHits: hits));
        }
      }
      else if (currentSection == 'HABILIDADES' || currentSection == 'RITUAIS' || currentSection == 'PASSIVAS') {
        if (line.startsWith('#')) {
          saveCurrentAbilityOrPassive(); // Salva a anterior
          String fullTitle = line.substring(1).trim();
          
          // Verifica se tem custo nos parênteses Ex: # Bola de Fogo (5 Esforço)
          final RegExp costRegex = RegExp(r'\((.*?)\)');
          final costMatch = costRegex.firstMatch(fullTitle);
          if (costMatch != null) {
            String costStr = costMatch.group(1)!;
            final nums = extractNumbers(costStr);
            if (nums.isNotEmpty) {
              tempCostAmount = nums.first;
              tempCostType = costStr.toUpperCase().contains('VIDA') ? 'Vida' : (costStr.toUpperCase().contains('SANIDADE') ? 'Sanidade' : 'Esforço');
            }
            tempTitle = fullTitle.replaceAll(costRegex, '').trim();
          } else {
            tempTitle = fullTitle;
          }
        } else {
          // Se não começa com #, é a descrição da habilidade atual
          if (tempTitle.isNotEmpty) tempDesc.add(line);
        }
      }
      else if (currentSection == 'INVENTARIO' || currentSection == 'INVENTÁRIO') {
        backpack.add(Item(id: const Uuid().v4(), name: line, description: ''));
      }
    }
    saveCurrentAbilityOrPassive(); // Salva o último item que estava sendo lido

    return CharacterSheet(name: name, classe: classe, level: level, attributes: attributes, status: status, pericias: pericias, weapons: weapons, armors: armors, backpack: backpack, abilities: abilities, rituals: rituals, passives: passives);
  }

  // --- ROLAGEM DE DADOS E NAVEGAÇÃO ---
  int _rollDie(int sides) {
    final random = Random();
    if (_isGodMode) {
      double r = random.nextDouble();
      switch (sides) {
        case 4: if (r < 0.55) return 4; return random.nextInt(3) + 1;
        case 6: if (r < 0.50) return 6; return random.nextInt(5) + 1;
        case 8: if (r < 0.30) return 8; return random.nextInt(7) + 1;
        case 10: if (r < 0.25) return 10; return random.nextInt(9) + 1;
        case 12: if (r < 0.20) return 12; if (r < 0.70) return random.nextInt(5) + 7; return random.nextInt(6) + 1;
        case 20: if (r < 0.15) return 20; if (r < 0.80) return random.nextInt(8) + 12; return random.nextInt(11) + 1;
        case 100:
          if (r < 0.10) return 100;                                      // 10% de chance para o 100 absoluto
          if (r < 0.65) return random.nextInt(15) + 85;                  // 55% de chance entre 85 e 99
          if (r < 0.90) return random.nextInt(20) + 65;                  // 25% de chance entre 65 e 84
          if (r < 0.999) return random.nextInt(63) + 2;                  // 9.9% de chance entre 2 e 64 (o resto)
          return 1;                                                      // 0.1% de chance para cair exatamente 1
        default: 
          int result; int attempts = 0; 
          do { result = random.nextInt(sides) + 1; attempts++; } while (result == 1 && attempts < 10); 
          return result;
      }
    }
    return random.nextInt(sides) + 1;
  }

  RollResult _performRoll({required String name, required List<DieSpecification> dice, int modifier = 0, double multiplier = 1.0, String extraDescription = '', int? defenseTarget, List<ConditionalEffect> triggers = const [], List<BonusSource> bonusSources = const [],}) {
    int totalRollResult = 0;
    final List<DieSpecification> individualRolls = [];
    List<DieSpecification> currentDice = List.from(dice);
    int currentModifier = modifier;
    String triggerDetails = '';

    for (final spec in currentDice) {
      int groupTotal = 0;
      final List<int> groupResults = [];
      for (int i = 0; i < spec.quantity; i++) {
        int singleRoll = _rollDie(spec.sides);
        groupTotal += singleRoll;
        groupResults.add(singleRoll);
      }
      totalRollResult += groupTotal;
      individualRolls.add(DieSpecification(quantity: spec.quantity, sides: spec.sides, damageType: spec.damageType, rollResult: groupTotal, individualResults: groupResults));
    }

    double finalMultiplier = multiplier;
    
    for (final trigger in triggers) {
      bool conditionMet = false;
      String conditionLog = '';
      final allDiceResults = individualRolls.expand((spec) => spec.individualResults ?? []).toList();

      if (trigger.conditionSource == 'ROLAGEM') {
        int successCount = allDiceResults.where((roll) {
          if (trigger.conditionOperator == '==') {
            return roll == trigger.conditionTargetValue;
          } else if (trigger.conditionOperator == 'Entre') return roll >= trigger.conditionTargetValue && roll <= trigger.conditionMaxValue;
          else return (trigger.conditionOperator == '>=' && roll >= trigger.conditionTargetValue) || (trigger.conditionOperator == '<=' && roll <= trigger.conditionTargetValue);
        }).length;
        if (successCount >= trigger.requiredSuccesses) conditionMet = true;
        conditionLog = '$successCount sucessos.';
      } else {
        final extraDieRoll = _rollDie(trigger.conditionDieSides);
        conditionLog = 'Extra: $extraDieRoll';
        if (trigger.conditionOperator == '==') {
          conditionMet = extraDieRoll == trigger.conditionTargetValue;
        } else if (trigger.conditionOperator == 'Entre') conditionMet = extraDieRoll >= trigger.conditionTargetValue && extraDieRoll <= trigger.conditionMaxValue;
        else conditionMet = (trigger.conditionOperator == '>=' && extraDieRoll >= trigger.conditionTargetValue) || (trigger.conditionOperator == '<=' && extraDieRoll <= trigger.conditionTargetValue);
      }

      if (conditionMet) {
        switch (trigger.effectType) {
          case 'Multiplicador de Dano': 
            finalMultiplier *= trigger.multiplier; 
            triggerDetails += '\nATIVADO: ${trigger.description} (x${trigger.multiplier}). $conditionLog';
            break;
          case 'Adicionar Dados':
            for (final spec in trigger.bonusDice) {
              int groupTotal = 0;
              final List<int> groupResults = [];
              for (int i = 0; i < spec.quantity; i++) {
                int singleRoll = _rollDie(spec.sides);
                groupTotal += singleRoll;
                groupResults.add(singleRoll);
              }
              totalRollResult += groupTotal;
              individualRolls.add(DieSpecification(quantity: spec.quantity, sides: spec.sides, damageType: 'Gatilho', rollResult: groupTotal, individualResults: groupResults));
            }
            triggerDetails += '\nATIVADO: ${trigger.description}. $conditionLog';
            break;
          case 'Adicionar Modificador': 
            currentModifier += trigger.bonusModifier; 
            triggerDetails += '\nATIVADO: ${trigger.description} (+${trigger.bonusModifier}). $conditionLog';
            break;
        }
      }
    }

    final int preMultipliedTotal = totalRollResult + currentModifier;
    final int finalTotal = (preMultipliedTotal * finalMultiplier).round();
    int finalResult = defenseTarget != null ? finalTotal - defenseTarget : finalTotal;

    final result = RollResult(total: finalResult, details: dice.map((d) => '${d.quantity}d${d.sides}').join(' + '), individualRolls: individualRolls, modifier: currentModifier, preMultipliedTotal: preMultipliedTotal, multiplier: finalMultiplier, incomingDamage: defenseTarget, mitigationResult: finalTotal, bonusSources: bonusSources);
    
    final now = DateTime.now();
    final timeString = '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')}';
    
    final multiplierString = finalMultiplier != 1.0 ? 'x${finalMultiplier.toStringAsFixed(2)} ' : '';
    String finalStringForHistory;
    if (defenseTarget != null) {
       finalStringForHistory = '$finalTotal (mitigado) - $defenseTarget = $finalResult'; 
    } else {
       finalStringForHistory = "= $finalTotal";
    }
    final individualRollsString = individualRolls.map((d) => '${d.quantity}d${d.sides}: [${d.individualResults!.join(', ')}]').join('; ');
    String bonusStringFormatted = "";
    if (bonusSources.isNotEmpty) {
        bonusStringFormatted = "Bônus: ${bonusSources.map((b) => '${b.sourceName} (${b.value})').join(', ')}";
    } else {
        bonusStringFormatted = " "; 
    }

    final historyEntry = '$timeString - $name: ${dice.map((d) => '${d.quantity}d${d.sides}').join(' + ')} $multiplierString+ ($currentModifier) $finalStringForHistory | $individualRollsString | $bonusStringFormatted | ${triggerDetails.replaceAll('\n', ' ')}';
    
    setState(() => _rollHistory.add(historyEntry));
    _saveRollHistory();
    
    if (NetworkManager().isConnected) NetworkManager().sendRoll("Jogador", name, finalResult);
    
    _showRollDialog(result, name, extraDescription: extraDescription + triggerDetails);
    return result;
  }

  RollResult _onDiceRolledOnMesa({required int sides, int quantity = 1, int modifier = 0}) {
    return _performRoll(name: '${quantity}d$sides', dice: [DieSpecification(quantity: quantity, sides: sides)], modifier: modifier);
  }

  RollResult _onDiceRolledFromSheet(String description, List<DieSpecification> dice, {int modifier = 0, double multiplier = 1.0, String extraDescription = '', int? defenseTarget, List<ConditionalEffect> triggers = const [], List<BonusSource> bonusSources = const [],}) {
    return _performRoll(name: description, dice: dice, modifier: modifier, multiplier: multiplier, extraDescription: extraDescription, defenseTarget: defenseTarget, triggers: triggers, bonusSources: bonusSources);
  }

  void _showRollDialog(RollResult result, String description, {String extraDescription = ''}) {
    final isBlockRoll = result.incomingDamage != null;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    showDialog(
      context: context,
      barrierColor: Colors.black54,
      builder: (context) => GestureDetector(
        onTap: () => Navigator.of(context).pop(),
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: Center(
            child: IntrinsicHeight(
              child: Container(
                width: 300,
                constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.8),
                padding: const EdgeInsets.all(24.0),
                decoration: BoxDecoration(color: theme.cardColor, borderRadius: BorderRadius.circular(16), boxShadow: const [BoxShadow(color: Colors.black45, blurRadius: 10, offset: Offset(0, 4))]),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(description, style: theme.textTheme.titleLarge, textAlign: TextAlign.center),
                      const SizedBox(height: 12),
                      if (isBlockRoll) ...[
                         Text('Dano: ${result.incomingDamage}', style: const TextStyle(color: Colors.redAccent)),
                         Text('Mitigação: ${result.mitigationResult}', style: const TextStyle(color: Colors.green)),
                      ],
                      const SizedBox(height: 10),
                      Text(result.total.toString(), style: theme.textTheme.displayLarge?.copyWith(color: colorScheme.primary, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
                       if (isBlockRoll)
                        Text(result.total >= 0 ? 'Bloqueado' : 'Sofreu Dano', style: TextStyle(color: result.total >= 0 ? Colors.green : Colors.red, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 16),
                      ...result.individualRolls.map((spec) => Text('${spec.quantity}d${spec.sides}: [${spec.individualResults?.join(', ') ?? ''}]', style: theme.textTheme.bodyMedium, textAlign: TextAlign.center)),
                      if (result.modifier != 0) Text('Modificador: ${result.modifier > 0 ? "+" : ""}${result.modifier}', style: theme.textTheme.bodySmall),
                      if (result.bonusSources.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Text('Bônus:', style: TextStyle(color: colorScheme.secondary, fontWeight: FontWeight.bold)),
                        ...result.bonusSources.map((b) => Text('${b.sourceName}: ${b.value}', style: theme.textTheme.bodySmall)),
                      ],
                      if (extraDescription.isNotEmpty) ...[
                        const SizedBox(height: 10),
                        Text(extraDescription.trim(), style: const TextStyle(color: Colors.amber), textAlign: TextAlign.center),
                      ],
                      if (result.multiplier != 1.0) Text('Mult: x${result.multiplier.toStringAsFixed(2)}', style: theme.textTheme.bodySmall),
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
    showDialog(
      context: context, 
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).cardColor,
        title: const Text('Apagar Histórico'), 
        content: const Text("Tem certeza? Depois não adianta dizer que foi sem querer!"), 
        actions: [
          TextButton(onPressed: () { setState(() { _rollHistory.clear(); _saveRollHistory(); }); Navigator.pop(context); }, child: const Text('Sim')),
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Não'))
        ]
      )
    );
  }

  void _addNewDie() {
     final c = TextEditingController();
     showDialog(context: context, builder: (context) => AlertDialog(title: const Text('Novo Dado Custom'), content: TextField(controller: c, keyboardType: TextInputType.number), actions: [TextButton(onPressed: () { final s = int.tryParse(c.text); if (s!=null) { setState(() { _customDice.add(s); _saveCustomDice(); }); } Navigator.pop(context); }, child: const Text('OK'))]));
  }
  
  void _deleteCustomDie(int sides) { setState(() { _customDice.remove(sides); _saveCustomDice(); }); }
  void _showHelp() { Navigator.of(context).push(MaterialPageRoute(builder: (context) => const HelpScreen())); }
  void _showSettings() { Navigator.of(context).push(MaterialPageRoute(builder: (context) => const SettingsScreen())); }
  void _showConnectionScreen() { Navigator.of(context).push(MaterialPageRoute(builder: (context) => ConnectionScreen(sheets: _characterSheets))); }
  void _showAbout() { showDialog(context: context, builder: (context) => AlertDialog(title: const Text('Sobre'), content: const Text('Overlord v1.0'), actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('OK'))])); }
  void _rateApp() {}

  @override
  Widget build(BuildContext context) {
    final List<Widget> screensList = [
      DiceRollerScreen(
        customDice: _customDice, onRoll: _onDiceRolledOnMesa, onClearHistory: _clearHistory, onAddNewDie: _addNewDie,
        onHelp: _showHelp, onAbout: _showAbout, onRateApp: _rateApp, onConnect: _showConnectionScreen, onSettings: _showSettings, onDeleteCustomDie: _deleteCustomDie,
      ),
      roll_history.RollHistoryScreen(
        rollHistory: _rollHistory, onClearHistory: _clearHistory, onAddNewDie: _addNewDie, onHelp: _showHelp, onAbout: _showAbout, onRateApp: _rateApp,
      ),
      CharacterSheetsScreen(
        onSaveSheet: _saveCharacterSheet,
        onDeleteSheet: _deleteCharacterSheet,
        onReorderSheets: _reorderCharacterSheets, // NOVO!
        characterSheets: _characterSheets,
        onClearHistory: _clearHistory, onAddNewDie: _addNewDie, onHelp: _showHelp, onAbout: _showAbout, onRateApp: _rateApp,
        onDiceRolledFromSheet: _onDiceRolledFromSheet, showToast: _showToast, onToggleGodMode: _toggleGodMode,
      ),
    ];

    return Scaffold(
      appBar: _selectedIndex == 0 ? null : AppBar(toolbarHeight: 0, backgroundColor: Theme.of(context).primaryColor),
      body: SafeArea(
        child: Column(
          children: [
            if (_selectedIndex != 0)
              Container(
                height: 56, 
                padding: const EdgeInsets.symmetric(horizontal: 16),
                color: Theme.of(context).cardColor,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(_selectedIndex == 1 ? 'Histórico' : 'Fichas', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (_selectedIndex == 2)
                          IconButton(icon: const Icon(Icons.file_download_outlined), tooltip: 'Importar Ficha', onPressed: _showImportDialog),
                        GlobalMenu(onClearHistory: _clearHistory, onAddNewDie: _addNewDie, onConnect: _showConnectionScreen, onSettings: _showSettings, onHelp: _showHelp, onAbout: _showAbout, onRateApp: _rateApp, sheets: const []),
                      ],
                    ),
                  ],
                ),
              ),
            Expanded(child: IndexedStack(index: _selectedIndex, children: screensList)),
          ],
        ),
      ),
      bottomNavigationBar: CustomBottomNavigationBar(selectedIndex: _selectedIndex, onTabTapped: _onTabTapped),
    );
  }
}