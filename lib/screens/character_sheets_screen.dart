// lib/screens/character_sheets_screen.dart

import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:overlord/models/character_sheet.dart';
import 'package:overlord/models/dice_roll_handler.dart';
import 'package:overlord/models/die_specification.dart'; 
import 'package:overlord/models/sheet_folder.dart';
import 'package:overlord/screens/new_character_sheet_form.dart';
import 'package:overlord/Réquiem/requiem_sheet_form.dart'; 
import 'package:overlord/Réquiem/requiem_character_sheet.dart'; 
import 'package:overlord/localization.dart';
import 'package:share_plus/share_plus.dart';

class CharacterSheetsScreen extends StatefulWidget {
  final Function(CharacterSheet) onSaveSheet;
  final Function(String) onDeleteSheet;
  final Function(int, int) onReorderSheets;
  final List<CharacterSheet> characterSheets;
  
  final VoidCallback onClearHistory;
  final VoidCallback onAddNewDie;
  final VoidCallback onHelp;
  final VoidCallback onAbout;
  final VoidCallback onRateApp;
  
  final DiceRollHandler onDiceRolledFromSheet;
  final void Function(String) showToast;
  final VoidCallback onToggleGodMode;

  const CharacterSheetsScreen({
    super.key,
    required this.onSaveSheet,
    required this.onDeleteSheet,
    required this.onReorderSheets,
    required this.characterSheets,
    required this.onClearHistory,
    required this.onAddNewDie,
    required this.onHelp,
    required this.onAbout,
    required this.onRateApp,
    required this.onDiceRolledFromSheet,
    required this.showToast,
    required this.onToggleGodMode,
  });

  @override
  State<CharacterSheetsScreen> createState() => _CharacterSheetsScreenState();
}

class _CharacterSheetsScreenState extends State<CharacterSheetsScreen> {
  List<SheetFolder> _folders = [];
  String? _currentFolderId;

  @override
  void initState() {
    super.initState();
    _loadFolders();
  }

  Future<void> _loadFolders() async {
    _folders = await SheetFolderManager.load();
    setState(() {});
  }

  Future<void> _saveFolders() async {
    await SheetFolderManager.save(_folders);
    setState(() {});
  }

  // ==========================================
  // ADAPTADOR DO MOTOR DE DADOS
  // ==========================================
  
  void _rollRequiemDice(String formula, String title) {
    List<DieSpecification> diceList = [];
    int modifier = 0;
    
    final parts = formula.split('+');
    for (var part in parts) {
      if (part.contains('d')) {
        final split = part.split('d');
        int qty = int.tryParse(split[0]) ?? 1;
        int sides = int.tryParse(split[1]) ?? 20;
        diceList.add(DieSpecification(quantity: qty, sides: sides));
      } else {
        modifier += int.tryParse(part) ?? 0;
      }
    }
    
    widget.onDiceRolledFromSheet(title, diceList, modifier: modifier);
  }

  // ==========================================
  // NAVEGAÇÃO E CRIAÇÃO
  // ==========================================

