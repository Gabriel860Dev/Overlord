// lib/screens/dice_roller_screen.dart

import 'package:flutter/material.dart';
import 'package:dark_age/widgets/custom_app_bar.dart';
import 'package:dark_age/widgets/global_menu.dart';

class DiceRollerScreen extends StatefulWidget {
  final void Function({required int sides, int quantity, int modifier}) onRoll;
  final VoidCallback onClearHistory;
  final VoidCallback onAddNewDie;
  final VoidCallback onHelp;
  final VoidCallback onAbout;
  final VoidCallback onRateApp;
  final List<int> customDice;
  final Function(int) onDeleteCustomDie;

  const DiceRollerScreen({
    super.key,
    required this.onRoll,
    required this.onClearHistory,
    required this.onAddNewDie,
    required this.onHelp,
    required this.onAbout,
    required this.onRateApp,
    required this.customDice,
    required this.onDeleteCustomDie,
  });

  @override
  State<DiceRollerScreen> createState() => _DiceRollerScreenState();
}

class _DiceRollerScreenState extends State<DiceRollerScreen> {
  int _quantity = 1;
  int _bonus = 0;

  final List<int> _baseDiceOptions = const [4, 6, 8, 10, 12, 20, 100];

  final TextEditingController _quantityController = TextEditingController(text: '1');
  final TextEditingController _bonusController = TextEditingController(text: '0');

  @override
  void initState() {
    super.initState();
    _quantityController.addListener(() {
      final newQuantity = int.tryParse(_quantityController.text) ?? 1;
      if (newQuantity > 0) {
        setState(() => _quantity = newQuantity);
      }
    });
    _bonusController.addListener(() {
      final newBonus = int.tryParse(_bonusController.text) ?? 0;
      setState(() => _bonus = newBonus);
    });
  }

  @override
  void dispose() {
    _quantityController.dispose();
    _bonusController.dispose();
    super.dispose();
  }

  void _confirmDeleteDie(int sides) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Apagar Dado d$sides?'),
        content: const Text('Tem certeza que deseja apagar este dado personalizado?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              widget.onDeleteCustomDie(sides);
              Navigator.of(context).pop();
            },
            child: const Text('Apagar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final allDice = [..._baseDiceOptions, ...widget.customDice]..sort();
    final uniqueDice = allDice.toSet().toList();

    return Scaffold(
      backgroundColor: Colors.grey[850],
      appBar: CustomAppBar(
        title: 'Overlord',
        subtitle: 'Toque no dado e boa sorte!',
        actions: [
          GlobalMenu(
            onClearHistory: widget.onClearHistory,
            onAddNewDie: widget.onAddNewDie,
            onHelp: widget.onHelp,
            onAbout: widget.onAbout,
            onRateApp: widget.onRateApp,
          ),
        ],
      ),
      body: Center(
        child: GridView.builder(
          padding: const EdgeInsets.all(16),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
          ),
          itemCount: uniqueDice.length,
          itemBuilder: (context, index) {
            final sides = uniqueDice[index];
            final isCustom = !_baseDiceOptions.contains(sides);
            return GestureDetector(
              onLongPress: isCustom ? () => _confirmDeleteDie(sides) : null,
              child: DiceIconButton(
                sides: sides,
                quantity: _quantity,
                modifier: _bonus,
                onRoll: widget.onRoll,
              ),
            );
          },
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(8.0),
        child: SizedBox(
          height: 56,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Expanded(
                child: _buildControlPanel(
                  label: "QTD",
                  controller: _quantityController,
                  onDecrement: () {
                    if (_quantity > 1) _quantityController.text = (_quantity - 1).toString();
                  },
                  onIncrement: () {
                     _quantityController.text = (_quantity + 1).toString();
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildControlPanel(
                  label: "MOD",
                  controller: _bonusController,
                  onDecrement: () => _bonusController.text = (_bonus - 1).toString(),
                  onIncrement: () => _bonusController.text = (_bonus + 1).toString(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildControlPanel({
    required String label,
    required TextEditingController controller,
    required VoidCallback onIncrement,
    required VoidCallback onDecrement,
  }) {
    return Container(
      height: 56,
      decoration: BoxDecoration(color: Colors.grey[900], borderRadius: BorderRadius.circular(8)),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        children: [
          SizedBox(width: 48, child: IconButton(onPressed: onDecrement, icon: const Icon(Icons.remove, color: Colors.white))),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(label, style: const TextStyle(color: Colors.white70, fontSize: 12)),
                TextField(
                  controller: controller,
                  textAlign: TextAlign.center,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(border: InputBorder.none, isDense: true, contentPadding: EdgeInsets.zero),
                  style: const TextStyle(fontSize: 24, color: Colors.white),
                ),
              ],
            ),
          ),
          SizedBox(width: 48, child: IconButton(onPressed: onIncrement, icon: const Icon(Icons.add, color: Colors.white))),
        ],
      ),
    );
  }
}

class DiceIconButton extends StatelessWidget {
  final int sides;
  final int quantity;
  final int modifier;
  final void Function({required int sides, required int quantity, required int modifier}) onRoll;

  const DiceIconButton({
    super.key,
    required this.sides,
    required this.quantity,
    required this.modifier,
    required this.onRoll,
  });

  String _getDiceIconPath(int sides) {
    switch (sides) {
      case 4: return 'assets/dice-2/d4.png';
      case 6: return 'assets/dice-2/d6.png';
      case 8: return 'assets/dice-2/d8.png';
      case 10: return 'assets/dice-2/d10.png';
      case 12: return 'assets/dice-2/d12.png';
      case 20: return 'assets/dice-2/d20.png';
      case 100: return 'assets/dice-2/d100.png';
      default: return 'assets/dice-2/dcustom.png';
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.zero,
      onTap: () => onRoll(sides: sides, quantity: quantity, modifier: modifier),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(child: Image.asset(_getDiceIconPath(sides), fit: BoxFit.contain)),
          const SizedBox(height: 4),
          Text('d$sides', style: const TextStyle(color: Colors.white, fontSize: 12)),
        ],
      ),
    );
  }
}