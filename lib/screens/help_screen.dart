// lib/screens/help_screen.dart

import 'package:flutter/material.dart';
import 'package:overlord/localization.dart';
import 'package:overlord/models/elemental_data.dart'; // Importa o sistema elemental

class HelpScreen extends StatelessWidget {
  const HelpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final strings = AppStrings.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(strings.get('help'), style: theme.appBarTheme.titleTextStyle),
        backgroundColor: theme.appBarTheme.backgroundColor,
        iconTheme: theme.appBarTheme.iconTheme,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _HelpSection(
            title: 'Grimório Elemental (Hierarquia)',
            content: [
              const Padding(
                padding: EdgeInsets.all(8.0),
                child: Text(
                  'REGRAS GERAIS:\n'
                  '• AURA (Tier 0): Ignora defesa (Soberano), Dano Normal.\n'
                  '• FÍSICO (Tier 1): Vantagem sobre todos (+30%), Resistência Absoluta.\n'
                  '• VANTAGEM: Dano +30%.\n'
                  '• DESVANTAGEM: Dano recebido reduzido em 30%.',
                  style: TextStyle(color: Colors.white70),
                ),
              ),
              // Geramos os itens automaticamente baseados nos dados
              ...ElementalSystem.data.values.map((element) => _ElementalHelpItem(element: element)),
            ],
          ),
          
          // --- NOVA SEÇÃO: GUIA DE CRIAÇÃO INTELIGENTE ---
          const _HelpSection(
            title: 'Guia de Criação Inteligente (Auto)',
            content: [
              Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  'O aplicativo possui um Motor Inteligente de Leitura! Ao criar Habilidades, Passivas, Armas ou Armaduras, você pode usar a aba "Auto" e colar o texto da mecânica diretamente. O motor lerá as seguintes palavras-chave:',
                  style: TextStyle(color: Colors.amber, fontSize: 14),
                ),
              ),
              _HelpItem(title: 'Custos e Recarga', description: '• Ex: "Custa 20 de Esforço", "Gasta 5 de Sanidade", "Cooldown: 3"'),
              _HelpItem(title: 'Dano e Cura', description: '• Ex: "Causa 2d10 de Fogo", "Recupera Vida equivalente a 10% do Teste de Vontade"'),
              _HelpItem(title: 'Buffs (Bônus)', description: '• Ex: "Concede +30 em Percepção", "ganha +5 de FOR"'),
              _HelpItem(title: 'Debuffs (Penalidades)', description: '• Ex: "sofre -50 em Destreza e Reflexo"'),
              _HelpItem(title: 'Multiplicadores', description: '• Ex: "Dobro do dano", "Crítico: x3"'),
              _HelpItem(title: 'Armas e Ataques', description: '• Ex: "+5 de Acerto", "+10 de Dano", "Ataca com Esgrima"'),
              _HelpItem(title: 'Armaduras e Defesa', description: '• Ex: "Redução de 5", "Máximo de 15 Hits"'),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Text(
                  'Dica: Tente escrever de forma clara, como nos exemplos acima, para que o sistema consiga extrair os dados e montar a sua ficha perfeitamente.',
                  style: TextStyle(color: Colors.white70, fontStyle: FontStyle.italic, fontSize: 12),
                ),
              ),
            ],
          ),
          // ------------------------------------------------

          _HelpSection(
            title: strings.get('help_guide_title'),
            content: [
              _HelpItem(title: strings.get('help_table_title'), description: strings.get('help_table_desc')),
              _HelpItem(title: strings.get('help_custom_die_title'), description: strings.get('help_custom_die_desc')),
              _HelpItem(title: strings.get('help_sheets_title'), description: strings.get('help_sheets_desc')),
              _HelpItem(title: strings.get('help_history_title'), description: strings.get('help_history_desc')),
            ],
          ),
          _HelpSection(
            title: strings.get('help_actions_title'),
            content: [
              _HelpItem(title: strings.get('help_action_move_title'), description: strings.get('help_action_move_desc')),
              _HelpItem(title: strings.get('help_action_attack_title'), description: strings.get('help_action_attack_desc')),
              _HelpItem(title: strings.get('help_action_free_title'), description: strings.get('help_action_free_desc')),
              _HelpItem(title: strings.get('help_action_skill_title'), description: strings.get('help_action_skill_desc')),
              _HelpItem(title: strings.get('help_action_passive_title'), description: strings.get('help_action_passive_desc')),
              _HelpItem(title: strings.get('help_action_reaction_title'), description: strings.get('help_action_reaction_desc')),
              _HelpItem(title: strings.get('help_action_joint_title'), description: strings.get('help_action_joint_desc')),
            ],
          ),
          _HelpSection(
            title: strings.get('help_fatigue_title'),
            content: [
              _HelpItem(title: strings.get('fatigue'), description: strings.get('help_fatigue_desc')),
            ],
          ),
          _HelpSection(
            title: strings.get('help_parry_title'),
            content: [
              _HelpItem(title: strings.get('parry'), description: strings.get('help_parry_desc')),
              _HelpItem(title: strings.get('help_parry_mech_title'), description: strings.get('help_parry_mech_desc')),
              _HelpItem(title: strings.get('help_parry_c_title'), description: strings.get('help_parry_c_desc')),
              _HelpItem(title: strings.get('help_parry_a_title'), description: strings.get('help_parry_a_desc')),
              _HelpItem(title: strings.get('help_parry_s_title'), description: strings.get('help_parry_s_desc')),
              _HelpItem(title: strings.get('help_parry_g_title'), description: strings.get('help_parry_g_desc')),
            ],
          ),
          _HelpSection(
            title: strings.get('help_other_title'),
            content: [
               _HelpItem(title: strings.get('help_fallen_title'), description: strings.get('help_fallen_desc')),
               _HelpItem(title: strings.get('help_dmg_type_title'), description: strings.get('help_dmg_type_desc')),
               _HelpItem(title: strings.get('help_confirm_title'), description: strings.get('help_confirm_desc')),
            ],
          ),
        ],
      ),
    );
  }
}

