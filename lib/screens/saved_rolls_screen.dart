// lib/screens/saved_rolls_screen.dart
import 'package:flutter/material.dart';
import '../models/saved_roll.dart';
import '../data/saved_rolls_manager.dart';

class SavedRollsScreen extends StatefulWidget {
  const SavedRollsScreen({super.key});

  @override
  State<SavedRollsScreen> createState() => _SavedRollsScreenState();
}

class _SavedRollsScreenState extends State<SavedRollsScreen> {
  List<SavedRoll> _savedRolls = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadRolls();
  }

  Future<void> _loadRolls() async {
    final rolls = await SavedRollsManager.loadSavedRolls();
    // Ordenar das mais recentes para as mais antigas
    rolls.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    setState(() {
      _savedRolls = rolls;
      _isLoading = false;
    });
  }

  String _formatDate(DateTime dt) {
    String pad(int n) => n.toString().padLeft(2, '0');
    return "${pad(dt.day)}/${pad(dt.month)}/${dt.year} às ${pad(dt.hour)}:${pad(dt.minute)}:${pad(dt.second)}";
  }

  // --- NOVO: Janela para Editar Nome ---
  void _showEditNameDialog(SavedRoll roll) {
    final controller = TextEditingController(text: roll.customName);
    
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: const Text("Editar Nome do Troféu", style: TextStyle(color: Colors.amber)),
        content: TextField(
          controller: controller,
          style: const TextStyle(color: Colors.white),
          autofocus: true,
          decoration: const InputDecoration(
            labelText: "Novo Nome",
            labelStyle: TextStyle(color: Colors.white70),
            enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.amber)),
            focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.amberAccent)),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancelar", style: TextStyle(color: Colors.grey))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.amber[700]),
            onPressed: () async {
              if (controller.text.trim().isNotEmpty) {
                roll.customName = controller.text.trim();
                await SavedRollsManager.updateRoll(roll); // Salva a alteração
                if (ctx.mounted) Navigator.pop(ctx);
                _loadRolls(); // Atualiza a tela
              }
            },
            child: const Text("Salvar", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  // --- NOVO: Janela de Confirmação de Exclusão ---
  void _showDeleteConfirmationDialog(SavedRoll roll) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: const Text("Tem certeza?", style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
        content: Text("Deseja apagar o troféu '${roll.customName}' para sempre?", style: const TextStyle(color: Colors.white)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancelar", style: TextStyle(color: Colors.grey))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red[900]),
            onPressed: () async {
              await SavedRollsManager.deleteRoll(roll.id);
              if (ctx.mounted) Navigator.pop(ctx);
              _loadRolls(); // Atualiza a tela após apagar
            },
            child: const Text("Sim, Apagar", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[900],
      appBar: AppBar(
        title: const Text("Mural de Troféus 🏆", style: TextStyle(color: Colors.amber)),
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.amber),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.amber))
          : _savedRolls.isEmpty
              ? const Center(
                  child: Text("Nenhuma rolagem eternizada ainda.\nSegure numa rolagem do histórico para salvar!", 
                  textAlign: TextAlign.center, style: TextStyle(color: Colors.white54, fontSize: 16)),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: _savedRolls.length,
                  itemBuilder: (context, index) {
                    final roll = _savedRolls[index];
                    return Card(
                      color: Colors.grey[850],
                      margin: const EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(
                        side: BorderSide(color: Colors.amber.withOpacity(0.5), width: 1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(16),
                        title: Text(
                          roll.customName, 
                          style: const TextStyle(color: Colors.amber, fontSize: 18, fontWeight: FontWeight.bold)
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 8),
                            Text("Ação: ${roll.rollName}", style: const TextStyle(color: Colors.white70)),
                            Text("Cálculo: ${roll.details}", style: const TextStyle(color: Colors.grey)),
                            const SizedBox(height: 8),
                            Text(
                              _formatDate(roll.timestamp), 
                              style: const TextStyle(color: Colors.white30, fontSize: 12, fontStyle: FontStyle.italic)
                            ),
                          ],
                        ),
                        // --- BOTÕES ATUALIZADOS AQUI ---
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              roll.total.toString(),
                              style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(width: 12),
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.blueAccent),
                              tooltip: "Editar Nome",
                              onPressed: () => _showEditNameDialog(roll),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                              tooltip: "Apagar",
                              onPressed: () => _showDeleteConfirmationDialog(roll),
                            )
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}