  void _navigateAndEditSheet(CharacterSheet sheet) {
    if (sheet.systemType == 'Requiem') {
      final requiemSheet = RequiemCharacterSheet(
         id: sheet.id,
         name: sheet.name,
         level: sheet.level ?? 1,
         className: sheet.classe ?? 'Sem Classe',
         raceName: sheet.abilitiesNotes ?? 'Humano',
         baseAttributes: sheet.attributes.map((k, v) => MapEntry(k, v ?? 0)),
         baseSkills: sheet.pericias.map((k, v) => MapEntry(k, v ?? 0)),
         currentHp: sheet.status['Vida']?['atual'] ?? 0,
         currentMana: sheet.status['Mana/Vigor']?['atual'] ?? 0,
      );
      
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => RequiemSheetForm(
            initialSheet: requiemSheet,
            onDiceRolledFromSheet: _rollRequiemDice, 
            onSave: (updatedRequiemSheet) {
               final updatedUniversalSheet = CharacterSheet(
                 id: sheet.id, 
                 name: updatedRequiemSheet.name,
                 level: updatedRequiemSheet.level,
                 classe: updatedRequiemSheet.className,
                 attributes: updatedRequiemSheet.baseAttributes,
                 pericias: updatedRequiemSheet.baseSkills,
                 status: {
                   'Vida': {'atual': updatedRequiemSheet.currentHp, 'total': updatedRequiemSheet.maxHp},
                   // CORREÇÃO: Usando maxResource ao invés do antigo baseMaxMana
                   'Mana/Vigor': {'atual': updatedRequiemSheet.currentMana, 'total': updatedRequiemSheet.maxResource},
                 },
                 abilitiesNotes: updatedRequiemSheet.raceName,
                 systemType: 'Requiem',
                 folderId: sheet.folderId,
                 weapons: sheet.weapons,     
                 abilities: sheet.abilities, 
                 passives: sheet.passives,   
               );
               
               widget.onSaveSheet(updatedUniversalSheet);
            }
          )
        )
      );
    } else {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => NewCharacterSheetForm(
            initialSheet: sheet,
            onSave: widget.onSaveSheet,
            onDiceRolledFromSheet: widget.onDiceRolledFromSheet,
            showToast: widget.showToast,
          ),
        ),
      );
    }
  }

  void _navigateAndCreateOverlordSheet({String? folderId}) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => NewCharacterSheetForm(
          onSave: (sheet) {
            if (folderId != null) sheet.folderId = folderId; 
            sheet.systemType = 'Overlord';
            widget.onSaveSheet(sheet);
          },
          onDiceRolledFromSheet: widget.onDiceRolledFromSheet,
          showToast: widget.showToast,
        ),
      ),
    );
  }

  void _navigateAndCreateRequiemSheet({String? folderId}) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => RequiemSheetForm(
          onDiceRolledFromSheet: _rollRequiemDice, 
          onSave: (requiemSheet) {
            final universalSheet = CharacterSheet(
              id: requiemSheet.id,
              name: requiemSheet.name,
              level: requiemSheet.level,
              classe: requiemSheet.className,
              attributes: requiemSheet.baseAttributes, 
              pericias: requiemSheet.baseSkills,       
              status: {
                'Vida': {'atual': requiemSheet.currentHp, 'total': requiemSheet.maxHp},
                // CORREÇÃO: Usando maxResource ao invés do antigo baseMaxMana
                'Mana/Vigor': {'atual': requiemSheet.currentMana, 'total': requiemSheet.maxResource},
              },
              abilitiesNotes: requiemSheet.raceName,
              systemType: 'Requiem', 
              folderId: folderId,
              weapons: const [],
              abilities: const [],
              passives: const [],
            );
            widget.onSaveSheet(universalSheet);
          },
        ),
      ),
    );
  }

  // --- MENUS DE FABRICAR (FAB) ---

  void _showFabMenu() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.grey[900],
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (ctx) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 8),
          ListTile(
            leading: const Icon(Icons.person_add, color: Colors.amber),
            title: const Text('Nova Ficha (Overlord)', style: TextStyle(color: Colors.white)),
            onTap: () { Navigator.pop(ctx); _navigateAndCreateOverlordSheet(folderId: _currentFolderId); }
          ),
          ListTile(
            leading: const Icon(Icons.person_add_alt_1, color: Colors.deepPurpleAccent),
            title: const Text('Nova Ficha (Réquiem das Almas)', style: TextStyle(color: Colors.white)),
            subtitle: const Text('Beta 0.43', style: TextStyle(color: Colors.white54, fontSize: 12)),
            onTap: () { Navigator.pop(ctx); _navigateAndCreateRequiemSheet(folderId: _currentFolderId); }
          ),
          if (_currentFolderId == null)
            ListTile(
              leading: const Icon(Icons.create_new_folder, color: Colors.blueAccent),
              title: const Text('Nova Pasta', style: TextStyle(color: Colors.white)),
              onTap: () { Navigator.pop(ctx); _showFolderDialog(); }
            ),
          const SizedBox(height: 16),
        ]
      )
    );
  }

  // --- GERENCIAMENTO DE PASTAS ---

  void _showFolderDialog({SheetFolder? existingFolder}) {
    final nameCtrl = TextEditingController(text: existingFolder?.name ?? '');
    String? imgPath = existingFolder?.imagePath;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          backgroundColor: Colors.grey[900],
          title: Text(existingFolder == null ? 'Nova Pasta' : 'Editar Pasta', style: const TextStyle(color: Colors.blueAccent)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              GestureDetector(
                onTap: () async {
                  final picker = ImagePicker();
                  final picked = await picker.pickImage(source: ImageSource.gallery);
                  if (picked != null) setDialogState(() => imgPath = picked.path);
                },
                child: Container(
                  width: 80, height: 80,
                  decoration: BoxDecoration(
                    color: Colors.black45,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.blueAccent),
                    image: imgPath != null && File(imgPath!).existsSync() ? DecorationImage(image: FileImage(File(imgPath!)), fit: BoxFit.cover) : null,
                  ),
                  child: imgPath == null || !File(imgPath!).existsSync() ? const Icon(Icons.add_photo_alternate, color: Colors.white54, size: 30) : null,
                )
              ),
              const SizedBox(height: 16),
              TextField(
                controller: nameCtrl, 
                style: const TextStyle(color: Colors.white), 
                decoration: const InputDecoration(labelText: 'Nome da Pasta', labelStyle: TextStyle(color: Colors.white54))
              ),
            ]
          ),
          actions: [
             TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar', style: TextStyle(color: Colors.grey))),
             ElevatedButton(
               style: ElevatedButton.styleFrom(backgroundColor: Colors.blueAccent),
               onPressed: () {
                 if (nameCtrl.text.isEmpty) return;
                 if (existingFolder == null) {
                   _folders.add(SheetFolder(name: nameCtrl.text, imagePath: imgPath));
                 } else {
                   existingFolder.name = nameCtrl.text;
                   existingFolder.imagePath = imgPath;
                 }
                 _saveFolders();
                 Navigator.pop(ctx);
               },
               child: const Text('Salvar', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))
             )
          ]
        )
      )
    );
  }

  void _deleteFolder(SheetFolder folder) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: const Text('Apagar Pasta', style: TextStyle(color: Colors.redAccent)),
        content: Text('Deseja apagar a pasta "${folder.name}"?\n\nAs fichas dentro dela NÃO serão apagadas, elas voltarão para a página inicial.', style: const TextStyle(color: Colors.white70)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar', style: TextStyle(color: Colors.grey))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red[900]),
            onPressed: () {
              _folders.removeWhere((f) => f.id == folder.id);
              _saveFolders();
              for(var s in widget.characterSheets) {
                if (s.folderId == folder.id) {
                  s.folderId = null;
                  widget.onSaveSheet(s);
                }
              }
              setState(() => _currentFolderId = null);
              Navigator.pop(ctx);
            },
            child: const Text('Apagar', style: TextStyle(color: Colors.white))
          )
        ]
      )
    );
  }

  void _moveSheetToFolder(CharacterSheet sheet) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: const Text('Mover para Pasta', style: TextStyle(color: Colors.white)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.home, color: Colors.white),
                title: const Text('Página Inicial (Remover)', style: TextStyle(color: Colors.white)),
                onTap: () {
                  sheet.folderId = null;
                  widget.onSaveSheet(sheet);
                  Navigator.pop(ctx);
                  setState((){});
                }
              ),
              const Divider(color: Colors.white24),
              ..._folders.map((f) => ListTile(
                leading: const Icon(Icons.folder, color: Colors.amber),
                title: Text(f.name, style: const TextStyle(color: Colors.white)),
                onTap: () {
                  sheet.folderId = f.id;
                  widget.onSaveSheet(sheet);
                  Navigator.pop(ctx);
                  setState((){});
                }
              ))
            ]
          )
        )
      )
    );
  }

  // --- UI HEADERS ---

  Widget _buildRootHeader() {
    if (_folders.isEmpty) return const SizedBox(height: 8);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('📁 Pastas', style: TextStyle(color: Colors.amber, fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, mainAxisSpacing: 12, crossAxisSpacing: 12, childAspectRatio: 0.9),
            itemCount: _folders.length,
            itemBuilder: (ctx, i) {
              final f = _folders[i];
              final hasImage = f.imagePath != null && File(f.imagePath!).existsSync();
              
              return InkWell(
                onTap: () => setState(() => _currentFolderId = f.id),
                onLongPress: () => _showFolderDialog(existingFolder: f),
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[850], 
                    borderRadius: BorderRadius.circular(12), 
                    border: Border.all(color: Colors.blueAccent.withOpacity(0.5)),
                    image: hasImage 
                        ? DecorationImage(image: FileImage(File(f.imagePath!)), fit: BoxFit.cover) 
                        : null,
                  ),
                  child: Stack(
                    children: [
                      if (!hasImage)
                        const Center(child: Icon(Icons.folder, color: Colors.blueAccent, size: 50)),
                      Align(
                        alignment: Alignment.bottomCenter,
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
                          decoration: BoxDecoration(
                            borderRadius: const BorderRadius.vertical(bottom: Radius.circular(11)),
                            gradient: LinearGradient(
                              begin: Alignment.bottomCenter,
                              end: Alignment.topCenter,
                              colors: [Colors.black.withOpacity(0.9), Colors.transparent],
                            ),
                          ),
                          child: Text(
                            f.name, 
                            style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold), 
                            maxLines: 1, 
                            overflow: TextOverflow.ellipsis, 
                            textAlign: TextAlign.center
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              );
            }
          ),
          const Divider(color: Colors.white24, height: 32),
          const Text('📄 Fichas', style: TextStyle(color: Colors.amber, fontSize: 18, fontWeight: FontWeight.bold)),
        ]
      )
    );
  }

  Widget _buildFolderHeader() {
    final f = _folders.firstWhere((x) => x.id == _currentFolderId, orElse: () => SheetFolder(name: 'Erro'));
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      margin: const EdgeInsets.only(bottom: 8),
      decoration: const BoxDecoration(
        color: Colors.black38,
        border: Border(bottom: BorderSide(color: Colors.blueAccent, width: 2))
      ),
      child: Row(
        children: [
          IconButton(icon: const Icon(Icons.arrow_back, color: Colors.white), onPressed: () => setState(() => _currentFolderId = null)),
          const SizedBox(width: 8),
          if (f.imagePath != null && File(f.imagePath!).existsSync())
             Padding(padding: const EdgeInsets.only(right: 12), child: CircleAvatar(backgroundImage: FileImage(File(f.imagePath!)), radius: 20)),
          Expanded(child: Text(f.name, style: const TextStyle(color: Colors.blueAccent, fontSize: 22, fontWeight: FontWeight.bold))),
          IconButton(icon: const Icon(Icons.edit, color: Colors.white54), onPressed: () => _showFolderDialog(existingFolder: f)),
          IconButton(icon: const Icon(Icons.delete, color: Colors.redAccent), onPressed: () => _deleteFolder(f)),
        ]
      )
    );
  }

  // --- EXPORT & DELETE ---

  void _exportSheetOptions(CharacterSheet sheet) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Theme.of(context).cardColor,
        title: Text('Exportar: ${sheet.name}', style: const TextStyle(color: Colors.white)),
        content: const Text('Como deseja compartilhar esta ficha?', style: TextStyle(color: Colors.white70)),
        actions: [
          TextButton(
            onPressed: () { Navigator.pop(ctx); _exportSheetAsText(sheet); },
            child: const Text('Texto Legível', style: TextStyle(color: Colors.amber)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.blueAccent),
            onPressed: () { Navigator.pop(ctx); _exportSheetAsJson(sheet); },
            child: const Text('Código (App)', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _exportSheetAsJson(CharacterSheet sheet) {
    String jsonString = jsonEncode(sheet.toJson());
    Share.share(jsonString, subject: 'Ficha [Código]: ${sheet.name}');
    Clipboard.setData(ClipboardData(text: jsonString));
    widget.showToast("Código da ficha copiado!");
  }

  void _exportSheetAsText(CharacterSheet sheet) {
    StringBuffer sb = StringBuffer();
    sb.writeln('👤 *NOME:* ${sheet.name}');
    sb.writeln('🎭 *CLASSE:* ${sheet.classe ?? "Sem Classe"} | *NÍVEL:* ${sheet.level ?? 1}');
    sb.writeln('---');
    sb.writeln('❤️ *VIDA:* ${sheet.status["Vida"]?["atual"] ?? 0}/${sheet.status["Vida"]?["total"] ?? 0}');
    sb.writeln('⚡ *ESFORÇO:* ${sheet.status["Esforço"]?["atual"] ?? 0}/${sheet.status["Esforço"]?["total"] ?? 0}');
    sb.writeln('🧠 *SANIDADE:* ${sheet.status["Sanidade"]?["atual"] ?? 0}/${sheet.status["Sanidade"]?["total"] ?? 0}');
    sb.writeln('---');
    sb.writeln('📊 *ATRIBUTOS:*');
    sheet.attributes.forEach((key, val) => sb.writeln('  $key: $val'));
    
    if (sheet.pericias.isNotEmpty) {
      sb.writeln('---');
      sb.writeln('📚 *PERÍCIAS:*');
      sheet.pericias.forEach((key, val) {
        if (val != null && val > 0) sb.writeln('  $key: $val');
      });
    }

    if (sheet.abilities.isNotEmpty || sheet.rituals.isNotEmpty) {
      sb.writeln('---');
      sb.writeln('✨ *HABILIDADES E RITUAIS:*');
      for (var a in sheet.abilities) {
        sb.writeln('  🔥 *${a.name}*');
        if (a.description.isNotEmpty) sb.writeln('     📝 _${a.description}_');
      }
      for (var r in sheet.rituals) {
        sb.writeln('  🔯 *${r.name}*');
        if (r.description.isNotEmpty) sb.writeln('     📝 _${r.description}_');
      }
    }

    if (sheet.passives.isNotEmpty) {
      sb.writeln('---');
      sb.writeln('🌀 *PASSIVAS:*');
      for (var p in sheet.passives) {
        sb.writeln('  ⚙️ *${p.name}*');
        if (p.description.isNotEmpty) sb.writeln('     📝 _${p.description}_');
      }
    }
    
    String text = sb.toString();
    Share.share(text, subject: 'Ficha RPG: ${sheet.name}');
    Clipboard.setData(ClipboardData(text: text));
    widget.showToast("Texto da ficha copiado!");
  }

  void _confirmDelete(CharacterSheet sheet, AppStrings strings, ThemeData theme) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: theme.cardColor,
        title: Text(strings.get('delete_sheet_title') ?? 'Excluir', style: const TextStyle(color: Colors.redAccent)),
        content: Text('Apagar os registros de ${sheet.name} para todo o sempre?'),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(), child: Text(strings.get('cancel') ?? 'Cancelar', style: const TextStyle(color: Colors.grey))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red[900]),
            onPressed: () { widget.onDeleteSheet(sheet.id); Navigator.of(context).pop(); }, 
            child: Text(strings.get('delete') ?? 'Excluir', style: const TextStyle(color: Colors.white))
          ),
        ],
      ),
    );
  }

  Widget _buildMiniStat(String label, int? atual, int? total, Color color) {
    return Column(
      children: [
        Text(label, style: TextStyle(color: color.withOpacity(0.8), fontSize: 10, fontWeight: FontWeight.bold)),
        Text('${atual ?? 0}/${total ?? 0}', style: TextStyle(color: color, fontSize: 14, fontWeight: FontWeight.bold)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final strings = AppStrings.of(context);

    final filteredSheets = widget.characterSheets.where((s) => s.folderId == _currentFolderId).toList();
    final bool isEmptyRoot = _currentFolderId == null && _folders.isEmpty && filteredSheets.isEmpty;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: isEmptyRoot
          ? Center(
              child: Text(
                '${strings.get('no_sheets') ?? 'Nenhuma Ficha ou Pasta Encontrada'}\nClique no (+) para criar.',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.grey, fontSize: 16),
              ),
            )
          : ReorderableListView.builder(
              padding: const EdgeInsets.only(bottom: 80, top: 16),
              header: _currentFolderId == null ? _buildRootHeader() : _buildFolderHeader(),
              footer: (_currentFolderId != null && filteredSheets.isEmpty)
                  ? const Padding(padding: EdgeInsets.all(32), child: Center(child: Text("Esta pasta está vazia.\nClique no (+) para criar uma ficha aqui.", textAlign: TextAlign.center, style: TextStyle(color: Colors.white54))))
                  : const SizedBox(),
              itemCount: filteredSheets.length,
              onReorder: (oldIndex, newIndex) {
                if (oldIndex < newIndex) newIndex -= 1;
                final movedSheet = filteredSheets[oldIndex];
                
                int globalOld = widget.characterSheets.indexOf(movedSheet);
                int globalNew;
                if (newIndex >= filteredSheets.length) {
                   final lastSheet = filteredSheets.last;
                   globalNew = widget.characterSheets.indexOf(lastSheet) + 1;
                } else {
                   final targetSheet = filteredSheets[newIndex];
                   globalNew = widget.characterSheets.indexOf(targetSheet);
                }
                widget.onReorderSheets(globalOld, globalNew);
              },
              itemBuilder: (context, index) {
                final sheet = filteredSheets[index];
                final effortColor = Color(sheet.effortColor);
                
                final bool isRequiem = sheet.systemType == 'Requiem';
                final Color borderColor = isRequiem ? Colors.deepPurpleAccent : Colors.amber.withOpacity(0.4);

                return ReorderableDelayedDragStartListener(
                  key: ValueKey(sheet.id),
                  index: index,
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.grey[850],
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: borderColor, width: 1.5),
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.5), blurRadius: 8, offset: const Offset(0, 4))],
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(16),
                        onTap: () => _navigateAndEditSheet(sheet), 
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    width: 60, height: 60,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(color: borderColor, width: 2),
                                      image: sheet.imagePath != null && File(sheet.imagePath!).existsSync()
                                          ? DecorationImage(image: FileImage(File(sheet.imagePath!)), fit: BoxFit.cover)
                                          : null,
                                    ),
                                    child: sheet.imagePath == null || !File(sheet.imagePath!).existsSync()
                                        ? const Icon(Icons.person, color: Colors.white54, size: 30)
                                        : null,
                                  ),
                                  const SizedBox(width: 16),
                                  
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          sheet.name, 
                                          style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                                          maxLines: 1, overflow: TextOverflow.ellipsis,
                                        ),
                                        Text(
                                          'Nível ${sheet.level ?? 1} • ${sheet.classe ?? 'Sem Classe'}${isRequiem ? " (Réquiem)" : ""}', 
                                          style: TextStyle(color: isRequiem ? Colors.deepPurpleAccent : Colors.amberAccent, fontSize: 12),
                                        ),
                                      ],
                                    ),
                                  ),

                                  PopupMenuButton<String>(
                                    icon: const Icon(Icons.more_vert, color: Colors.white),
                                    onSelected: (value) {
                                      if (value == 'delete') {
                                        _confirmDelete(sheet, strings, theme);
                                      } else if (value == 'export') _exportSheetOptions(sheet);
                                      else if (value == 'move') _moveSheetToFolder(sheet);
                                    },
                                    itemBuilder: (context) => [
                                      const PopupMenuItem(
                                        value: 'move',
                                        child: Row(children: [Icon(Icons.drive_file_move, color: Colors.greenAccent), SizedBox(width: 8), Text('Mover para Pasta')]),
                                      ),
                                      const PopupMenuItem(
                                        value: 'export',
                                        child: Row(children: [Icon(Icons.share, color: Colors.blueAccent), SizedBox(width: 8), Text('Exportar')]),
                                      ),
                                      const PopupMenuItem(
                                        value: 'delete', 
                                        child: Row(children: [Icon(Icons.delete, color: Colors.redAccent), SizedBox(width: 8), Text('Apagar', style: TextStyle(color: Colors.redAccent))]),
                                      ),
                                    ],
                                  ),
                                  const Icon(Icons.drag_handle, color: Colors.white30),
                                ],
                              ),
                              const SizedBox(height: 12),
                              
                              Container(
                                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                                decoration: BoxDecoration(color: Colors.black45, borderRadius: BorderRadius.circular(10)),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                                  children: [
                                    _buildMiniStat('VIDA', sheet.status['Vida']?['atual'], sheet.status['Vida']?['total'], Colors.redAccent),
                                    if (!isRequiem)
                                      _buildMiniStat('ESFORÇO', sheet.status['Esforço']?['atual'], sheet.status['Esforço']?['total'], effortColor),
                                    if (!isRequiem)
                                      _buildMiniStat('SANIDADE', sheet.status['Sanidade']?['atual'], sheet.status['Sanidade']?['total'], Colors.grey),
                                    
                                    if (isRequiem)
                                      _buildMiniStat('MANA/VIGOR', sheet.status['Mana/Vigor']?['atual'], sheet.status['Mana/Vigor']?['total'], Colors.blueAccent),
                                  ],
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showFabMenu,
        backgroundColor: Colors.amber[700],
        child: const Icon(Icons.add, color: Colors.black, size: 28),
      ),
    );
  }
}