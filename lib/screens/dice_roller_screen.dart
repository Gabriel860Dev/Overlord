// lib/screens/dice_roller_screen.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart'; 
import 'package:audioplayers/audioplayers.dart'; 
import 'package:overlord/widgets/custom_app_bar.dart';
import 'package:overlord/widgets/global_menu.dart';
import 'package:overlord/localization.dart';
import 'package:overlord/models/custom_dice.dart';
import 'package:overlord/models/roll_result.dart';

class DiceRollerScreen extends StatefulWidget {
  final dynamic Function({required int sides, int quantity, int modifier}) onRoll;
  final VoidCallback onClearHistory;
  final VoidCallback onAddNewDie;
  final VoidCallback onHelp;
  final VoidCallback onAbout;
  final VoidCallback onRateApp;
  final VoidCallback onConnect;
  final VoidCallback onSettings;
  
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
    required this.onConnect,
    required this.onSettings,
    required this.customDice,
    required this.onDeleteCustomDie,
  });

  @override
  State<DiceRollerScreen> createState() => _DiceRollerScreenState();
}

class _DiceRollerScreenState extends State<DiceRollerScreen> {
  int _quantity = 1;
  int _bonus = 0;
  Map<int, DiceConfig> _diceConfigs = {}; 

  final List<int> _baseDiceOptions = const [4, 6, 8, 10, 12, 16, 20, 100];
  final TextEditingController _quantityController = TextEditingController(text: '1');
  final TextEditingController _bonusController = TextEditingController(text: '0');
  
  final AudioPlayer _audioPlayer = AudioPlayer();

  @override
  void initState() {
    super.initState();
    _loadConfigs();
    _quantityController.addListener(() {
      final newQuantity = int.tryParse(_quantityController.text) ?? 1;
      if (newQuantity > 0) setState(() => _quantity = newQuantity);
    });
    _bonusController.addListener(() {
      setState(() => _bonus = int.tryParse(_bonusController.text) ?? 0);
    });
  }

  Future<void> _loadConfigs() async {
    final configs = await DiceConfigManager.loadConfigs();
    setState(() {
      _diceConfigs = configs;
    });
  }

  @override
  void dispose() {
    _quantityController.dispose();
    _bonusController.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  void _handleRoll({required int sides, required int quantity, required int modifier}) async {
    final result = widget.onRoll(sides: sides, quantity: quantity, modifier: modifier);
    
    if (quantity == 1 && result != null && result is RollResult) {
      int faceValue = result.individualRolls.first.individualResults!.first;
      
      // CRÍTICO!
      if (faceValue == sides) {
        final config = _diceConfigs[sides];
        if (config != null) {
          if (config.critImagePath != null && File(config.critImagePath!).existsSync()) {
            _showCritOverlay(config.critImagePath!);
          }
          if (config.critAudioPath != null && File(config.critAudioPath!).existsSync()) {
            await _audioPlayer.stop();
            await _audioPlayer.play(DeviceFileSource(config.critAudioPath!));
          }
        }
      }
    }
  }

  // A função que desenha o GIF na tela (estava faltando!)
  void _showCritOverlay(String imagePath) {
    final overlay = Overlay.of(context);
    late OverlayEntry entry;
    
    entry = OverlayEntry(
      builder: (context) => Positioned.fill(
        child: IgnorePointer(
          child: Container(
            color: Colors.black.withOpacity(0.6), 
            alignment: Alignment.center,
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.5, end: 1.0),
              duration: const Duration(milliseconds: 300),
              curve: Curves.elasticOut,
              builder: (context, scale, child) {
                return Transform.scale(
                  scale: scale,
                  child: Image.file(File(imagePath), width: 350, fit: BoxFit.contain), 
                );
              },
            ),
          ),
        ),
      ),
    );
    