// Widget específico para mostrar os Elementos com cor
class _ElementalHelpItem extends StatelessWidget {
  final ElementalInfo element;

  const _ElementalHelpItem({required this.element});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.grey[850], // Fundo escuro para contraste com as cores dos elementos
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.circle, color: element.color, size: 16),
                const SizedBox(width: 8),
                Text(
                  '${element.name} (Tier ${element.tier})',
                  style: TextStyle(color: element.color, fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text('Vantagem: ${element.advantages.join(", ")}', style: const TextStyle(color: Colors.greenAccent, fontSize: 12)),
            Text('Desvantagem: ${element.disadvantages.join(", ")}', style: const TextStyle(color: Colors.redAccent, fontSize: 12)),
            const SizedBox(height: 4),
            Text(element.narrativeLogic, style: const TextStyle(color: Colors.white70, fontStyle: FontStyle.italic, fontSize: 12)),
          ],
        ),
      ),
    );
  }
}

class _HelpSection extends StatelessWidget {
  final String title;
  final List<Widget> content;

  const _HelpSection({required this.title, required this.content});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      color: theme.cardColor,
      margin: const EdgeInsets.only(bottom: 16.0),
      child: ExpansionTile(
        title: Text(title, style: theme.textTheme.titleLarge?.copyWith(fontSize: 18)),
        iconColor: theme.colorScheme.secondary,
        collapsedIconColor: theme.unselectedWidgetColor,
        children: content,
      ),
    );
  }
}

class _HelpItem extends StatelessWidget {
  final String title;
  final String description;

  const _HelpItem({required this.title, required this.description});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(color: theme.colorScheme.primary, fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            description,
            style: TextStyle(color: theme.textTheme.bodyMedium?.color?.withOpacity(0.8), fontSize: 14),
          ),
        ],
      ),
    );
  }
}