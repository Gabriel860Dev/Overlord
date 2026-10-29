// lib/screens/roll_history_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Adicionado para a vibração
import 'package:overlord/localization.dart';
// IMPORTS DO MURAL DE TROFÉUS:
import '../models/saved_roll.dart';
import '../data/saved_rolls_manager.dart';

class RollHistoryScreen extends StatelessWidget {
  final List<String> rollHistory;
  
  final VoidCallback onClearHistory;
  final VoidCallback onAddNewDie;
  final VoidCallback onHelp;
  final VoidCallback onAbout;
  final VoidCallback onRateApp;

  const RollHistoryScreen({
    super.key,
    required this.rollHistory,
    required this.onClearHistory,
    required this.onAddNewDie,
    required this.onHelp,
    required this.onAbout,
    required this.onRateApp,
  });

  // --- NOVA FUNÇÃO: Janela para Salvar Rolagem ---
  void _showSaveRollDialog(BuildContext context, String rollName, int total, String details) {
    final nameController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: const Text("Eternizar Rolagem", style: TextStyle(color: Colors.amber)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("Dê um nome épico para esta rolagem:", style: TextStyle(color: Colors.white70)),
            const SizedBox(height: 12),
            TextField(
              controller: nameController,
              style: const TextStyle(color: Colors.white),
              autofocus: true,
              decoration: const InputDecoration(
                hintText: "Ex: Crítico no Chefe Final",
                hintStyle: TextStyle(color: Colors.white30),
                enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.amber)),
                focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.amberAccent)),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancelar", style: TextStyle(color: Colors.grey))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.amber[700]),
            onPressed: () async {
              if (nameController.text.trim().isEmpty) return;

              final newSavedRoll = SavedRoll(
                customName: nameController.text.trim(),
                rollName: rollName,
                total: total,
                details: details,
                timestamp: DateTime.now(), // Pega o momento EXATO
              );

              await SavedRollsManager.saveRoll(newSavedRoll);
              if (ctx.mounted) Navigator.pop(ctx);
              
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Rolagem eternizada no Mural de Troféus! 🏆', style: TextStyle(fontWeight: FontWeight.bold)),
                    backgroundColor: Colors.amber,
                  ),
                );
              }
            },
            child: const Text("Salvar", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const double squareSize = 80.0;
    final theme = Theme.of(context);
    final strings = AppStrings.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      floatingActionButton: rollHistory.isNotEmpty 
          ? FloatingActionButton(
              onPressed: () {
                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (context) => MemeClearHistoryDialog(
                    onConfirmClear: onClearHistory,
                  ),
                );
              },
              backgroundColor: Colors.red[900],
              child: const Icon(Icons.delete_sweep, color: Colors.white),
            )
          : null,
      body: rollHistory.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.history, size: 64, color: theme.disabledColor),
                  const SizedBox(height: 16),
                  Text(
                    strings.get('history_empty'),
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyLarge?.copyWith(color: theme.disabledColor),
                  ),
                ],
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.fromLTRB(0, 8, 0, 80),
              itemCount: rollHistory.length,
              separatorBuilder: (context, index) => Divider(
                color: theme.dividerColor.withOpacity(0.1),
                thickness: 1,
                height: 1,
              ),
              itemBuilder: (context, index) {
                final historyItem = rollHistory[rollHistory.length - 1 - index];
                
                String time = "";
                String content = historyItem;
                
                if (content.contains(" - ")) {
                  final splitIndex = content.indexOf(" - ");
                  time = content.substring(0, splitIndex);
                  content = content.substring(splitIndex + 3);
                }

                List<String> parts = content.split(' | ');
                String mainPart = parts.isNotEmpty ? parts[0] : "???";
                List<String> details = parts.length > 1 ? parts.sublist(1) : [];

                String resultValue = "?";
                String title = mainPart;

                if (mainPart.contains(' = ')) {
                  final eqParts = mainPart.split(' = ');
                  title = eqParts.first.trim();
                  resultValue = eqParts.last.trim();
                }

                return GestureDetector(
                  onLongPress: () {
                    HapticFeedback.vibrate(); // Dá um leve tremor no celular
                    int total = int.tryParse(resultValue) ?? 0;
                    String detailsString = details.join(' | ');
                    _showSaveRollDialog(context, title, total, detailsString);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                    color: index % 2 == 0 ? theme.cardColor.withOpacity(0.3) : Colors.transparent,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: squareSize,
                          height: squareSize,
                          decoration: BoxDecoration(
                            color: theme.cardColor,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: theme.dividerColor.withOpacity(0.2)),
                            boxShadow: [
                               BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 4, offset: const Offset(2, 2))
                            ]
                          ),
                          alignment: Alignment.center,
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Padding(
                              padding: const EdgeInsets.all(4.0),
                              child: Text(
                                resultValue,
                                style: TextStyle(
                                  fontSize: 28, 
                                  color: _getResultColor(resultValue, theme), 
                                  fontWeight: FontWeight.w900
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      title,
                                      style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  Text(
                                    time,
                                    style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              if (details.isNotEmpty)
                                ...details.map((detail) {
                                  bool isTrigger = detail.toUpperCase().contains("ATIVADO") || 
                                                   detail.toUpperCase().contains("SUCESSO") ||
                                                   detail.toUpperCase().contains("FALHA") ||
                                                   detail.toUpperCase().contains("KOKUSEN");
                                  
                                  Color detailColor = theme.textTheme.bodySmall?.color?.withOpacity(0.8) ?? Colors.grey;
                                  
                                  if (isTrigger) {
                                    if (detail.toUpperCase().contains("ATIVADO") || detail.toUpperCase().contains("SUCESSO")) {
                                      detailColor = Colors.amber;
                                    } else {
                                      detailColor = Colors.redAccent;
                                    }
                                  }

                                  return Padding(
                                    padding: const EdgeInsets.only(bottom: 2),
                                    child: Text(
                                      detail.trim(),
                                      style: theme.textTheme.bodySmall?.copyWith(
                                        color: detailColor,
                                        fontStyle: isTrigger ? FontStyle.italic : FontStyle.normal,
                                        fontWeight: isTrigger ? FontWeight.bold : FontWeight.normal
                                      ),
                                    ),
                                  );
                                }),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }

  Color _getResultColor(String result, ThemeData theme) {
    int? val = int.tryParse(result);
    if (val != null) {
      if (val == 20) return Colors.greenAccent;
      if (val == 1) return Colors.redAccent;
    }
    return theme.colorScheme.primary;
  }
}

// --- WIDGET DO MEME ATUALIZADO (USANDO ASSETS) ---

class MemeClearHistoryDialog extends StatefulWidget {
  final VoidCallback onConfirmClear;

  const MemeClearHistoryDialog({super.key, required this.onConfirmClear});

  @override
  State<MemeClearHistoryDialog> createState() => _MemeClearHistoryDialogState();
}

class _MemeClearHistoryDialogState extends State<MemeClearHistoryDialog> {
  int _stage = 0; 

  final String pathMeme1 = "assets/icons/meme_Historico_1.png";
  final String pathMeme2 = "assets/icons/meme_historico_2.png";
  final String pathMeme3 = "assets/icons/meme_Historico_3.png";
  final String pathMeme4 = "assets/icons/meme_Historico_4.png";

  Widget _buildMemeImage(String path) {
    return Container(
      constraints: const BoxConstraints(maxHeight: 250),
      child: Image.asset(
        path,
        fit: BoxFit.contain,
        errorBuilder: (c, o, s) => const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.broken_image, size: 50, color: Colors.grey),
            Text("Imagem não encontrada (verifique assets/icons/)", style: TextStyle(fontSize: 10, color: Colors.grey)),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.grey[900],
      title: _stage == 0 ? const Text("Tem Certeza?", style: TextStyle(color: Colors.white)) : null,
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (_stage == 1) ...[
              _buildMemeImage(pathMeme1),
              const SizedBox(height: 10),
              const Text("Entendi então voce apertou errado e não quer apagar o histórico não é? afinal para que apagar ele?", style: TextStyle(color: Colors.white)),
            ],
            if (_stage == 2) ...[
              _buildMemeImage(pathMeme2),
              const SizedBox(height: 10),
              RichText(
                text: const TextSpan(
                  style: TextStyle(color: Colors.white, fontSize: 16),
                  children: [
                    TextSpan(text: "VOCÊ ACHOU QUE IRIA APAGAR O HISTÓRICO, MAS ERA EU, "),
                    TextSpan(text: "DIOOOOOOOOOOOO", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.yellowAccent)),
                  ],
                ),
              ),
            ],
            if (_stage == 3) ...[
              _buildMemeImage(pathMeme3),
              const SizedBox(height: 10),
              const Text("MAS EU SOU DIOOOOOOOOOO", style: TextStyle(color: Colors.yellowAccent, fontWeight: FontWeight.bold, fontSize: 18)),
            ],
            if (_stage == 4) ...[
              _buildMemeImage(pathMeme4),
              const SizedBox(height: 10),
              const Text("Você é um bom Homem", style: TextStyle(color: Colors.white, fontSize: 16)),
            ],
          ],
        ),
      ),
      actions: _buildActions(),
    );
  }

  List<Widget> _buildActions() {
    switch (_stage) {
      case 0:
        return [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Não")),
          TextButton(onPressed: () => setState(() => _stage = 1), child: const Text("Sim", style: TextStyle(color: Colors.red))),
        ];
      case 1:
        return [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Não")),
          TextButton(onPressed: () => setState(() => _stage = 2), child: const Text("Apagar", style: TextStyle(color: Colors.red))),
        ];
      case 2:
        return [
          TextButton(onPressed: () => setState(() => _stage = 4), child: const Text("Cancelar")),
          TextButton(onPressed: () => setState(() => _stage = 3), child: const Text("Matar", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold))),
        ];
      case 3:
        return [
          TextButton(onPressed: () => setState(() => _stage = 4), child: const Text("Cancelar")),
          TextButton(onPressed: () {
            widget.onConfirmClear(); 
            Navigator.pop(context);
          }, child: const Text("Apagar", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 16))),
        ];
      case 4:
        return [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Fechar", style: TextStyle(color: Colors.green))),
        ];
      default:
        return [];
    }
  }
}