// lib/screens/online_tabletop_screen.dart

import 'dart:io';
import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:overlord/models/armor.dart';
import 'package:overlord/models/character_sheet.dart';
import 'package:overlord/models/die_specification.dart';
import 'package:overlord/models/ability.dart';
import 'package:overlord/models/passive_bonuses.dart';
import 'package:overlord/models/status_effect.dart';
import 'package:overlord/models/weapon.dart';
import 'package:overlord/services/network_manager.dart';
import 'package:uuid/uuid.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:overlord/models/passive.dart';

// --- MODELO VISUAL DO HISTÓRICO ---
class HistoryEntry {
  final String author;
  final String action;
  final String time;
  final String? resultDetails;
  final String type;

  HistoryEntry({required this.author, required this.action, required this.time, this.resultDetails, this.type = 'info'});
  
  Map<String, dynamic> toJson() => {'author': author, 'action': action, 'time': time, 'resultDetails': resultDetails, 'type': type};
  factory HistoryEntry.fromJson(Map<String, dynamic> json) => HistoryEntry(
    author: json['author'], action: json['action'], time: json['time'], resultDetails: json['resultDetails'], type: json['type'] ?? 'info'
  );
}

// --- MODELO DE DESENHO (CANETA TÁTICA) ---
class DrawLine {
  String id;
  String authorId;
  List<Offset> points;
  int colorValue;
  
  DrawLine({required this.id, required this.authorId, required this.points, required this.colorValue});
  
  Map<String, dynamic> toJson() => {'id': id, 'a': authorId, 'c': colorValue, 'p': points.map((e) => {'x': e.dx, 'y': e.dy}).toList()};
  factory DrawLine.fromJson(Map<String, dynamic> json) => DrawLine(
    id: json['id'] ?? const Uuid().v4(),
    authorId: json['a'] ?? 'unknown',
    colorValue: json['c'] ?? Colors.red.value,
    points: (json['p'] as List).map((e) => Offset((e['x'] as num).toDouble(), (e['y'] as num).toDouble())).toList()
  );
}

// --- MODELOS DA MESA ---
class MapToken {
  String id;
  String sheetId;
  String name;
  String? imagePath;
  double x;
  double y;
  double size;
  bool isHidden;
  int team;

  bool isObstacle;
  int stunRounds;
  List<StatusEffect> activeStatusEffects;
  List<String> elementalTypes; 

  int hpCurrent;
  int hpTotal;
  int sanCurrent;
  int sanTotal;
  int effCurrent;
  int effTotal;
  int effTempCurrent;  // NOVO: Esforço Temporário
  int effTempTotal;    // NOVO: Esforço Temporário
  int madCurrent;

  int initiative;
  
  String battleCondition;
  String enemyScenario;
  
  Map<String, int> maxActions;
  Map<String, int> currentActions;

  int reactionsCurrent;
  int reactionsMax;

  MapToken({
    required this.id,
    required this.sheetId,
    required this.name,
    this.imagePath,
    this.x = 0,
    this.y = 0,
    this.size = 1.0,
    this.isHidden = false,
    this.team = 0,
    this.isObstacle = false,
    this.stunRounds = 0,
    this.activeStatusEffects = const [],
    this.elementalTypes = const ['Neutro'],
    this.hpCurrent = 10,
    this.hpTotal = 10,
    this.sanCurrent = 10,
    this.sanTotal = 10,
    this.effCurrent = 10,
    this.effTotal = 10,
    this.effTempCurrent = 0,
    this.effTempTotal = 0,
    this.madCurrent = 0,
    this.initiative = 0,
    this.battleCondition = 'Desafiante',
    this.enemyScenario = '1v1',
    this.reactionsCurrent = 0,
    this.reactionsMax = 0,
    Map<String, int>? maxActions,
    Map<String, int>? currentActions,
  }) : 
    maxActions = maxActions ?? {'MOV': 1, 'ATK': 1, 'MAG': 1, 'LIV': 1},
    currentActions = currentActions ?? {'MOV': 1, 'ATK': 1, 'MAG': 1, 'LIV': 1};

  Map<String, dynamic> toJson() => {
    'id': id, 'sheetId': sheetId, 'name': name, 'imagePath': imagePath,
    'x': x, 'y': y, 'size': size, 'isHidden': isHidden, 'team': team,
    'isObstacle': isObstacle,
    'stunRounds': stunRounds,
    'activeStatusEffects': activeStatusEffects.map((s) => s.toJson()).toList(),
    'elementalTypes': elementalTypes,
    'hpCurrent': hpCurrent, 'hpTotal': hpTotal,
    'sanCurrent': sanCurrent, 'sanTotal': sanTotal,
    'effCurrent': effCurrent, 'effTotal': effTotal,
    'effTempCurrent': effTempCurrent, 'effTempTotal': effTempTotal,
    'madCurrent': madCurrent,
    'initiative': initiative,
    'maxActions': maxActions,
    'currentActions': currentActions,
    'battleCondition': battleCondition,
    'enemyScenario': enemyScenario,
    'reactionsCurrent': reactionsCurrent,
    'reactionsMax': reactionsMax,
  };

  factory MapToken.fromJson(Map<String, dynamic> json) => MapToken(
    id: json['id'], sheetId: json['sheetId'], name: json['name'], imagePath: json['imagePath'],
    x: json['x'], y: json['y'], size: json['size'], isHidden: json['isHidden'] ?? false, team: json['team'] ?? 0,
    isObstacle: json['isObstacle'] ?? false,
    stunRounds: json['stunRounds'] ?? 0,
    activeStatusEffects: (json['activeStatusEffects'] as List?)?.map((s) => StatusEffect.fromJson(s)).toList() ?? [],
    elementalTypes: List<String>.from(json['elementalTypes'] ?? ['Neutro']),
    hpCurrent: json['hpCurrent'], hpTotal: json['hpTotal'],
    sanCurrent: json['sanCurrent'], sanTotal: json['sanTotal'],
    effCurrent: json['effCurrent'], effTotal: json['effTotal'],
    effTempCurrent: json['effTempCurrent'] ?? 0,
    effTempTotal: json['effTempTotal'] ?? 0,
    madCurrent: json['madCurrent'],
    initiative: json['initiative'] ?? 0,
    maxActions: Map<String, int>.from(json['maxActions'] ?? {'MOV': 1, 'ATK': 1, 'MAG': 1, 'LIV': 1}),
    currentActions: Map<String, int>.from(json['currentActions'] ?? {'MOV': 1, 'ATK': 1, 'MAG': 1, 'LIV': 1}),
    battleCondition: json['battleCondition'] ?? 'Desafiante',
    enemyScenario: json['enemyScenario'] ?? '1v1',
    reactionsCurrent: json['reactionsCurrent'] ?? 0,
    reactionsMax: json['reactionsMax'] ?? 0,
  );
}

class TableScenario {
  String name;
  String? backgroundPath;
  int gridRows;
  int gridCols;
  double blockSize;
  bool drawingsLocked;
  List<MapToken> tokens;
  List<DrawLine> drawings;

  TableScenario({
    this.name = "Novo Cenário", this.backgroundPath,
    this.gridRows = 20, this.gridCols = 20, this.blockSize = 60.0,
    this.drawingsLocked = false,
    List<MapToken>? tokens, List<DrawLine>? drawings,
  }) : tokens = tokens ?? [], drawings = drawings ?? [];

  Map<String, dynamic> toJson() => {
    'name': name, 'backgroundPath': backgroundPath, 'gridRows': gridRows, 'gridCols': gridCols,
    'blockSize': blockSize, 'drawingsLocked': drawingsLocked,
    'tokens': tokens.map((t) => t.toJson()).toList(), 'drawings': drawings.map((d) => d.toJson()).toList(),
  };

  factory TableScenario.fromJson(Map<String, dynamic> json) => TableScenario(
    name: json['name'] ?? "Cenário Carregado", backgroundPath: json['backgroundPath'],
    gridRows: json['gridRows'] ?? 20, gridCols: json['gridCols'] ?? 20,
    blockSize: (json['blockSize'] as num?)?.toDouble() ?? 60.0,
    drawingsLocked: json['drawingsLocked'] ?? false,
    tokens: (json['tokens'] as List?)?.map((t) => MapToken.fromJson(t)).toList() ?? [],
    drawings: (json['drawings'] as List?)?.map((d) => DrawLine.fromJson(d)).toList() ?? [],
  );
}

class OnlineTabletopScreen extends StatefulWidget {
  final bool isHost;
  final List<CharacterSheet> availableSheets;
  final CharacterSheet? myCharacterSheet;

  static TableScenario? persistentScenario;
  static List<HistoryEntry>? persistentHistory;
  static MapToken? persistentMyToken;

  static void clearTable() {
    persistentScenario = null;
    persistentHistory = null;
    persistentMyToken = null;
  }

  const OnlineTabletopScreen({super.key, required this.isHost, required this.availableSheets, this.myCharacterSheet});

  @override
  State<OnlineTabletopScreen> createState() => _OnlineTabletopScreenState();
}

class _OnlineTabletopScreenState extends State<OnlineTabletopScreen> with SingleTickerProviderStateMixin {
  bool _isSheetOpen = false;
  bool _isGodModeActive = false;

