// lib/screens/clash_screen.dart

import 'package:flutter/material.dart';
import 'dart:math';
import 'package:overlord/models/elemental_system.dart'; 

class ClashParticipant {
  String name;
  int damage;
  String damageType;
  bool isMain;

  ClashParticipant({
    this.name = '',
    this.damage = 0,
    this.damageType = 'Físico', 
    this.isMain = false,
  });
}

class ClashScreen extends StatefulWidget {
  const ClashScreen({super.key});

  @override
  State<ClashScreen> createState() => _ClashScreenState();
}

class _ClashScreenState extends State<ClashScreen> {
  // Lista dinâmica de "Lados" para suportar X lados
  final List<List<ClashParticipant>> _sides = [
    [ClashParticipant(name: 'Atacante A', isMain: true)],
    [ClashParticipant(name: 'Defensor B', isMain: true)],
  ];
  final List<String> _sideNames = ["LADO 1", "LADO 2"];
  
  final List<Color> _defaultColors = [
    Colors.cyanAccent, Colors.redAccent, Colors.greenAccent, 
    Colors.purpleAccent, Colors.orangeAccent, Colors.pinkAccent
  ];

  String _resultLog = "";
  Color _winnerColor = Colors.amber;

  @override
  void initState() {
    super.initState();
    ElementalSystem.loadCustomElements().then((_) {
      if (mounted) setState(() {});
    });
  }

  // --- GERENCIAMENTO DE X LADOS ---
  void _addNewSide() {
    setState(() {
      int nextNum = _sides.length + 1;
      _sideNames.add("LADO $nextNum");
      _sides.add([ClashParticipant(name: 'Alvo $nextNum', isMain: true)]);
    });
  }

  void _removeSide(int sideIndex) {
    if (_sides.length <= 2) return; // Mínimo de 2 lados
    setState(() {
      _sides.removeAt(sideIndex);
      _sideNames.removeAt(sideIndex);
    });
  }

  void _addParticipant(int sideIndex) {
    setState(() {
      _sides[sideIndex].add(ClashParticipant(name: 'Novo', damageType: 'Físico', isMain: _sides[sideIndex].isEmpty));
    });
  }

  void _removeParticipant(int sideIndex, int pIndex) {
    setState(() {
      _sides[sideIndex].removeAt(pIndex);
      if (_sides[sideIndex].isNotEmpty && !_sides[sideIndex].any((p) => p.isMain)) {
        _sides[sideIndex].first.isMain = true;
      }
    });
  }

  void _setMain(int sideIndex, int pIndex) {
    setState(() {
      for (var p in _sides[sideIndex]) {
        p.isMain = false;
      }
      _sides[sideIndex][pIndex].isMain = true;
    });
  }

  // --- MOTOR SUPREMO E EXPLOSÃO ---
  Map<String, String> _getFusionDetails(List<String> elements) {
    if (elements.isEmpty) {
      return {'name': 'Golpe Bruto', 'desc': 'Dano material cinético e contundente.'};
    }

    final elsSet = elements.toSet();
    String fusionName = ElementalSystem.getFusionName(elsSet);

    if (elsSet.length == 1) {
      final info = ElementalSystem.allElementsMap[elsSet.first];
      return {
        'name': elsSet.first,
        'desc': info?.narrativeLogic ?? 'Poder elemental puro.'
      };
    }

    Map<String, String> fusionsDesc = {
      'Névoa Escaldante': 'Vapor superaquecido que cozinha o inimigo dentro da armadura.',
      'Canhão Railgun': 'Magnetismo acelera rocha a velocidade supersônica.',
      'Magma Vivo': 'Rocha derretida que gruda e causa dano contínuo extremo.',
      'Tempestade de Estilhaços': 'Vento tritura gelo em pó de vidro invisível.',
      'Condução Fatal': 'Eletrocuta tudo ao redor usando a água como fio condutor.',
      'Tempestade de Areia': 'Erosão acelerada. Lixa a armadura do inimigo.',
      'Lança de Obsidiana': 'Pressão absurda molda minerais em uma lança impenetrável.',
      'Tsunami Congelante': 'Uma onda massiva que solidifica tudo que toca.',
      'Acupuntura Hemática': 'Controle mental dos fluidos vitais do inimigo.',
      'Prisma de Cristal': 'Refração de energia que multiplica o poder de fogo.'
    };

    return {
      'name': fusionName, 
      'desc': fusionsDesc[fusionName] ?? 'Os elementos colidem criando uma ressonância instável, selvagem e letal!'
    };
  }

