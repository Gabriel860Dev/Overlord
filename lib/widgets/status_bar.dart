// lib/widgets/status_bar.dart

import 'package:flutter/material.dart';

class StatusBar extends StatefulWidget {
  final String label;
  final double currentValue;
  final double totalValue;
  final Color barColor;
  final VoidCallback? onPercentageTap;

  const StatusBar({
    super.key,
    required this.label,
    required this.currentValue,
    required this.totalValue,
    required this.barColor,
    this.onPercentageTap,
  });

  @override
  State<StatusBar> createState() => _StatusBarState();
}

class _StatusBarState extends State<StatusBar> with SingleTickerProviderStateMixin {
  late AnimationController _blinkController;
  late Animation<Color?> _blinkAnimation;

  @override
  void initState() {
    super.initState();
    // Configura a velocidade da piscada quando a vida estiver crítica
    _blinkController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    )..repeat(reverse: true);

    _blinkAnimation = ColorTween(
      begin: Colors.redAccent,
      end: Colors.red[900],
    ).animate(_blinkController);
  }

  @override
  void dispose() {
    _blinkController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double percentage = (widget.totalValue > 0) ? (widget.currentValue / widget.totalValue).clamp(0.0, 1.0) : 0.0;
    
    Color? currentBarColor = widget.barColor;
    bool hideNumbers = false;

    // Converte a label para minúsculas para segurança (suporte a PT e EN)
    final labelLower = widget.label.toLowerCase();
    final isVida = labelLower.contains('vida') || labelLower.contains('life') || labelLower.contains('hp');
    final isEsforco = labelLower.contains('esforço') || labelLower.contains('esforco') || labelLower.contains('effort');
    final isSanidade = labelLower.contains('sanidade') || labelLower.contains('sanity');
    final isLoucura = labelLower.contains('loucura') || labelLower.contains('madness');

    // 1. LÓGICA DA VIDA (Escurece, e abaixo de 5% começa a piscar Neon)
    if (isVida) {
      if (percentage <= 0.05) {
        return AnimatedBuilder(
          animation: _blinkAnimation,
          builder: (context, child) {
            return _buildBar(percentage, _blinkAnimation.value ?? Colors.red, hideNumbers, isNeon: true);
          }
        );
      } else {
        currentBarColor = Color.lerp(Colors.red[900], Colors.redAccent, percentage);
      }
    } 
    // 2. LÓGICA DO ESFORÇO (Apaga/Escurece até o negro conforme é gasto)
    else if (isEsforco) {
      currentBarColor = Color.lerp(Colors.black, widget.barColor, percentage);
    } 
    // 3. LÓGICA DA SANIDADE (Começa Branca e vai ficando cinza)
    else if (isSanidade) {
      currentBarColor = Color.lerp(Colors.grey[800], Colors.white, percentage);
    } 
    // 4. LÓGICA DA LOUCURA (Em "Escadinhas" de 10% e esconde os números no ápice)
    else if (isLoucura) {
      int step = (percentage * 10).floor(); // Cria os degraus de 10%
      double stepPercentage = step / 10.0;
      currentBarColor = Color.lerp(Colors.white, Colors.black, stepPercentage);
      
      if (percentage >= 0.9) {
         currentBarColor = Colors.black87; // Quase totalmente negro
      }
      if (percentage >= 1.0) {
         currentBarColor = Colors.black; // Preto absoluto
         hideNumbers = true;             // Esconde os números
      }
    }

    return _buildBar(percentage, currentBarColor ?? widget.barColor, hideNumbers);
  }

  Widget _buildBar(double percentage, Color color, bool hideNumbers, {bool isNeon = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4.0, bottom: 4.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              hideNumbers 
                ? const Text('', style: TextStyle(color: Colors.transparent))
                : Text(
                    '${widget.label}: ${widget.currentValue.toStringAsFixed(0)} / ${widget.totalValue.toStringAsFixed(0)}',
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                  ),
              hideNumbers
                ? const Text('', style: TextStyle(color: Colors.transparent))
                : GestureDetector(
                    onTap: widget.onPercentageTap,
                    child: Text(
                      '(${((percentage) * 100).toStringAsFixed(1)}%)',
                      style: const TextStyle(color: Colors.blueAccent, fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                  ),
            ],
          ),
        ),
        Container(
          height: 12,
          decoration: BoxDecoration(
            color: Colors.grey[900], // Fundo escuro para contrastar o brilho
            borderRadius: BorderRadius.circular(6),
            border: hideNumbers ? Border.all(color: Colors.grey[900]!, width: 1) : null,
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: Align(
              alignment: Alignment.centerLeft,
              child: FractionallySizedBox(
                widthFactor: percentage,
                child: Container(
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(6),
                    boxShadow: hideNumbers ? [] : [
                      // O brilho Neon ativo se a vida estiver piscando ou nas outras barras
                      BoxShadow(color: color.withOpacity(isNeon ? 0.9 : 0.4), blurRadius: isNeon ? 10 : 4)
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}