  Future<void> _loadGodMode() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.reload(); // <-- ISTO GARANTE QUE ELE LÊ O CÓDIGO 777 ATUALIZADO!
    if (mounted) {
      setState(() => _isGodModeActive = prefs.getBool('god_mode') ?? false);
    }
  }

  late TableScenario _scenario;
  List<HistoryEntry> _historyLog = [];
  MapToken? _myToken;
  MapToken? _focusedToken;
  
  final TransformationController _transformController = TransformationController();
  double? _dragStartX;
  double? _dragStartY;
  
  bool _isPlacingMode = false;
  CharacterSheet? _pendingSheetToPlace;
  Map<String, dynamic>? _pendingObstacleToPlace;

  final bool _isCombatActive = false;
  final int _currentRound = 1;
  final int _turnIndex = 0;
  final List<MapToken> _initiativeOrder = [];

  bool _isTargetMode = false;
  String? _pendingActionName;
  List<DieSpecification>? _pendingActionDice;
  int _pendingActionModifier = 0;
  double _pendingActionMultiplier = 1.0;
  Ability? _pendingAbility;
  String? _pendingObstacleImage;

  final String _myClientId = const Uuid().v4();
  bool _isDrawingMode = false;

  bool _isClashZoneMode = false;
  Offset? _clashZoneStart;
  Offset? _clashZoneEnd;
  final List<Map<String, dynamic>> _clashZones = [];
  String _drawingTool = 'brush';
  Color _brushColor = Colors.redAccent;
  List<Offset> _currentLine = [];
  final List<Color> _palette = [Colors.redAccent, Colors.greenAccent, Colors.blueAccent, Colors.white, Colors.black];

  late TabController _bottomTabController;

  final List<Map<String, dynamic>> _pendingJointActions = [];
  Map<String, dynamic>? _hostedJointAction;

  // --- MATEMÁTICA DA BORRACHA ---
  double _distToSegmentSquared(Offset p, Offset v, Offset w) {
    double l2 = (v.dx - w.dx)*(v.dx - w.dx) + (v.dy - w.dy)*(v.dy - w.dy);
    if (l2 == 0) return (p.dx - v.dx)*(p.dx - v.dx) + (p.dy - v.dy)*(p.dy - v.dy);
    double t = ((p.dx - v.dx) * (w.dx - v.dx) + (p.dy - v.dy) * (w.dy - v.dy)) / l2;
    t = max(0, min(1, t));
    Offset proj = Offset(v.dx + t * (w.dx - v.dx), v.dy + t * (w.dy - v.dy));
    return (p.dx - proj.dx)*(p.dx - proj.dx) + (p.dy - proj.dy)*(p.dy - proj.dy);
  }

  bool _isLineHit(Offset p, DrawLine line) {
    for (int i = 0; i < line.points.length - 1; i++) {
       double distSq = _distToSegmentSquared(p, line.points[i], line.points[i+1]);
       if (distSq < 0.03) return true;
    }
    return false;
  }

  // --- LÓGICA DE EQUIPAMENTO E PERSISTÊNCIA ---
  Future<void> _saveGlobalChanges() async {
    final prefs = await SharedPreferences.getInstance();
    final String sheetsJson = jsonEncode(widget.availableSheets.map((s) => s.toJson()).toList());
    await prefs.setString('character_sheets', sheetsJson);
    if (_focusedToken != null) _syncTokenToSheet(_focusedToken!);
  }

  void _equipItem(CharacterSheet sheet, dynamic item) {
    setState(() {
      if (item is Weapon) {
        sheet.weapons.add(item);
        sheet.backpack.remove(item);
        _showToast("${item.name} equipada com sucesso!");
      } else if (item is Armor) {
        if (sheet.equippedArmor != null) {
          sheet.backpack.add(sheet.equippedArmor!);
        }
        sheet.equippedArmor = item;
        sheet.backpack.remove(item);
        _showToast("${item.name} equipada com sucesso!");
      } else {
        _showToast("Este item não é uma arma ou armadura equipável.");
      }
    });
    _saveGlobalChanges();
  }

  void _unequipWeapon(CharacterSheet sheet, Weapon weapon) {
    setState(() {
      sheet.backpack.add(weapon); 
      sheet.weapons.removeWhere((w) => w.id == weapon.id);
    });
    _saveGlobalChanges();
    _showToast("${weapon.name} guardada na mochila.");
  }

  void _showItemOptionsDialog(CharacterSheet sheet, dynamic item) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.grey[900],
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(
                item is Weapon ? Icons.colorize : (item is Armor ? Icons.shield : Icons.info), 
                color: item is Weapon ? Colors.redAccent : (item is Armor ? Colors.blueAccent : Colors.amber),
                size: 30,
              ),
              title: Text(item.name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
              subtitle: Text(item.description, style: const TextStyle(color: Colors.white54), maxLines: 2, overflow: TextOverflow.ellipsis),
            ),
            const Divider(color: Colors.white24),
            if (item is Weapon || item is Armor)
              ListTile(
                leading: const Icon(Icons.pan_tool, color: Colors.greenAccent),
                title: const Text("Equipar", style: TextStyle(color: Colors.white)),
                onTap: () { Navigator.pop(ctx); _equipItem(sheet, item); },
              ),
            ListTile(
              leading: const Icon(Icons.edit, color: Colors.blueAccent),
              title: const Text("Editar Nome / Descrição", style: TextStyle(color: Colors.white)),
              onTap: () { Navigator.pop(ctx); _editItemDialog(sheet, item); },
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.redAccent),
              title: const Text("Excluir / Jogar Fora", style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(ctx);
                setState(() { sheet.backpack.remove(item); });
                _saveGlobalChanges();
                _showToast("${item.name} foi destruído/jogado fora.");
              },
            ),
          ],
        ),
      ),
    );
  }

  void _editItemDialog(CharacterSheet sheet, dynamic item) {
    final nameCtrl = TextEditingController(text: item.name);
    final descCtrl = TextEditingController(text: item.description);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: const Text("Editar Item", style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: nameCtrl, style: const TextStyle(color: Colors.white), decoration: const InputDecoration(labelText: "Nome do Item", labelStyle: TextStyle(color: Colors.amber))),
            const SizedBox(height: 10),
            TextField(controller: descCtrl, style: const TextStyle(color: Colors.white), decoration: const InputDecoration(labelText: "Descrição", labelStyle: TextStyle(color: Colors.amber)), maxLines: 3),
            if (item is Weapon) 
               const Padding(padding: EdgeInsets.only(top: 12.0), child: Text("Para editar o Dano (Dados), use a Ficha de Personagem completa.", style: TextStyle(color: Colors.white30, fontSize: 10))),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancelar", style: TextStyle(color: Colors.grey))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            onPressed: () {
              setState(() { item.name = nameCtrl.text; item.description = descCtrl.text; });
              _saveGlobalChanges();
              Navigator.pop(ctx);
              _showToast("Item atualizado!");
            },
            child: const Text("Salvar", style: TextStyle(color: Colors.white))
          )
        ]
      )
    );
  }

  // --- AÇÕES DA ARMA ---
  void _rollWeaponDamageDirectly(Weapon w) {
    if (w.dice.isEmpty && w.modifier == 0) { _showToast("Esta arma não possui dano configurado."); return; }
    int total = 0;
    List<String> rollBreakdown = [];
    
    if (w.dice.isNotEmpty) {
      for (var d in w.dice) {
         List<int> currentRolls = [];
         for(int i = 0; i < d.quantity; i++) { int roll = _rollDie(d.sides); currentRolls.add(roll); total += roll; }
         rollBreakdown.add("${d.quantity}d${d.sides} (${d.damageType ?? 'Físico'}): [${currentRolls.join(' + ')}]");
      }
    
    int finalTotal = ((total + w.modifier) * w.multiplier).toInt();
    List<String> modLines = [];
    if (w.modifier != 0) modLines.add("Modificador: ${w.modifier > 0 ? '+' : ''}${w.modifier}");
    if (w.multiplier != 1.0) modLines.add("Multiplicador: x${w.multiplier.toStringAsFixed(1)}");
    String modText = modLines.isNotEmpty ? "\n${modLines.join(' | ')}" : "";
    String charName = _myToken?.name ?? (widget.isHost ? "Mestre" : "Jogador");
    _broadcastLog(charName, "Causou Dano com ${w.name}", type: 'damage', details: "${rollBreakdown.join('\n')}$modText\n\n🩸 DANO TOTAL: $finalTotal");
    NetworkManager().sendRoll(charName, "Dano: ${w.name}", finalTotal);
    }
  }

  void _showAttackSkillSelector(CharacterSheet sheet, Weapon w) {
    int pontaria = sheet.pericias['Pontaria'] ?? sheet.pericias['Tiro'] ?? sheet.attributes['DES'] ?? 0;
    int luta = sheet.pericias['Artes-marciais'] ?? sheet.pericias['Luta'] ?? sheet.attributes['FOR'] ?? 0;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: Text("Teste de Acerto: ${w.name}", style: const TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
             const Text("Qual perícia vai usar para atacar?", style: TextStyle(color: Colors.white70)),
             const SizedBox(height: 16),
             ElevatedButton.icon(
               style: ElevatedButton.styleFrom(backgroundColor: Colors.blueAccent, minimumSize: const Size(double.infinity, 45)),
               icon: const Icon(Icons.gps_fixed, color: Colors.white),
               label: Text("Pontaria / Distância ($pontaria)", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
               onPressed: () { Navigator.pop(ctx); _executeTabletopRoll(sheet, _myToken?.name ?? sheet.name, "Acerto (${w.name})", pontaria + w.attackBonus); }
             ),
             const SizedBox(height: 10),
             ElevatedButton.icon(
               style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent, minimumSize: const Size(double.infinity, 45)),
               icon: const Icon(Icons.sports_martial_arts, color: Colors.white),
               label: Text("Luta / Corpo-a-Corpo ($luta)", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
               onPressed: () { Navigator.pop(ctx); _executeTabletopRoll(sheet, _myToken?.name ?? sheet.name, "Acerto (${w.name})", luta + w.attackBonus); }
             )
          ]
        ),
        actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancelar", style: TextStyle(color: Colors.grey)))],
      )
    );
  }

  void _showWeaponActionDialog(CharacterSheet sheet, Weapon w) {
    String diceConfig = w.dice.isNotEmpty ? w.dice.map((d) => '${d.quantity}d${d.sides}').join(' + ') : "Apenas Dano Fixo";
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.grey[900],
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.colorize, color: Colors.redAccent, size: 30),
              title: Text(w.name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
              subtitle: Text("Dados Configurados: $diceConfig", style: const TextStyle(color: Colors.amber)),
            ),
            const Divider(color: Colors.white24),
            ListTile(
              leading: const Icon(Icons.bloodtype, color: Colors.redAccent),
              title: const Text("Rolar DANO da Arma", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              subtitle: Text("Joga os $diceConfig configurados no chat", style: const TextStyle(color: Colors.white54)),
              onTap: () { Navigator.pop(ctx); _rollWeaponDamageDirectly(w); }
            ),
            ListTile(
              leading: const Icon(Icons.casino, color: Colors.blueAccent),
              title: const Text("Teste de Acerto (Perícia)", style: TextStyle(color: Colors.white)),
              subtitle: const Text("Usa Luta ou Pontaria para rolar o acerto", style: TextStyle(color: Colors.white54)),
              onTap: () { Navigator.pop(ctx); _showAttackSkillSelector(sheet, w); }
            ),
            ListTile(
              leading: const Icon(Icons.map, color: Colors.greenAccent),
              title: const Text("Atacar Alvo no Mapa (Dano)", style: TextStyle(color: Colors.white)),
              subtitle: const Text("Mirar em um inimigo e subtrair a vida dele", style: TextStyle(color: Colors.white54)),
              onTap: () { Navigator.pop(ctx); _startTargetMode(w.name, w.dice, w.modifier, null, multiplier: w.multiplier); }
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWeaponCard(Weapon w, CharacterSheet sheet) {
    return Card(
      color: Colors.black45,
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: const Icon(Icons.flash_on, color: Colors.redAccent),
        title: Text(w.name, style: const TextStyle(color: Colors.white)),
        trailing: IconButton(icon: const Icon(Icons.archive, size: 18, color: Colors.grey), onPressed: () => _unequipWeapon(sheet, w)),
        onTap: () => _showWeaponActionDialog(sheet, w),
      ),
    );
  }

  Widget _buildTabBackpack(CharacterSheet sheet) {
    if (sheet.backpack.isEmpty) return const Center(child: Text("Mochila vazia.", style: TextStyle(color: Colors.grey)));
    return GridView.builder(
      padding: const EdgeInsets.all(12),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, mainAxisSpacing: 10, crossAxisSpacing: 10, childAspectRatio: 0.8),
      itemCount: sheet.backpack.length,
      itemBuilder: (context, index) {
        final item = sheet.backpack[index];
        IconData iconData = Icons.inventory_2;
        Color iconColor = Colors.amber;
        if (item is Weapon) { iconData = Icons.colorize; iconColor = Colors.redAccent; }
        else if (item is Armor) { iconData = Icons.shield; iconColor = Colors.blueAccent; }
        return InkWell(
          onTap: () => _showItemOptionsDialog(sheet, item),
          child: Container(
            decoration: BoxDecoration(color: Colors.black38, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.white10)),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(child: Icon(iconData, color: iconColor, size: 30)),
                Padding(padding: const EdgeInsets.all(4.0), child: Text(item.name, textAlign: TextAlign.center, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.white, fontSize: 10))),
              ],
            ),
          ),
        );
      },
    );
  }

  // --- COMBINA DADOS DA ARMA + HABILIDADE ---
  List<DieSpecification> _getCombinedDice(CharacterSheet sheet, Ability ability) {
    List<DieSpecification> allDice = List.from(ability.bonusDice);
    if (ability.description.toLowerCase().contains("usa a arma") || ability.name.toLowerCase().contains("soco")) {
      for (var weapon in sheet.weapons) { allDice.addAll(weapon.dice); }
    }
    return allDice;
  }

  // --- AÇÕES DE HABILIDADE E RITUAIS ---
  void _rollAbilityDamageDirectly(MapToken token, Ability a) {
    final sheet = widget.availableSheets.firstWhere((s) => s.id == token.sheetId);
    final bonuses = _getCharacterBonuses(sheet, [a.name, 'Geral']);
    List<DieSpecification> combinedDice = _getCombinedDice(sheet, a);
    int diceSum = 0;
    List<String> rollBreakdown = [];
    for (var d in combinedDice) {
      List<int> results = [];
      for (int i = 0; i < d.quantity; i++) { int r = _rollDie(d.sides); results.add(r); diceSum += r; }
      rollBreakdown.add("${d.quantity}d${d.sides}: [${results.join(' + ')}]");
    }
    if (combinedDice.isEmpty) rollBreakdown.add("Apenas Efeito Fixo");
    int totalMod = a.bonusModifier + bonuses.modifier;
    int rawTotal = diceSum + totalMod;
    int finalTotal = (rawTotal * bonuses.multiplier).toInt();
    List<String> bonusLines = [];
    if (totalMod != 0) bonusLines.add("Modificador: ${totalMod > 0 ? '+' : ''}$totalMod");
    if (bonuses.multiplier != 1.0) bonusLines.add("Multiplicador: x${bonuses.multiplier.toStringAsFixed(1)}");
    String bonusText = bonusLines.isNotEmpty ? "\n${bonusLines.join(' | ')}" : "";
    _broadcastLog(token.name, "Ativou ${a.name}", type: a.abilityType == 'Restaurar Vida' ? 'info' : 'damage', details: "${rollBreakdown.join('\n')}$bonusText\n\n💥 TOTAL: $finalTotal");
    NetworkManager().sendRoll(token.name, "Efeito: ${a.name}", finalTotal);
  }

  void _showAbilityActionDialog(CharacterSheet sheet, MapToken token, Ability a) {
    List<DieSpecification> combinedDice = _getCombinedDice(sheet, a);
    String diceConfig = combinedDice.isNotEmpty ? combinedDice.map((d) => '${d.quantity}d${d.sides}').join(' + ') : "Efeito Fixo";
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.grey[900],
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.auto_awesome, color: a.abilityType == 'Restaurar Vida' ? Colors.greenAccent : Colors.cyan, size: 30),
              title: Text(a.name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
              subtitle: Text("Custo: ${a.costAmount} ${a.costType} | Dados Reais: $diceConfig", style: const TextStyle(color: Colors.amber)),
            ),
            const Divider(color: Colors.white24),
            if (a.abilityType == 'Buff/Transformação')
              SwitchListTile(
                title: const Text("Ativar Transformação (Buff)", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                subtitle: const Text("Aplica modificadores e gatilhos", style: TextStyle(color: Colors.white54)),
                value: a.isActive,
                activeThumbColor: Colors.cyanAccent,
                onChanged: (val) {
                  setState(() {
                     a.isActive = val;
                     if (val) { _consumeSheetResources(token, a); _applyAbilityTriggers(sheet, token, a); }
                     else {
                        if (a.selfStatusEffectsToApply.isNotEmpty) {
                           sheet.statusEffects.removeWhere((e) => a.selfStatusEffectsToApply.any((debuff) => debuff.name == e.name));
                           token.activeStatusEffects.removeWhere((e) => a.selfStatusEffectsToApply.any((debuff) => debuff.name == e.name));
                        }
                     }
                  });
                  _saveGlobalChanges();
                  Navigator.pop(ctx);
                  _broadcastLog(token.name, val ? "Ativou ${a.name}" : "Desativou ${a.name}", type: 'info');
                }
              ),
            ListTile(
              leading: Icon(a.abilityType == 'Restaurar Vida' ? Icons.healing : Icons.local_fire_department, color: Colors.redAccent),
              title: Text(a.abilityType == 'Restaurar Vida' ? "Rolar Cura Direta" : "Rolar Dano/Efeito Direto", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              subtitle: const Text("Gasta o custo e rola os dados configurados no chat", style: TextStyle(color: Colors.white54)),
              onTap: () { Navigator.pop(ctx); _consumeSheetResources(token, a); _applyAbilityTriggers(sheet, token, a); _rollAbilityDamageDirectly(token, a); }
            ),
            ListTile(
              leading: const Icon(Icons.casino, color: Colors.blueAccent),
              title: const Text("Teste de Acerto/Ativação", style: TextStyle(color: Colors.white)),
              subtitle: Text(a.attackSkill != null && a.attackSkill!.isNotEmpty ? "Rolar com ${a.attackSkill}" : "Rolar 1d20 + Bônus genérico", style: const TextStyle(color: Colors.white54)),
              onTap: () {
                Navigator.pop(ctx);
                if (a.attackSkill != null && a.attackSkill!.isNotEmpty) {
                   int pnt = sheet.pericias[a.attackSkill] ?? sheet.attributes[a.attackSkill] ?? 0;
                   _executeTabletopRoll(sheet, _myToken?.name ?? sheet.name, "Ativação (${a.name})", pnt + a.attackBonus);
                } else {
                   _rollGenericDice(20, quantity: 1, modifier: a.attackBonus);
                }
              }
            ),
            ListTile(
              leading: const Icon(Icons.map, color: Colors.greenAccent),
              title: const Text("Usar Habilidade no Mapa", style: TextStyle(color: Colors.white)),
              subtitle: const Text("Mirar em um alvo e aplicar efeitos", style: TextStyle(color: Colors.white54)),
              onTap: () {
                Navigator.pop(ctx);
                _consumeSheetResources(token, a);
                _applyAbilityTriggers(sheet, token, a);
                _startTargetMode(a.name, combinedDice, a.bonusModifier, a, multiplier: a.multiplier);
              }
            ),
          ],
        ),
      ),
    );
  }

  // --- MOTOR DE CÁLCULO DE MODIFICADORES ---
  PassiveBonuses _getCharacterBonuses(CharacterSheet sheet, List<String> targets) {
    double points = 0;
    double mod = 0;
    double mult = 1.0;

    void processEffect(dynamic effect) {
      if (targets.any((t) => effect.targets.contains(t))) {
        if (effect.bonusType == 'Pontos') { points += effect.value; }
        else if (effect.bonusType == 'Percentual') { mult += (effect.value / 100); }
        else { mod += effect.value; }
      }
    }

    for (var effect in sheet.statusEffects) {
      processEffect(effect);
    }
    for (var passive in sheet.passives) { if (passive.isActive) { for (var effect in passive.effects) {
      processEffect(effect);
    } } }
    for (var ability in sheet.abilities) { if (ability.isActive) { for (var effect in ability.effects) {
      processEffect(effect);
    } } }
    for (var weapon in sheet.weapons) { for (var effect in weapon.effects) {
      processEffect(effect);
    } }
    if (sheet.equippedArmor != null) { for (var effect in sheet.equippedArmor!.effects) {
      processEffect(effect);
    } }

    return PassiveBonuses(bonusPoints: points.toInt(), modifier: mod.toInt(), multiplier: mult, sources: []);
  }

  @override
  void initState() {
    super.initState();
    _loadGodMode();
    
    if (OnlineTabletopScreen.persistentScenario == null) {
      OnlineTabletopScreen.persistentScenario = TableScenario();
      OnlineTabletopScreen.persistentHistory = [];
    }
    
    _scenario = OnlineTabletopScreen.persistentScenario!;
    _historyLog = OnlineTabletopScreen.persistentHistory!;
    _myToken = OnlineTabletopScreen.persistentMyToken;
    _bottomTabController = TabController(length: 7, vsync: this);
    _setupNetwork();
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.myCharacterSheet != null && _myToken == null) {
        _prepareTokenPlacement(widget.myCharacterSheet!);
      } else if (widget.isHost && _myToken == null && _scenario.tokens.isEmpty) _showSheetSelectionDialog();
    });
  }

  @override
  void dispose() {
    OnlineTabletopScreen.persistentMyToken = _myToken;
    _bottomTabController.dispose();
    _transformController.dispose();
    super.dispose();
  }

  void _setupNetwork() {
    final net = NetworkManager();
    if (widget.isHost) {
      net.onPeerConnected = (peerId) {
        net.sendMessage(jsonEncode({'type': 'SYNC_SCENARIO', 'scenario': _scenario.toJson()}));
      };
    }
    net.onMessageReceived = (String jsonString) {
      if (!mounted) return;
      try {
        final data = jsonDecode(jsonString);
        if (data['type'] == 'LOG_ENTRY') {
          setState(() => _historyLog.insert(0, HistoryEntry.fromJson(data['entry'])));
        } else if (data['type'] == 'SYNC_SCENARIO') {
           setState(() {
             _scenario = TableScenario.fromJson(data['scenario']);
             if (!widget.isHost && widget.myCharacterSheet != null) {
                try { _myToken = _scenario.tokens.firstWhere((t) => t.sheetId == widget.myCharacterSheet!.id); } catch (_) {}
             }
           });
           _showToast("Mapa sincronizado!");
        } else if (data['type'] == 'SPAWN_TOKEN') {
           setState(() => _scenario.tokens.add(MapToken.fromJson(data['token'])));
        } else if (data['type'] == 'SPAWN_STRUCTURE') {
           _createStructureAt(data['name'], data['hp'], (data['x'] as num).toDouble(), (data['y'] as num).toDouble(), sync: false);
        } else if (data['type'] == 'MOVE_TOKEN') {
           setState(() {
              final token = _scenario.tokens.firstWhere((t) => t.id == data['id'], orElse: () => MapToken(id: 'null', sheetId: '', name: ''));
              if (token.id != 'null') { token.x = (data['x'] as num).toDouble(); token.y = (data['y'] as num).toDouble(); }
           });
        } else if (data['type'] == 'RESIZE_TOKEN') {
           setState(() {
              final token = _scenario.tokens.firstWhere((t) => t.id == data['id'], orElse: () => MapToken(id: 'null', sheetId: '', name: ''));
              if (token.id != 'null') token.size = (data['size'] as num).toDouble();
           });
        } else if (data['type'] == 'SYNC_TOKEN_HP') {
           setState(() {
              final token = _scenario.tokens.firstWhere((t) => t.id == data['id'], orElse: () => MapToken(id: 'null', sheetId: '', name: ''));
              if (token.id != 'null') {
                token.hpCurrent = (data['hp'] as num).toInt();
                if (data.containsKey('san')) token.sanCurrent = (data['san'] as num).toInt();
                if (data.containsKey('eff')) token.effCurrent = (data['eff'] as num).toInt();
                if (data.containsKey('mad')) token.madCurrent = (data['mad'] as num).toInt();
              }
           });
        } else if (data['type'] == 'TOGGLE_VISIBILITY') {
           setState(() {
              final token = _scenario.tokens.firstWhere((t) => t.id == data['id'], orElse: () => MapToken(id: 'null', sheetId: '', name: ''));
              if (token.id != 'null') token.isHidden = data['isHidden'];
           });
        } else if (data['type'] == 'JOINT_INVITE') {
           if (data['initiator'] != (_myToken?.name ?? (widget.isHost ? "Mestre" : ""))) {
              for (String allyId in data['allies']) {
                 if (widget.isHost || _myToken?.id == allyId) {
                    String tokenName = _scenario.tokens.firstWhere((t) => t.id == allyId, orElse: () => MapToken(id: 'null', sheetId: '', name: 'Desconhecido')).name;
                    _showJointInviteDialog(data['initiator'], data['targetName'], data['actionId'], data['isAttack'], tokenName, allyId);
                 }
              }
           }
        } else if (data['type'] == 'JOINT_ROLL') {
           if (_hostedJointAction != null && _hostedJointAction!['id'] == data['actionId']) {
              setState(() {
                 (_hostedJointAction!['rolls'] as List).add(data);
                 _hostedJointAction!['totalHit'] = (_hostedJointAction!['totalHit'] as int) + (data['hit'] as int);
                 _hostedJointAction!['totalDamage'] = (_hostedJointAction!['totalDamage'] as int) + (data['damage'] as int);
              });
           }
        }
      } catch (e) { debugPrint("Erro mesa: $e"); }
    };
  }

  void _broadcastLog(String author, String action, {String type = 'info', String? details}) {
    final time = "${DateTime.now().hour}:${DateTime.now().minute.toString().padLeft(2,'0')}";
    final entry = HistoryEntry(author: author, action: action, time: time, type: type, resultDetails: details);
    NetworkManager().sendMessage(jsonEncode({'type': 'LOG_ENTRY', 'entry': entry.toJson()}));
  }

  // --- POSICIONAMENTO E MAPA ---
  void _prepareTokenPlacement(CharacterSheet sheet) {
    setState(() { _isPlacingMode = true; _pendingSheetToPlace = sheet; _pendingObstacleToPlace = null; });
    _showToast("Toque no mapa para posicionar ${sheet.name}");
  }

  void _finalizePlacement(double x, double y) {
    if (_isSpaceOccupied(x, y)) { _showToast("Local ocupado!"); return; }
    if (_pendingSheetToPlace != null) {
      _createCharacterTokenAt(_pendingSheetToPlace!, x, y);
    } else if (_pendingObstacleToPlace != null) _createStructureAt(_pendingObstacleToPlace!['name'], _pendingObstacleToPlace!['hp'], x, y, sync: true);
    setState(() { _isPlacingMode = false; _pendingSheetToPlace = null; _pendingObstacleToPlace = null; });
  }

  bool _isSpaceOccupied(double x, double y, {String? excludeId}) {
    for (var t in _scenario.tokens) {
      if (t.id == excludeId) continue;
      if (t.x.round() == x.round() && t.y.round() == y.round()) return true;
    }
    return false;
  }

  void _createCharacterTokenAt(CharacterSheet sheet, double x, double y) {
    // Lê o Esforço Temporário da ficha se existir
    int effTempAtual = sheet.status['Esforço Temporário']?['atual']?.toInt() ?? 0;
    int effTempTotal = sheet.status['Esforço Temporário']?['total']?.toInt() ?? 0;

    final newToken = MapToken(
      id: const Uuid().v4(), sheetId: sheet.id, name: sheet.name, imagePath: sheet.imagePath, x: x, y: y,
      hpCurrent: sheet.status['Vida']?['atual']?.toInt() ?? 10, hpTotal: sheet.status['Vida']?['total']?.toInt() ?? 10,
      sanCurrent: sheet.status['Sanidade']?['atual']?.toInt() ?? 10, sanTotal: sheet.status['Sanidade']?['total']?.toInt() ?? 10,
      effCurrent: sheet.status['Esforço']?['atual']?.toInt() ?? 10, effTotal: sheet.status['Esforço']?['total']?.toInt() ?? 10,
      effTempCurrent: effTempAtual, effTempTotal: effTempTotal,
    );
    setState(() { _scenario.tokens.add(newToken); if (!widget.isHost && _myToken == null) _myToken = newToken; });
    _broadcastLog("GM", "${sheet.name} entrou na mesa.", type: 'info');
    if (widget.isHost) NetworkManager().sendMessage(jsonEncode({'type': 'SPAWN_TOKEN', 'token': newToken.toJson()}));
  }

  void _createStructureAt(String name, int hp, double x, double y, {bool sync = true}) {
     final struct = MapToken(id: const Uuid().v4(), sheetId: 'OBSTACLE', name: name, x: x, y: y, isObstacle: true, hpCurrent: hp, hpTotal: hp, imagePath: null);
     setState(() => _scenario.tokens.add(struct));
     if (sync && widget.isHost) {
        _broadcastLog("Mesa", "Estrutura '$name' criada.", type: 'info');
        NetworkManager().sendMessage(jsonEncode({'type': 'SPAWN_STRUCTURE', 'name': name, 'hp': hp, 'x': x, 'y': y}));
     }
  }

  CharacterSheet? _getSheetForToken(MapToken token) {
    try { return widget.availableSheets.firstWhere((s) => s.id == token.sheetId); } catch (e) { return null; }
  }

  void _refillActions(MapToken token) {
    token.currentActions = Map.from(token.maxActions);
    token.reactionsCurrent = token.reactionsMax;
  }

  // --- CONSUMO DE RECURSOS (COM SUPORTE A ESFORÇO TEMPORÁRIO) ---
  void _consumeSheetResources(MapToken token, Ability ability) {
     if (token.sheetId == 'OBSTACLE') return;
     try {
       final sheet = widget.availableSheets.firstWhere((s) => s.id == token.sheetId);
       double currentVida = (sheet.status['Vida']?['atual'] ?? 0).toDouble();
       double currentSan = (sheet.status['Sanidade']?['atual'] ?? 0).toDouble();
       double currentEff = (sheet.status['Esforço']?['atual'] ?? 0).toDouble();
       double currentEffTemp = (sheet.status['Esforço Temporário']?['atual'] ?? 0).toDouble();

       if (ability.costType == 'Vida') currentVida = (currentVida - ability.costAmount).clamp(0.0, 999.0).toDouble();
       if (ability.costType == 'Sanidade') currentSan = (currentSan - ability.costAmount).clamp(0.0, 999.0).toDouble();
       if (ability.costType == 'Esforço') {
         // Lógica híbrida: consome Esforço Temporário primeiro
         int cost = ability.costAmount;
         if (currentEffTemp > 0) {
           int fromTemp = min(cost, currentEffTemp.toInt());
           currentEffTemp -= fromTemp;
           cost -= fromTemp;
         }
         if (cost > 0) currentEff = (currentEff - cost).clamp(0.0, 999.0);
       }
       
       setState(() {
          sheet.status['Vida']!['atual'] = currentVida.toInt();
          sheet.status['Sanidade']!['atual'] = currentSan.toInt();
          sheet.status['Esforço']!['atual'] = currentEff.toInt();
          if (sheet.status.containsKey('Esforço Temporário')) {
            sheet.status['Esforço Temporário']!['atual'] = currentEffTemp.toInt();
          }
          token.hpCurrent = currentVida.toInt();
          token.sanCurrent = currentSan.toInt();
          token.effCurrent = currentEff.toInt();
          token.effTempCurrent = currentEffTemp.toInt();
       });
       if (!widget.isHost) {
         NetworkManager().sendMessage(jsonEncode({'type': 'SYNC_TOKEN_HP', 'id': token.id, 'hp': token.hpCurrent, 'san': token.sanCurrent, 'eff': token.effCurrent}));
       }
     } catch (e) { debugPrint("Erro ao consumir recursos: $e"); }
  }

  void _consumeSpecificResource(MapToken token, CharacterSheet sheet, String costType, int costAmount) {
     if (token.sheetId == 'OBSTACLE' || costAmount <= 0) return;
     try {
       double currentVida = (sheet.status['Vida']?['atual'] ?? 0).toDouble();
       double currentSan = (sheet.status['Sanidade']?['atual'] ?? 0).toDouble();
       double currentEff = (sheet.status['Esforço']?['atual'] ?? 0).toDouble();
       double currentEffTemp = (sheet.status['Esforço Temporário']?['atual'] ?? 0).toDouble();

       if (costType == 'Vida') currentVida = (currentVida - costAmount).clamp(0.0, 9999.0).toDouble();
       if (costType == 'Sanidade') currentSan = (currentSan - costAmount).clamp(0.0, 9999.0).toDouble();
       if (costType == 'Esforço') {
         int cost = costAmount;
         if (currentEffTemp > 0) {
           int fromTemp = min(cost, currentEffTemp.toInt());
           currentEffTemp -= fromTemp;
           cost -= fromTemp;
         }
         if (cost > 0) currentEff = (currentEff - cost).clamp(0.0, 9999.0);
       }
       
       setState(() {
          sheet.status['Vida']!['atual'] = currentVida.toInt();
          sheet.status['Sanidade']!['atual'] = currentSan.toInt();
          sheet.status['Esforço']!['atual'] = currentEff.toInt();
          if (sheet.status.containsKey('Esforço Temporário')) {
            sheet.status['Esforço Temporário']!['atual'] = currentEffTemp.toInt();
          }
          token.hpCurrent = currentVida.toInt();
          token.sanCurrent = currentSan.toInt();
          token.effCurrent = currentEff.toInt();
          token.effTempCurrent = currentEffTemp.toInt();
       });
       if (!widget.isHost) NetworkManager().sendMessage(jsonEncode({'type': 'SYNC_TOKEN_HP', 'id': token.id, 'hp': token.hpCurrent, 'san': token.sanCurrent, 'eff': token.effCurrent}));
     } catch (e) {}
  }

  // --- SINCRONIZA TOKEN → FICHA (COMPLETO) ---
  void _syncTokenToSheet(MapToken token) {
    if (token.sheetId == 'OBSTACLE') return;
    try {
      final sheet = widget.availableSheets.firstWhere((s) => s.id == token.sheetId);
      // Sincroniza todos os status de volta para a CharacterSheet
      sheet.status['Vida']!['atual'] = token.hpCurrent;
      sheet.status['Sanidade']!['atual'] = token.sanCurrent;
      sheet.status['Esforço']!['atual'] = token.effCurrent;
      if (sheet.status.containsKey('Esforço Temporário')) {
        sheet.status['Esforço Temporário']!['atual'] = token.effTempCurrent;
      }
      // Loucura não tem campo direto na CharacterSheet mas está no MapToken
      NetworkManager().sendMessage(jsonEncode({
        'type': 'SYNC_TOKEN_HP',
        'id': token.id,
        'hp': token.hpCurrent,
        'san': token.sanCurrent,
        'eff': token.effCurrent,
        'mad': token.madCurrent,
      }));
    } catch (e) {}
  }

  void _applyAbilityTriggers(CharacterSheet sheet, MapToken token, dynamic entity) {
    bool hasTriggers = false;
    if (entity.selfStatusEffectsToApply.isNotEmpty) {
      for (var effectData in entity.selfStatusEffectsToApply) {
        final newEffect = StatusEffect.fromJson(effectData.toJson());
        sheet.statusEffects.add(newEffect);
        token.activeStatusEffects.add(newEffect);
        _broadcastLog(token.name, "Gatilho: Sofreu o efeito ${newEffect.name}", type: 'alert');
      }
      hasTriggers = true;
    }
    if (entity.dynamicHealingStat != null && entity.dynamicHealingStat!.isNotEmpty && entity.dynamicHealingPercentage > 0) {
      int statBase = sheet.attributes[entity.dynamicHealingStat!] ?? sheet.pericias[entity.dynamicHealingStat!] ?? 0;
      int bonusPoints = _getCharacterBonuses(sheet, [entity.dynamicHealingStat!]).bonusPoints;
      int healAmount = ((statBase + bonusPoints) * (entity.dynamicHealingPercentage / 100)).toInt(); 
      if (healAmount > 0) {
         setState(() {
           token.hpCurrent = min(token.hpCurrent + healAmount, token.hpTotal);
           sheet.status['Vida']!['atual'] = token.hpCurrent;
         });
         NetworkManager().sendMessage(jsonEncode({'type': 'SYNC_TOKEN_HP', 'id': token.id, 'hp': token.hpCurrent}));
         _broadcastLog(token.name, "Gatilho: Recuperou $healAmount de Vida via ${entity.name}", type: 'info');
         hasTriggers = true;
      }
    }
    if (hasTriggers) { _saveGlobalChanges(); setState((){}); }
  }

  void _showPassiveActionDialog(CharacterSheet sheet, MapToken token, Passive p) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.grey[900],
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) => SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.psychology, color: Colors.amber, size: 30),
                title: Text(p.name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
                subtitle: Text("Gatilho: ${p.triggerType}", style: const TextStyle(color: Colors.white54)),
              ),
              const Divider(color: Colors.white24),
              if (p.triggerFrequency == 'Acumulável') ...[
                const Padding(padding: EdgeInsets.all(16.0), child: Text("Acúmulos Atuais", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(icon: const Icon(Icons.remove_circle_outline, color: Colors.redAccent, size: 40), onPressed: () { if (p.stacks > 0) { setState(() { p.stacks--; if (p.stacks == 0) p.isActive = false; }); setModalState(() {}); _saveGlobalChanges(); } }),
                    Padding(padding: const EdgeInsets.symmetric(horizontal: 20), child: Text("${p.stacks} / ${p.maxStacks > 90 ? '∞' : p.maxStacks}", style: const TextStyle(color: Colors.amber, fontSize: 24, fontWeight: FontWeight.bold))),
                    IconButton(icon: const Icon(Icons.add_circle_outline, color: Colors.greenAccent, size: 40), onPressed: () { if (p.stacks < p.maxStacks) { setState(() { p.stacks++; p.isActive = true; }); setModalState(() {}); _saveGlobalChanges(); } }),
                  ],
                ),
              ],
              if (p.triggerType != 'Sempre Ativo' && p.triggerFrequency != 'Acumulável') ...[
                SwitchListTile(
                  title: const Text("Ativar / Desativar Passiva", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  subtitle: Text(p.costAmount > 0 ? "Custo: ${p.costAmount} ${p.costType}" : "Nenhum custo extra", style: const TextStyle(color: Colors.white54)),
                  value: p.isActive,
                  activeThumbColor: Colors.cyanAccent,
                  onChanged: (val) {
                    setState(() {
                      p.isActive = val;
                      if (val) { if (p.costAmount > 0) _consumeSpecificResource(token, sheet, p.costType, p.costAmount); _applyAbilityTriggers(sheet, token, p); }
                      else {
                        if (p.selfStatusEffectsToApply.isNotEmpty) {
                           sheet.statusEffects.removeWhere((e) => p.selfStatusEffectsToApply.any((debuff) => debuff.name == e.name));
                           token.activeStatusEffects.removeWhere((e) => p.selfStatusEffectsToApply.any((debuff) => debuff.name == e.name));
                        }
                      }
                    });
                    setModalState(() {});
                    _saveGlobalChanges();
                    _broadcastLog(token.name, val ? "Ativou a passiva ${p.name}" : "Desativou a passiva ${p.name}", type: 'info');
                  },
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  // --- SISTEMA DE ESQUIVA ---
  void _showDodgeSystemDialog(MapToken myToken) {
    final sheet = _getSheetForToken(myToken);
    int diceQtd = 1; int diceSides = 20;
    int modDes = sheet?.attributes['DES'] ?? 0;
    int modRef = sheet?.pericias['Reflexo'] ?? modDes;
    int modAcr = sheet?.pericias['Acrobacia'] ?? modDes;
    int modAtl = sheet?.pericias['Atletismo'] ?? sheet?.attributes['FOR'] ?? 0;
    String selectedSkill = 'Reflexo';
    int mod = modRef;
    double percentBonus = 0;
    String attackerName = "Atacante Desconhecido";
    int incomingDamage = 0;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: Colors.grey[900],
          title: const Row(children: [Icon(Icons.directions_run, color: Colors.greenAccent), SizedBox(width: 8), Text("Ação de Esquiva", style: TextStyle(color: Colors.white))]),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("DADOS DO ATAQUE", style: TextStyle(color: Colors.orangeAccent, fontWeight: FontWeight.bold)),
                Row(
                  children: [
                    Expanded(child: TextFormField(initialValue: attackerName, decoration: const InputDecoration(labelText: "Nome do Atacante", labelStyle: TextStyle(color: Colors.white54)), style: const TextStyle(color: Colors.white), onChanged: (v) => attackerName = v.isEmpty ? "Atacante" : v)),
                    const SizedBox(width: 8),
                    Expanded(child: TextField(keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: "Dano Recebido", labelStyle: TextStyle(color: Colors.white54)), style: const TextStyle(color: Colors.white), onChanged: (v) => incomingDamage = int.tryParse(v) ?? 0)),
                  ],
                ),
                const Divider(color: Colors.white24, height: 20),
                const Text("SUA ESQUIVA", style: TextStyle(color: Colors.greenAccent, fontWeight: FontWeight.bold)),
                DropdownButton<String>(
                  dropdownColor: Colors.black, value: selectedSkill, isExpanded: true, style: const TextStyle(color: Colors.amber),
                  items: ['Reflexo', 'Acrobacia', 'Atletismo', 'Destreza'].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                  onChanged: (v) {
                    setDialogState(() {
                      selectedSkill = v!;
                      if (v == 'Destreza') mod = modDes;
                      if (v == 'Reflexo') mod = modRef;
                      if (v == 'Acrobacia') mod = modAcr;
                      if (v == 'Atletismo') mod = modAtl;
                    });
                  }
                ),
                Row(
                  children: [
                    Expanded(child: TextFormField(initialValue: diceQtd.toString(), keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: "Qtd"), style: const TextStyle(color: Colors.white), onChanged: (v) => diceQtd = int.tryParse(v) ?? 1)),
                    const Padding(padding: EdgeInsets.symmetric(horizontal: 4), child: Text("D", style: TextStyle(color: Colors.white))),
                    Expanded(child: TextFormField(initialValue: diceSides.toString(), keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: "Faces"), style: const TextStyle(color: Colors.white), onChanged: (v) => diceSides = int.tryParse(v) ?? 20)),
                    const Padding(padding: EdgeInsets.symmetric(horizontal: 4), child: Text("+", style: TextStyle(color: Colors.white))),
                    Expanded(child: TextFormField(key: ValueKey(mod), initialValue: mod.toString(), keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: "Mod"), style: const TextStyle(color: Colors.white), onChanged: (v) => mod = int.tryParse(v) ?? 0)),
                  ],
                ),
                const SizedBox(height: 10),
                TextField(keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: "Bônus de Esquiva (%)", hintText: "Ex: 20 para +20%", labelStyle: TextStyle(color: Colors.white54)), style: const TextStyle(color: Colors.white), onChanged: (v) => percentBonus = double.tryParse(v) ?? 0),
                const SizedBox(height: 20),
                SizedBox(width: double.infinity, child: ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: Colors.greenAccent[700]), onPressed: () { Navigator.pop(ctx); _resolveDodge(myToken, attackerName, incomingDamage, selectedSkill, diceQtd, diceSides, mod, percentBonus); }, child: const Text("💨 EXECUTAR ESQUIVA 💨", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))))
              ],
            ),
          ),
        )
      )
    );
  }

  void _resolveDodge(MapToken defender, String attackerName, int incomingDmg, String skillName, int diceQtd, int diceSides, int mod, double percentBonus) {
    final random = Random();
    int rollSum = 0; List<int> rolls = [];
    for(int i=0; i<diceQtd; i++) { int r = _rollDie(diceSides); rolls.add(r); rollSum+=r; }
    double dodgeBase = (rollSum + mod).toDouble();
    double dodgeFinal = dodgeBase * (1.0 + (percentBonus / 100.0));
    int dodgeResult = dodgeFinal.toInt();
    int damageTaken = max(0, incomingDmg - dodgeResult);
    String logDetails = "ESQUIVA ($skillName):\n${diceQtd}d$diceSides [${rolls.join(',')}] + $mod = $dodgeBase\n";
    if (percentBonus > 0) logDetails += "Eficiência Extra da Esquiva: +${percentBonus.toInt()}%\n";
    logDetails += "Esquiva Total: $dodgeResult\n\nDano do Ataque ($attackerName): $incomingDmg\n🩸 DANO RECEBIDO: $damageTaken";
    _broadcastLog(defender.name, "Tentou esquivar de um ataque de $attackerName!", type: 'alert', details: logDetails);
    if (damageTaken > 0) { _resolveDamage(defender, 0); } else { _showToast("Esquiva Perfeita! Saiu ileso."); }
  }

  // --- LÓGICA DE ALVOS ---
  void _onTokenTap(MapToken token) {
    _loadGodMode();
    if (_isTargetMode) {
       if (_pendingAbility?.targetType == 'Área') { _resolveAreaEffect(token.x, token.y); return; }
       if (_myToken != null && token.id == _myToken!.id && _pendingAbility?.targetType != 'Buff/Transformação') { _showToast("Não pode atacar a si mesmo!"); return; }
       _confirmAttack(token);
       if (_pendingAbility?.targetType != 'Múltiplos Alvos') setState(() => _isTargetMode = false);
    } else {
      setState(() {
        if (widget.isHost) _myToken = token;
        _focusedToken = token; 
        _isSheetOpen = true;
      });
    }
  }

  void _startTargetMode(String actionName, List<DieSpecification> damageDice, int modifier, Ability? ability, {double multiplier = 1.0}) {
    setState(() { 
      _isTargetMode = true; 
      _pendingActionName = actionName; 
      _pendingActionDice = damageDice; 
      _pendingActionModifier = modifier; 
      _pendingActionMultiplier = multiplier;
      _pendingAbility = ability; 
      _isSheetOpen = false; 
    });
    _showToast(ability != null && ability.targetType == 'Área' ? "Toque no CENTRO da área." : "Selecione o ALVO no mapa.");
  }

  void _resolveAreaEffect(double centerX, double centerY) {
     if (_pendingAbility == null) return;
     double radiusInBlocks = (_pendingAbility!.areaRadius) / 2.0; 
     List<MapToken> affectedTokens = [];
     for (var token in _scenario.tokens) {
       double dist = sqrt(pow(token.x - centerX, 2) + pow(token.y - centerY, 2));
       if (dist <= radiusInBlocks) affectedTokens.add(token);
     }
     if (affectedTokens.isEmpty) { _showToast("Nenhum alvo na área."); setState(() => _isTargetMode = false); return; }
     for (var target in affectedTokens) {
       _confirmAttack(target, isArea: true);
     }
     setState(() => _isTargetMode = false);
     _broadcastLog(_myToken?.name ?? "GM", "Usou ${_pendingAbility!.name} na área!", type: 'damage');
  }

  void _confirmAttack(MapToken target, {bool isArea = false}) {
    if (target.isObstacle || isArea) { _resolveDamage(target, 0); return; }
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.red[900],
        title: Text("⚠️ ATAQUE contra ${target.name}! ⚠️", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        content: const Text("Como você quer reagir a este ataque?", style: TextStyle(color: Colors.white, fontSize: 16)),
        actionsAlignment: MainAxisAlignment.center,
        actionsOverflowAlignment: OverflowBarAlignment.center,
        actions: [
             ElevatedButton.icon(
               style: ElevatedButton.styleFrom(backgroundColor: Colors.black54, minimumSize: const Size(double.infinity, 40)),
               icon: const Icon(Icons.shield, color: Colors.blueAccent),
               label: const Text("Bloquear Ataque", style: TextStyle(color: Colors.white)),
               onPressed: () { Navigator.pop(context); _showBlockSystemDialog(target); },
             ),
             ElevatedButton.icon(
               style: ElevatedButton.styleFrom(backgroundColor: Colors.black54, minimumSize: const Size(double.infinity, 40)),
               icon: const Icon(Icons.compare_arrows, color: Colors.amber),
               label: const Text("Parry Extremo", style: TextStyle(color: Colors.white)),
               onPressed: () { Navigator.pop(context); _showParrySystemDialog(target); },
             ),
             ElevatedButton.icon(
               style: ElevatedButton.styleFrom(backgroundColor: Colors.black54, minimumSize: const Size(double.infinity, 40)),
               icon: const Icon(Icons.flash_on, color: Colors.yellow),
               label: const Text("Clash Event", style: TextStyle(color: Colors.white)),
               onPressed: () { Navigator.pop(context); _showClashSystemDialog(target); },
             ),
             ElevatedButton.icon(
               style: ElevatedButton.styleFrom(backgroundColor: Colors.black54, minimumSize: const Size(double.infinity, 40)),
               icon: const Icon(Icons.directions_run, color: Colors.greenAccent),
               label: const Text("Esquivar Ataque", style: TextStyle(color: Colors.white)),
               onPressed: () { Navigator.pop(context); _showDodgeSystemDialog(target); },
             ),
          const SizedBox(height: 10),
          TextButton(
            style: TextButton.styleFrom(backgroundColor: Colors.black, minimumSize: const Size(double.infinity, 40)),
            onPressed: () { Navigator.pop(context); _resolveDamage(target, 0); }, 
            child: const Text("🩸 Receber Dano Total", style: TextStyle(color: Colors.white))
          ),
        ],
      ),
    );
  }

  void _resolveDamage(MapToken target, int mitigation) {
    int diceSum = 0;
    List<String> rollBreakdown = [];
    final random = Random();
    
    if (_pendingActionDice != null && _pendingActionDice!.isNotEmpty) {
       for (var d in _pendingActionDice!) {
         List<int> currentRolls = [];
         for(int i=0; i<d.quantity; i++) { int roll = _rollDie(d.sides); currentRolls.add(roll); diceSum += roll; }
         rollBreakdown.add("${d.quantity}d${d.sides}(${d.damageType ?? 'Físico'}): [${currentRolls.join(' + ')}]");
       }
    } else { rollBreakdown.add("Dano Fixo/Base"); }
    
    int rawDamage = ((diceSum + _pendingActionModifier) * _pendingActionMultiplier).toInt();
    int finalDamage = max(0, rawDamage - mitigation);

    setState(() {
      target.hpCurrent -= finalDamage;
      _syncTokenToSheet(target);
      if (target.isObstacle && target.hpCurrent <= 0) _broadcastLog("Sistema", "${target.name} destruído!", type: 'info');
    });

    String multText = _pendingActionMultiplier > 1.0 ? "\nMultiplicador: x${_pendingActionMultiplier.toInt()}" : "";
    _broadcastLog(_myToken?.name ?? "GM", "Atingiu ${target.name}", type: 'damage', details: "${rollBreakdown.join('\n')}\nModificador: +$_pendingActionModifier$multText\n🩸 DANO TOTAL: $finalDamage");
  }

  // --- MOTOR DE DADOS REAL ---
  List<DieSpecification> _getDiceFromPoints(int points) {
    if (points <= 0) return [DieSpecification(quantity: 1, sides: 20)];
    int d20Count = 1 + (points ~/ 10);
    int remainder = points % 10;
    int d10Count = remainder ~/ 5;
    final dice = <DieSpecification>[];
    if (d20Count > 0) dice.add(DieSpecification(quantity: d20Count, sides: 20));
    if (d10Count > 0) dice.add(DieSpecification(quantity: d10Count, sides: 10));
    return dice;
  }

  int _getModifierFromPoints(int points) { return points <= 0 ? 0 : (points % 10) % 5; }

  int _rollDie(int sides) {
    final random = Random();
    if (_isGodModeActive) {
      double r = random.nextDouble();
      switch (sides) {
        case 4: if (r < 0.55) return 4; return random.nextInt(3) + 1;
        case 6: if (r < 0.50) return 6; return random.nextInt(5) + 1;
        case 8: if (r < 0.30) return 8; return random.nextInt(7) + 1;
        case 10: if (r < 0.25) return 10; return random.nextInt(9) + 1;
        case 12: if (r < 0.20) return 12; if (r < 0.70) return random.nextInt(5) + 7; return random.nextInt(6) + 1;
        case 20: if (r < 0.25) return 20; if (r < 0.80) return random.nextInt(8) + 12; return random.nextInt(11) + 1;
        case 100: 
          if (r < 0.03) return 100;                              
          if (r < 0.45) return random.nextInt(15) + 85;          
          if (r < 0.755) return random.nextInt(20) + 65;         
          if (r < 0.855) return random.nextInt(15) + 50;         
          if (r < 0.995) return random.nextInt(44) + 6;          
          return random.nextInt(5) + 1;                          
        default: 
          int result; int attempts = 0; 
          do { result = random.nextInt(sides) + 1; attempts++; } while (result == 1 && attempts < 10); 
          return result;
      }
    }
    return random.nextInt(sides) + 1;
  }

  void _executeTabletopRoll(CharacterSheet sheet, String charName, String rollName, int basePoints) {
    final characterBonuses = _getCharacterBonuses(sheet, [rollName, 'Geral']);
    int finalPoints = basePoints + characterBonuses.bonusPoints;
    final dice = _getDiceFromPoints(finalPoints);
    final baseMod = _getModifierFromPoints(finalPoints);
    int finalMod = baseMod + characterBonuses.modifier;
    int totalRoll = 0; 
    List<String> rollDetails = []; 
    for (var d in dice) {
        int groupSum = 0; List<int> results = [];
        for(int i = 0; i < d.quantity; i++) { int r = _rollDie(d.sides); groupSum += r; results.add(r); }
        totalRoll += groupSum; 
        rollDetails.add("${d.quantity}d${d.sides}[${results.join(', ')}]");
    }
    int rawTotal = totalRoll + finalMod;
    int finalTotal = (rawTotal * characterBonuses.multiplier).toInt();
    List<String> bonusLines = [];
    if (characterBonuses.bonusPoints != 0) bonusLines.add("Pontos Bônus: ${characterBonuses.bonusPoints > 0 ? '+' : ''}${characterBonuses.bonusPoints}");
    if (characterBonuses.modifier != 0) bonusLines.add("Modificador: ${characterBonuses.modifier > 0 ? '+' : ''}${characterBonuses.modifier}");
    if (characterBonuses.multiplier != 1.0) { int pct = ((characterBonuses.multiplier - 1.0) * 100).toInt(); bonusLines.add("Multiplicador: ${pct > 0 ? '+' : ''}$pct%"); }
    String bonusText = bonusLines.isNotEmpty ? "\n${bonusLines.join(' | ')}" : "";
    _broadcastLog(charName, "Teste de $rollName", type: 'roll', details: "${rollDetails.join(' + ')}$bonusText\n\n🎯 TOTAL: $finalTotal");
    NetworkManager().sendRoll(charName, rollName, finalTotal);
  }

  void _rollGenericDice(int sides, {int quantity = 1, int modifier = 0}) {
    if (sides < 2 || quantity < 1) return;
    int total = 0; 
    List<int> results = []; 
    
    for (int i = 0; i < quantity; i++) { 
      // O ERRO ESTAVA AQUI! Antes estava random.nextInt...
      int r = _rollDie(sides); 
      results.add(r); 
      total += r; 
    }
    
    int finalTotal = total + modifier;
    String modText = modifier == 0 ? "" : (modifier > 0 ? " +$modifier" : " $modifier");
    String charName = _myToken?.name ?? (widget.isHost ? "Mestre" : "Jogador");
    
    _broadcastLog(charName, "Rolou ${quantity}d$sides$modText", type: 'roll', details: "Resultados: [${results.join(', ')}]$modText\nTOTAL = $finalTotal");
    NetworkManager().sendRoll(charName, "${quantity}d$sides$modText", finalTotal);
  }

  void _showDicePanel() {
    _loadGodMode();
    int customQuantity = 1; int customModifier = 0; int customSides = 20;
    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: Colors.grey[900],
          title: const Text("Painel de Dados", style: TextStyle(color: Colors.white)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // UX MELHORADA: Quantidade e Modificador primeiro!
                Row(
                  children: [
                    Expanded(child: TextField(keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: "Quantidade (Qtd)", labelStyle: TextStyle(color: Colors.white54)), style: const TextStyle(color: Colors.white), onChanged: (v) => customQuantity = int.tryParse(v) ?? 1)),
                    const SizedBox(width: 8),
                    Expanded(child: TextField(keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: "Modificador", labelStyle: TextStyle(color: Colors.white54)), style: const TextStyle(color: Colors.white), onChanged: (v) => customModifier = int.tryParse(v) ?? 0)),
                  ],
                ),
                const SizedBox(height: 16),
                const Text("Rolagem Rápida", style: TextStyle(color: Colors.white54)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8, runSpacing: 8,
                  children: [4, 6, 8, 10, 12, 20, 100].map((s) => ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.deepPurple[800]),
                    onPressed: () { 
                      Navigator.pop(ctx); 
                      // CORREÇÃO: Agora os botões rápidos respeitam a Qtd e o Mod!
                      _rollGenericDice(s, quantity: customQuantity, modifier: customModifier); 
                    },
                    child: Text("d$s", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  )).toList(),
                ),
                const Divider(color: Colors.white24, height: 30),
                const Text("Dado Personalizado:", style: TextStyle(color: Colors.white54)),
                const SizedBox(height: 10),
                Row(
                  children: [
                    const Text("D", style: TextStyle(color: Colors.purpleAccent, fontSize: 24, fontWeight: FontWeight.bold)),
                    const SizedBox(width: 8),
                    Expanded(child: TextField(keyboardType: TextInputType.number, decoration: const InputDecoration(hintText: "Faces (Ex: 14)", hintStyle: TextStyle(color: Colors.white30)), style: const TextStyle(color: Colors.white), onChanged: (v) => customSides = int.tryParse(v) ?? 20)),
                    const SizedBox(width: 16),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.purpleAccent), 
                      onPressed: () { 
                        Navigator.pop(ctx); 
                        _rollGenericDice(customSides, quantity: customQuantity, modifier: customModifier); 
                      }, 
                      child: const Text("Rolar", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))
                    )
                  ],
                )
              ],
            ),
          ),
          actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Fechar", style: TextStyle(color: Colors.grey)))],
        )
      )
    );
  }

  // --- UI DA GAVETA (SLIDE-OUT SHEET) ---
  Widget _buildSlideOutSheet() {
    if (_focusedToken == null) return const SizedBox();
    final sheet = _getSheetForToken(_focusedToken!);
    if (sheet == null && !_focusedToken!.isObstacle) return Container(color: Colors.black87, child: const Center(child: Text("Ficha não encontrada")));

    bool isOwner = _myToken != null && _focusedToken!.id == _myToken!.id;
    bool canView = widget.isHost || isOwner;

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: const BorderRadius.only(topLeft: Radius.circular(20), bottomLeft: Radius.circular(20)),
        border: Border(left: BorderSide(color: canView ? Colors.amber : Colors.red[900]!, width: 2)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.8), blurRadius: 20, offset: const Offset(-5, 0))]
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(color: Colors.black26, borderRadius: BorderRadius.only(topLeft: Radius.circular(20))),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 30, backgroundColor: Colors.grey[800],
                  backgroundImage: _focusedToken!.imagePath != null ? FileImage(File(_focusedToken!.imagePath!)) : null,
                  child: _focusedToken!.imagePath == null ? const Icon(Icons.person, size: 30, color: Colors.white) : null,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(_focusedToken!.name, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                      if (sheet != null && canView) Text(sheet.classe ?? 'Sem Classe', style: const TextStyle(color: Colors.amber, fontSize: 12)),
                    ],
                  ),
                ),
                IconButton(icon: const Icon(Icons.close, color: Colors.white54), onPressed: () => setState(() => _isSheetOpen = false))
              ],
            ),
          ),
          
          if (!canView && !_focusedToken!.isObstacle)
             Expanded(child: Center(child: Column(mainAxisSize: MainAxisSize.min, children: [Icon(Icons.visibility_off, color: Colors.red[900], size: 60), const SizedBox(height: 16), const Text("Acesso Restrito", style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)), const SizedBox(height: 8), const Text("Você não tem permissão para\nver os dados deste personagem.", textAlign: TextAlign.center, style: TextStyle(color: Colors.white54))])))
          else if (_focusedToken!.isObstacle) _buildObstaclePanel(_focusedToken!)
          else ...[
            Container(
              color: Colors.black12,
              child: TabBar(
                controller: _bottomTabController,
                isScrollable: true,
                tabAlignment: TabAlignment.start,
                labelColor: Colors.amber, unselectedLabelColor: Colors.grey, indicatorColor: Colors.amber,
                tabs: const [Tab(text: "Status"), Tab(text: "Atributos"), Tab(text: "Combate"), Tab(text: "Habilidades"), Tab(text: "Rituais"), Tab(text: "Mochila"), Tab(text: "Efeitos")],
              ),
            ),
            Expanded(
              child: TabBarView(
                controller: _bottomTabController,
                children: [
                  _buildTabStatus(_focusedToken!, sheet!),
                  _buildTabStats(sheet, _focusedToken!),
                  _buildTabCombat(sheet, _focusedToken!),
                  _buildTabAbilities(sheet, _focusedToken!),
                  _buildTabRituals(sheet, _focusedToken!),
                  _buildTabBackpack(sheet),
                  _buildTabEffects(_focusedToken!),
                ],
              ),
            ),
          ]
        ],
      ),
    );
  }

  Widget _buildObstaclePanel(MapToken token) {
    return Expanded(child: Padding(padding: const EdgeInsets.all(20), child: Column(children: [
      _buildEditableStatusBar("Integridade", token.hpCurrent, token.hpTotal, Colors.brown, (val) => _updateTokenStat(token, 'hp', val)), 
      if (widget.isHost) ...[
         Row(children: [
           const Text("Escala:", style: TextStyle(color: Colors.white54, fontSize: 10)),
           Expanded(child: Slider(value: token.size, min: 0.5, max: 10.0, divisions: 38, activeColor: Colors.amber, onChanged: (v) { setState(() => token.size = v); NetworkManager().sendMessage(jsonEncode({'type': 'RESIZE_TOKEN', 'id': token.id, 'size': v})); })),
           Text("${token.size.toStringAsFixed(1)}x", style: const TextStyle(color: Colors.amber, fontSize: 12)),
         ]),
         const SizedBox(height: 10),
         Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
           ElevatedButton.icon(
             style: ElevatedButton.styleFrom(backgroundColor: Colors.black45),
             icon: Icon(token.isHidden ? Icons.visibility_off : Icons.visibility, color: token.isHidden ? Colors.redAccent : Colors.white),
             label: Text(token.isHidden ? "Revelar" : "Esconder", style: const TextStyle(color: Colors.white)),
             onPressed: () { setState(() => token.isHidden = !token.isHidden); NetworkManager().sendMessage(jsonEncode({'type': 'TOGGLE_VISIBILITY', 'id': token.id, 'isHidden': token.isHidden})); }
           ),
           ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: Colors.red[900]), onPressed: () => setState(() { _scenario.tokens.remove(token); _isSheetOpen = false; }), child: const Text("Remover", style: TextStyle(color: Colors.white))),
         ])
      ]
    ])));
  }

  // --- ABA 1: STATUS (COMPLETO COM ESFORÇO TEMPORÁRIO) ---
  Widget _buildTabStatus(MapToken token, CharacterSheet sheet) {
    bool isOwner = _myToken != null && token.id == _myToken!.id;
    bool canHide = widget.isHost || isOwner;

    // Verifica se a ficha tem Esforço Temporário configurado
    bool hasEffTemp = token.effTempTotal > 0 || token.effTempCurrent > 0;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        if (canHide || widget.isHost)
          Container(
            margin: const EdgeInsets.only(bottom: 24),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: Colors.black45, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.white10)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(children: [Icon(Icons.settings, color: Colors.white54, size: 16), SizedBox(width: 8), Text("Controles de Mesa", style: TextStyle(color: Colors.white54, fontWeight: FontWeight.bold))]),
                const SizedBox(height: 12),
                if (canHide)
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(backgroundColor: token.isHidden ? Colors.red[900] : Colors.grey[800], padding: const EdgeInsets.symmetric(vertical: 12)),
                      icon: Icon(token.isHidden ? Icons.visibility_off : Icons.visibility, color: Colors.white),
                      label: Text(token.isHidden ? "Furtividade Ativa (Invisível)" : "Esconder Personagem", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      onPressed: () {
                        setState(() => token.isHidden = !token.isHidden);
                        NetworkManager().sendMessage(jsonEncode({'type': 'TOGGLE_VISIBILITY', 'id': token.id, 'isHidden': token.isHidden}));
                        _showToast(token.isHidden ? "Você está invisível para os outros jogadores!" : "Você está visível novamente.");
                      }
                    ),
                  ),
                if (widget.isHost) ...[
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      const Text("Tamanho:", style: TextStyle(color: Colors.amber, fontSize: 12)),
                      Expanded(child: Slider(value: token.size, min: 0.5, max: 10.0, divisions: 38, activeColor: Colors.amber, onChanged: (v) { setState(() => token.size = v); NetworkManager().sendMessage(jsonEncode({'type': 'RESIZE_TOKEN', 'id': token.id, 'size': v})); })),
                      Text("${token.size.toStringAsFixed(1)}x", style: const TextStyle(color: Colors.amber, fontSize: 12, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ]
              ],
            ),
          ),

        _buildEditableStatusBar("Vida", token.hpCurrent, token.hpTotal, Colors.red, (val) => _updateTokenStat(token, 'hp', val)),
        _buildEditableStatusBar("Sanidade", token.sanCurrent, token.sanTotal, Colors.blue, (val) => _updateTokenStat(token, 'san', val)),
        _buildEditableStatusBar("Esforço", token.effCurrent, token.effTotal, Color(sheet.effortColor).withOpacity(1.0), (val) => _updateTokenStat(token, 'eff', val), sheet: sheet),
        
        // ESFORÇO TEMPORÁRIO — Só exibe se existir
        if (hasEffTemp)
          _buildEditableStatusBar("Esforço Temp.", token.effTempCurrent, token.effTempTotal, Colors.orangeAccent, (val) => _updateTokenStat(token, 'effTemp', val)),
        
        _buildEditableStatusBar("Loucura", token.madCurrent, 100, Colors.deepPurpleAccent, (val) => _updateTokenStat(token, 'mad', val)),
        const SizedBox(height: 20),
        const Text("AÇÕES MANUAIS", style: TextStyle(color: Colors.white54, fontSize: 12, fontWeight: FontWeight.bold)),
        const Divider(color: Colors.white24),
        Wrap(
          spacing: 8, runSpacing: 8,
          children: [
              _buildManualActionCounter(token, 'MOV', Colors.green),
              _buildManualActionCounter(token, 'ATK', Colors.redAccent),
              _buildManualActionCounter(token, 'MAG', Colors.blueAccent),
              _buildManualActionCounter(token, 'LIV', Colors.grey),
          ],
        ),
      ],
    );
  }

  void _updateTokenStat(MapToken token, String stat, int newVal) {
    setState(() {
      if (stat == 'hp') token.hpCurrent = newVal.clamp(0, 9999);
      if (stat == 'san') token.sanCurrent = newVal.clamp(0, 9999);
      if (stat == 'eff') token.effCurrent = newVal.clamp(0, 9999);
      if (stat == 'effTemp') token.effTempCurrent = newVal.clamp(0, 9999);
      if (stat == 'mad') token.madCurrent = newVal.clamp(0, 100);
      _syncTokenToSheet(token);
    });
  }

  void _showEditStatDialog(String label, int current, int total, Function(int) onChanged) {
    final ctrl = TextEditingController(text: current.toString());
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: Text("Editar $label", style: const TextStyle(color: Colors.white)),
        content: TextField(
          controller: ctrl,
          keyboardType: TextInputType.number,
          style: const TextStyle(color: Colors.amber, fontSize: 32, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
          autofocus: true,
          decoration: InputDecoration(
            filled: true, fillColor: Colors.black26,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            helperText: "Máximo: $total", helperStyle: const TextStyle(color: Colors.white54)
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancelar", style: TextStyle(color: Colors.grey))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            onPressed: () { int? val = int.tryParse(ctrl.text); if (val != null) onChanged(val); Navigator.pop(ctx); },
            child: const Text("Confirmar", style: TextStyle(color: Colors.white))
          )
        ]
      )
    );
  }

  Widget _buildEditableStatusBar(String label, int current, int total, Color baseColor, Function(int) onChanged, {CharacterSheet? sheet}) {
    Color barColor = baseColor;
    if (label == "Esforço" && sheet != null) barColor = Color(sheet.effortColor);
    bool isLowHp = label == "Vida" && (current / (total > 0 ? total : 1)) < 0.25 && current > 0;
    double percent = total > 0 ? (current / total).clamp(0.0, 1.0) : 0.0;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GestureDetector(
        onTap: () => _showEditStatDialog(label, current, total, onChanged),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text(label, style: TextStyle(color: barColor, fontWeight: FontWeight.bold)),
              Text("$current / $total", style: const TextStyle(color: Colors.white, fontSize: 14)),
            ]),
            const SizedBox(height: 6),
            Stack(
              children: [
                ClipRRect(borderRadius: BorderRadius.circular(4), child: LinearProgressIndicator(value: percent, backgroundColor: Colors.black45, color: isLowHp ? Colors.redAccent : barColor, minHeight: 12)),
                if (isLowHp) Positioned.fill(child: Container(decoration: BoxDecoration(borderRadius: BorderRadius.circular(4), border: Border.all(color: Colors.white.withOpacity(0.5), width: 1)))),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildManualActionCounter(MapToken token, String type, Color color) {
    int val = token.currentActions[type] ?? 0;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      decoration: BoxDecoration(color: color.withOpacity(0.15), borderRadius: BorderRadius.circular(12), border: Border.all(color: color.withOpacity(0.4))),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
           IconButton(icon: Icon(Icons.remove, size: 18, color: color), padding: EdgeInsets.zero, constraints: const BoxConstraints(), onPressed: () { setState(() => token.currentActions[type] = max(0, val - 1)); }),
           Padding(padding: const EdgeInsets.symmetric(horizontal: 12), child: Text("$type: $val", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14))),
           IconButton(icon: Icon(Icons.add, size: 18, color: color), padding: EdgeInsets.zero, constraints: const BoxConstraints(), onPressed: () { setState(() => token.currentActions[type] = val + 1); }),
        ]
      )
    );
  }

  // --- ABA 2: ATRIBUTOS ---
  Color _getAttributeColor(String attr) {
    switch (attr.toUpperCase()) {
      case 'FOR': return Colors.redAccent;
      case 'DES': return Colors.greenAccent;
      case 'CON': return Colors.orangeAccent;
      case 'INT': return Colors.blueAccent;
      case 'SAB': return Colors.purpleAccent;
      case 'CAR': return Colors.pinkAccent;
      default: return Colors.amber;
    }
  }

  Widget _buildTabStats(CharacterSheet sheet, MapToken token) {
    int maxPericia = 0;
    for (var v in sheet.pericias.values) { if ((v ?? 0) > maxPericia) maxPericia = (v ?? 0); }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text("ATRIBUTOS BASE", style: TextStyle(color: Colors.white54, fontSize: 12, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 12, runSpacing: 12,
          children: sheet.attributes.entries.map((e) {
             int bonus = _getCharacterBonuses(sheet, [e.key]).bonusPoints;
             return _buildNeonButton(e.key, (e.value ?? 0) + bonus, _getAttributeColor(e.key), () => _executeTabletopRoll(sheet, token.name, e.key, e.value ?? 0));
          }).toList(),
        ),
        const SizedBox(height: 24),
        const Text("PERÍCIAS", style: TextStyle(color: Colors.white54, fontSize: 12, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8, runSpacing: 8,
          children: sheet.pericias.entries.map((e) {
            int val = e.value ?? 0;
            int bonus = _getCharacterBonuses(sheet, [e.key]).bonusPoints;
            Color glowColor = (val == maxPericia && val > 0) ? Colors.white : Colors.grey;
            return _buildNeonButton(e.key, val + bonus, glowColor, () => _executeTabletopRoll(sheet, token.name, e.key, val));
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildNeonButton(String label, int value, Color glowColor, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.black54,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: glowColor.withOpacity(0.5)),
          boxShadow: [BoxShadow(color: glowColor.withOpacity(0.2), blurRadius: 8, spreadRadius: 1)]
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(label, style: const TextStyle(color: Colors.white70, fontSize: 12)),
            const SizedBox(width: 8),
            Text(value.toString(), style: TextStyle(color: glowColor, fontSize: 16, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  // --- ABA 3: COMBATE ---
  Widget _buildTabCombat(CharacterSheet sheet, MapToken token) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            ElevatedButton.icon(icon: const Icon(Icons.shield, color: Colors.blueAccent), label: const Text("Bloqueio"), onPressed: () => _showBlockSystemDialog(token)),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.amber[900]),
              icon: const Icon(Icons.compare_arrows, color: Colors.white), 
              label: const Text("Parry", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)), 
              onPressed: () => _showParrySystemDialog(token)
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
             Expanded(child: ElevatedButton.icon(
               style: ElevatedButton.styleFrom(backgroundColor: Colors.indigo[900], padding: const EdgeInsets.symmetric(vertical: 12)), 
               icon: const Icon(Icons.group, color: Colors.white), 
               label: const Text("Ataque Conjunto", style: TextStyle(color: Colors.white, fontSize: 13)), 
               onPressed: () => _showJointActionSetupDialog(token, true)
             )),
             const SizedBox(width: 8),
             Expanded(child: ElevatedButton.icon(
               style: ElevatedButton.styleFrom(backgroundColor: Colors.teal[900], padding: const EdgeInsets.symmetric(vertical: 12)), 
               icon: const Icon(Icons.security, color: Colors.white), 
               label: const Text("Defesa Conjunta", style: TextStyle(color: Colors.white, fontSize: 13)), 
               onPressed: () => _showJointActionSetupDialog(token, false)
             ))
          ]
        ),
        const SizedBox(height: 16),
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: Colors.red[900], padding: const EdgeInsets.symmetric(vertical: 12)),
          onPressed: () => _showClashSystemDialog(token),
          child: const Row(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.flash_on, color: Colors.yellow), SizedBox(width: 8), Text("⚡ INICIAR CLASH ⚡", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16))]),
        ),
        const SizedBox(height: 20),
        const Text("ARMAS", style: TextStyle(color: Colors.white54, fontSize: 12, fontWeight: FontWeight.bold)),
        ...sheet.weapons.map((w) => Card(
          color: Colors.black45,
          child: ListTile(
            leading: const Icon(Icons.colorize, color: Colors.redAccent),
            title: Text(w.name, style: const TextStyle(color: Colors.white)),
            trailing: IconButton(icon: const Icon(Icons.archive, color: Colors.grey), onPressed: () => _unequipWeapon(sheet, w)),
            onTap: () => _showWeaponActionDialog(sheet, w),
          ),
        )),
      ],
    );
  }

  // --- ABA 4: HABILIDADES E PASSIVAS (COM STACKS) ---
  Widget _buildTabAbilities(CharacterSheet sheet, MapToken token) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text("PASSIVAS", style: TextStyle(color: Colors.white54, fontSize: 12, fontWeight: FontWeight.bold)),
        if (sheet.passives.isEmpty) const Text("Nenhuma passiva.", style: TextStyle(color: Colors.grey)),
        ...sheet.passives.map((p) {
          // Indicadores visuais de estado
          Color statusColor = p.isActive ? Colors.greenAccent : Colors.grey;
          String stacksText = '';
          if (p.triggerFrequency == 'Acumulável' && p.stacks > 0) {
            stacksText = ' ×${p.stacks}';
            statusColor = Colors.amber;
          } else if (p.triggerType == 'Sempre Ativo') {
            statusColor = Colors.cyanAccent;
          }

          return Card(
            color: Colors.black45,
            shape: RoundedRectangleBorder(
              side: BorderSide(color: statusColor.withOpacity(0.4), width: 1),
              borderRadius: BorderRadius.circular(8)
            ),
            child: ListTile(
              leading: Icon(Icons.psychology, color: statusColor),
              title: Text("${p.name}$stacksText", style: TextStyle(color: p.isActive ? Colors.white : Colors.white60)),
              subtitle: Text(p.description, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.white54)),
              trailing: p.triggerFrequency == 'Acumulável' && p.stacks > 0
                ? Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(color: Colors.amber.withOpacity(0.2), borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.amber)),
                    child: Text(p.stacks.toString(), style: const TextStyle(color: Colors.amber, fontWeight: FontWeight.bold)),
                  )
                : null,
              onTap: () => _showPassiveActionDialog(sheet, token, p),
            ),
          );
        }),
        const SizedBox(height: 16),
        const Text("HABILIDADES ATIVAS", style: TextStyle(color: Colors.white54, fontSize: 12, fontWeight: FontWeight.bold)),
        if (sheet.abilities.isEmpty) const Text("Nenhuma habilidade.", style: TextStyle(color: Colors.grey)),
        ...sheet.abilities.map((a) => _buildMagicCard(a, token, Colors.cyan, sheet)),
      ],
    );
  }

  // --- ABA 5: RITUAIS ---
  Widget _buildTabRituals(CharacterSheet sheet, MapToken token) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        if (sheet.rituals.isEmpty) const Text("Nenhum ritual aprendido.", style: TextStyle(color: Colors.grey)),
        ...sheet.rituals.map((r) => _buildMagicCard(r, token, Colors.purpleAccent, sheet)),
      ],
    );
  }

  Widget _buildMagicCard(Ability a, MapToken token, Color color, CharacterSheet sheet) {
    return Card(
      color: Colors.black45,
      shape: RoundedRectangleBorder(side: BorderSide(color: a.isActive ? color : color.withOpacity(0.3), width: a.isActive ? 1.5 : 0.5), borderRadius: BorderRadius.circular(8)),
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(Icons.auto_awesome, color: a.isActive ? color : color.withOpacity(0.5)),
        title: Text(a.name, style: TextStyle(color: a.isActive ? Colors.white : Colors.white70, fontWeight: FontWeight.bold)),
        subtitle: Text("Custo: ${a.costAmount} ${a.costType}", style: const TextStyle(color: Colors.white70)),
        trailing: a.isActive ? Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(color: color.withOpacity(0.2), borderRadius: BorderRadius.circular(8), border: Border.all(color: color)),
          child: Text("ATIVO", style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold)),
        ) : null,
        onTap: () => _showAbilityActionDialog(sheet, token, a),
      ),
    );
  }

  // --- ABA 7: EFEITOS ---
  Widget _buildTabEffects(MapToken token) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: ElevatedButton.icon(icon: const Icon(Icons.add), label: const Text("Adicionar Novo Efeito"), onPressed: () => _showAddEffectDialog(token)),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: token.activeStatusEffects.length,
            itemBuilder: (context, index) {
              final effect = token.activeStatusEffects[index];
              return ListTile(
                leading: const Icon(Icons.auto_fix_high, color: Colors.amber),
                title: Text(effect.name, style: const TextStyle(color: Colors.white)),
                subtitle: Text("${effect.durationInRounds} rodadas restantes", style: const TextStyle(color: Colors.white54)),
                trailing: IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: () => setState(() => token.activeStatusEffects.removeAt(index))),
              );
            },
          ),
        ),
      ],
    );
  }

  void _showAddEffectDialog(MapToken token) {
    final nameCtrl = TextEditingController();
    final durCtrl = TextEditingController(text: "3");
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: const Text("Novo Efeito"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: "Nome (Ex: Queimando, Sangue)")),
            TextField(controller: durCtrl, decoration: const InputDecoration(labelText: "Duração (Rodadas)"), keyboardType: TextInputType.number),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancelar")),
          ElevatedButton(onPressed: () {
            setState(() { token.activeStatusEffects.add(StatusEffect(id: const Uuid().v4(), name: nameCtrl.text, durationInRounds: int.tryParse(durCtrl.text) ?? 1, targets: [], bonusType: '', value: 0)); });
            Navigator.pop(ctx);
          }, child: const Text("Aplicar")),
        ],
      ),
    );
  }

  // --- LOG E HISTÓRICO VISUAL ---
  Widget _buildBeautifulLog() {
    return Container(
      decoration: BoxDecoration(color: Colors.black.withOpacity(0.75), borderRadius: const BorderRadius.only(topRight: Radius.circular(16), bottomRight: Radius.circular(16)), border: const Border(right: BorderSide(color: Colors.white10), top: BorderSide(color: Colors.white10), bottom: BorderSide(color: Colors.white10))),
      child: Column(
        children: [
          Container(
             padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
             decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: Colors.white10))),
             child: const Row(children: [Icon(Icons.history, color: Colors.amber, size: 20), SizedBox(width: 8), Text("Histórico da Mesa", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))])
          ),
          Expanded(
             child: ListView.builder(
                padding: const EdgeInsets.only(top: 8, bottom: 20),
                reverse: true,
                itemCount: _historyLog.length,
                itemBuilder: (ctx, i) => _buildHistoryCard(_historyLog[i])
             )
          )
        ],
      ),
    );
  }

  Widget _buildHistoryCard(HistoryEntry entry) {
    Color stripeColor = Colors.grey;
    IconData icon = Icons.info_outline;
    if (entry.type == 'damage') { stripeColor = Colors.redAccent; icon = Icons.local_fire_department; }
    if (entry.type == 'roll') { stripeColor = Colors.blueAccent; icon = Icons.casino; }
    if (entry.type == 'info') { stripeColor = Colors.greenAccent; icon = Icons.directions_run; }
    if (entry.type == 'alert') { stripeColor = Colors.amber; icon = Icons.warning; }

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 10),
      decoration: BoxDecoration(color: Colors.black.withOpacity(0.6), borderRadius: BorderRadius.circular(8), border: Border(left: BorderSide(color: stripeColor, width: 4))),
      padding: const EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(children: [Icon(icon, color: stripeColor, size: 14), const SizedBox(width: 6), Text(entry.author, style: TextStyle(fontWeight: FontWeight.bold, color: stripeColor, fontSize: 13))]),
              Text(entry.time, style: const TextStyle(fontSize: 10, color: Colors.white54)),
            ],
          ),
          const SizedBox(height: 6),
          Text(entry.action, style: const TextStyle(fontSize: 13, color: Colors.white)),
          if (entry.resultDetails != null) ...[
            const SizedBox(height: 6),
            Container(
              width: double.infinity, padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: Colors.black45, borderRadius: BorderRadius.circular(4)),
              child: Text(entry.resultDetails!, style: const TextStyle(fontFamily: 'monospace', fontSize: 11, color: Colors.amberAccent)),
            )
          ]
        ],
      ),
    );
  }

  void _showMovementPrompt(MapToken token) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          backgroundColor: Colors.grey[900],
          title: const Text("Movimento Detectado", style: TextStyle(color: Colors.amber)),
          content: const Text("O personagem foi movido no mapa. Deseja consumir 1 Ação de Movimento (MOV)?\n\n(Ignore caso ele tenha sido arremessado ou usado uma ação gratuita).", style: TextStyle(color: Colors.white70)),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Não", style: TextStyle(color: Colors.grey))),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
              onPressed: () {
                setState(() { if ((token.currentActions['MOV'] ?? 0) > 0) token.currentActions['MOV'] = token.currentActions['MOV']! - 1; });
                _broadcastLog(token.name, "Gastou 1 Ação de Movimento.", type: 'info');
                Navigator.pop(ctx);
              }, 
              child: const Text("Sim, Gastar MOV", style: TextStyle(color: Colors.white))
            ),
          ]
        )
      );
  }

  void _showToast(String msg) { ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg), duration: const Duration(seconds: 2))); }

  void _showSheetSelectionDialog() {
    showDialog(
      context: context, 
      builder: (c) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: const Text("Adicionar Ficha", style: TextStyle(color: Colors.white)),
        content: SizedBox(
          width: double.maxFinite, height: 300,
          child: ListView.builder(
            itemCount: widget.availableSheets.length,
            itemBuilder: (ctx, i) {
              final s = widget.availableSheets[i];
              return ListTile(
                title: Text(s.name, style: const TextStyle(color: Colors.amber)), 
                subtitle: Text("Nível ${s.level ?? 1} • ${s.classe ?? ''}", style: const TextStyle(color: Colors.grey)),
                onTap: () { Navigator.pop(c); _prepareTokenPlacement(s); }
              );
            },
          ),
        ),
      )
    );
  }

  Future<void> _saveScenario() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('saved_scenario', jsonEncode(_scenario.toJson()));
    _showToast("Cenário salvo localmente!");
  }

  Future<void> _loadScenario() async {
    final prefs = await SharedPreferences.getInstance();
    final String? scenarioJson = prefs.getString('saved_scenario');
    if (scenarioJson != null) {
      setState(() { _scenario = TableScenario.fromJson(jsonDecode(scenarioJson)); });
      if (widget.isHost) NetworkManager().sendMessage(jsonEncode({'type': 'SYNC_SCENARIO', 'scenario': _scenario.toJson()}));
      _showToast("Cenário carregado com sucesso!");
    } else { _showToast("Nenhum cenário salvo encontrado."); }
  }

  void _showMapConfigDialog() {
    final rowsCtrl = TextEditingController(text: _scenario.gridRows.toString());
    final colsCtrl = TextEditingController(text: _scenario.gridCols.toString());
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: const Text("Configurar Mapa", style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Expanded(child: TextField(controller: colsCtrl, decoration: const InputDecoration(labelText: "Colunas (Largura)", labelStyle: TextStyle(color: Colors.amber)), keyboardType: TextInputType.number, style: const TextStyle(color: Colors.white))),
                const SizedBox(width: 16),
                Expanded(child: TextField(controller: rowsCtrl, decoration: const InputDecoration(labelText: "Linhas (Altura)", labelStyle: TextStyle(color: Colors.amber)), keyboardType: TextInputType.number, style: const TextStyle(color: Colors.white))),
              ],
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () async {
                final picker = ImagePicker();
                final pickedFile = await picker.pickImage(source: ImageSource.gallery);
                if (pickedFile != null) { setState(() => _scenario.backgroundPath = pickedFile.path); Navigator.pop(ctx); _showMapConfigDialog(); }
              }, 
              icon: const Icon(Icons.image), label: const Text("Escolher Imagem de Fundo")
            ),
            if (_scenario.backgroundPath != null)
               Padding(padding: const EdgeInsets.only(top: 8.0), child: TextButton(onPressed: () => setState(() => _scenario.backgroundPath = null), child: const Text("Remover Imagem", style: TextStyle(color: Colors.red)))),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancelar", style: TextStyle(color: Colors.grey))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            onPressed: () {
              setState(() { _scenario.gridCols = int.tryParse(colsCtrl.text) ?? 20; _scenario.gridRows = int.tryParse(rowsCtrl.text) ?? 20; });
              if (widget.isHost) NetworkManager().sendMessage(jsonEncode({'type': 'SYNC_SCENARIO', 'scenario': _scenario.toJson()}));
              Navigator.pop(ctx);
              _showToast("Mapa atualizado!");
            }, 
            child: const Text("Salvar")
          )
        ],
      )
    );
  }

  Future<void> _saveScenarioAs() async {
    final ctrl = TextEditingController();
    showDialog(context: context, builder: (c) => AlertDialog(
      backgroundColor: Colors.grey[900], title: const Text("Salvar Preset", style: TextStyle(color: Colors.white)),
      content: TextField(controller: ctrl, style: const TextStyle(color: Colors.amber), decoration: const InputDecoration(hintText: "Ex: Caverna do Dragão")),
      actions: [
        TextButton(onPressed: () => Navigator.pop(c), child: const Text("Cancelar")),
        ElevatedButton(onPressed: () async {
          if (ctrl.text.isEmpty) return;
          final prefs = await SharedPreferences.getInstance();
          List<String> savedNames = prefs.getStringList('scenario_names') ?? [];
          if (!savedNames.contains(ctrl.text)) savedNames.add(ctrl.text);
          await prefs.setStringList('scenario_names', savedNames);
          _scenario.name = ctrl.text;
          await prefs.setString('scenario_${ctrl.text}', jsonEncode(_scenario.toJson()));
          Navigator.pop(c); _showToast("Mapa '${ctrl.text}' salvo!");
        }, child: const Text("Salvar"))
      ]
    ));
  }

  Future<void> _loadScenarioList() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> savedNames = prefs.getStringList('scenario_names') ?? [];
    if (savedNames.isEmpty) { _showToast("Nenhum mapa salvo."); return; }
    showDialog(context: context, builder: (c) => AlertDialog(
      backgroundColor: Colors.grey[900], title: const Text("Carregar Mapa", style: TextStyle(color: Colors.white)),
      content: SizedBox(width: double.maxFinite, child: ListView.builder(
        shrinkWrap: true, itemCount: savedNames.length,
        itemBuilder: (ctx, i) => ListTile(
          title: Text(savedNames[i], style: const TextStyle(color: Colors.amber)),
          trailing: IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: () async {
            savedNames.removeAt(i); await prefs.setStringList('scenario_names', savedNames); await prefs.remove('scenario_${savedNames[i]}');
            Navigator.pop(c); _loadScenarioList(); 
          }),
          onTap: () async {
            final jsonStr = prefs.getString('scenario_${savedNames[i]}');
            if (jsonStr != null) {
              setState(() => _scenario = TableScenario.fromJson(jsonDecode(jsonStr)));
              if (widget.isHost) NetworkManager().sendMessage(jsonEncode({'type': 'SYNC_SCENARIO', 'scenario': _scenario.toJson()}));
              _showToast("Mapa carregado!");
            }
            Navigator.pop(c);
          }
        )
      ))
    ));
  }

  void _showAddObstacleDialog() {
    final nameCtrl = TextEditingController(text: "Obstáculo");
    final hpCtrl = TextEditingController(text: "50");
    _pendingObstacleImage = null; 
    showDialog(context: context, builder: (ctx) => StatefulBuilder(
      builder: (context, setDialogState) => AlertDialog(
        backgroundColor: Colors.grey[900], title: const Text("Criar Obstáculo/NPC Extra", style: TextStyle(color: Colors.white)),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: "Nome", labelStyle: TextStyle(color: Colors.amber)), style: const TextStyle(color: Colors.white)),
          TextField(controller: hpCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: "Vida", labelStyle: TextStyle(color: Colors.amber)), style: const TextStyle(color: Colors.white)),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            icon: const Icon(Icons.add_photo_alternate), label: Text(_pendingObstacleImage == null ? "Escolher Imagem" : "Imagem Selecionada"),
            onPressed: () async {
              final picker = ImagePicker();
              final file = await picker.pickImage(source: ImageSource.gallery);
              if (file != null) setDialogState(() => _pendingObstacleImage = file.path);
            }
          )
        ]),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancelar", style: TextStyle(color: Colors.grey))),
          ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: Colors.green), onPressed: () {
            Navigator.pop(ctx);
            setState(() { _isPlacingMode = true; _pendingObstacleToPlace = {'name': nameCtrl.text, 'hp': int.tryParse(hpCtrl.text) ?? 50, 'img': _pendingObstacleImage}; _pendingSheetToPlace = null; });
            _showToast("Toque no mapa.");
          }, child: const Text("Posicionar", style: TextStyle(color: Colors.white))),
        ],
      )
    ));
  }

  // ==========================================
  // SISTEMA DE BLOQUEIO AVANÇADO (ATUALIZADO)
  // ==========================================
  void _showBlockSystemDialog(MapToken myToken) {
    final sheet = _getSheetForToken(myToken);
    
    // Lê os percentuais de atributo da ficha (padrão: 100% CON, 0% FOR, 0% SAB)
    int conPerc = sheet?.blockConPercentage ?? 100;
    int forPerc = sheet?.blockForPercentage ?? 0;
    int sabPerc = sheet?.blockSabPercentage ?? 0;
    
    // Calcula o modificador base com base nos atributos e percentuais
    int conValue = sheet?.attributes['CON'] ?? 0;
    int forValue = sheet?.attributes['FOR'] ?? 0;
    int sabValue = sheet?.attributes['SAB'] ?? 0;
    int baseAttrMod = ((conValue * conPerc / 100) + (forValue * forPerc / 100) + (sabValue * sabPerc / 100)).toInt();

    int diceQtd = 1; 
    int diceSides = 20; 
    int mod = baseAttrMod; // Pré-preenchido com os atributos da ficha
    double percentBonus = 0;
    
    String attackerName = "Atacante Desconhecido";
    int incomingDamage = 0;
    String damageType = "Físico";

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: Colors.grey[900],
          title: const Row(children: [Icon(Icons.shield, color: Colors.blueAccent), SizedBox(width: 8), Text("Ação de Bloqueio", style: TextStyle(color: Colors.white))]),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Info dos atributos usados
                if (sheet != null)
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(color: Colors.blueAccent.withOpacity(0.1), borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.blueAccent.withOpacity(0.3))),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("BASE DA FICHA", style: TextStyle(color: Colors.blueAccent, fontSize: 11, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4),
                        if (conPerc > 0) Text("CON $conValue × $conPerc% = ${(conValue * conPerc / 100).toInt()}", style: const TextStyle(color: Colors.white70, fontSize: 11)),
                        if (forPerc > 0) Text("FOR $forValue × $forPerc% = ${(forValue * forPerc / 100).toInt()}", style: const TextStyle(color: Colors.white70, fontSize: 11)),
                        if (sabPerc > 0) Text("SAB $sabValue × $sabPerc% = ${(sabValue * sabPerc / 100).toInt()}", style: const TextStyle(color: Colors.white70, fontSize: 11)),
                        Text("Mod. Total: $baseAttrMod", style: const TextStyle(color: Colors.amber, fontWeight: FontWeight.bold, fontSize: 12)),
                      ],
                    ),
                  ),
                const SizedBox(height: 12),
                const Text("DADOS DO ATAQUE", style: TextStyle(color: Colors.orangeAccent, fontWeight: FontWeight.bold)),
                Row(
                  children: [
                    Expanded(child: TextFormField(initialValue: attackerName, decoration: const InputDecoration(labelText: "Nome do Atacante", labelStyle: TextStyle(color: Colors.white54)), style: const TextStyle(color: Colors.white), onChanged: (v) => attackerName = v.isEmpty ? "Atacante" : v)),
                    const SizedBox(width: 8),
                    Expanded(child: TextField(keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: "Dano Recebido", labelStyle: TextStyle(color: Colors.white54)), style: const TextStyle(color: Colors.white), onChanged: (v) => incomingDamage = int.tryParse(v) ?? 0)),
                  ],
                ),
                const SizedBox(height: 8),
                DropdownButton<String>(
                  dropdownColor: Colors.black, value: damageType, isExpanded: true, style: const TextStyle(color: Colors.amber),
                  items: ['Físico', 'Cortante', 'Impacto', 'Perfurante', 'Fogo', 'Gelo', 'Elétrico', 'Água', 'Sangue', 'Morte', 'Energia'].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                  onChanged: (v) => setDialogState(() => damageType = v!),
                ),
                const Divider(color: Colors.white24, height: 20),
                const Text("SEU BLOQUEIO (Defesa)", style: TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.bold)),
                Row(
                  children: [
                    Expanded(child: TextFormField(initialValue: diceQtd.toString(), keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: "Qtd"), style: const TextStyle(color: Colors.white), onChanged: (v) => diceQtd = int.tryParse(v) ?? 1)),
                    const Padding(padding: EdgeInsets.symmetric(horizontal: 4), child: Text("D", style: TextStyle(color: Colors.white))),
                    Expanded(child: TextFormField(initialValue: diceSides.toString(), keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: "Faces"), style: const TextStyle(color: Colors.white), onChanged: (v) => diceSides = int.tryParse(v) ?? 20)),
                    const Padding(padding: EdgeInsets.symmetric(horizontal: 4), child: Text("+", style: TextStyle(color: Colors.white))),
                    Expanded(child: TextFormField(key: ValueKey(mod), initialValue: mod.toString(), keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: "Mod (Attr)"), style: const TextStyle(color: Colors.white), onChanged: (v) => mod = int.tryParse(v) ?? 0)),
                  ],
                ),
                const SizedBox(height: 10),
                TextField(keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: "Bônus de Bloqueio (%)", hintText: "Ex: 20 para +20%", labelStyle: TextStyle(color: Colors.white54)), style: const TextStyle(color: Colors.white), onChanged: (v) => percentBonus = double.tryParse(v) ?? 0),
                const SizedBox(height: 20),
                SizedBox(width: double.infinity, child: ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: Colors.blueAccent, padding: const EdgeInsets.symmetric(vertical: 12)), onPressed: () { Navigator.pop(ctx); _resolveBlock(myToken, attackerName, incomingDamage, damageType, diceQtd, diceSides, mod, percentBonus); }, child: const Text("🛡️ EXECUTAR BLOQUEIO 🛡️", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))))
              ],
            ),
          ),
        )
      )
    );
  }

  void _resolveBlock(MapToken defender, String attackerName, int incomingDmg, String damageType, int diceQtd, int diceSides, int mod, double percentBonus) {
    int rollSum = 0; List<int> rolls = [];
    for(int i=0; i<diceQtd; i++) { int r = _rollDie(diceSides); rolls.add(r); rollSum+=r; }
    
    double blockBase = (rollSum + mod).toDouble();
    double blockFinal = blockBase * (1.0 + (percentBonus / 100.0));
    int blockResult = blockFinal.toInt();

    int damageTaken = max(0, incomingDmg - blockResult);

    String logDetails = "BLOQUEIO:\n${diceQtd}d$diceSides [${rolls.join(',')}] + $mod = $blockBase\n";
    if (percentBonus > 0) logDetails += "Eficiência Extra: +${percentBonus.toInt()}%\n";
    logDetails += "Tipo de Dano: $damageType\n";
    logDetails += "Bloqueio Total: $blockResult\n\nDano do Ataque ($attackerName): $incomingDmg\nDano Mitigado: ${min(incomingDmg, blockResult)}\n🩸 DANO VAZADO (RECEBIDO): $damageTaken";

    _broadcastLog(defender.name, "Bloqueou um ataque de $attackerName!", type: 'alert', details: logDetails);

    if (damageTaken > 0) {
       _resolveDamage(defender, 0);
    } else {
       _showToast("Bloqueio Perfeito! Nenhum dano recebido.");
    }
  }

  // ==========================================
  // SISTEMA DE PARRY (ATUALIZADO — LÊ DA FICHA)
  // ==========================================
  void _showParrySystemDialog(MapToken myToken) {
    final sheet = _getSheetForToken(myToken);

    // Mapeia o parryType da ficha para o formato do dialog
    String mapParryType(String sheetType) {
      switch (sheetType) {
        case 'Avançado': return 'Avançado (A)';
        case 'Super': return 'Super (S)';
        case 'God': return 'God (G)';
        default: return 'Comum (C)';
      }
    }

    // Pré-popula com os dados da ficha do personagem
    String myTier = mapParryType(sheet?.parryType ?? 'Comum');
    int myQtd = sheet?.parryDiceCount ?? 4;
    
    String oppTier = 'Ataque Normal';
    int oppQtd = 4; int oppSides = 20;
    String attackerName = "Atacante Desconhecido";
    int incomingDamage = 0;

    int getFaces(String t) {
      if (t == 'Comum (C)') return 4;
      if (t == 'Avançado (A)') return 8;
      if (t == 'Super (S)') return 12;
      if (t == 'God (G)') return 20;
      return 20;
    }

    int getMax(String t) {
      if (t == 'Comum (C)') return 6;
      if (t == 'Avançado (A)') return 8;
      if (t == 'Super (S)') return 12;
      if (t == 'God (G)') return 20;
      return 99;
    }

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) {
          int mySides = getFaces(myTier);
          int myMax = getMax(myTier);
          if (myQtd > myMax) myQtd = myMax;
          bool oppIsParry = oppTier != 'Ataque Normal';
          int oppMax = oppIsParry ? getMax(oppTier) : 99;
          if (oppIsParry) { oppSides = getFaces(oppTier); if (oppQtd > oppMax) oppQtd = oppMax; }

          return AlertDialog(
            backgroundColor: Colors.grey[900],
            title: const Row(children: [Icon(Icons.security, color: Colors.amber), SizedBox(width: 8), Text("Sistema de Parry", style: TextStyle(color: Colors.white))]),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Info da ficha
                  if (sheet != null)
                    Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(color: Colors.amber.withOpacity(0.1), borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.amber.withOpacity(0.3))),
                      child: Text("Tipo da Ficha: ${sheet.parryType} | Dados configurados: ${sheet.parryDiceCount}", style: const TextStyle(color: Colors.amber, fontSize: 11)),
                    ),
                  const Text("DADOS DO ATAQUE", style: TextStyle(color: Colors.orangeAccent, fontWeight: FontWeight.bold)),
                  Row(
                    children: [
                      Expanded(child: TextField(decoration: const InputDecoration(labelText: "Nome do Atacante", labelStyle: TextStyle(color: Colors.white54)), style: const TextStyle(color: Colors.white), onChanged: (v) => attackerName = v.isEmpty ? "Atacante" : v)),
                      const SizedBox(width: 8),
                      Expanded(child: TextField(keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: "Dano Recebido", labelStyle: TextStyle(color: Colors.white54)), style: const TextStyle(color: Colors.white), onChanged: (v) => incomingDamage = int.tryParse(v) ?? 0)),
                    ],
                  ),
                  const Divider(color: Colors.white24, height: 20),
                  const Text("SEU PARRY", style: TextStyle(color: Colors.greenAccent, fontWeight: FontWeight.bold)),
                  DropdownButton<String>(
                    dropdownColor: Colors.black, value: myTier, style: const TextStyle(color: Colors.amber), isExpanded: true,
                    items: ['Comum (C)', 'Avançado (A)', 'Super (S)', 'God (G)'].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                    onChanged: (v) => setDialogState(() { myTier = v!; myQtd = min(myQtd, getMax(myTier)); }),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      const Text("Dados:", style: TextStyle(color: Colors.white54)),
                      Expanded(
                        child: Slider(
                          value: myQtd.toDouble().clamp(1.0, myMax.toDouble()),
                          min: 1, max: myMax.toDouble(), divisions: (myMax - 1 > 0) ? myMax - 1 : 1,
                          activeColor: Colors.greenAccent,
                          onChanged: (v) => setDialogState(() => myQtd = v.toInt()),
                        )
                      ),
                      Text("${myQtd}d$mySides", style: const TextStyle(color: Colors.greenAccent, fontSize: 18, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const Divider(color: Colors.white24, height: 30),
                  const Text("OPONENTE (ATACANTE)", style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
                  DropdownButton<String>(
                    dropdownColor: Colors.black, value: oppTier, style: const TextStyle(color: Colors.amber), isExpanded: true,
                    items: ['Ataque Normal', 'Comum (C)', 'Avançado (A)', 'Super (S)', 'God (G)'].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                    onChanged: (v) => setDialogState(() => oppTier = v!),
                  ),
                  const SizedBox(height: 10),
                  if (oppIsParry)
                    Row(
                      children: [
                        const Text("Dados:", style: TextStyle(color: Colors.white54)),
                        Expanded(child: Slider(value: oppQtd.toDouble().clamp(1.0, oppMax.toDouble()), min: 1, max: oppMax.toDouble(), divisions: (oppMax - 1 > 0) ? oppMax - 1 : 1, activeColor: Colors.redAccent, onChanged: (v) => setDialogState(() => oppQtd = v.toInt()))),
                        Text("${oppQtd}d$oppSides", style: const TextStyle(color: Colors.redAccent, fontSize: 18, fontWeight: FontWeight.bold)),
                      ],
                    )
                  else
                    Row(
                      children: [
                        Expanded(child: TextField(keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: "Qtd Dados", labelStyle: TextStyle(color: Colors.white54)), style: const TextStyle(color: Colors.white), onChanged: (v) => oppQtd = int.tryParse(v) ?? 4)),
                        const Padding(padding: EdgeInsets.symmetric(horizontal: 8), child: Text("D", style: TextStyle(color: Colors.white))),
                        Expanded(child: TextField(keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: "Faces", labelStyle: TextStyle(color: Colors.white54)), style: const TextStyle(color: Colors.white), onChanged: (v) => oppSides = int.tryParse(v) ?? 20)),
                      ],
                    ),
                  const SizedBox(height: 20),
                  SizedBox(width: double.infinity, child: ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: Colors.amber[800], padding: const EdgeInsets.symmetric(vertical: 12)), onPressed: () { Navigator.pop(ctx); _resolveParryBattle(myToken.name, attackerName, incomingDamage, myTier, myQtd, mySides, oppTier, oppQtd, oppSides); }, child: const Text("⚔️ CHOCAR PARRY ⚔️", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16))))
                ],
              ),
            ),
          );
        }
      )
    );
  }

  void _resolveParryBattle(String defenderName, String attackerName, int incomingDmg, String myTier, int myQtd, int mySides, String oppTier, int oppQtd, int oppSides) {
    final random = Random();
    List<int> myRolls = []; int myCrits = 0;
    for(int i=0; i<myQtd; i++) { int r = _rollDie(mySides); myRolls.add(r); if(r == mySides) myCrits++; }
    List<int> oppRolls = []; int oppCrits = 0;
    for(int i=0; i<oppQtd; i++) { int r = _rollDie(oppSides); oppRolls.add(r); if(r == oppSides) oppCrits++; }

    double myCritScore = myCrits.toDouble(); double oppCritScore = oppCrits.toDouble();
    if (myTier == 'Super (S)') myCritScore *= 1.5; if (oppTier == 'Super (S)') oppCritScore *= 1.5;
    if (myTier == 'God (G)') myCritScore *= 2.0; if (oppTier == 'God (G)') oppCritScore *= 2.0;

    int reqCrits = 0;
    if (myTier == 'Avançado (A)' && oppTier != 'God (G)' && oppTier != 'Super (S)') reqCrits = 1;
    if (myTier == 'Super (S)' && oppTier != 'God (G)') reqCrits = 1;
    if (myTier == 'God (G)') reqCrits = 2;

    String resolutionText = "";
    if (oppCrits < reqCrits) {
      resolutionText = "🔥 VITÓRIA ESMAGADORA! O oponente não tirou os $reqCrits críticos obrigatórios!";
    } else {
      double effectiveOppScore = oppCritScore - reqCrits;
      if (myCritScore > effectiveOppScore) {
        resolutionText = "🏆 PARRY BEM SUCEDIDO! ($myCritScore contra $effectiveOppScore críticos).";
      } else if (myCritScore < effectiveOppScore) resolutionText = "💀 PARRY QUEBRADO! Atacante venceu a disputa.";
      else resolutionText = "⚔️ EMPATE! Ambos recebem 50% do dano.";
    }

    String consequence = "";
    if (resolutionText.contains("VITÓRIA") || resolutionText.contains("BEM SUCEDIDO")) {
       if (myTier == 'Comum (C)') consequence = "Efeito: Cancela o turno! $defenderName REFLETE ${(incomingDmg * 1.2).toInt()} de Dano em $attackerName!";
       if (myTier == 'Avançado (A)') consequence = "Efeito: $defenderName REFLETE ${(incomingDmg * 1.4).toInt()} de Dano em $attackerName!\nExposição: Próximos 2 ataques dão +20% no parry.";
       if (myTier == 'Super (S)') consequence = "Efeito: $defenderName REFLETE ${(incomingDmg * 1.6).toInt()} de Dano Maciço em $attackerName!";
       if (myTier == 'God (G)') consequence = "EFEITO GOD: $defenderName REFLETE ${(incomingDmg * 1.8).toInt()} de Dano Divino em $attackerName!\nBuff de +25% em tudo por 2 rounds.";
    } else if (resolutionText.contains("QUEBRADO")) {
       if (myTier == 'Comum (C)') consequence = "Penalidade: Falha Crítica! $defenderName RECEBE ${(incomingDmg * 1.2).toInt()} de Dano. Perde 1 dado de Parry por 2 rounds.";
       if (myTier == 'Avançado (A)') consequence = "Penalidade: Falha Crítica! $defenderName RECEBE ${(incomingDmg * 1.4).toInt()} de Dano. Perde o Parry por 2 rounds.";
       if (myTier == 'Super (S)') consequence = "Penalidade: Falha Crítica! $defenderName RECEBE ${(incomingDmg * 1.6).toInt()} de Dano.";
       if (myTier == 'God (G)') consequence = "Penalidade: Um Deus sangra. $defenderName RECEBE ${(incomingDmg * 1.8).toInt()} de Dano massivo.";
    } else {
       consequence = "Ambos ($defenderName e $attackerName) RECEBEM ${(incomingDmg * 0.5).toInt()} de Dano.";
    }

    String logDetails = "DEFENSOR ($defenderName - $myTier): ${myQtd}d$mySides [${myRolls.join(',')}] -> Críticos: $myCrits\nATACANTE ($attackerName - $oppTier): ${oppQtd}d$oppSides [${oppRolls.join(',')}] -> Críticos: $oppCrits\n\nDano Base: $incomingDmg\n\n$resolutionText\n\n$consequence";
    _broadcastLog(defenderName, "Tentou um PARRY contra $attackerName!", type: 'alert', details: logDetails);
  }

  // ==========================================
  // SISTEMA DE CLASH SUPREMO
  // ==========================================
  void _showClashSystemDialog(MapToken myToken) {
    bool isUltimate = false;
    List<Map<String, dynamic>> sideA = [{'dice': 1, 'sides': 20, 'mod': 0, 'element': 'Impacto'}];
    List<Map<String, dynamic>> sideB = [{'dice': 1, 'sides': 20, 'mod': 0, 'element': 'Impacto'}];
    final elementsList = ['Impacto', 'Perfurante', 'Cortante', 'Físico (Exclusivo)', 'Aura', 'Fogo', 'Água', 'Terra', 'Vento', 'Raio', 'Gelo', 'Natureza', 'Lodo', 'Morte', 'Sangue', 'Energia', 'Espaço', 'Gravidade', 'Conhecimento', 'Tempo'];

    Widget buildParticipantRow(List<Map<String, dynamic>> list, int index, StateSetter setDialogState) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 8.0),
        child: Row(
          children: [
            Expanded(flex: 1, child: TextField(keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: "Qtd", isDense: true), style: const TextStyle(color: Colors.white), onChanged: (v) => list[index]['dice'] = int.tryParse(v) ?? 1)),
            const Padding(padding: EdgeInsets.symmetric(horizontal: 2), child: Text("D", style: TextStyle(color: Colors.white))),
            Expanded(flex: 1, child: TextField(keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: "Faces", isDense: true), style: const TextStyle(color: Colors.white), onChanged: (v) => list[index]['sides'] = int.tryParse(v) ?? 20)),
            const Padding(padding: EdgeInsets.symmetric(horizontal: 2), child: Text("+", style: TextStyle(color: Colors.white))),
            Expanded(flex: 1, child: TextField(keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: "Mod", isDense: true), style: const TextStyle(color: Colors.white), onChanged: (v) => list[index]['mod'] = int.tryParse(v) ?? 0)),
            const SizedBox(width: 8),
            Expanded(flex: 2, child: DropdownButton<String>(dropdownColor: Colors.black, isExpanded: true, value: list[index]['element'], style: const TextStyle(color: Colors.amber, fontSize: 13), items: elementsList.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(), onChanged: (v) => setDialogState(() => list[index]['element'] = v!))),
            if (list.length > 1) IconButton(icon: const Icon(Icons.remove_circle, color: Colors.red, size: 20), onPressed: () => setDialogState(() => list.removeAt(index)))
          ],
        ),
      );
    }

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: Colors.grey[900],
          title: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
             const Row(children: [Icon(Icons.flash_on, color: Colors.yellow), SizedBox(width: 8), Text("CLASH EVENT", style: TextStyle(color: Colors.white, fontSize: 18))]),
             Row(children: [const Text("ULTIMATE", style: TextStyle(color: Colors.purpleAccent, fontSize: 10, fontWeight: FontWeight.bold)), Switch(value: isUltimate, activeThumbColor: Colors.purpleAccent, onChanged: (v) => setDialogState(() => isUltimate = v))])
          ]),
          content: SizedBox(
            width: double.maxFinite,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("LADO A (Aliados / Dano Ultimate)", style: TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  ...List.generate(sideA.length, (i) => buildParticipantRow(sideA, i, setDialogState)),
                  TextButton.icon(icon: const Icon(Icons.add, color: Colors.blueAccent), label: const Text("Adicionar Participante A", style: TextStyle(color: Colors.blueAccent)), onPressed: () => setDialogState(() => sideA.add({'dice': 1, 'sides': 20, 'mod': 0, 'element': 'Impacto'}))),
                  if (!isUltimate) ...[
                    const Divider(color: Colors.white24, height: 30),
                    const Text("LADO B (Inimigos)", style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    ...List.generate(sideB.length, (i) => buildParticipantRow(sideB, i, setDialogState)),
                    TextButton.icon(icon: const Icon(Icons.add, color: Colors.redAccent), label: const Text("Adicionar Participante B", style: TextStyle(color: Colors.redAccent)), onPressed: () => setDialogState(() => sideB.add({'dice': 1, 'sides': 20, 'mod': 0, 'element': 'Impacto'}))),
                  ],
                  const SizedBox(height: 20),
                  SizedBox(width: double.infinity, child: ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: isUltimate ? Colors.purple[900] : Colors.red[900]), onPressed: () { Navigator.pop(ctx); _resolveClash(myToken.name, isUltimate, sideA, sideB); }, child: Text(isUltimate ? "💥 DETONAR ULTIMATE 💥" : "⚔️ COLIDIR VERSUS!", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold))))
                ],
              ),
            ),
          ),
        )
      )
    );
  }

  Map<String, String> _getFusionDetails(List<String> elements) {
    var els = elements.where((e) => e != 'Impacto' && e != 'Perfurante' && e != 'Cortante' && e != 'Físico (Exclusivo)' && e != 'Aura').toSet().toList();
    els.sort(); String key = els.join('+');
    Map<String, Map<String, String>> fusions = {
      'Fogo+Água': {'name': 'Névoa Escaldante', 'desc': 'Vapor superaquecido que cozinha o inimigo dentro da armadura.'},
      'Raio+Terra': {'name': 'Canhão Railgun', 'desc': 'Magnetismo acelera rocha a velocidade supersônica.'},
      'Fogo+Terra': {'name': 'Magma Vivo', 'desc': 'Rocha derretida que gruda e causa dano contínuo extremo.'},
      'Gelo+Vento': {'name': 'Tempestade de Estilhaços', 'desc': 'Vento tritura gelo em pó de vidro invisível.'},
      'Raio+Água': {'name': 'Condução Fatal', 'desc': 'Eletrocuta tudo ao redor usando a água como fio condutor.'},
      'Terra+Vento': {'name': 'Tempestade de Areia', 'desc': 'Erosão acelerada. Lixa a armadura do inimigo.'},
      'Fogo+Gelo': {'name': 'Choque Térmico', 'desc': 'Mudança brusca de temperatura. Estilhaça defesas rígidas.'},
      'Lodo+Morte': {'name': 'Podridão Absoluta', 'desc': 'Biomassa morta que apodrece tudo que toca.'},
      'Natureza+Sangue': {'name': 'Gênesis Macabra', 'desc': 'Crescimento biológico extremo. Câncer celular acelerado.'},
      'Espaço+Terra': {'name': 'Meteoro', 'desc': 'Dobra o espaço para derrubar rochas com peso de toneladas.'},
      'Energia+Fogo+Raio': {'name': 'Plasma Real', 'desc': 'O quarto estado da matéria. Desintegração atômica.'},
      'Fogo+Terra+Vento': {'name': 'Piroclasto', 'desc': 'Nuvem de cinzas vulcânicas e rocha em pó superaquecida.'},
      'Energia+Fogo+Gravidade': {'name': 'Supernova', 'desc': 'Colapso de uma estrela artificial. Dano e pressão massivos.'},
      'Fogo+Lodo+Morte': {'name': 'Chama Negra', 'desc': 'Combustível podre que queima a alma e não apaga.'},
      'Energia+Fogo+Lodo': {'name': 'Radiação', 'desc': 'Isótopos instáveis. Derrete células e impede qualquer cura.'},
      'Energia+Gravidade+Morte': {'name': 'Entropia', 'desc': 'Acelera o decaimento. Envelhece e destrói qualquer matéria.'},
      'Espaço+Gelo+Vento': {'name': 'Zero Absoluto', 'desc': 'Para o movimento molecular. O frio mortal do vácuo espacial.'},
      'Energia+Espaço+Natureza': {'name': 'Éter', 'desc': 'Mana pura e bruta. A matéria-prima da magia condensada.'},
      'Gelo+Morte+Água': {'name': 'Abismo', 'desc': 'Oceano escuro, frio e sem fim. Afogamento espiritual.'},
      'Raio+Sangue+Vento': {'name': 'Tempestade Rubra', 'desc': 'Chuva de sangue eletrificado e fatiante.'},
      'Raio+Tempo+Água': {'name': 'Estase Condutiva', 'desc': 'Paralisa o alvo em um loop temporal enquanto o frita.'},
    };
    if (els.isEmpty) {
      String phys = elements.where((e) => e == 'Impacto' || e == 'Perfurante' || e == 'Cortante' || e == 'Físico (Exclusivo)' || e == 'Aura').toSet().join(' + ');
      if (phys.contains('Aura')) return {'name': 'Ataque Mental (Aura)', 'desc': 'Aura Soberana. Dano puramente psicológico que transcende defesas materiais.'};
      if (phys.contains('Físico (Exclusivo)')) return {'name': 'Físico Absoluto', 'desc': 'Violência física no seu ápice, esmagando magia e matéria simultaneamente.'};
      return {'name': phys.isNotEmpty ? 'Ataque Físico ($phys)' : 'Golpe Bruto', 'desc': 'Dano material cinético e contundente.'};
    }
    if (els.length == 1) return {'name': els.first, 'desc': 'Ataque Elemental Puro de ${els.first}.'};
    if (fusions.containsKey(key)) return fusions[key]!;
    return {'name': 'Fusão Caótica: $key', 'desc': 'Os elementos colidem criando uma ressonância instável, selvagem e letal!'};
  }

  double _getElementalMultiplier(List<String> aElems, List<String> bElems) {
    double mult = 1.0;
    Map<String, List<String>> advantages = {
      'Físico (Exclusivo)': ['Impacto', 'Perfurante', 'Cortante', 'Aura', 'Fogo', 'Água', 'Terra', 'Vento', 'Raio', 'Gelo', 'Natureza', 'Lodo', 'Morte', 'Sangue', 'Energia', 'Espaço', 'Gravidade', 'Conhecimento', 'Tempo'],
      'Gravidade': ['Espaço', 'Vento', 'Terra'], 'Espaço': ['Fogo', 'Vento'], 'Sangue': ['Morte', 'Lodo'],
      'Morte': ['Natureza', 'Lodo'], 'Energia': ['Morte', 'Terra', 'Gravidade'], 'Fogo': ['Natureza', 'Gelo', 'Sangue'],
      'Água': ['Fogo', 'Terra'], 'Vento': ['Lodo', 'Fogo'], 'Raio': ['Água', 'Morte'], 'Lodo': ['Natureza', 'Fogo'],
      'Gelo': ['Natureza', 'Água', 'Sangue'], 'Natureza': ['Terra', 'Água'], 'Terra': ['Raio', 'Fogo', 'Sangue'],
      'Impacto': ['Terra', 'Gelo', 'Perfurante', 'Cortante'], 'Perfurante': ['Sangue', 'Natureza'],
      'Cortante': ['Natureza', 'Sangue', 'Perfurante'], 'Tempo': ['Gravidade', 'Espaço', 'Fogo'],
    };
    Map<String, List<String>> disadvantages = {
      'Gravidade': ['Energia', 'Morte'], 'Espaço': ['Gravidade'], 'Sangue': ['Fogo', 'Gelo', 'Terra'],
      'Morte': ['Energia', 'Sangue'], 'Energia': ['Espaço'], 'Fogo': ['Água', 'Vento'],
      'Água': ['Raio', 'Natureza', 'Gelo'], 'Vento': ['Gelo', 'Terra'], 'Raio': ['Terra'],
      'Lodo': ['Vento', 'Água', 'Sangue'], 'Gelo': ['Fogo', 'Morte', 'Lodo'],
      'Natureza': ['Fogo', 'Morte', 'Lodo'], 'Terra': ['Água', 'Gravidade', 'Vento'],
      'Impacto': ['Água', 'Lodo'], 'Perfurante': ['Terra', 'Gelo', 'Impacto', 'Cortante'],
      'Cortante': ['Terra', 'Gelo', 'Impacto'],
    };
    for (var a in aElems) {
      for (var b in bElems) {
        if (advantages[a]?.contains(b) ?? false) mult += 0.3;
        if (disadvantages[a]?.contains(b) ?? false) mult -= 0.3;
      }
    }
    return mult;
  }

  void _resolveClash(String charName, bool isUltimate, List<Map<String, dynamic>> sideA, List<Map<String, dynamic>> sideB) {
    final random = Random();
    int aBaseTotal = 0; List<String> aElems = [];
    for(var p in sideA) { int rTotal = p['mod']; for(int i=0; i<p['dice']; i++) {
      rTotal += _rollDie(p['sides']);
    } aBaseTotal += rTotal; aElems.add(p['element']); }
    var aFusion = _getFusionDetails(aElems);
    if (isUltimate) {
       _broadcastLog("Mestre", "💥 CLASH ULTIMATE DECLARADO! 💥", type: 'alert', details: "TIPO DO DANO: ${aFusion['name']}\nEFEITO: ${aFusion['desc']}\n\nDano Total Acumulado: $aBaseTotal\n\nO Mestre vai desenhar as áreas de explosão no mapa!");
       if (widget.isHost) setState(() { _isClashZoneMode = true; _isDrawingMode = false; });
       return;
    }
    int bBaseTotal = 0; List<String> bElems = [];
    for(var p in sideB) { int rTotal = p['mod']; for(int i=0; i<p['dice']; i++) {
      rTotal += random.nextInt(p['sides'])+1;
    } bBaseTotal += rTotal; bElems.add(p['element']); }
    var bFusion = _getFusionDetails(bElems);
    double aMult = _getElementalMultiplier(aElems, bElems); double aFinal = aBaseTotal * aMult;
    double bMult = _getElementalMultiplier(bElems, aElems); double bFinal = bBaseTotal * bMult;
    int aPeople = sideA.length; int bPeople = sideB.length;
    String winnerText = "";
    if (aFinal > bFinal) { double ds = (bPeople >= 5 || aPeople >= 5) ? 0.40 : 0.35; if (bPeople == 1 && aPeople == 1) ds = 0.70; int dmg = bPeople == 1 && aPeople == 1 ? (aFinal * 0.70).toInt() : ((aFinal + bFinal) * ds).toInt(); winnerText = "🔥 LADO A VENCE! (TIPO: ${aFusion['name']})\nO Lado B recebe $dmg de Dano de Rebote!\nEFEITO VENCEDOR: ${aFusion['desc']}"; }
    else if (bFinal > aFinal) { double ds = (bPeople >= 5 || aPeople >= 5) ? 0.40 : 0.35; if (bPeople == 1 && aPeople == 1) ds = 0.70; int dmg = bPeople == 1 && aPeople == 1 ? (bFinal * 0.70).toInt() : ((aFinal + bFinal) * ds).toInt(); winnerText = "💀 LADO B VENCE! (TIPO: ${bFusion['name']})\nO Lado A recebe $dmg de Dano de Rebote!\nEFEITO VENCEDOR: ${bFusion['desc']}"; }
    else { int dmg = ((aFinal + bFinal) * 0.40).toInt(); winnerText = "⚖️ EMPATE ABSOLUTO!\nAmbos os lados recebem $dmg de Dano resultante da colisão instável!"; }
    String logDetails = "LADO A (${aFusion['name']}): Força Base $aBaseTotal (Mult ${aMult.toStringAsFixed(1)}x) -> Final: ${aFinal.toInt()}\nLADO B (${bFusion['name']}): Força Base $bBaseTotal (Mult ${bMult.toStringAsFixed(1)}x) -> Final: ${bFinal.toInt()}\n\n$winnerText";
    _broadcastLog("Sistema de Clash", "Resolução de Colisão Elemental!", type: 'alert', details: logDetails);
  }

  // ==========================================
  // SISTEMA DE AÇÃO CONJUNTA
  // ==========================================
  void _showJointActionSetupDialog(MapToken myToken, bool isAttack) {
     List<String> selectedAllyIds = [];
     MapToken? selectedTarget;
     String attackType = 'Comum'; 
     showDialog(
       context: context,
       builder: (ctx) => StatefulBuilder(
         builder: (context, setDialogState) {
            var availableTargets = _scenario.tokens.where((t) => t.id != myToken.id && !t.isObstacle).toList();
            var availableAllies = _scenario.tokens.where((t) => t.id != myToken.id && t.id != selectedTarget?.id && !t.isObstacle).toList();
            return AlertDialog(
               backgroundColor: Colors.grey[900],
               title: Row(children: [Icon(isAttack ? Icons.group : Icons.security, color: Colors.indigoAccent), const SizedBox(width: 8), Text(isAttack ? "Ataque em Conjunto" : "Defesa Conjunta", style: const TextStyle(color: Colors.white))]),
               content: SingleChildScrollView(
                 child: Column(
                   mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start,
                   children: [
                      if (isAttack) ...[
                         const Text("Tipo de Estratégia:", style: TextStyle(color: Colors.white54, fontWeight: FontWeight.bold)),
                         DropdownButton<String>(value: attackType, dropdownColor: Colors.black, isExpanded: true, items: ['Comum', 'Flanqueado'].map((e) => DropdownMenuItem(value: e, child: Text(e, style: const TextStyle(color: Colors.amber)))).toList(), onChanged: (v) => setDialogState(() => attackType = v!)),
                         const SizedBox(height: 10),
                         const Text("Selecione o Alvo do Ataque:", style: TextStyle(color: Colors.white54, fontWeight: FontWeight.bold)),
                         DropdownButton<MapToken>(value: selectedTarget, dropdownColor: Colors.black, isExpanded: true, hint: const Text("Escolher Alvo (Obrigatório)", style: TextStyle(color: Colors.white54)), items: availableTargets.map((t) => DropdownMenuItem(value: t, child: Text(t.name, style: const TextStyle(color: Colors.redAccent)))).toList(), onChanged: (v) => setDialogState(() { selectedTarget = v; selectedAllyIds.remove(v?.id); })),
                         const Divider(color: Colors.white24, height: 30),
                      ],
                      const Text("Convidar Aliados:", style: TextStyle(color: Colors.white54, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 10),
                      if (availableAllies.isEmpty) const Text("Nenhum outro personagem no mapa.", style: TextStyle(color: Colors.grey)),
                      ...availableAllies.map((t) => CheckboxListTile(title: Text(t.name, style: const TextStyle(color: Colors.white)), value: selectedAllyIds.contains(t.id), activeColor: Colors.indigoAccent, checkColor: Colors.white, onChanged: (v) { setDialogState(() { if (v == true) {
                        selectedAllyIds.add(t.id);
                      } else {
                        selectedAllyIds.remove(t.id);
                      } }); })),
                   ]
                 )
               ),
               actions: [
                  TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancelar", style: TextStyle(color: Colors.grey))),
                  ElevatedButton(
                     style: ElevatedButton.styleFrom(backgroundColor: Colors.indigoAccent),
                     onPressed: () {
                        if (isAttack && selectedTarget == null) { _showToast("Selecione um alvo primeiro!"); return; }
                        if (selectedAllyIds.isEmpty) { _showToast("Selecione pelo menos um aliado!"); return; }
                        Navigator.pop(ctx);
                        String actionId = const Uuid().v4();
                        setState(() { _hostedJointAction = {'id': actionId, 'initiator': myToken.name, 'isAttack': isAttack, 'attackType': attackType, 'targetToken': selectedTarget, 'rolls': [], 'totalHit': 0, 'totalDamage': 0}; });
                        NetworkManager().sendMessage(jsonEncode({'type': 'JOINT_INVITE', 'actionId': actionId, 'initiator': myToken.name, 'targetName': selectedTarget?.name ?? "Múltiplos", 'isAttack': isAttack, 'allies': selectedAllyIds}));
                        for (String allyId in selectedAllyIds) {
                           if (widget.isHost || _myToken?.id == allyId) {
                              String tokenName = _scenario.tokens.firstWhere((t) => t.id == allyId, orElse: () => MapToken(id:'null', sheetId:'', name:'Desconhecido')).name;
                              _showJointInviteDialog(myToken.name, selectedTarget?.name ?? "Múltiplos", actionId, isAttack, tokenName, allyId);
                           }
                        }
                        _showHostedJointActionPanel();
                     },
                     child: const Text("Iniciar e Convidar", style: TextStyle(color: Colors.white))
                  )
               ]
             );
         }
       )
     );
  }

  void _showJointInviteDialog(String initiator, String targetName, String actionId, bool isAttack, String myTokenName, String myTokenId) {
     showDialog(
       context: context, barrierDismissible: false,
       builder: (ctx) => AlertDialog(
          backgroundColor: Colors.grey[900],
          title: Row(children: [const Icon(Icons.mail, color: Colors.amber), const SizedBox(width: 8), Text("Convite para $myTokenName", style: const TextStyle(color: Colors.white))]),
          content: Text("$initiator chamou $myTokenName para um ${isAttack ? 'Ataque' : 'Defesa'} Conjunto${isAttack ? ' contra $targetName' : ''}!\n\nSe aceitar, as próximas DUAS rolagens na ficha de $myTokenName serão roubadas para contar como Acerto e Dano.", style: const TextStyle(color: Colors.white70)),
          actions: [
             TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Recusar", style: TextStyle(color: Colors.red))),
             ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                onPressed: () {
                   Navigator.pop(ctx);
                   setState(() { _pendingJointActions.add({'id': actionId, 'tokenName': myTokenName, 'hasRolledHit': false, 'hasRolledDamage': false, 'hit': 0, 'damage': 0}); });
                   _showToast("$myTokenName Aceitou! Clique no Atributo ou Arma na ficha DELE agora mesmo.");
                },
                child: const Text("Aceitar e Participar", style: TextStyle(color: Colors.white))
             )
          ]
       )
     );
  }

  void _showHostedJointActionPanel() {
     int myHit = 0; int myDamage = 0;
     showDialog(
       context: context, barrierDismissible: false,
       builder: (ctx) => StatefulBuilder(
         builder: (context, setDialogState) {
            Future.delayed(const Duration(seconds: 1), () { if(mounted) setDialogState((){}); }); 
            var state = _hostedJointAction!;
            return AlertDialog(
               backgroundColor: Colors.grey[900],
               title: Text(state['isAttack'] ? "Liderando Ataque Conjunto (${state['attackType']})" : "Liderando Defesa Conjunta", style: const TextStyle(color: Colors.white)),
               content: Column(
                 mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start,
                 children: [
                    const Text("Aguardando aliados rolarem na ficha deles...", style: TextStyle(color: Colors.amber)),
                    const SizedBox(height: 10),
                    ...((state['rolls'] as List).map((r) => Text("✓ ${r['who']}: Acerto ${r['hit']}, Dano ${r['damage']}", style: const TextStyle(color: Colors.greenAccent)))),
                    const Divider(color: Colors.white24, height: 30),
                    const Text("Sua Parte (Líder):", style: TextStyle(color: Colors.white54)),
                    const SizedBox(height: 10),
                    Row(children: [
                       Expanded(child: TextField(keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: "Seu Acerto", labelStyle: TextStyle(color: Colors.grey)), style: const TextStyle(color: Colors.white), onChanged: (v)=>myHit=int.tryParse(v)??0)),
                       const SizedBox(width: 8),
                       Expanded(child: TextField(keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: "Seu Dano/Def", labelStyle: TextStyle(color: Colors.grey)), style: const TextStyle(color: Colors.white), onChanged: (v)=>myDamage=int.tryParse(v)??0)),
                    ])
                 ]
               ),
               actions: [
                  TextButton(onPressed: () { setState(()=>_hostedJointAction=null); Navigator.pop(ctx); }, child: const Text("Cancelar Ação", style: TextStyle(color: Colors.red))),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.indigoAccent),
                    onPressed: () {
                       int baseHit = state['totalHit'] + myHit;
                       int finalHit = state['isAttack'] && state['attackType'] == 'Comum' ? (baseHit * 0.75).toInt() : baseHit;
                       int finalDamage = state['totalDamage'] + myDamage;
                       Navigator.pop(ctx);
                       String detailsText = state['isAttack'] ? "Estratégia: ${state['attackType']}\nAcerto Final: $finalHit ${state['attackType'] == 'Comum' ? '(Penalidade 75%)' : '(Bônus 100% Flanqueado)'}\nDano Maciço: $finalDamage\nParticipantes: ${(state['rolls'] as List).length + 1}" : "Defesa Conjunta Final: $finalHit\nParticipantes: ${(state['rolls'] as List).length + 1}";
                       _broadcastLog(state['initiator'], "Disparou uma ${state['isAttack'] ? 'Ação Conjunta' : 'Defesa Conjunta'}!", type: 'alert', details: detailsText);
                       if (state['isAttack'] && state['targetToken'] != null) _confirmAttack(state['targetToken']!); 
                       setState(()=>_hostedJointAction=null);
                    },
                    child: const Text("DISPARAR AÇÃO!", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))
                  )
               ]
            );
         }
       )
     );
  }

  void _showClashZoneDamageDialog(Rect area) {
    int zoneDmg = 100; Color zoneColor = Colors.redAccent;
    showDialog(
      context: context, barrierDismissible: false,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: Colors.grey[900], title: const Text("Dano da Área", style: TextStyle(color: Colors.white)),
          content: Column(mainAxisSize: MainAxisSize.min, children: [
             TextField(keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: "Dano nesta zona"), style: const TextStyle(color: Colors.white), onChanged: (v) => zoneDmg = int.tryParse(v) ?? 100),
             const SizedBox(height: 10),
             Wrap(spacing: 8, children: [Colors.red, Colors.orange, Colors.yellow, Colors.blue, Colors.purple].map((c) => InkWell(onTap: () => setDialogState(()=>zoneColor = c), child: Container(width: 30, height: 30, decoration: BoxDecoration(color: c.withOpacity(0.5), border: Border.all(color: zoneColor == c ? Colors.white : Colors.transparent, width: 2))))).toList())
          ]),
          actions: [
             TextButton(onPressed: () { setState(()=>_isClashZoneMode=false); Navigator.pop(ctx); }, child: const Text("Cancelar Clash", style: TextStyle(color: Colors.red))),
             ElevatedButton(
                onPressed: () {
                   setState(() => _clashZones.add({'rect': area, 'damage': zoneDmg, 'color': zoneColor}));
                   Navigator.pop(ctx);
                   showDialog(context: context, builder: (ctx2) => AlertDialog(backgroundColor: Colors.grey[900], title: const Text("Mais Áreas?", style: TextStyle(color: Colors.white)), actions: [
                      TextButton(onPressed: () { Navigator.pop(ctx2); _applyClashUltimateDamage(); }, child: const Text("Detonar Agora!", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold))),
                      ElevatedButton(onPressed: () { Navigator.pop(ctx2); }, child: const Text("Desenhar Outra Área"))
                   ]));
                },
                child: const Text("Confirmar Zona")
             )
          ]
        )
      )
    );
  }

  void _applyClashUltimateDamage() {
     setState(() { _isClashZoneMode = false; });
     String targetsHit = "";
     for (var token in _scenario.tokens) {
        if (token.isObstacle) continue;
        int maxDmg = 0;
        for (var zone in _clashZones) {
           Rect r = zone['rect'];
           Rect tokenRect = Rect.fromLTWH(token.x, token.y, token.size, token.size);
           if (r.overlaps(tokenRect) || r.contains(Offset(token.x, token.y))) { if (zone['damage'] > maxDmg) maxDmg = zone['damage']; }
        }
        if (maxDmg > 0) { _resolveDamage(token, -maxDmg); targetsHit += "\n- ${token.name} recebeu $maxDmg de Dano!"; }
     }
     _clashZones.clear();
     _broadcastLog("Mestre", "💣 A EXPLOSÃO DO CLASH OCORREU! 💣", type: 'alert', details: targetsHit.isEmpty ? "Ninguém foi pego na área da explosão!" : targetsHit);
     NetworkManager().sendMessage(jsonEncode({'type': 'SYNC_SCENARIO', 'scenario': _scenario.toJson()}));
  }

  @override
  Widget build(BuildContext context) {
    bool canDraw = widget.isHost || !_scenario.drawingsLocked;

    return WillPopScope(
      onWillPop: () async {
        // INTERCEPTADOR: Se estiver mirando ou posicionando algo, apenas cancela a ação e NÃO fecha a mesa.
        if (_isTargetMode) {
          setState(() => _isTargetMode = false);
          return false; 
        }
        if (_isPlacingMode) {
          setState(() {
            _isPlacingMode = false;
            _pendingSheetToPlace = null;
            _pendingObstacleToPlace = null;
          });
          return false;
        }
        if (_isClashZoneMode) {
          setState(() {
            _isClashZoneMode = false;
            _clashZones.clear();
          });
          return false;
        }
        // Se não estiver em nenhum modo especial, permite fechar a mesa online.
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          // UX MELHORADA: Troca a seta de voltar por um "X" de cancelar durante a mira
          leading: (_isTargetMode || _isPlacingMode || _isClashZoneMode)
              ? IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
                  tooltip: "Cancelar",
                  onPressed: () {
                    setState(() {
                      _isTargetMode = false;
                      _isPlacingMode = false;
                      _isClashZoneMode = false;
                    });
                  },
                )
              : const BackButton(color: Colors.white),
          title: Text(_isPlacingMode ? "POSICIONE O ITEM" : (_isTargetMode ? "SELECIONE ALVO" : "Mesa Online")),
        backgroundColor: _isPlacingMode ? Colors.purple[900] : (_isTargetMode ? Colors.red[900] : Theme.of(context).primaryColor),
        actions: [
          IconButton(icon: const Icon(Icons.casino, color: Colors.purpleAccent), tooltip: "Rolar Dados", onPressed: _showDicePanel),
          if (widget.isHost)
             IconButton(
               icon: Icon(_scenario.drawingsLocked ? Icons.lock : Icons.lock_open, color: _scenario.drawingsLocked ? Colors.red : Colors.greenAccent),
               tooltip: _scenario.drawingsLocked ? "Desbloquear Desenho" : "Bloquear Desenho p/ Jogadores",
               onPressed: () { setState(() => _scenario.drawingsLocked = !_scenario.drawingsLocked); NetworkManager().sendMessage(jsonEncode({'type': 'SYNC_SCENARIO', 'scenario': _scenario.toJson()})); _showToast(_scenario.drawingsLocked ? "Desenho bloqueado" : "Desenho liberado"); },
             ),
          if (canDraw)
            IconButton(
              icon: Icon(_isDrawingMode ? Icons.brush : Icons.brush_outlined, color: _isDrawingMode ? _brushColor : Colors.white),
              tooltip: "Modo Desenho Tático",
              onPressed: () => setState(() => _isDrawingMode = !_isDrawingMode),
            ),
          if (widget.isHost) ...[
             IconButton(icon: const Icon(Icons.person_add, color: Colors.amber), tooltip: "Invocar Personagem", onPressed: _showSheetSelectionDialog),
             PopupMenuButton<String>(
               icon: const Icon(Icons.map_outlined, color: Colors.white),
               onSelected: (val) {
                 if (val == 'config') _showMapConfigDialog();
                 if (val == 'obstacle') _showAddObstacleDialog();
                 if (val == 'save') _saveScenarioAs();
                 if (val == 'load') _loadScenarioList();
               },
               itemBuilder: (ctx) => const [
                 PopupMenuItem(value: 'config', child: Row(children: [Icon(Icons.grid_on), SizedBox(width: 8), Text("Configurar Mapa")])),
                 PopupMenuItem(value: 'obstacle', child: Row(children: [Icon(Icons.shield), SizedBox(width: 8), Text("Criar Obstáculo/NPC")])),
                 PopupMenuDivider(),
                 PopupMenuItem(value: 'save', child: Row(children: [Icon(Icons.save), SizedBox(width: 8), Text("Salvar Preset")])),
                 PopupMenuItem(value: 'load', child: Row(children: [Icon(Icons.folder_open), SizedBox(width: 8), Text("Carregar Preset")])),
               ],
             )
          ]
        ],
      ),
      body: Stack(
        children: [
          // 1. O MAPA EM TELA CHEIA
          Positioned.fill(
            child: InteractiveViewer(
              transformationController: _transformController,
              constrained: false,
              panEnabled: !_isDrawingMode && !_isClashZoneMode,
              scaleEnabled: true,
              trackpadScrollCausesScale: true,
              minScale: 0.1, 
              maxScale: 5.0,
              boundaryMargin: const EdgeInsets.all(3000), 
              child: Listener(
                onPointerDown: (e) {
                   if (_isSheetOpen) setState(() => _isSheetOpen = false); 
                   double gridX = (e.localPosition.dx / _scenario.blockSize).floorToDouble();
                   double gridY = (e.localPosition.dy / _scenario.blockSize).floorToDouble();
                   if (_isClashZoneMode) { setState(() { _clashZoneStart = Offset(gridX, gridY); _clashZoneEnd = Offset(gridX, gridY); }); return; }
                   if (_isPlacingMode) { _finalizePlacement(gridX, gridY); }
                   else if (_isTargetMode && _pendingAbility?.targetType == 'Área') { _resolveAreaEffect(gridX, gridY); }
                   else if (_isDrawingMode && canDraw && _drawingTool == 'brush') { setState(() => _currentLine = [e.localPosition / _scenario.blockSize]); }
                },
                onPointerMove: (e) { 
                   if (_isClashZoneMode && _clashZoneStart != null) { setState(() => _clashZoneEnd = Offset((e.localPosition.dx / _scenario.blockSize).floorToDouble(), (e.localPosition.dy / _scenario.blockSize).floorToDouble())); return; }
                   if (!_isDrawingMode || !canDraw) return;
                   Offset localP = e.localPosition / _scenario.blockSize;
                   if (_drawingTool == 'brush') { setState(() => _currentLine.add(localP)); }
                   else if (_drawingTool == 'eraser') {
                     bool erased = false;
                     for (int i = _scenario.drawings.length - 1; i >= 0; i--) { if (_isLineHit(localP, _scenario.drawings[i])) { setState(() => _scenario.drawings.removeAt(i)); erased = true; } }
                     if (erased) NetworkManager().sendMessage(jsonEncode({'type': 'SYNC_SCENARIO', 'scenario': _scenario.toJson()}));
                   }
                },
                onPointerUp: (e) { 
                   if (_isClashZoneMode && _clashZoneStart != null && _clashZoneEnd != null) {
                      Rect finalRect = Rect.fromPoints(_clashZoneStart!, _clashZoneEnd!);
                      _clashZoneStart = null; _clashZoneEnd = null;
                      _showClashZoneDamageDialog(finalRect);
                      return;
                   }
                   if (_isDrawingMode && canDraw && _drawingTool == 'brush' && _currentLine.isNotEmpty) {
                     setState(() { _scenario.drawings.add(DrawLine(id: const Uuid().v4(), authorId: _myClientId, points: List.from(_currentLine), colorValue: _brushColor.value)); _currentLine.clear(); });
                     NetworkManager().sendMessage(jsonEncode({'type': 'SYNC_SCENARIO', 'scenario': _scenario.toJson()}));
                   }
                },
                child: Container(
                  width: _scenario.gridCols * _scenario.blockSize,
                  height: _scenario.gridRows * _scenario.blockSize,
                  color: Colors.black54, 
                  child: Stack(
                    children: [
                      if (_scenario.backgroundPath != null) Positioned.fill(child: Image.file(File(_scenario.backgroundPath!), fit: BoxFit.fill))
                      else Container(color: Colors.grey[800]),
                      Positioned.fill(child: CustomPaint(painter: GridPainter(cols: _scenario.gridCols, rows: _scenario.gridRows, size: _scenario.blockSize, color: Colors.white24))),
                      Positioned.fill(child: CustomPaint(painter: DrawingPainter(_scenario.drawings, _currentLine, _brushColor, _scenario.blockSize))),
                      ..._clashZones.map((z) => Positioned(
                         left: min((z['rect'] as Rect).left, (z['rect'] as Rect).right) * _scenario.blockSize,
                         top: min((z['rect'] as Rect).top, (z['rect'] as Rect).bottom) * _scenario.blockSize,
                         width: ((z['rect'] as Rect).width).abs() * _scenario.blockSize + _scenario.blockSize,
                         height: ((z['rect'] as Rect).height).abs() * _scenario.blockSize + _scenario.blockSize,
                         child: Container(decoration: BoxDecoration(color: (z['color'] as Color).withOpacity(0.4), border: Border.all(color: z['color'] as Color, width: 2)))
                      )),
                      if (_isClashZoneMode && _clashZoneStart != null && _clashZoneEnd != null) 
                         Positioned(
                           left: min(_clashZoneStart!.dx, _clashZoneEnd!.dx) * _scenario.blockSize,
                           top: min(_clashZoneStart!.dy, _clashZoneEnd!.dy) * _scenario.blockSize,
                           width: (_clashZoneStart!.dx - _clashZoneEnd!.dx).abs() * _scenario.blockSize + _scenario.blockSize,
                           height: (_clashZoneStart!.dy - _clashZoneEnd!.dy).abs() * _scenario.blockSize + _scenario.blockSize,
                           child: Container(decoration: BoxDecoration(color: Colors.purpleAccent.withOpacity(0.3), border: Border.all(color: Colors.purpleAccent, width: 2, style: BorderStyle.solid)))
                         ),
                      ..._scenario.tokens.map((token) {
                         if (token.isHidden && !widget.isHost) return const SizedBox();
                         return Positioned(
                           left: token.x * _scenario.blockSize,
                           top: token.y * _scenario.blockSize,
                           width: token.size * _scenario.blockSize,
                           height: token.size * _scenario.blockSize,
                           child: GestureDetector(
                             onTap: () => _onTokenTap(token),
                             onPanStart: (details) { if (widget.isHost || token.id == _myToken?.id) { _dragStartX = token.x; _dragStartY = token.y; } },
                             onPanUpdate: (d) { if (widget.isHost || token.id == _myToken?.id) { setState(() { token.x += d.delta.dx / _scenario.blockSize; token.y += d.delta.dy / _scenario.blockSize; }); } },
                             onPanEnd: (_) {
                               if (widget.isHost || token.id == _myToken?.id) {
                                 setState(() {
                                   double newX = token.x.roundToDouble().clamp(0, _scenario.gridCols - 1).toDouble();
                                   double newY = token.y.roundToDouble().clamp(0, _scenario.gridRows - 1).toDouble();
                                   double distance = sqrt(pow(newX - (_dragStartX ?? newX), 2) + pow(newY - (_dragStartY ?? newY), 2));
                                   if (_isSpaceOccupied(newX, newY, excludeId: token.id)) {
                                      token.x = _dragStartX ?? token.x; token.y = _dragStartY ?? token.y; _showToast("Espaço ocupado!");
                                   } else {
                                      token.x = newX; token.y = newY;
                                      NetworkManager().sendMessage(jsonEncode({'type': 'MOVE_TOKEN', 'id': token.id, 'x': token.x, 'y': token.y}));
                                      if (distance >= 1.0) _showMovementPrompt(token);
                                   }
                                 });
                               }
                             },
                             child: Opacity(
                                opacity: token.isHidden ? 0.5 : 1.0,
                                child: Container(
                                  decoration: BoxDecoration(
                                    border: Border.all(color: token.id == _focusedToken?.id ? Colors.amber : (token.id == _myToken?.id ? Colors.green : Colors.white), width: 2),
                                    color: token.isObstacle ? Colors.brown : (token.team == 0 ? Colors.blueAccent : Colors.redAccent),
                                    shape: token.isObstacle ? BoxShape.rectangle : BoxShape.circle,
                                    image: token.imagePath != null 
  ? DecorationImage(
      // CORREÇÃO: Usar FileImage(File()) para ler do armazenamento local
      image: FileImage(File(token.imagePath!)), 
      fit: BoxFit.cover, 
      colorFilter: token.hpCurrent <= 0 ? const ColorFilter.mode(Colors.red, BlendMode.color) : null
    ) 
  : null,
                                  ),
                                  child: token.imagePath == null 
                                    ? Center(child: Text(token.name.isNotEmpty ? token.name[0] : "?", style: const TextStyle(color: Colors.white))) 
                                    : (token.hpCurrent <= 0 ? const Center(child: Icon(Icons.bloodtype, color: Colors.white70)) : null),
                               ),
                             ),
                           ),
                         );
                      })
                    ],
                  ),
                ),
              ),
            ),
          ),

          // BARRA FLUTUANTE DE FERRAMENTAS DA CANETA
          if (_isDrawingMode && canDraw)
            Positioned(
              top: 10, left: 10, right: 10,
              child: Center(
                child: Card(
                  color: Colors.grey[900], elevation: 8,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(icon: Icon(Icons.brush, color: _drawingTool == 'brush' ? Colors.amber : Colors.white), tooltip: "Pincel", onPressed: () => setState(() => _drawingTool = 'brush')),
                        IconButton(icon: Icon(Icons.cleaning_services, color: _drawingTool == 'eraser' ? Colors.amber : Colors.white), tooltip: "Borracha", onPressed: () => setState(() => _drawingTool = 'eraser')),
                        const SizedBox(width: 8),
                        ..._palette.map((c) => GestureDetector(
                          onTap: () => setState(() { _brushColor = c; _drawingTool = 'brush'; }),
                          child: Container(margin: const EdgeInsets.symmetric(horizontal: 4), width: 24, height: 24, decoration: BoxDecoration(color: c, shape: BoxShape.circle, border: Border.all(color: _brushColor == c ? Colors.amber : Colors.white24, width: 2))),
                        )),
                        const SizedBox(width: 16),
                        Container(height: 30, width: 1, color: Colors.white24),
                        IconButton(icon: const Icon(Icons.delete, color: Colors.orangeAccent), tooltip: "Apagar Meus Desenhos", onPressed: () { setState(() => _scenario.drawings.removeWhere((d) => d.authorId == _myClientId)); NetworkManager().sendMessage(jsonEncode({'type': 'SYNC_SCENARIO', 'scenario': _scenario.toJson()})); }),
                        if (widget.isHost)
                          IconButton(icon: const Icon(Icons.delete_forever, color: Colors.red), tooltip: "Limpar Todo o Mapa", onPressed: () { setState(() => _scenario.drawings.clear()); NetworkManager().sendMessage(jsonEncode({'type': 'SYNC_SCENARIO', 'scenario': _scenario.toJson()})); }),
                      ],
                    ),
                  ),
                ),
              )
            ),

          // LOG FLUTUANTE NA ESQUERDA
          Positioned(left: 0, top: 40, bottom: 40, width: 260, child: _buildBeautifulLog()),

          // FICHA DESLIZANTE NA DIREITA
          AnimatedPositioned(
             duration: const Duration(milliseconds: 300),
             curve: Curves.easeOutCubic,
             right: _isSheetOpen ? 0 : -450,
             top: 0, bottom: 0, width: 400,
             child: _buildSlideOutSheet(),
          ),
        ],
      ),
    ));
  }
}