  // Multiplicador lê fraquezas contra TODOS os outros lados na explosão
  double _getElementalMultiplier(List<String> myElems, List<String> enemiesElems) {
    double mult = 1.0;
    for (var a in myElems) {
      final infoA = ElementalSystem.allElementsMap[a];
      if (infoA == null) continue;
      for (var b in enemiesElems) {
        if (infoA.disadvantages.contains(b)) {
          mult -= 0.3; // Desvantagem reduz 30%
        }
      }
    }
    return mult < 0.1 ? 0.1 : mult; 
  }

  void _calculateClash() {
    List<double> finalPowers = [];
    List<int> rawPowers = [];
    List<Map<String, String>> fusions = [];
    double totalColisionPower = 0;

    // Calcula o poder de cada lado contra a mistura de todos os outros lados
    for (int i = 0; i < _sides.length; i++) {
      var side = _sides[i];
      List<String> myElements = side.map((p) => p.damageType).toSet().toList();
      fusions.add(_getFusionDetails(myElements));

      // Coleta elementos de TODOS os outros lados
      List<String> enemiesElements = [];
      for (int j = 0; j < _sides.length; j++) {
        if (i != j) enemiesElements.addAll(_sides[j].map((p) => p.damageType));
      }

      double mult = _getElementalMultiplier(myElements, enemiesElements.toSet().toList());
      int raw = side.fold(0, (sum, p) => sum + p.damage);
      double finalPwr = raw * mult;

      rawPowers.add(raw);
      finalPowers.add(finalPwr);
      totalColisionPower += finalPwr;
    }

    double maxPower = finalPowers.reduce(max);
    List<int> winners = [];
    for (int i = 0; i < finalPowers.length; i++) {
      if (finalPowers[i] == maxPower) winners.add(i);
    }

    StringBuffer log = StringBuffer();
    log.writeln("=== CHOQUE DE ENERGIAS (${_sides.length} LADOS) ===");
    log.writeln("Poder Total no Centro: ${totalColisionPower.toInt()}");
    log.writeln("\n--- Leituras Individuais ---");
    
    for (int i = 0; i < _sides.length; i++) {
      double mult = finalPowers[i] / (rawPowers[i] == 0 ? 1 : rawPowers[i]);
      log.writeln("${_sideNames[i]}: ${finalPowers[i].toInt()} (Base ${rawPowers[i]} | Mult x${mult.toStringAsFixed(1)})");
      log.writeln("   └ Elemento: ${fusions[i]['name']}");
    }

    log.writeln("\n--- RESULTADO DA COLISÃO ---");
    if (winners.length > 1) {
      log.writeln("💥 EMPATE CATASTRÓFICO!");
      log.writeln("O centro não aguentou a pressão! As magias colapsaram em uma EXPLOSÃO EM ÁREA (AoE) imparável.");
      double aoeDmg = totalColisionPower * 0.40;
      log.writeln("🔥 TODOS os lados recebem ${aoeDmg.toInt()} de Dano Residual!");
      _winnerColor = Colors.orangeAccent;
    } else {
      int w = winners.first;
      log.writeln("🏆 DOMÍNIO ABSOLUTO: ${_sideNames[w]} esmagou os outros ataques!");
      log.writeln("Efeito Vencedor: ${fusions[w]['desc']}");
      
      double aoeDmg = totalColisionPower * 0.35;
      log.writeln("💥 EXPLOSÃO EM ÁREA (AoE): Os poderes perdedores detonam no impacto.");
      log.writeln("Todos os perdedores recebem ${aoeDmg.toInt()} de Dano.");
      _winnerColor = _getSideColor(_sides[w], _defaultColors[w % _defaultColors.length]);
    }

    setState(() { _resultLog = log.toString(); });
  }