    overlay.insert(entry);
    Future.delayed(const Duration(seconds: 3), () => entry.remove());
  }

  void _showDieOptions(int sides, bool isCustom) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.grey[900],
      builder: (bottomSheetContext) {
        return SafeArea(
          child: Wrap(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text("Configurar d$sides", style: const TextStyle(color: Colors.amber, fontSize: 18, fontWeight: FontWeight.bold)),
              ),
              ListTile(
                leading: const Icon(Icons.image, color: Colors.blueAccent),
                title: const Text("Trocar Imagem do Dado", style: TextStyle(color: Colors.white)),
                onTap: () async {
                  final messenger = ScaffoldMessenger.of(context); 
                  Navigator.pop(bottomSheetContext);
                  final picker = ImagePicker();
                  final pickedFile = await picker.pickImage(source: ImageSource.gallery);
                  if (pickedFile != null) {
                    DiceConfig config = _diceConfigs[sides] ?? DiceConfig(sides: sides);
                    config.imagePath = pickedFile.path;
                    await DiceConfigManager.saveConfig(config);
                    _loadConfigs();
                    if (mounted) messenger.showSnackBar(const SnackBar(content: Text('Imagem do dado salva!'), backgroundColor: Colors.blue));
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.animation, color: Colors.redAccent),
                title: const Text("Animação de Crítico (GIF/Img)", style: TextStyle(color: Colors.white)),
                subtitle: const Text("Toca ao tirar o valor máximo (1 dado)", style: TextStyle(color: Colors.grey, fontSize: 12)),
                onTap: () async {
                  final messenger = ScaffoldMessenger.of(context); 
                  Navigator.pop(bottomSheetContext);
                  final picker = ImagePicker();
                  final pickedFile = await picker.pickImage(source: ImageSource.gallery);
                  if (pickedFile != null) {
                    DiceConfig config = _diceConfigs[sides] ?? DiceConfig(sides: sides);
                    config.critImagePath = pickedFile.path;
                    await DiceConfigManager.saveConfig(config);
                    _loadConfigs();
                    if (mounted) messenger.showSnackBar(const SnackBar(content: Text('Animação de crítico salva!'), backgroundColor: Colors.amber));
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.audiotrack, color: Colors.greenAccent),
                title: const Text("Áudio de Crítico", style: TextStyle(color: Colors.white)),
                subtitle: const Text("Toca ao tirar o valor máximo (1 dado)", style: TextStyle(color: Colors.grey, fontSize: 12)),
                onTap: () async {
                   final messenger = ScaffoldMessenger.of(context); 
                   Navigator.pop(bottomSheetContext);
                   FilePickerResult? result = await FilePicker.platform.pickFiles(type: FileType.audio);
                   if (result != null && result.files.single.path != null) {
                     DiceConfig config = _diceConfigs[sides] ?? DiceConfig(sides: sides);
                     config.critAudioPath = result.files.single.path;
                     await DiceConfigManager.saveConfig(config);
                     _loadConfigs();
                     if (mounted) messenger.showSnackBar(const SnackBar(content: Text('Efeito Sonoro de crítico guardado!'), backgroundColor: Colors.green));
                   }
                },
              ),
              const Divider(color: Colors.white24),
              if (isCustom)
                ListTile(
                  leading: const Icon(Icons.delete, color: Colors.red),
                  title: const Text("Excluir Dado Customizado", style: TextStyle(color: Colors.red)),
                  onTap: () {
                    Navigator.pop(bottomSheetContext);
                    widget.onDeleteCustomDie(sides);
                    DiceConfigManager.deleteConfig(sides);
                    _loadConfigs();
                  },
                ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final allDice = [..._baseDiceOptions, ...widget.customDice]..sort();
    final uniqueDice = allDice.toSet().toList();
    final strings = AppStrings.of(context);
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: CustomAppBar(
        title: strings.get('app_title') ?? 'Overlord',
        subtitle: strings.get('dice_roller_subtitle') ?? 'Rolagem',
        actions: [
          GlobalMenu(
            onClearHistory: widget.onClearHistory,
            onAddNewDie: widget.onAddNewDie,
            onHelp: widget.onHelp,
            onAbout: widget.onAbout,
            onRateApp: widget.onRateApp,
            onConnect: widget.onConnect,
            onSettings: widget.onSettings, sheets: const [],
          ),
        ],
      ),
      body: Center(
        child: GridView.builder(
          padding: const EdgeInsets.all(16),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4, crossAxisSpacing: 8, mainAxisSpacing: 8,
          ),
          itemCount: uniqueDice.length,
          itemBuilder: (context, index) {
            final sides = uniqueDice[index];
            final isCustom = !_baseDiceOptions.contains(sides);
            final config = _diceConfigs[sides]; 

            return GestureDetector(
              onLongPress: () => _showDieOptions(sides, isCustom), 
              child: DiceIconButton(
                sides: sides, 
                quantity: _quantity, 
                modifier: _bonus, 
                config: config, 
                onRoll: _handleRoll
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
                  label: strings.get('quantity') ?? 'Qtd',
                  controller: _quantityController,
                  onDecrement: () { if (_quantity > 1) _quantityController.text = (_quantity - 1).toString(); },
                  onIncrement: () { _quantityController.text = (_quantity + 1).toString(); },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildControlPanel(
                  label: strings.get('modifier') ?? 'Mod',
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

  Widget _buildControlPanel({required String label, required TextEditingController controller, required VoidCallback onIncrement, required VoidCallback onDecrement}) {
    final theme = Theme.of(context);
    return Container(
      height: 56,
      decoration: BoxDecoration(color: theme.cardColor, borderRadius: BorderRadius.circular(8)),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        children: [
          SizedBox(width: 48, child: IconButton(onPressed: onDecrement, icon: Icon(Icons.remove, color: theme.iconTheme.color))),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(label, style: TextStyle(color: theme.textTheme.bodySmall?.color, fontSize: 12)),
                TextField(
                  controller: controller,
                  textAlign: TextAlign.center,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(border: InputBorder.none, isDense: true, contentPadding: EdgeInsets.zero),
                  style: TextStyle(fontSize: 24, color: theme.textTheme.bodyLarge?.color, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          SizedBox(width: 48, child: IconButton(onPressed: onIncrement, icon: Icon(Icons.add, color: theme.iconTheme.color))),
        ],
      ),
    );
  }
}

class DiceIconButton extends StatelessWidget {
  final int sides;
  final int quantity;
  final int modifier;
  final DiceConfig? config; 
  final void Function({required int sides, required int quantity, required int modifier}) onRoll;

  const DiceIconButton({super.key, required this.sides, required this.quantity, required this.modifier, this.config, required this.onRoll});

  String _getDiceIconPath(int sides) {
    switch (sides) {
      case 4: return 'assets/dice-2/D4.png';
      case 6: return 'assets/dice-2/D6.png';
      case 8: return 'assets/dice-2/D8.png';
      case 10: return 'assets/dice-2/D10.png';
      case 12: return 'assets/dice-2/D12.png';
      case 16: return 'assets/dice-2/D16.png'; 
      case 20: return 'assets/dice-2/D20.png';
      case 100: return 'assets/dice-2/D100.png';
      default: return 'assets/dice-2/Dquantos.png'; // O seu ícone padrão para dados customizados!
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isLightMode = theme.brightness == Brightness.light;
    
    final bool hasCustomImage = config != null && config!.imagePath != null && File(config!.imagePath!).existsSync();

    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () => onRoll(sides: sides, quantity: quantity, modifier: modifier),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: Container(
              decoration: isLightMode && !hasCustomImage
                ? BoxDecoration(
                    color: Colors.grey[900], 
                    shape: BoxShape.circle,  
                    boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(0, 2))]
                  )
                : null,
              padding: isLightMode && !hasCustomImage ? const EdgeInsets.all(8) : EdgeInsets.zero,
              child: hasCustomImage 
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.file(File(config!.imagePath!), fit: BoxFit.cover, width: double.infinity, height: double.infinity),
                  )
                : Image.asset(
                    _getDiceIconPath(sides), 
                    fit: BoxFit.contain,
                  ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'd$sides', 
            style: TextStyle(
              color: theme.textTheme.bodyMedium?.color, 
              fontSize: 12, 
              fontWeight: FontWeight.bold
            )
          ),
        ],
      ),
    );
  }
}