class GridPainter extends CustomPainter {
  final int cols, rows;
  final double size;
  final Color color;
  GridPainter({required this.cols, required this.rows, required this.size, required this.color});
  @override
  void paint(Canvas c, Size s) { 
    final p = Paint()..color = color..style = PaintingStyle.stroke..strokeWidth = 1; 
    for (int i=0; i<=cols; i++) {
      c.drawLine(Offset(i*size, 0), Offset(i*size, rows*size), p);
    }
    for (int i=0; i<=rows; i++) {
      c.drawLine(Offset(0, i*size), Offset(cols*size, i*size), p);
    }
    final border = Paint()..color = Colors.red.withOpacity(0.5)..style = PaintingStyle.stroke..strokeWidth = 4;
    c.drawRect(Rect.fromLTWH(0, 0, cols*size, rows*size), border);
  }
  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}

class DrawingPainter extends CustomPainter {
  final List<DrawLine> drawings;
  final List<Offset> currentLine;
  final Color currentColor;
  final double blockSize;
  DrawingPainter(this.drawings, this.currentLine, this.currentColor, this.blockSize);
  
  @override
  void paint(Canvas c, Size s) {
    for (var l in drawings) {
      final p = Paint()..color = Color(l.colorValue)..strokeWidth = 4..style = PaintingStyle.stroke..strokeCap = StrokeCap.round;
      for(int i=0; i<l.points.length-1; i++) {
        c.drawLine(l.points[i] * blockSize, l.points[i+1] * blockSize, p);
      }
    }
    if (currentLine.isNotEmpty) {
      final p = Paint()..color = currentColor..strokeWidth = 4..style = PaintingStyle.stroke..strokeCap = StrokeCap.round;
      for(int i=0; i<currentLine.length-1; i++) {
        c.drawLine(currentLine[i] * blockSize, currentLine[i+1] * blockSize, p);
      }
    }
  }
  @override bool shouldRepaint(covariant CustomPainter old) => true;
}