  Color _getSideColor(List<ClashParticipant> side, Color defaultColor) {
    if (side.isEmpty) return defaultColor;
    String mainEl = side.firstWhere((p) => p.isMain, orElse: () => side.first).damageType;
    return ElementalSystem.allElementsMap[mainEl]?.color ?? defaultColor;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(title: const Text("Clash Supremo em Área", style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.5)), backgroundColor: theme.appBarTheme.backgroundColor),
      body: Column(
        children: [
          Expanded(
            // ListView Horizontal para suportar X lados
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _sides.length + 1,
              itemBuilder: (context, index) {
                // Botão de Adicionar Lado no final da lista
                if (index == _sides.length) {
                  return Container(
                    width: 150,
                    alignment: Alignment.center,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.add_circle, color: Colors.amber, size: 60),
                          onPressed: _addNewSide,
                        ),
                        const Text("Adicionar Força", style: TextStyle(color: Colors.amber, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  );
                }

                Color sColor = _getSideColor(_sides[index], _defaultColors[index % _defaultColors.length]);
                return SizedBox(
                  width: 360, // Largura fixa para cada coluna rolar suavemente no PC/Celular
                  child: Row(
                    children: [
                      _buildSideColumn(index, sColor, _sideNames[index]),
                      const VerticalDivider(width: 2, color: Colors.white12),
                    ],
                  ),
                );
              },
            ),
          ),
          
          // PAINEL INFERIOR DE CÁLCULO
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.grey[900],
              border: const Border(top: BorderSide(color: Colors.white12, width: 2)),
              boxShadow: const [BoxShadow(color: Colors.black54, blurRadius: 20, spreadRadius: 5)],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: double.infinity,
                  height: 60,
                  child: ElevatedButton.icon(
                    onPressed: _calculateClash,
                    icon: const SwordsIcon(size: 30, color: Colors.black), 
                    label: Text("DETONAR COLISÃO (${_sides.length} LADOS)", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.amber, 
                      foregroundColor: Colors.black,
                      shadowColor: Colors.amberAccent,
                      elevation: 10,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))
                    ),
                  ),
                ),
                if (_resultLog.isNotEmpty) ...[
                  const SizedBox(height: 20),
                  Container(
                    width: double.infinity, 
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.black87, 
                      borderRadius: BorderRadius.circular(12), 
                      border: Border.all(color: _winnerColor.withOpacity(0.8), width: 2),
                      boxShadow: [BoxShadow(color: _winnerColor.withOpacity(0.2), blurRadius: 15, spreadRadius: 2)]
                    ),
                    child: Text(
                      _resultLog, 
                      style: const TextStyle(color: Colors.white, fontFamily: 'Courier', fontSize: 13, height: 1.5),
                    ),
                  ),
                ]
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSideColumn(int sideIndex, Color color, String title) {
    List<ClashParticipant> side = _sides[sideIndex];
    int totalRaw = side.fold(0, (sum, p) => sum + p.damage);
    List<String> activeElements = side.map((p) => p.damageType).toSet().toList();
    var fusion = _getFusionDetails(activeElements);

    List<String> allSystemElements = ElementalSystem.allElements;
    if (allSystemElements.isEmpty) allSystemElements = ['Físico']; 

    return Expanded(
      child: Container(
        color: Colors.black12,
        child: Column(
          children: [
            // CABEÇALHO DO LADO COM NEON
            Container(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8), 
              width: double.infinity,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                border: Border(bottom: BorderSide(color: color.withOpacity(0.5), width: 2)),
                boxShadow: [BoxShadow(color: color.withOpacity(0.05), blurRadius: 10)],
              ),
              child: Stack(
                children: [
                  Column(
                    children: [
                      Text(title, style: TextStyle(color: color, fontWeight: FontWeight.bold, letterSpacing: 2)),
                      const SizedBox(height: 8),
                      Text("Dano: $totalRaw", style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white)),
                      const SizedBox(height: 4),
                      Text(
                        fusion['name']!, 
                        style: TextStyle(fontSize: 14, color: color, fontStyle: FontStyle.italic, fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                  if (_sides.length > 2)
                    Positioned(
                      right: -10, top: -10,
                      child: IconButton(
                        icon: const Icon(Icons.delete_forever, color: Colors.redAccent),
                        onPressed: () => _removeSide(sideIndex),
                        tooltip: "Remover este lado do Clash",
                      ),
                    )
                ],
              ),
            ),
            
            // LISTA DE PARTICIPANTES
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(8),
                itemCount: side.length,
                itemBuilder: (context, index) {
                  final p = side[index];
                  if (!allSystemElements.contains(p.damageType)) p.damageType = allSystemElements.first;

                  // Correção de Texto Segura (Evita Crash de Cursor)
                  String dmgText = p.damage == 0 ? '' : p.damage.toString();

                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey[900],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: p.isMain ? color : Colors.white12, width: p.isMain ? 2 : 1),
                      boxShadow: p.isMain ? [BoxShadow(color: color.withOpacity(0.2), blurRadius: 8)] : [],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                decoration: const InputDecoration(labelText: "Nome do Ataque", isDense: true, border: InputBorder.none), 
                                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                onChanged: (v) => p.name = v, 
                                controller: TextEditingController(text: p.name)..selection = TextSelection.collapsed(offset: p.name.length)
                              )
                            ),
                            IconButton(
                              icon: Icon(p.isMain ? Icons.star : Icons.star_border, color: p.isMain ? color : Colors.grey), 
                              onPressed: () => _setMain(sideIndex, index), 
                              tooltip: "Alvo Principal"
                            ),
                          ],
                        ),
                        const Divider(color: Colors.white12),
                        Row(
                          children: [
                            Expanded(
                              flex: 2,
                              child: TextField(
                                decoration: InputDecoration(labelText: "Dano", isDense: true, labelStyle: TextStyle(color: color.withOpacity(0.7))), 
                                keyboardType: TextInputType.number, 
                                style: const TextStyle(color: Colors.white, fontSize: 18),
                                controller: TextEditingController(text: dmgText)..selection = TextSelection.collapsed(offset: dmgText.length),
                                onChanged: (v) { setState(() { p.damage = int.tryParse(v) ?? 0; }); }
                              )
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              flex: 3,
                              child: DropdownButtonFormField<String>(
                                initialValue: p.damageType,
                                isExpanded: true,
                                dropdownColor: Colors.grey[850],
                                decoration: const InputDecoration(isDense: true, border: InputBorder.none),
                                items: allSystemElements.map((e) {
                                  Color elColor = ElementalSystem.allElementsMap[e]?.color ?? Colors.white;
                                  return DropdownMenuItem(value: e, child: Text(e, style: TextStyle(fontSize: 13, color: elColor, fontWeight: FontWeight.bold)));
                                }).toList(),
                                onChanged: (v) => setState(() => p.damageType = v!),
                              ),
                            ),
                            if (side.length > 1) 
                              IconButton(icon: const Icon(Icons.close, color: Colors.redAccent, size: 20), onPressed: () => _removeParticipant(sideIndex, index)),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            
            // BOTÃO DE ADICIONAR AO COMBO
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: OutlinedButton.icon(
                onPressed: () => _addParticipant(sideIndex), 
                icon: Icon(Icons.add, color: color), 
                label: Text("Combada +1", style: TextStyle(color: color)),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: color.withOpacity(0.5)),
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SwordsIcon extends StatelessWidget {
  final double size;
  final Color color;
  const SwordsIcon({super.key, this.size = 60, this.color = const Color(0xFFFFD700)});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size, height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Transform.rotate(angle: pi / 4, child: _buildSingleSword()),
          Transform.rotate(angle: -pi / 4, child: _buildSingleSword()),
        ],
      ),
    );
  }

  Widget _buildSingleSword() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(width: size * 0.1, height: size * 0.6, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(2), boxShadow: const [BoxShadow(color: Colors.black45, blurRadius: 1, offset: Offset(1,1))])),
        Container(width: size * 0.3, height: size * 0.08, color: color),
        Container(width: size * 0.08, height: size * 0.2, color: Colors.brown[400]),
        Container(width: size * 0.12, height: size * 0.12, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
      ],
    );
  }
}