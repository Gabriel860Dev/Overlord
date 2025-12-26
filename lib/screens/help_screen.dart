// lib/screens/help_screen.dart

import 'package:flutter/material.dart';

class HelpScreen extends StatelessWidget {
  const HelpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[850],
      appBar: AppBar(
        title: const Text('Guia Completo', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.grey[900],
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: const [
          _HelpSection(
            title: 'Tela Principal: Mesa de Dados',
            content: [
              _HelpItem(
                title: 'Rolando Dados',
                description: 'Toque em qualquer um dos dados na grelha para realizar uma rolagem simples.',
              ),
              _HelpItem(
                title: 'Quantidade (QTD) e Modificador (MOD)',
                description: 'Use os controlos na parte inferior do ecrã para rolar múltiplos dados de uma vez (QTD) ou para adicionar um valor fixo ao resultado final (MOD).',
              ),
              _HelpItem(
                title: 'Criar Dados Personalizados',
                description: 'No menu superior direito (ícone de três pontos), selecione "Adicionar novo dado". Insira o número de faces e o novo dado aparecerá na sua mesa.',
              ),
              _HelpItem(
                title: 'Apagar Dados Personalizados',
                description: 'Para apagar um dado que você criou, simplesmente toque e segure (toque longo) sobre o ícone do dado na mesa. Uma confirmação será solicitada.',
              ),
            ],
          ),
          _HelpSection(
            title: 'Histórico de Rolagens',
            content: [
              _HelpItem(
                title: 'Visualizando Rolagens',
                description: 'A aba "Histórico" mostra uma lista de todas as rolagens realizadas, da mais recente para a mais antiga. Cada entrada exibe o resultado total, o nome da rolagem e o horário.',
              ),
              _HelpItem(
                title: 'Detalhes da Rolagem',
                description: 'Cada item no histórico detalha os dados rolados, os resultados individuais de cada dado, os bónus aplicados por passivas/itens e quaisquer gatilhos que foram ativados durante a rolagem.',
              ),
            ],
          ),
          _HelpSection(
            title: 'Fichas de Personagem',
            content: [
              _HelpItem(
                title: 'Criar, Editar e Apagar',
                description: 'Na aba "Fichas", use o botão "+" para criar uma nova ficha. Toque numa ficha existente para a abrir e editar. Para apagar, deslize o dedo sobre a ficha ou use o ícone de lixo dentro da própria ficha.',
              ),
               _HelpItem(
                title: 'Layout da Ficha (Abas vs. Clássico)',
                description: 'No canto superior direito da ficha, o ícone de layout permite alternar entre a visão padrão com abas e a visão "Clássica", que exibe tudo numa única página com secções expansíveis.',
              ),
            ],
          ),
          _HelpSection(
            title: 'Guia da Ficha: Aba Geral',
            content: [
              _HelpItem(
                title: 'Informações Básicas',
                description: 'Edite o nome, classe, nível e imagem do seu personagem. Os botões de "+" e "-" ao lado do nível ajustam o nível e aplicam os ganhos configurados.',
              ),
              _HelpItem(
                title: 'Status e Atributos',
                description: 'Gestão dos seus pontos de Vida, Esforço, Sanidade, etc. Toque diretamente no nome de um Atributo ou Perícia para realizar uma rolagem, que já incluirá todos os bónus de passivas e itens equipados.',
              ),
            ],
          ),
          _HelpSection(
            title: 'Guia da Ficha: Aba Combate',
            content: [
               _HelpItem(
                title: 'Armas e Armaduras',
                description: 'Esta secção mostra as armas e armaduras atualmente equipadas e o seu estado (ex: durabilidade da armadura). Use a aba "Mochila" para equipar ou desequipar itens.',
              ),
              _HelpItem(
                title: 'Bloqueio',
                description: 'Define a contribuição (em %) dos seus atributos (CON, FOR, SAB) para a sua rolagem de bloqueio. Ao usar a ação de bloquear, o resultado da sua rolagem é subtraído do dano recebido.',
              ),
              _HelpItem(
                title: 'Ações de Combate',
                description: '• + Round: Avança um turno no combate, reduzindo a duração de efeitos e os cooldowns de habilidades/passivas.\n• Descansar: Recupera totalmente a Vida e o Esforço e zera a Fadiga.\n• Fim de Combate: Zera todos os contadores de cooldown e fadiga, desativa habilidades e restaura a durabilidade de armaduras temporárias.',
              ),
            ],
          ),
          _HelpSection(
            title: 'Guia da Ficha: Habilidades e Passivas',
            content: [
              _HelpItem(
                title: 'Habilidades (Ações Ativas)',
                description: 'São ações que você escolhe usar, como ataques, curas ou buffs. Elas podem ter um custo (Vida, Esforço) e um tempo de espera (cooldown).',
              ),
              _HelpItem(
                title: 'Sistema de Fadiga',
                description: 'Para desincentivar o uso repetitivo da mesma habilidade, cada uso dentro de um mesmo combate aumenta o seu custo (seja de Vida, Esforço, etc.). Este aumento é progressivo e é zerado com as ações "Fim de Combate" ou "Descansar".\n\n• 1º Uso: Custo normal\n• 2º Uso: Custo +30%\n• 3º Uso: Custo +60%\n• 4º Uso: Custo x2\n• E assim por diante...',
              ),
              _HelpItem(
                title: 'Passivas (Efeitos Automáticos)',
                description: 'São efeitos que acontecem automaticamente quando uma condição (gatilho) é cumprida. Exemplos de gatilhos:\n• Sempre Ativo: O bónus está sempre a funcionar.\n• Vida Perdida: Ativa sempre que perder uma certa quantidade de vida.\n• Dano Sofrido: Ativa com base no dano recebido em bloqueios/defesas.\n• Cooldown: Ativa-se sozinha após um número de turnos.',
              ),
            ],
          ),
           _HelpSection(
            title: 'Guia da Ficha: Mochila e Buffs',
            content: [
              _HelpItem(
                title: 'Mochila (Inventário)',
                description: 'Adicione e gira os seus Itens, Armas e Armaduras. Toque num item para o equipar/desequipar. Toque e segure para o arrastar e reordenar na lista.',
              ),
              _HelpItem(
                title: 'Buffs/Debuffs',
                description: 'Esta aba é um resumo de todos os efeitos atualmente ativos no seu personagem, sejam eles de itens equipados, habilidades ativas, passivas acumuladas ou efeitos manuais que você adicionou.',
              ),
            ],
          ),
          _HelpSection(
            title: 'Sistema de Parry (Resumo)',
            content: [
              _HelpItem(
                title: 'Conceito e Regras Gerais',
                description: 'Uma ação especial para cancelar e devolver o ataque de um oponente. A vitória na disputa é decidida pela quantidade de "críticos" (o valor máximo do dado de Parry), não pela soma.',
              ),
              _HelpItem(
                title: 'Evolução',
                description: 'O Parry evolui por vários estágios (Comum, Avançado, Super, God), mudando o tipo de dado (d4 -> d8 -> d12 -> d20) e as regras da disputa. Cada evolução requer o cumprimento de pré-requisitos e o sacrifício de pontos de atributo e perícia.',
              ),
            ],
          ),
        ],
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
    return Card(
      color: Colors.grey[900],
      margin: const EdgeInsets.only(bottom: 16.0),
      child: ExpansionTile(
        title: Text(title, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
        iconColor: Colors.white,
        collapsedIconColor: Colors.white,
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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(color: Colors.blueAccent, fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            description,
            style: const TextStyle(color: Colors.white70, fontSize: 14),
          ),
        ],
      ),
    );
  }
}
