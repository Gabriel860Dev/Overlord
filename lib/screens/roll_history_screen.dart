import 'package:flutter/material.dart';
import 'package:dark_age/widgets/custom_app_bar.dart';
import 'package:dark_age/widgets/global_menu.dart';

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

  @override
  Widget build(BuildContext context) {
    const double squareSize = 90.0;

    return Scaffold(
      backgroundColor: Colors.grey[850],
      appBar: CustomAppBar(
        title: 'Overlord',
        subtitle: 'Histórico de Rolagens',
        actions: [
          GlobalMenu(
            onClearHistory: onClearHistory,
            onAddNewDie: onAddNewDie,
            onHelp: onHelp,
            onAbout: onAbout,
            onRateApp: onRateApp,
          ),
        ],
      ),
      body: rollHistory.isEmpty
          ? const Center(
              child: Text(
                'O histórico está vazio.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18, color: Colors.white),
              ),
            )
          : ListView.separated(
              itemCount: rollHistory.length,
              separatorBuilder: (context, index) => const Divider(
                color: Colors.white,
                thickness: 0.2,
                height: 4,
              ),
              itemBuilder: (context, index) {
                final historyItem = rollHistory[rollHistory.length - 1 - index];
                // ATUALIZADO: Lógica de parsing para o novo formato do histórico
                final parts = historyItem.split(' - ');
                final timestamp = parts.isNotEmpty ? parts[0] : '';
                final details = parts.length > 1 ? parts.sublist(1).join(' - ') : '';

                String totalResult = '?';
                String rollName = 'Erro de Parsing';
                String rollDetails = '';
                String individualRolls = '';
                String bonusDetails = '';
                String triggerDetails = '';

                try {
                  if (details.isNotEmpty) {
                    final mainParts = details.split(' | ');
                    final resultAndDetails = mainParts.isNotEmpty ? mainParts[0] : '';

                    if (mainParts.length > 1) {
                      individualRolls = mainParts[1].trim();
                    }
                     if (mainParts.length > 2) {
                      bonusDetails = mainParts[2].trim();
                    }
                     if (mainParts.length > 3) {
                      triggerDetails = mainParts[3].trim();
                    }

                    if (resultAndDetails.isNotEmpty) {
                      final resultParts = resultAndDetails.split(' = ');
                      totalResult = resultParts.isNotEmpty ? resultParts.last.trim() : '?';
                      
                      if (resultParts.isNotEmpty) {
                        final nameAndDice = resultParts.first.split(':');
                        rollName = nameAndDice.isNotEmpty ? nameAndDice[0].trim() : 'Rolagem';
                        rollDetails = nameAndDice.length > 1 ? nameAndDice[1].trim() : '';
                      }
                    }
                  }
                } catch (e) {
                  debugPrint('Erro ao parsear item do histórico: $e');
                  // Os valores padrão já lidam com a UI em caso de erro.
                }

                return Padding(
                  padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: squareSize,
                        height: squareSize,
                        color: Colors.grey[900],
                        alignment: Alignment.center,
                        child: Text(
                          totalResult,
                          style: const TextStyle(fontSize: 25, color: Colors.white),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Text(
                                    rollName,
                                    style: const TextStyle(fontSize: 19, color: Colors.white, fontWeight: FontWeight.bold),
                                  ),
                                ),
                                Text(
                                  timestamp,
                                  style: const TextStyle(fontSize: 12, color: Colors.white),
                                ),
                              ],
                            ),
                            if (rollDetails.isNotEmpty)
                              Text(
                                rollDetails,
                                style: const TextStyle(fontSize: 16, color: Colors.grey),
                              ),
                            if (individualRolls.isNotEmpty) ...[
                              const SizedBox(height: 4),
                              ...individualRolls.split(';').map((roll) => 
                                Text(
                                  roll.trim(),
                                  style: const TextStyle(fontSize: 14, color: Colors.white70),
                                )
                              ),
                            ],
                             // ATUALIZADO: Exibir os bônus e gatilhos
                            if (bonusDetails.isNotEmpty) ...[
                              const SizedBox(height: 4),
                               Text(
                                bonusDetails,
                                style: const TextStyle(fontSize: 12, color: Colors.grey),
                              ),
                            ],
                             if (triggerDetails.isNotEmpty) ...[
                              const SizedBox(height: 4),
                               Text(
                                triggerDetails,
                                style: const TextStyle(fontSize: 12, color: Colors.amberAccent, fontStyle: FontStyle.italic),
                              ),
                            ]
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}