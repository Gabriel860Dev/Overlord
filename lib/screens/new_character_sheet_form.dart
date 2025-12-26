// lib/screens/new_character_sheet_form.dart

import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'packagepackage:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:provider/provider.dart'; // Import Provider
import 'package:dark_age/models/ability.dart';
import 'package:dark_age/models/armor.dart';
import 'package:dark_age/models/character_sheet.dart';
import 'package:dark_age/models/dice_roll_handler.dart';
import 'package:dark_age/models/die_specification.dart';
import 'package:dark_age/models/item.dart';
import 'package:dark_age/models/passive.dart';
import 'package:dark_age/models/roll_result.dart';
import 'package:dark_age/models/status_effect.dart';
import 'package:dark_age/models/weapon.dart';
import 'package:dark_age/screens/add_edit_entity_form.dart';
import 'package:dark_age/widgets/status_bar.dart';
import 'package:dark_age/models/passive_bonuses.dart';
import 'package:dark_age/models/dark_age_logic.dart'; // Importa a nova lógica
import 'package:dark_age/services/localization_service.dart'; // Importa localização
import 'package:dark_age/generated/l10n.dart'; // Importa localizações geradas
import 'package:dark_age/widgets/form_helpers.dart'; // Importa helpers
import 'package:dark_age/widgets/image_picker_button.dart'; // Importa picker

// (O restante das classes ActiveEffect e _NewCharacterSheetFormState initState, etc. permanece o mesmo)
// ... (Todo o código anterior da classe _NewCharacterSheetFormState) ...

class ActiveEffect {
  final String id;
  final String name;
  final String sourceTypeDescription;
  final Color color;
  final String sourceId;
  final String sourceType;

  ActiveEffect({
    required this.id,
    required this.name,
    required this.sourceTypeDescription,
    required this.color,
    required this.sourceId,
    required this.sourceType,
  });
}

class NewCharacterSheetForm extends StatefulWidget {
  final void Function(CharacterSheet newSheet) onSave;
  final CharacterSheet? initialSheet;
  final DiceRollHandler onDiceRolledFromSheet;
  final void Function(String) showToast;

  const NewCharacterSheetForm({
    super.key,
    required this.onSave,
    this.initialSheet,
    required this.onDiceRolledFromSheet,
    required this.showToast,
  });

  @override
  State<NewCharacterSheetForm> createState() => _NewCharacterSheetFormState();
}

class _NewCharacterSheetFormState extends State<NewCharacterSheetForm> {
  final _nameController = TextEditingController();
  final _classController = TextEditingController();
  final _levelController = TextEditingController();
  final _parryDiceCountController = TextEditingController();
  // final _esforcoExtraController = TextEditingController(text: '0'); // Removido, será 'manaExtraController'
  final _manaExtraController = TextEditingController(text: '0'); // NOVO

  final _blockConController = TextEditingController(text: '100');
  final _blockForController = TextEditingController(text: '0');
  final _blockSabController = TextEditingController(text: '0');

  final Map<String, double> _blockResistances = {};
  // ATUALIZAÇÃO: Lista de tipos de dano movida para um local central se necessário
  // ou mantida aqui se específica para esta tela.
  final List<String> _damageTypes = const [
    'Cortante',
    'Impacto',
    'Perfurante',
    'Dilacerante', // Adicionado Dilacerante
    'Fogo',
    'Gelo',
    'Elétrico',
    'Água',
    'Sangue',
    'Morte',
    'Conhecimento',
    'Energia',
    'Especial',
    'Cura'
  ];

  final _attributesControllers = {
    'FOR': TextEditingController(),
    'CON': TextEditingController(),
    'DES': TextEditingController(),
    'INT': TextEditingController(),
    'SAB': TextEditingController(),
    'CAR': TextEditingController()
  };
  // ATUALIZAÇÃO: Nomes dos status alterados
  final _statusControllers = {
    'Vida': {'atual': TextEditingController(), 'total': TextEditingController()},
    'Mana': {'atual': TextEditingController(), 'total': TextEditingController()},
    'Mana Temporária': {
      'atual': TextEditingController(),
      'total': TextEditingController()
    },
    'Estamina': {'atual': TextEditingController(), 'total': TextEditingController()},
    // 'Loucura': {'atual': TextEditingController(), 'total': TextEditingController()} // Removido
  };
  final Map<String, TextEditingController> _periciasControllers = {};

  final Map<String, int> _lastStatusValues = {};
  final Map<String, int> _unaccountedStatusLoss = {
    'Vida': 0,
    'Mana': 0,
    'Estamina': 0
  }; // Atualizado
  int _unaccountedDamageTaken = 0;
  bool _isDown = false;

  // ATUALIZAÇÃO: Lista de perícias padrão do Dark Age (ajuste conforme necessário)
  final List<String> _allPericias = const [
    'Acrobacia',
    'Atletismo',
    'Adestramento',
    'Guerra',
    'Pontaria',
    'Oculto',
    'Presença',
    'Percepção',
    'Pilotagem',
    'Diplomacia',
    'Tática',
    'Enganação',
    'Atuação',
    'Ladinagem',
    'Artes Marciais',
    'Sobrevivência',
    'Conhecimento (Geral)',
    'Direção',
    'Atualidades',
    'Montaria',
    'Primeiros Socorros',
    'Tecnologia',
    'Intimidação',
    'Sorte',
    'Furtividade',
    'Investigação',
    'Reflexos',
    'Vontade',
    // Adicione outras perícias específicas do Dark Age aqui
    'Alquimia',
    'Herbalismo',
    'Rastreio',
    'Ofícios (Específico)',
    'Etiqueta'
  ];
  List<String> _periciasExibidas = [];
  final List<Item> _inventory = []; // Contém Itens, Armas, Armaduras
  final List<Ability> _abilities = [];
  final List<Passive> _passives = [];
  final List<StatusEffect> _statusEffects = [];
  final List<Armor> _temporaryArmors = [];
  String? _imagePath;
  int _hpPerLevel = 0;
  // int _effortPerLevel = 0; // Renomeado
  // int _sanityPerLevel = 0; // Renomeado
  int _manaPerLevel = 0; // NOVO
  int _staminaPerLevel = 0; // NOVO
  int _pontosAtributoPorNivel = 0;
  int _pontosPericiaPorNivel = 0;
  int _vidaPorCon = 0;
  // int _esforcoPorSab = 0; // Renomeado
  // int _esforcoPorDes = 0; // Renomeado
  int _manaPerSab = 0; // NOVO
  int _manaPerDes = 0; // NOVO
  String _parryType = 'Comum'; // Ajuste se os tipos de Parry mudaram
  Color _manaColor = Colors.blue; // Renomeado de _effortColor

  // NOVO: Pontos de Bônus (Treino)
  final _bonusAttributePointsController = TextEditingController(text: '0');
  final _bonusSkillPointsController = TextEditingController(text: '0');

  // NOVO: Mapas para Maestria e Proficiência
  Map<String, String> _periciaMaestria = {}; // "Atletismo": "Mestre"
  Map<String, int> _periciaProficiencia = {}; // "Atletismo": 3
  Map<String, int> _armaMaestria = {}; // "Espada": 4

  // Mapeamento de limites de Parry (se aplicável no Dark Age)
  final Map<String, int> _parryDiceLimits = {
    'Comum': 6,
    'Avançado': 6,
    'Super': 8,
    'God': 10,
  };

  Timer? _saveDebounce;
  final bool _isFirstSave = true;
  String? _sheetId;
  final bool _isClassicLayout = false; // Layout da Ficha

  @override
  void initState() {
    super.initState();
    _sheetId = widget.initialSheet?.id;
    if (widget.initialSheet != null) {
      _loadSheetData(widget.initialSheet!);
    } else {
      _parryDiceCountController.text = '4'; // Valor inicial padrão
      _levelController.text = '1';
      // Inicializa status com valores mínimos para evitar erros
      _statusControllers.forEach((key, controllers) {
        controllers['atual']!.text = '1';
        controllers['total']!.text = '1';
        if (key == 'Mana Temporária') {
          controllers['atual']!.text = '0';
          controllers['total']!.text = '0';
        }
      });
      // Inicializa atributos
      _attributesControllers.forEach((key, controller) {
        controller.text = '0';
      });
      WidgetsBinding.instance.addPostFrameCallback((_) => _saveFicha(showToast: false)); // Primeiro save sem toast
    }

    _setupListeners();
    _initializeLastStatusValues();
    _parryDiceCountController.addListener(_validateParryDiceCount);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkIfDown();
    });
  }

  // Valida contagem de dados de Parry (se usado)
  void _validateParryDiceCount() {
    final limit = _parryDiceLimits[_parryType] ?? 4;
    final currentValue = int.tryParse(_parryDiceCountController.text) ?? 0;
    if (currentValue > limit) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _parryDiceCountController.text = limit.toString();
        _parryDiceCountController.selection = TextSelection.fromPosition(
            TextPosition(offset: _parryDiceCountController.text.length));
      });
    }
  }

  // Verifica se o personagem está "caído" (HP <= 0)
  void _checkIfDown() {
    final currentHp =
        int.tryParse(_statusControllers['Vida']!['atual']!.text) ?? 0;
    // Evita setState desnecessário se o estado não mudou
    if (_isDown != (currentHp <= 0)) {
      setState(() {
        _isDown = currentHp <= 0;
      });
    }
  }

  // Inicializa os últimos valores de status conhecidos
  void _initializeLastStatusValues() {
    _statusControllers.forEach((key, controllers) {
      _lastStatusValues[key] = int.tryParse(controllers['atual']!.text) ?? 0;
    });
  }

  // Configura listeners para salvar automaticamente e verificar passivas
  void _setupListeners() {
    final allControllers = [
      _nameController,
      _classController,
      _levelController,
      _parryDiceCountController,
      _manaExtraController, // ATUALIZADO
      _blockConController,
      _blockForController,
      _blockSabController,
      _bonusAttributePointsController, // NOVO
      _bonusSkillPointsController, // NOVO
      ..._attributesControllers.values,
      ..._statusControllers.values.expand((map) => map.values),
    ];

    for (var controller in allControllers) {
      controller.addListener(_onFieldChanged);
    }
    // Adiciona listener para novos controllers de perícia
    for (var c in _periciasControllers.values) {
      c.addListener(_onFieldChanged);
    }

    // Listeners específicos para mudanças de status
    _statusControllers['Vida']!['atual']!
        .addListener(() => _onStatusChange('Vida'));
    _statusControllers['Mana']!['atual']!
        .addListener(() => _onStatusChange('Mana')); // ATUALIZADO
    _statusControllers['Estamina']!['atual']!
        .addListener(() => _onStatusChange('Estamina')); // ATUALIZADO
    // _statusControllers['Loucura']!['atual']!.addListener(() { // REMOVIDO
    //   _validateLoucura();
    //   _onStatusChange('Loucura');
    // });
    _statusControllers['Mana Temporária']!['atual']!
        .addListener(() => _onStatusChange('Mana Temporária')); // ATUALIZADO
  }

  // Chamado quando um campo da ficha é alterado
  void _onFieldChanged() {
    // Atualiza UI se montado
    if (mounted) {
      setState(() {});
    }
    // Debounce para salvar automaticamente após um tempo
    if (_saveDebounce?.isActive ?? false) _saveDebounce!.cancel();
    _saveDebounce = Timer(const Duration(seconds: 2), () {
      if (mounted) {
        _saveFicha();
      }
    });
  }

  // Lida com mudanças nos status atuais (Vida, Mana, etc.)
  void _onStatusChange(String status) {
    // Garante que o controller não seja nulo
    final currentController = _statusControllers[status]?['atual'];
    if (currentController == null) return;

    int newValue = int.tryParse(currentController.text) ?? 0;
    int oldValue = _lastStatusValues[status] ?? newValue;

    // Garante que o valor não exceda o total (exceto Mana Temporária)
    if (status != 'Mana Temporária') {
      final totalController = _statusControllers[status]?['total'];
      if (totalController != null) {
        // Usa o getter para calcular o total real com bônus
        int totalValue = _getTotalStatWithBonuses(status);
        if (newValue > totalValue) {
          newValue = totalValue;
          // Atualiza o controller sem chamar o listener novamente
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              currentController.removeListener(() => _onStatusChange(status));
              currentController.text = newValue.toString();
              currentController.selection = TextSelection.fromPosition(
                  TextPosition(offset: currentController.text.length));
              currentController.addListener(() => _onStatusChange(status));
            }
          });
        }
      }
    } else {
      // Para Mana Temporária, garante que não exceda o seu próprio total
      final totalController = _statusControllers[status]?['total'];
      if (totalController != null) {
        int totalValue = int.tryParse(totalController.text) ?? 0;
        if (newValue > totalValue) {
          newValue = totalValue;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              currentController.removeListener(() => _onStatusChange(status));
              currentController.text = newValue.toString();
              currentController.selection = TextSelection.fromPosition(
                  TextPosition(offset: currentController.text.length));
              currentController.addListener(() => _onStatusChange(status));
            }
          });
        }
      }
    }

    // Verifica se caiu (Vida <= 0)
    if (status == 'Vida') {
      // É importante obter o AppLocalizations ANTES de qualquer lógica assíncrona
      // ou garantir que o context ainda é válido.
      final localization = AppLocalizations.of(context);
      final bool nowDown = newValue <= 0;
      if (nowDown && !_isDown) {
        // Transição para caído
        widget.showToast(localization.youFellToast);
      }
      // Atualiza o estado _isDown apenas se houver mudança
      if (_isDown != nowDown) {
        setState(() {
          _isDown = nowDown;
        });
      }
    }

    // Rastreia perda de status não contabilizada para gatilhos passivos
    if (newValue < oldValue) {
      int loss = oldValue - newValue;
      // Garante que a chave existe antes de adicionar
      _unaccountedStatusLoss.update(status, (value) => value + loss,
          ifAbsent: () => loss);
    }

    _lastStatusValues[status] = newValue;
    _checkAllStatusPassives(); // Verifica se alguma passiva foi ativada
  }

  // Verifica todos os tipos de gatilhos passivos
  void _checkAllStatusPassives() {
    if (!mounted) return; // Evita erros se a tela for descartada
    _checkDamageBasedPassives();
    _checkStatusBasedPassives('healthLost', 'Vida'); // Chave ARB
    _checkStatusBasedPassives('effortSpent', 'Mana'); // Chave ARB
    _checkStatusBasedPassives('sanityLost', 'Estamina'); // Chave ARB
    // _checkStatusBasedPassives('Loucura Gasta', 'Loucura'); // Removido
    _checkProportionalPassives();
  }

  // Verifica passivas baseadas em Dano Sofrido
  void _checkDamageBasedPassives() {
    if (_unaccountedDamageTaken <= 0) return;

    int processedDamage = 0;
    List<Passive> passivesToUpdate = []; // Lista para atualizações de estado
    final localization = AppLocalizations.of(context);

    for (var passive in _passives) {
      if (!mounted) return; // Checa se ainda está montado
      if (passive.triggerType == localization.damageTaken) {
        // 'Dano Sofrido'
        int triggerValue =
            _getTriggerValue(passive, 'Vida'); // Dano Sofrido afeta a Vida

        if (triggerValue > 0 && _unaccountedDamageTaken >= triggerValue) {
          int timesTriggered = _unaccountedDamageTaken ~/ triggerValue;
          // Armazena a mudança para aplicar depois
          passivesToUpdate.add(_triggerPassiveLogic(passive, timesTriggered));
          int damageConsumed = timesTriggered * triggerValue;
          _unaccountedDamageTaken -=
              damageConsumed; // Reduz o dano não contabilizado
          processedDamage += damageConsumed;

          if (_unaccountedDamageTaken < 0) {
            _unaccountedDamageTaken = 0; // Garante que não fique negativo
          }
        }
      }
    }

    // Aplica as atualizações de estado de uma vez
    if (passivesToUpdate.isNotEmpty && mounted) {
      setState(() {
        for (var updatedPassive in passivesToUpdate) {
          final index =
              _passives.indexWhere((p) => p.id == updatedPassive.id);
          if (index != -1) {
            _passives[index] = updatedPassive;
          }
        }
      });
    }

    // Ajusta a perda de Vida não contabilizada
    if (processedDamage > 0) {
      _unaccountedStatusLoss['Vida'] =
          (_unaccountedStatusLoss['Vida'] ?? 0) - processedDamage;
      if (_unaccountedStatusLoss['Vida']! < 0) {
        _unaccountedStatusLoss['Vida'] = 0;
      }
    }
  }

  // Verifica passivas baseadas em perda de Status (Vida, Mana, etc.)
  void _checkStatusBasedPassives(String triggerKey, String statusType) {
    int loss = _unaccountedStatusLoss[statusType] ?? 0;
    if (loss <= 0) return;

    List<Passive> passivesToUpdate = [];
    final localization = AppLocalizations.of(context);
    final triggerName = localization.translate(triggerKey); // Obtém o nome traduzido do gatilho

    for (var passive in _passives) {
      if (!mounted) return;
      if (passive.triggerType == triggerName) {
        if (passive.basedOnTotal) continue; // Ignora passivas proporcionais aqui

        int triggerValue = _getTriggerValue(passive, statusType);

        if (triggerValue > 0 && loss >= triggerValue) {
          int timesTriggered = loss ~/ triggerValue;
          passivesToUpdate.add(_triggerPassiveLogic(passive, timesTriggered));
          loss %= triggerValue; // Atualiza a perda restante
        }
      }
    }
    // Aplica as atualizações de estado
    if (passivesToUpdate.isNotEmpty && mounted) {
      setState(() {
        for (var updatedPassive in passivesToUpdate) {
          final index =
              _passives.indexWhere((p) => p.id == updatedPassive.id);
          if (index != -1) {
            _passives[index] = updatedPassive;
          }
        }
        _unaccountedStatusLoss[statusType] =
            loss; // Atualiza a perda não contabilizada restante
      });
    } else if (mounted) {
      // Mesmo se nenhuma passiva foi ativada, atualiza a perda restante
      _unaccountedStatusLoss[statusType] = loss;
    }
  }

  // Verifica passivas que escalam inversamente com o status total
  void _checkProportionalPassives() {
    bool changed = false;
    final localization = AppLocalizations.of(context);
    final statusMap = {
      localization.healthLost: 'Vida',
      localization.effortSpent: 'Mana', // Atualizado
      localization.sanityLost: 'Estamina', // Atualizado
      // localization.madnessSpent: 'Loucura' // Removido
    };

    // Não precisa de setState dentro do loop, apenas marca se houve mudança
    for (var passive in _passives) {
      if (!mounted) return;
      if (passive.basedOnTotal && statusMap.containsKey(passive.triggerType)) {
        String statusToCheck = statusMap[passive.triggerType]!;
        // Garante que os controllers existem
        final currentController = _statusControllers[statusToCheck]?['atual'];
        final totalController = _statusControllers[statusToCheck]?['total'];
        if (currentController == null || totalController == null) continue;

        int current = int.tryParse(currentController.text) ?? 0;
        int total = _getTotalStatWithBonuses(statusToCheck); // Usa o getter para total com bônus
        if (total == 0) total = 1; // Evita divisão por zero
        int newStacks = total - current;
        if (passive.stacks != newStacks) {
          passive.stacks = newStacks;
          changed = true;
        }
      }
    }
    // Aplica setState uma única vez no final, se necessário
    if (changed && mounted) {
      setState(() {});
    }
  }

  // Obtém o valor de gatilho (fixo ou percentual) para uma passiva
  int _getTriggerValue(Passive passive, String statusType) {
    if (passive.triggerValueType == 'Percentual') {
      // Garante que o controller existe
      final totalController = _statusControllers[statusType]?['total'];
      if (totalController == null) {
        return 0; // Ou algum valor padrão/erro
      }

      int total = _getTotalStatWithBonuses(statusType); // Usa total com bônus
      if (total == 0) total = 1; // Evita divisão por zero
      return (total * (passive.triggerValue / 100)).round().clamp(1, total); // Garante pelo menos 1
    }
    return max(1, passive.triggerValue); // Garante que o valor fixo seja pelo menos 1
  }

  // Lógica para ativar/acumular uma passiva (retorna a passiva atualizada)
  Passive _triggerPassiveLogic(Passive passive, int times) {
    final localization = AppLocalizations.of(context); // Para traduções
    Passive updatedPassive = Passive.fromJson(passive.toJson()); // Cria cópia

    if (updatedPassive.triggerFrequency == localization.stackable) { // 'Acumulável'
      if (!updatedPassive.basedOnTotal) {
        // Não acumula se for proporcional
        updatedPassive.stacks += times;
        widget.showToast(
            localization.passiveAccumulatedToast(updatedPassive.name, times));
      }
    } else {
      // 'Uma Vez por Cooldown'
      if (updatedPassive.currentCooldown == 0) {
        updatedPassive.isActive = true;
        if (updatedPassive.cooldown > 0) {
          updatedPassive.currentCooldown =
              updatedPassive.cooldown + 1; // +1 porque o round atual conta
        }
        widget.showToast(localization.passiveActivatedToast(updatedPassive.name));
      }
    }
    return updatedPassive;
  }

  // Carrega os dados de uma ficha existente
  void _loadSheetData(CharacterSheet sheet) {
    _nameController.text = sheet.name;
    _classController.text = sheet.classe ?? '';
    _levelController.text = sheet.level?.toString() ?? '1';
    _inventory.clear(); // Limpa inventário antes de adicionar
    _inventory.addAll(sheet.backpack);
    _statusEffects.clear(); // Limpa efeitos antes de adicionar
    _statusEffects.addAll(sheet.statusEffects);
    _imagePath = sheet.imagePath;
    _manaColor = Color(sheet.effortColor); // ATUALIZADO
    _hpPerLevel = sheet.hpPerLevel;
    _manaPerLevel = sheet.manaPerLevel; // ATUALIZADO
    _staminaPerLevel = sheet.staminaPerLevel; // ATUALIZADO
    _pontosAtributoPorNivel = sheet.pontosAtributoPorNivel;
    _pontosPericiaPorNivel = sheet.pontosPericiaPorNivel;
    _vidaPorCon = sheet.vidaPorCon;
    _manaPerSab = sheet.manaPerSab; // ATUALIZADO
    _manaPerDes = sheet.manaPerDes; // ATUALIZADO
    _parryType = sheet.parryType;
    _parryDiceCountController.text = sheet.parryDiceCount.toString();
    _manaExtraController.text = sheet.esforcoExtra.toString(); // ATUALIZADO
    _blockConController.text = sheet.blockConPercentage.toString();
    _blockForController.text = sheet.blockForPercentage.toString();
    _blockSabController.text = sheet.blockSabPercentage.toString();

    _abilities.clear(); // Limpa habilidades antes de adicionar
    _abilities.addAll(sheet.abilities);
    _passives.clear(); // Limpa passivas antes de adicionar
    _passives.addAll(sheet.passives);

    // NOVO: Carregar Pontos de Bônus
    _bonusAttributePointsController.text = sheet.bonusAttributePoints.toString();
    _bonusSkillPointsController.text = sheet.bonusSkillPoints.toString();

    // NOVO: Carregar Maestria e Proficiência
    _periciaMaestria = Map.from(sheet.periciaMaestria);
    _periciaProficiencia = Map.from(sheet.periciaProficiencia);
    _armaMaestria = Map.from(sheet.armaMaestria);

    // Carrega Atributos
    sheet.attributes.forEach((key, value) {
      // Garante que a chave existe antes de tentar definir o texto
      if (_attributesControllers.containsKey(key)) {
        _attributesControllers[key]?.text = value?.toString() ?? '0';
      }
    });

    // Carrega Status, garantindo que as chaves existem
    sheet.status.forEach((key, valueMap) {
      if (_statusControllers.containsKey(key)) {
        // Garante que 'atual' e 'total' não sejam nulos
        _statusControllers[key]?['atual']?.text =
            valueMap['atual']?.toString() ?? '0';
        _statusControllers[key]?['total']?.text =
            valueMap['total']?.toString() ?? '1'; // Mínimo 1 para total
      }
    });
    // Garante que 'Mana Temporária' seja carregado corretamente (pode ser 0)
    _statusControllers['Mana Temporária']!['atual']!.text =
        sheet.status['Mana Temporária']?['atual']?.toString() ?? '0';
    _statusControllers['Mana Temporária']!['total']!.text =
        sheet.status['Mana Temporária']?['total']?.toString() ?? '0';

    // _validateLoucura(); // Removido

    // Carrega Perícias existentes e configura controllers
    _periciasExibidas = List.from(sheet.pericias.keys)..sort();
    // Limpa controllers antigos antes de recriar
    for (var controller in _periciasControllers.values) {
      controller.removeListener(_onFieldChanged);
      controller.dispose();
    }
    _periciasControllers.clear();
    for (var pericia in _periciasExibidas) {
      _periciasControllers[pericia] =
          TextEditingController(text: sheet.pericias[pericia]?.toString() ?? '0');
      // Adiciona listener aos novos controllers
      _periciasControllers[pericia]?.addListener(_onFieldChanged);
    }

    // Inicializa valores após carregar
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeLastStatusValues();
      _checkIfDown();
    });
  }

  // Limpa recursos ao sair da tela
  @override
  void dispose() {
    _saveDebounce?.cancel();
    if (mounted) {
      // Salva apenas se ainda estiver montado
      _saveFicha(showToast: false); // Último save sem toast
    }

    // Remove listeners e descarta controllers
    final allControllers = [
      _nameController,
      _classController,
      _levelController,
      _parryDiceCountController,
      _manaExtraController, // ATUALIZADO
      _blockConController,
      _blockForController,
      _blockSabController,
      _bonusAttributePointsController, // NOVO
      _bonusSkillPointsController, // NOVO
      ..._attributesControllers.values,
      ..._statusControllers.values.expand((map) => map.values),
      ..._periciasControllers.values,
    ];
    for (var controller in allControllers) {
      // Verifica se o listener existe antes de remover (mais seguro)
      try {
        controller.removeListener(_onFieldChanged);
      } catch (e) {
        // Ignora erro se o listener já foi removido
      }
      controller.dispose();
    }
    try {
      _parryDiceCountController.removeListener(_validateParryDiceCount);
    } catch (e) {} // Ignora
    super.dispose();
  }

  // Garante que o valor de Loucura fique entre 0 e 100
  // void _validateLoucura() { // REMOVIDO
  //    // Garante que o controller existe
  //   final controller = _statusControllers['Loucura']?['atual'];
  //   if (controller == null) return;
  //
  //   final currentValue = int.tryParse(controller.text) ?? 0;
  //   final clampedValue = currentValue.clamp(0, 100);
  //
  //   // Atualiza apenas se o valor for diferente para evitar loop de listener
  //   if (currentValue != clampedValue) {
  //      // Atualiza sem chamar o listener novamente
  //       WidgetsBinding.instance.addPostFrameCallback((_) {
  //         if (mounted) {
  //           controller.removeListener(() => _onStatusChange('Loucura'));
  //           controller.text = clampedValue.toString();
  //           controller.selection = TextSelection.fromPosition(TextPosition(offset: controller.text.length));
  //           controller.addListener(() => _onStatusChange('Loucura'));
  //         }
  //       });
  //   }
  // }

  // Remove a imagem do personagem
  void _removeImage() {
    if (_imagePath != null && mounted) {
      // Verifica se há imagem e se está montado
      setState(() => _imagePath = null);
      _onFieldChanged(); // Trigger save
    }
  }

  // Mostra opções para escolher ou remover imagem
  void _showImageOptions() {
    final localization = AppLocalizations.of(context);
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Padding(
          // Garante espaço na parte inferior em dispositivos com notch/barra
          padding:
              EdgeInsets.only(bottom: MediaQuery.of(context).viewPadding.bottom),
          child: Wrap(
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: Text(localization.translate(
                    'selectFromGallery')), // TODO: Adicionar chave 'selectFromGallery'
                onTap: () async {
                  Navigator.of(context).pop();
                  // Tenta pegar imagem da galeria
                  // try {
                  //    final picker = ImagePicker();
                  //    final pickedFile = await picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
                  //    if (pickedFile != null && mounted) { // Verifica se montado antes de setState
                  //       setState(() => _imagePath = pickedFile.path);
                  //        _onFieldChanged(); // Trigger save
                  //    }
                  // } catch (e) {
                  //    print("Erro ao pegar imagem: $e");
                  //    widget.showToast("Falha ao selecionar imagem."); // TODO: Localize
                  // }
                },
              ),
              // Opção de remover só aparece se houver imagem
              if (_imagePath != null && _imagePath!.isNotEmpty)
                ListTile(
                  leading: Icon(Icons.delete,
                      color: Theme.of(context).colorScheme.error),
                  title: Text(
                      localization.translate(
                          'removeImage'), // TODO: Adicionar chave 'removeImage'
                      style: TextStyle(
                          color: Theme.of(context).colorScheme.error)),
                  onTap: () {
                    Navigator.of(context).pop();
                    _removeImage();
                  },
                ),
            ],
          ),
        );
      },
    );
  }

  // Reseta estados de combate
  void _endCombat() {
    bool changed = false; // Flag para evitar setState desnecessário
    // Desativa habilidades de custo por round e reseta usos em combate
    for (var ability in _abilities) {
      if (ability.usesInCombat != 0) {
        ability.usesInCombat = 0;
        changed = true;
      }
      if (ability.costPerRound > 0 && ability.isActive) {
        ability.isActive = false;
        changed = true;
      }
      if (ability.currentCooldown != 0) {
        ability.currentCooldown = 0;
        changed = true;
      }
    }
    // Reseta cooldowns e stacks de passivas
    for (var passive in _passives) {
      bool passiveChanged = false;
      if (passive.triggerType == context.loc.onCooldown || // ATUALIZADO
          passive.triggerFrequency == context.loc.oncePerCooldown) { // ATUALIZADO
        if (passive.currentCooldown != 0) {
          passive.currentCooldown = 0;
          passiveChanged = true;
        }
        // Desativa passivas que dependem de cooldown ao fim do combate
        if (passive.isActive) {
          passive.isActive = false;
          passiveChanged = true;
        }
      }
      if (passive.triggerFrequency == context.loc.stackable && // ATUALIZADO
          passive.stacks != 0) {
        passive.stacks = 0;
        passiveChanged = true;
      }
      // Restaura durabilidade de armaduras concedidas por passivas
      for (var effect in passive.effects) {
        if (effect.grantsArmor != null &&
            effect.grantsArmor!.currentDefenseValue !=
                effect.grantsArmor!.defenseValue) {
          effect.grantsArmor!.currentDefenseValue =
              effect.grantsArmor!.defenseValue;
          passiveChanged = true; // Indica que houve mudança na passiva
        }
      }
      if (passiveChanged) changed = true;
    }
    // Zera Mana Temporária
    if (_statusControllers['Mana Temporária']?['atual']?.text != '0') {
      _statusControllers['Mana Temporária']!['atual']!.text = '0';
      changed = true;
    }
    if (_statusControllers['Mana Temporária']?['total']?.text != '0') {
      _statusControllers['Mana Temporária']!['total']!.text = '0';
      changed = true;
    }

    // Remove Armaduras Temporárias
    if (_temporaryArmors.isNotEmpty) {
      _temporaryArmors.clear();
      changed = true;
    }

    // Restaura durabilidade de armaduras equipadas
    _inventory.whereType<Armor>().forEach((armor) {
      if (armor.currentDefenseValue != armor.defenseValue) {
        armor.currentDefenseValue = armor.defenseValue;
        changed = true;
      }
    });
    // Zera perdas não contabilizadas
    _unaccountedStatusLoss.updateAll((key, value) => 0);
    if (_unaccountedDamageTaken != 0) {
      _unaccountedDamageTaken = 0;
      changed = true;
    }

    // Aplica o setState apenas se algo mudou
    if (changed && mounted) {
      setState(() {});
    }
    widget.showToast(context.loc.combatEndedToast);
  }

  // Avança um round no combate
  void _nextRound() {
    int totalCost = 0;
    bool changed = false;

    // Calcula custo de habilidades ativas e reduz cooldowns
    for (var ability in _abilities) {
      if (ability.isActive && ability.costPerRound > 0) {
        totalCost += ability.costPerRound;
      }
      if (ability.currentCooldown > 0) {
        ability.currentCooldown--;
        changed = true;
      }
    }

    // Paga o custo das habilidades ativas
    if (totalCost > 0) {
      // Tenta pagar com mana (prioriza temporário se Híbrido)
      bool paid = _payMana(totalCost, 'Híbrido (Temp. > Padrão)'); // ATUALIZADO
      if (!paid) {
        widget.showToast(context.loc.insufficientResourcesToast); // Avisa se não puder pagar
        // Opcional: Desativar habilidades se não puder pagar?
        // for (var ability in _abilities) {
        //   if (ability.isActive && ability.costPerRound > 0) ability.isActive = false;
        // }
      }
      changed = true; // Indica mudança de estado
    }

    // Reduz duração de efeitos de status
    // Usa toList() para criar uma cópia e evitar erro de modificação durante iteração
    _statusEffects.toList().forEach((effect) {
      if (effect.durationInRounds > 0) {
        effect.durationInRounds--;
        if (effect.durationInRounds == 0) {
          _statusEffects.remove(effect);
        }
        changed = true;
      }
    });

    // Reduz cooldown de passivas
    for (var passive in _passives) {
      if (passive.currentCooldown > 0) {
        passive.currentCooldown--;
        if (passive.currentCooldown == 0) {
          if (passive.triggerFrequency == context.loc.oncePerCooldown) { // ATUALIZADO
            passive.isActive = false; // Desativa após cooldown
          }
          widget.showToast(context.loc.passiveReadyToast(passive.name));
        }
        changed = true;
      }
    }

    // Aplica setState apenas se houve mudanças
    if (changed && mounted) {
      setState(() {});
    }
  }

  // Descansar: Recupera Vida/Mana e finaliza combate
  void _rest() {
    bool changed = false;
    // Recupera Vida
    if (_statusControllers['Vida']?['atual']?.text !=
        _statusControllers['Vida']?['total']?.text) {
      _statusControllers['Vida']!['atual']!.text =
          _statusControllers['Vida']!['total']!.text;
      changed = true;
    }
    // Recupera Mana
    if (_statusControllers['Mana']?['atual']?.text !=
        _statusControllers['Mana']?['total']?.text) {
      _statusControllers['Mana']!['atual']!.text =
          _statusControllers['Mana']!['total']!.text;
      changed = true;
    }
    // Recupera Estamina
    if (_statusControllers['Estamina']?['atual']?.text !=
        _statusControllers['Estamina']?['total']?.text) {
      _statusControllers['Estamina']!['atual']!.text =
          _statusControllers['Estamina']!['total']!.text;
      changed = true;
    }
    // Zera Esforço Temporário (já feito em _endCombat)

    // Finaliza o combate (reseta cooldowns, etc.)
    _endCombat(); // endCombat já chama setState se necessário

    // Chama setState se a recuperação de Vida/Mana/Estamina causou mudança
    if (changed && !_endCombatChangedState() && mounted) {
      // Evita setState duplo
      setState(() {});
    }
  }

  // Função auxiliar para saber se _endCombat já chamou setState
  bool _endCombatChangedState() {
    // Verifica se alguma condição de _endCombat foi atendida
    bool abilitiesChanged = _abilities.any((a) =>
        a.usesInCombat != 0 ||
        (a.costPerRound > 0 && a.isActive) ||
        a.currentCooldown != 0);
    bool passivesChanged = _passives.any((p) =>
        ((p.triggerType == context.loc.onCooldown || // ATUALIZADO
                p.triggerFrequency == context.loc.oncePerCooldown) && // ATUALIZADO
            (p.currentCooldown != 0 || p.isActive)) ||
        (p.triggerFrequency == context.loc.stackable && p.stacks != 0) || // ATUALIZADO
        p.effects.any((e) =>
            e.grantsArmor != null &&
            e.grantsArmor!.currentDefenseValue !=
                e.grantsArmor!.defenseValue));
    bool tempManaChanged =
        _statusControllers['Mana Temporária']?['atual']?.text != '0' ||
            _statusControllers['Mana Temporária']?['total']?.text != '0';
    bool tempArmorChanged = _temporaryArmors.isNotEmpty;
    bool equippedArmorChanged = _inventory
        .whereType<Armor>()
        .any((a) => a.currentDefenseValue != a.defenseValue);
    bool unaccountedChanged =
        _unaccountedStatusLoss.values.any((v) => v != 0) ||
            _unaccountedDamageTaken != 0;

    return abilitiesChanged ||
        passivesChanged ||
        tempManaChanged ||
        tempArmorChanged ||
        equippedArmorChanged ||
        unaccountedChanged;
  }

  // Remove uma perícia da lista exibida
  void _removePericia(String pericia) {
    if (!mounted) return;
    setState(() {
      _periciasExibidas.remove(pericia);
      // Remove listener e descarta controller
      _periciasControllers[pericia]?.removeListener(_onFieldChanged);
      _periciasControllers[pericia]?.dispose();
      _periciasControllers.remove(pericia);
      // Remove dos mapas de maestria e proficiência
      _periciaMaestria.remove(pericia);
      _periciaProficiencia.remove(pericia);
    });
    _onFieldChanged(); // Trigger save
  }

  // Realiza rolagem de Parry (se usado no Dark Age)
  void _performParryRoll() {
    final diceFaces = {
      'Comum': 4,
      'Avançado': 8,
      'Super': 12,
      'God': 20
    }; // Ajuste se necessário
    final faces = diceFaces[_parryType] ?? 4;
    final count = int.tryParse(_parryDiceCountController.text) ?? 0;
    if (count <= 0) {
      widget.showToast(
          "Número de dados de Parry inválido."); // TODO: Localize
      return;
    }
    final localization = AppLocalizations.of(context);

    // Busca bônus específicos para 'Parry' (se houver)
    final bonuses = _getBonusesFor(localization.parry); // Ou uma perícia específica como 'Esgrima'?

    // Converte pontos de bônus em dados Dark Age
    final bonusRollData = DarkAgeLogic.getRollData(
        bonuses.bonusPoints, 'Novato', 0); // Usa escala base para bônus

    // Rola os dados de Parry + dados de bônus
    _performRoll(
      dice: [
        DieSpecification(quantity: count, sides: faces, damageType: 'Parry'),
        ...bonusRollData.dice
      ],
      modifier: bonuses.modifier,
      multiplier: bonuses.multiplier,
      name: '${localization.parry} $_parryType',
      bonusSources: bonuses.sources,
      // Bônus fixo de Mestre/Proficiência NÃO se aplica a Parry normally
      fixedBonus: 0,
    );
  }

  // Mostra diálogo para inserir dano a ser bloqueado
  void _showBlockDamageDialog() {
    final damageController = TextEditingController();
    String damageType = _damageTypes.first; // Usa a lista de tipos de dano
    final localization = AppLocalizations.of(context);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        // backgroundColor: Colors.grey[850], // Usa tema
        title: Text(localization.block,
            style:
                Theme.of(context).textTheme.titleLarge), // TODO: Localize "Block Damage"
        content: StatefulBuilder(
            // Para atualizar o dropdown
            builder: (context, setDialogState) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: damageController,
                decoration:
                    InputDecoration(labelText: localization.damageTaken), // Usa localização
                keyboardType: TextInputType.number,
                // style: const TextStyle(color: Colors.white), // Usa tema
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: damageType,
                items: _damageTypes
                    .map((String value) => DropdownMenuItem<String>(
                        value: value, child: Text(value))) // Usa tema
                    .toList(),
                onChanged: (newValue) {
                  if (newValue != null) {
                    setDialogState(() {
                      // Atualiza o estado do diálogo
                      damageType = newValue;
                    });
                  }
                },
                // dropdownColor: Colors.grey[850], // Usa tema
                decoration: InputDecoration(labelText: localization.damageType), // Usa localização
              ),
            ],
          );
        }),
        actions: [
          TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(localization.cancel)),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              final incomingDamage = int.tryParse(damageController.text) ?? 0;
              if (incomingDamage > 0) {
                // Só executa se houver dano
                _executeBlock(incomingDamage, damageType);
              }
            },
            child: Text(localization.block),
          ),
        ],
      ),
    );
  }

  // Executa a lógica de bloqueio
  void _executeBlock(int incomingDamage, String damageType) {
    // 1. Obter todas as armaduras ativas
    final List<Armor> allArmors = [
      ..._getEquippedArmors(),
      ..._temporaryArmors
    ];
    _passives
        .where((p) => p.isActive || p.triggerType == context.loc.alwaysActive) // ATUALIZADO
        .forEach((p) {
      for (var effect in p.effects) {
        if (effect.grantsArmor != null) {
          allArmors.add(effect.grantsArmor!);
        }
      }
    });
    final localization = AppLocalizations.of(context);

    // 2. Calcular pontos de Bloqueio base (CON%, FOR%, SAB%)
    final conPerc = int.tryParse(_blockConController.text) ?? 100;
    final forPerc = int.tryParse(_blockForController.text) ?? 0;
    final sabPerc = int.tryParse(_blockSabController.text) ?? 0;
    final conValue = int.tryParse(_attributesControllers['CON']!.text) ?? 0;
    final forValue = int.tryParse(_attributesControllers['FOR']!.text) ?? 0;
    final sabValue = int.tryParse(_attributesControllers['SAB']!.text) ?? 0;

    int blockPoints = 0;
    blockPoints += (conValue * (conPerc / 100.0)).round();
    blockPoints += (forValue * (forPerc / 100.0)).round();
    blockPoints += (sabValue * (sabPerc / 100.0)).round();

    // 3. Obter bônus passivos para 'Bloqueio'
    final blockBonuses =
        _getBonusesFor(localization.block); // Usa chave localizada
    blockPoints += blockBonuses.bonusPoints;
    int blockModifier = blockBonuses.modifier;

    // 4. Converter pontos de bloqueio em dados Dark Age
    // Assume-se que Bloqueio usa a progressão base (Novato), a menos que haja uma perícia "Bloqueio"
    final blockRollData =
        DarkAgeLogic.getRollData(blockPoints, 'Novato', 0); // Ajuste maestria se necessário

    // 5. Realizar a rolagem de Bloqueio
    final blockRollResult = _performRoll(
      dice: blockRollData.dice,
      modifier: blockModifier,
      multiplier: blockBonuses.multiplier,
      name: localization.block, // Nome localizado
      defenseTarget: incomingDamage,
      bonusSources: blockBonuses.sources,
      fixedBonus: blockRollData.fixedBonus, // Inclui bônus fixo se aplicável
    );

    // 6. Calcular dano final após mitigação da rolagem
    int finalDamage = blockRollResult.total < 0 ? blockRollResult.total.abs() : 0;

    // 7. Aplicar resistências/vulnerabilidades ao dano restante
    // (Resistência de Bloqueio - se houver - foi removida, usar resistências da armadura)
    // double blockResistance = _blockResistances[damageType] ?? 1.0;
    // finalDamage = (finalDamage * blockResistance).round();

    // 8. Aplicar absorção e resistências das armaduras
    int armorAbsorbedTotal = 0;
    int healthLost = 0;
    int damageBeforeArmor = finalDamage; // Guarda o dano antes da armadura

    if (finalDamage > 0 && allArmors.isNotEmpty) {
      // Ordena armaduras (ex: temporária primeiro, ou pela maior defesa?) - Opcional
      // allArmors.sort((a, b) => b.currentDefenseValue.compareTo(a.currentDefenseValue));

      for (var armor in allArmors) {
        if (!mounted) break; // Sai se a tela for descartada
        if (finalDamage <= 0) break; // Sai se todo dano foi absorvido

        // Calcula o multiplicador de resistência
        // Chave do mapa é o tipo de dano (ex: 'Fogo')
        // Valor é o multiplicador (ex: 0.5 para 50% res, 1.5 para 50% vul)
        double armorResistanceMultiplier = armor.resistances[damageType] ?? 1.0;

        // Calcula o dano que *chega* na armadura após a resistência dela
        int damageReachingArmor = (finalDamage * armorResistanceMultiplier).round();
        if (damageReachingArmor <= 0) {
          // Se a resistência anulou o dano (ex: imunidade),
          // a armadura não gasta durabilidade.
          armorAbsorbedTotal +=
              (finalDamage - damageReachingArmor).abs(); // Conta o dano "resistido"
          finalDamage = 0; // Zera o dano final
          break; // Pára de processar armaduras
        }

        // Quanto a armadura pode absorver desse dano que chegou
        int canAbsorb = min(damageReachingArmor, armor.currentDefenseValue);

        // Quanto de dano *original* foi efetivamente reduzido por essa absorção
        // (Considera a resistência: se resiste 50% (mult 0.5), absorver 10 reduz 20 do original)
        int originalDamageReduced = (armorResistanceMultiplier > 0)
            ? (canAbsorb / armorResistanceMultiplier).round()
            : canAbsorb; // Evita divisão por zero (embora não deva acontecer com `damageReachingArmor > 0`)

        // Atualiza estado da armadura (só faz setState uma vez no final)
        armor.currentDefenseValue -= canAbsorb;
        bool armorBroke = false;
        if (armor.currentDefenseValue <= 0) {
          armor.currentDefenseValue = 0; // Não deixa negativo
          armorBroke = true;
          // Remove armadura temporária ou desequipa permanente
          // (A lógica de remoção/desequipar será feita no setState)
        }

        finalDamage -= originalDamageReduced; // Reduz o dano final
        armorAbsorbedTotal += canAbsorb; // Soma o valor bruto absorvido
      }
      // Garante que o dano final não seja negativo
      finalDamage = max(0, finalDamage);
    }

    // Aplica dano à vida
    healthLost = finalDamage;
    if (healthLost > 0) {
      _unaccountedDamageTaken += healthLost; // Para gatilhos de 'Dano Sofrido'
      // Garante que o controller existe
      final hpController = _statusControllers['Vida']?['atual'];
      if (hpController != null) {
        final currentHp = int.tryParse(hpController.text) ?? 0;
        final newHp = currentHp - healthLost;
        hpController.text = newHp.toString(); // Isso vai chamar _onStatusChange e _checkIfDown
      }
    } else {
      // Se nenhum dano passou, ainda checa passivas (pode haver gatilhos em rolagem 0?)
      _checkAllStatusPassives();
    }

    // Atualiza o estado das armaduras e remove as quebradas/temporárias
    if (mounted) {
      setState(() {
        // Remove armaduras temporárias quebradas
        _temporaryArmors.removeWhere((a) => a.currentDefenseValue <= 0);
        // Desequipa armaduras permanentes quebradas
        _inventory.whereType<Armor>().forEach((a) {
          if (a.isEquipped && a.currentDefenseValue <= 0) {
            a.isEquipped = false;
          }
        });
      });
    }

    // Mostra resultado
    widget.showToast(
        localization.finalDamageToast(healthLost, armorAbsorbedTotal));
  }

  // Mostra diálogo para adicionar perícias não listadas
  void _showPericiasDialog() {
    final localization = AppLocalizations.of(context);
    final availablePericias = _allPericias
        .where((p) => !_periciasExibidas.contains(p))
        .toList()
      ..sort();
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              // backgroundColor: Colors.grey[850], // Usa tema
              title: Text(localization.addSkill), // Usa localização
              content: SingleChildScrollView(
                  child: Column(
                mainAxisSize: MainAxisSize.min,
                children: availablePericias.isEmpty
                    ? [
                        Center(
                            child: Text(
                                localization.translate('noSkillsToAdd'), // TODO: Localize
                                style: TextStyle(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurface
                                        .withOpacity(0.7))))
                      ]
                    : availablePericias
                        .map((pericia) => ListTile(
                              title: Text(pericia), // Usa tema
                              onTap: () {
                                if (!mounted) return; // Checa antes de setState
                                setState(() {
                                  _periciasExibidas.add(pericia);
                                  _periciasExibidas.sort();
                                  _periciasControllers[pericia] =
                                      TextEditingController(text: '0');
                                  // Adiciona listener ao novo controller
                                  _periciasControllers[pericia]
                                      ?.addListener(_onFieldChanged);
                                  // Define maestria inicial como Novato
                                  _periciaMaestria[pericia] =
                                      MaestriaLevel.Novato.toJsonString();
                                  _periciaProficiencia[pericia] = 0;
                                });
                                Navigator.of(context).pop();
                                _onFieldChanged(); // Trigger save
                              },
                            ))
                        .toList(),
              )),
              actions: [
                TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text(localization.close)) // Usa localização
              ],
            ));
  }

  // Abre formulário para adicionar/editar Item, Arma, Armadura, Habilidade, etc.
  void _openEntityForm<T>({T? entity}) {
    EntityType? type;
    // Determina o tipo de entidade
    if (T == Weapon) {
      type = EntityType.weapon;
    } else if (T == Armor)
      type = EntityType.armor;
    else if (T == Item)
      type = EntityType.item;
    else if (T == Ability)
      type = EntityType.ability;
    else if (T == Passive)
      type = EntityType.passive;
    else if (T == StatusEffect) type = EntityType.statusEffect;

    if (type == null) {
      print("Tipo de entidade desconhecido: $T");
      return;
    }

    Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => AddEditEntityForm(
              entityType: type!,
              initialEntity: entity,
              // Passa listas atuais para preencher dropdowns no formulário
              characterAttributes: _attributesControllers.keys.toList(),
              characterPericias: _periciasExibidas,
              characterWeapons: _inventory.whereType<Weapon>().toList(),
              characterAbilities: _abilities,
              // Callback chamado ao salvar no formulário
              onSave: (savedEntity) {
                if (!mounted) return; // Checa antes de setState
                setState(() {
                  if (entity != null) {
                    // Editando
                    // Lógica para substituir a entidade existente na lista correta
                    if (savedEntity is Item) {
                      // Inclui Weapon e Armor
                      final index =
                          _inventory.indexWhere((i) => i.id == savedEntity.id);
                      if (index != -1) _inventory[index] = savedEntity;
                    } else if (savedEntity is Ability) {
                      final index =
                          _abilities.indexWhere((a) => a.id == savedEntity.id);
                      if (index != -1) _abilities[index] = savedEntity;
                    } else if (savedEntity is Passive) {
                      final index =
                          _passives.indexWhere((p) => p.id == savedEntity.id);
                      if (index != -1) _passives[index] = savedEntity;
                    } else if (savedEntity is StatusEffect) {
                      final index = _statusEffects
                          .indexWhere((e) => e.id == savedEntity.id);
                      if (index != -1) _statusEffects[index] = savedEntity;
                    }
                  } else {
                    // Adicionando nova entidade
                    if (savedEntity is Item) {
                      _inventory.add(savedEntity); // Inclui Weapon e Armor
                    } else if (savedEntity is Ability)
                      _abilities.add(savedEntity);
                    else if (savedEntity is Passive)
                      _passives.add(savedEntity);
                    else if (savedEntity is StatusEffect)
                      _statusEffects.add(savedEntity);
                  }
                });
                _onFieldChanged(); // Trigger save
              },
            )));
  }

  // Calcula bônus de passivas, itens, habilidades ativas e efeitos de status
  PassiveBonuses _getBonusesFor(String target) {
    int modifier = 0;
    double multiplier = 1.0;
    int bonusPoints = 0;
    List<BonusSource> sources = [];

    // Fontes de bônus: Passivas ativas/stackadas, Itens equipados, Habilidades ativas, Efeitos manuais
    final allSources = [
      ..._passives.where((p) =>
          p.isActive ||
          p.triggerType == context.loc.alwaysActive || // ATUALIZADO
          p.stacks > 0),
      ..._inventory.where((i) => i.isEquipped),
      ..._abilities.where((a) => a.isActive),
      ..._statusEffects,
    ];

    for (var source in allSources) {
      List<dynamic> effects = []; // Lista genérica para efeitos
      int stacks = 1; // Número de acumulações (para passivas)
      String sourceName = ''; // Nome da fonte (ex: "Espada Longa", "Fúria")

      // Determina a lista de efeitos e o nome da fonte
      if (source is Passive) {
        effects = source.effects;
        stacks = source.stacks > 0 ? source.stacks : 1; // Usa stacks se > 0
        sourceName = source.name;
      } else if (source is Item) {
        effects = source.effects;
        sourceName = source.name;
      } else if (source is Ability) {
        effects = source.effects;
        sourceName = source.name;
      } else if (source is StatusEffect) {
        // StatusEffect é o próprio efeito
        effects = [source];
        sourceName = source.name;
      }

      // Itera sobre os efeitos da fonte
      for (var effect in effects) {
        // Garante que effect.targets existe e é uma lista antes de verificar
        final effectTargets = (effect?.targets as List<String>?) ?? [];

        if (effect != null && effectTargets.contains(target)) {
          // Aplica o bônus com base no tipo
          final value =
              (effect.value as num?)?.toDouble() ?? 0.0; // Garante que value é double

          if (effect.bonusType == context.loc.modifier) { // ATUALIZADO
            final totalValue = (value * stacks).toInt(); // Modificador é inteiro
            modifier += totalValue;
            sources.add(BonusSource(
                sourceName: sourceName,
                value: '${totalValue >= 0 ? '+' : ''}$totalValue',
                type: 'Mod.'));
          } else if (effect.bonusType == context.loc.percentual) { // ATUALIZADO
            final totalValue = value * stacks; // Percentual pode ser double
            multiplier *= (1 + totalValue / 100.0); // Aplica multiplicativamente
            sources.add(BonusSource(
                sourceName: sourceName,
                value: '+${totalValue.toStringAsFixed(0)}%',
                type: 'Mult.'));
          } else if (effect.bonusType == context.loc.bonusPoints) { // ATUALIZADO
            final totalValue = (value * stacks).toInt(); // Pontos são inteiros
            bonusPoints += totalValue;
            sources.add(BonusSource(
                sourceName: sourceName, value: '+$totalValue', type: 'Pts.'));
          }
          // Ignora 'Conceder Armadura' aqui, pois é tratado separadamente no bloqueio
        }
      }
    }
    // Garante que o multiplicador não seja negativo
    multiplier = max(0.0, multiplier);
    return PassiveBonuses(
        modifier: modifier,
        multiplier: multiplier,
        bonusPoints: bonusPoints,
        sources: sources);
  }

  // Calcula o valor total de um status (ex: Vida Total) considerando bônus
  int _getTotalStatWithBonuses(String statName) {
    // Garante que o controller existe
    final totalController = _statusControllers[statName]?['total'];
    if (totalController == null) {
      return 1; // Retorna 1 se o status não existir
    }

    int baseTotal = int.tryParse(totalController.text) ?? 1; // Mínimo 1
    final bonuses = _getBonusesFor(statName); // Calcula bônus para esse status
    // Aplica bônus: Modificador é somado, Pontos de Bônus são somados
    int modifiedTotal = baseTotal + bonuses.modifier + bonuses.bonusPoints;
    // Multiplicador é aplicado (se houver)
    int finalTotal = (modifiedTotal * bonuses.multiplier).round();

    // Adiciona bônus extra (ex: manaExtra)
    if (statName == 'Mana') {
      finalTotal += int.tryParse(_manaExtraController.text) ?? 0;
    }

    // Retorna o maior valor entre 1 e o total calculado
    return max(1, finalTotal);
  }

  // Usa uma arma (realiza rolagem de ataque)
  void _useWeapon(Weapon weapon) {
    // 1. Obter bônus passivos para esta arma específica
    final bonuses = _getBonusesFor(weapon.name);

    // 2. Obter nível de Maestria da Arma
    final int maestriaArma = _armaMaestria[weapon.name] ?? 0; // Nível 0-4

    // 3. Calcular dados de Scaling com base nos atributos, maestria e proficiência
    int attributePoints = 0;
    String attributeUsed =
        weapon.attributeScaling.split('/').first; // Pega o primeiro atributo para cálculo base
    String? maestriaNivel = 'Novato'; // Assume novato para cálculo dos dados de scaling
    int proficienciaNivel = 0;

    // TODO: Determinar a maestria e proficiência corretas para o atributo usado (FOR ou DES)
    // Isso pode exigir buscar a maestria da *perícia* associada ou do *atributo*
    // Exemplo simplificado (assumindo que scaling usa a maestria do atributo):
    if (_attributesControllers.containsKey(attributeUsed)) {
      attributePoints =
          int.tryParse(_attributesControllers[attributeUsed]!.text) ?? 0;
      // Aqui você precisaria ter maestria/proficiência para ATRIBUTOS também,
      // ou associar a uma perícia (ex: Luta para Força, Pontaria para Destreza)
      // Exemplo: maestriaNivel = _periciaMaestria['Luta'] ?? 'Novato';
      // Exemplo: proficienciaNivel = _periciaProficiencia['Luta'] ?? 0;
    }

    // Aplica bônus percentual da proficiência aos pontos do atributo antes de calcular os dados
    double profMultiplier =
        DarkAgeLogic.getProficiencyMultiplier(proficienciaNivel);
    int effectiveAttributePoints = (attributePoints * profMultiplier).round();

    // Calcula os dados que vêm do scaling do atributo
    final scalingRollData = DarkAgeLogic.getRollData(
        effectiveAttributePoints ~/ weapon.pointsPerDie, // Divide os pontos pelo custo da arma
        maestriaNivel,
        proficienciaNivel);

    // 4. Combina dados base da arma (se houver) com dados de scaling e bônus
    final List<DieSpecification> allDice = [
      ...weapon.dice, // Dados fixos da arma (raro)
      ...scalingRollData.dice, // Dados do scaling de atributo
      // Adiciona dados de "Pontos de Bônus" de passivas/itens
      // (Convertidos usando a lógica Dark Age)
      ...DarkAgeLogic.getRollData(
              bonuses.bonusPoints, maestriaNivel, proficienciaNivel)
          .dice,
    ];

    // 5. Calcula modificador e bônus fixo
    int modifier = weapon.modifier + bonuses.modifier; // Modificador da arma + passivas
    int fixedBonus =
        scalingRollData.fixedBonus; // Bônus fixo de Mestre/Proficiência do atributo

    // 6. Realiza a rolagem
    _performRoll(
      name: weapon.name,
      dice: allDice,
      modifier: modifier,
      multiplier:
          weapon.multiplier * bonuses.multiplier, // Multiplicadores da arma e passivas
      triggers: weapon.triggers, // Gatilhos da arma
      bonusSources: bonuses.sources, // Detalhamento dos bônus
      fixedBonus: fixedBonus, // Bônus fixo do atributo
    );

    // TODO: Implementar lógica de Acerto vs Defesa do Alvo
    // TODO: Implementar lógica de Dano vs HP do Alvo
    // TODO: Implementar lógica de Crítico (d100) e Ferimentos Graves
    // TODO: Implementar lógica de consumo de Resistência da Arma
  }

  // Mostra diálogo para editar Maestria e Proficiência de uma perícia
  void _showEditMaestriaDialog(String pericia) {
    final localization = AppLocalizations.of(context);
    // Pega os valores atuais da ficha
    MaestriaLevel currentLevel =
        MaestriaLevel.fromString(_periciaMaestria[pericia]);
    int currentProficiencia = _periciaProficiencia[pericia] ?? 0;
    final proficienciaController =
        TextEditingController(text: currentProficiencia.toString());

    showDialog(
      context: context,
      builder: (dialogContext) {
        // StatefulBuilder é necessário para que o diálogo possa atualizar
        // a si mesmo (ex: habilitar/desabilitar o campo de proficiência)
        return StatefulBuilder(
          builder: (context, setDialogState) {
            bool isProficienciaEnabled =
                currentLevel == MaestriaLevel.Proficiencia;

            return AlertDialog(
              backgroundColor:
                  Theme.of(context).cardColor, // Usa cor do tema
              title: Text(localization.editMaestriaTitle(pericia)),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Dropdown para Nível de Maestria
                    Text(localization.maestriaLevel,
                        style: Theme.of(context).textTheme.labelMedium),
                    DropdownButtonFormField<MaestriaLevel>(
                      value: currentLevel,
                      dropdownColor:
                          Theme.of(context).cardColor, // Usa cor do tema
                      items: MaestriaLevel.values
                          .map((MaestriaLevel level) {
                        String levelName = '';
                        switch (level) {
                          case MaestriaLevel.Novato:
                            levelName = localization.novice;
                            break;
                          case MaestriaLevel.Treinado:
                            levelName = localization.trained;
                            break;
                          case MaestriaLevel.Mestre:
                            levelName = localization.master;
                            break;
                          case MaestriaLevel.Proficiencia:
                            levelName = localization.proficiency;
                            break;
                        }
                        return DropdownMenuItem<MaestriaLevel>(
                          value: level,
                          child: Text(levelName), // Usa texto localizado
                        );
                      }).toList(),
                      onChanged: (MaestriaLevel? newValue) {
                        if (newValue != null) {
                          setDialogState(() {
                            currentLevel = newValue;
                            isProficienciaEnabled =
                                (newValue == MaestriaLevel.Proficiencia);
                            // Se não for Proficiência, zera o nível de proficiência
                            if (!isProficienciaEnabled) {
                              currentProficiencia = 0;
                              proficienciaController.text = '0';
                            } else if (currentProficiencia == 0) {
                              // Se virou proficiência e estava 0, define como 1 (ou mantém 0 se preferir)
                              currentProficiencia = 1; // Começa em P I
                              proficienciaController.text = '1';
                            }
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 20),

                    // Campo de texto para Nível de Proficiência
                    Text(localization.proficienciaLevel,
                        style: Theme.of(context).textTheme.labelMedium),
                    TextField(
                      controller: proficienciaController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      enabled:
                          isProficienciaEnabled, // Só habilita se Maestria for Proficiência
                      decoration: InputDecoration(
                        hintText: isProficienciaEnabled
                            ? '1-20'
                            : localization.translate(
                                'notApplicable'), // TODO: Localize N/A
                        filled: !isProficienciaEnabled, // Destaca se estiver desabilitado
                        fillColor: isProficienciaEnabled
                            ? null
                            : Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withOpacity(0.1),
                      ),
                      onChanged: (value) {
                        currentProficiencia = int.tryParse(value) ?? 0;
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  child: Text(localization.cancel),
                ),
                TextButton(
                  onPressed: () {
                    // Salva os valores do diálogo de volta para a ficha
                    setState(() {
                      _periciaMaestria[pericia] =
                          currentLevel.toJsonString();
                      _periciaProficiencia[pericia] =
                          currentProficiencia.clamp(0, 20); // Garante 0-20
                    });
                    _onFieldChanged(); // Dispara o auto-save
                    Navigator.of(dialogContext).pop();
                  },
                  child: Text(localization.saveChanges),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // Exclui uma habilidade
  void _deleteAbility(Ability ability) {
    if (!mounted) return;
    setState(() => _abilities.removeWhere((a) => a.id == ability.id));
    _onFieldChanged(); // Trigger save
  }

  // Calcula o custo de fadiga de uma habilidade
  int _calculateFatigueCost(Ability ability) {
    if (ability.costAmount <= 0) return 0; // Sem custo, sem fadiga

    double multiplier = 1.0;
    // Tabela de multiplicador de fadiga (ajuste conforme regras)
    switch (ability.usesInCombat) {
      case 0:
        multiplier = 1.0;
        break; // Primeiro uso
      case 1:
        multiplier = 1.3;
        break; // Segundo uso (+30%)
      case 2:
        multiplier = 1.6;
        break; // Terceiro uso (+60%)
      case 3:
        multiplier = 2.0;
        break; // Quarto uso (x2)
      case 4:
        multiplier = 2.5;
        break; // Quinto uso (x2.5)
      case 5:
        multiplier = 3.0;
        break; // Sexto uso (x3)
      case 6:
        multiplier = 4.0;
        break; // Sétimo uso (x4)
      case 7:
        multiplier = 5.0;
        break; // Oitavo uso (x5)
      default:
        multiplier = 7.0;
        break; // Demais usos (x7)
    }
    // Arredonda o custo final para o inteiro mais próximo
    return (ability.costAmount * multiplier).round();
  }

  // Verifica se há recursos suficientes para pagar um custo
  bool _hasEnoughResources(int cost, String costType, String costSource) {
    if (cost <= 0) return true; // Custo zero sempre pode ser pago
    final localization = AppLocalizations.of(context);

    // Garante que os controllers existem
    final manaController = _statusControllers['Mana']?['atual'];
    final tempManaController = _statusControllers['Mana Temporária']?['atual'];

    if (costType == localization.effort) { // ATUALIZADO (usa 'Mana')
      if (manaController == null || tempManaController == null) {
        return false; // Não pode pagar se controllers não existem
      }
      final tempMana = int.tryParse(tempManaController.text) ?? 0;
      final standardMana = int.tryParse(manaController.text) ?? 0;

      switch (costSource) {
        case 'Apenas Temporário': // TODO: Usar localization.temporaryOnly
          return tempMana >= cost;
        case 'Padrão': // TODO: Usar localization.standard
          return standardMana >= cost;
        case 'Híbrido (Temp. > Padrão)': // TODO: Usar localization.hybridTempStandard
          return (tempMana + standardMana) >= cost;
        default: // Assume Padrão como default
          return standardMana >= cost;
      }
    } else {
      // Para Vida, Estamina, etc.
      String statusKey;
      if (costType == localization.health) {
        statusKey = 'Vida';
      } else if (costType == localization.sanity) { // 'Sanidade' agora é 'Estamina'
        statusKey = 'Estamina';
      } else {
        statusKey = costType; // Caso seja 'Vida' direto
      }

      final controller = _statusControllers[statusKey]?['atual'];
      if (controller == null) {
        return false; // Não pode pagar se controller não existe
      }
      final resource = int.tryParse(controller.text) ?? 0;
      return resource >= cost;
    }
  }

  // Deduz o custo de Mana (considerando fonte Padrão, Temporário ou Híbrido)
  // Retorna true se conseguiu pagar, false caso contrário.
  bool _payMana(int cost, String source) { // Renomeado de _payEffort
    if (cost <= 0) return true; // Custo zero não precisa ser pago
    final localization = AppLocalizations.of(context);

    // Garante que os controllers existem
    final tempManaController = _statusControllers['Mana Temporária']?['atual'];
    final manaController = _statusControllers['Mana']?['atual'];
    if (manaController == null || tempManaController == null) {
      return false; // Falha se controllers não existem
    }

    int tempMana = int.tryParse(tempManaController.text) ?? 0;
    int mana = int.tryParse(manaController.text) ?? 0;

    // TODO: Usar chaves de localização para comparar 'source'
    if (source == localization.temporaryOnly) { // 'Apenas Temporário'
      if (tempMana >= cost) {
        tempManaController.text = (tempMana - cost).toString();
        widget.showToast(localization.effortTempConsumedToast(cost)); // Chave ARB ainda é 'effortTempConsumedToast'
        return true; // Pagamento bem-sucedido
      } else {
        return false; // Falha no pagamento
      }
    } else if (source == localization.standard) { // 'Padrão'
      if (mana >= cost) {
        manaController.text = (mana - cost).toString();
        // Não mostra toast para mana padrão, geralmente é o esperado
        return true;
      } else {
        return false;
      }
    } else {
      // 'Híbrido (Temp. > Padrão)'
      if ((tempMana + mana) >= cost) {
        int costLeft = cost;
        int toDeductFromTemp = min(costLeft, tempMana);
        if (toDeductFromTemp > 0) {
          tempManaController.text = (tempMana - toDeductFromTemp).toString();
          costLeft -= toDeductFromTemp;
          widget.showToast(localization.effortTempConsumedToast(toDeductFromTemp)); // Chave ARB ainda é 'effortTempConsumedToast'
        }
        if (costLeft > 0) {
          manaController.text = (mana - costLeft).toString();
        }
        return true; // Pagamento bem-sucedido
      } else {
        return false; // Falha no pagamento
      }
    }
  }

  // Usa uma habilidade (verifica cooldown, custo, fadiga e executa o efeito)
  void _useAbility(Ability ability) {
    final localization = AppLocalizations.of(context);
    // 1. Verifica Cooldown
    if (ability.currentCooldown > 0) {
      widget.showToast(
          localization.cooldownToast(ability.name, ability.currentCooldown));
      return;
    }

    // 2. Calcula Custo com Fadiga
    final fatigueCost = _calculateFatigueCost(ability);

    // 3. Verifica Recursos e Paga Custo
    bool paid = false;
    if (fatigueCost > 0) {
      // ATUALIZADO: Verifica 'Mana' e 'Estamina' usando localization keys
      if (ability.costType == localization.effort) { // "Esforço" (agora Mana)
        paid = _payMana(fatigueCost, ability.costSource);
      } else {
        String statusKey;
        if (ability.costType == localization.health) { // "Vida"
          statusKey = 'Vida';
        } else if (ability.costType == localization.sanity) { // "Sanidade" (agora Estamina)
          statusKey = 'Estamina';
        } else {
          statusKey = ability.costType; // Caso raro
        }

        // Paga outros recursos (Vida, Estamina)
        final controller = _statusControllers[statusKey]?['atual'];
        if (controller != null) {
          int current = int.tryParse(controller.text) ?? 0;
          if (current >= fatigueCost) {
            controller.text = (current - fatigueCost).toString();
            paid = true;
          }
        }
      }
    } else {
      paid = true; // Custo zero é sempre pago
    }

    if (!paid) {
      widget.showToast(localization.insufficientResourcesToast);
      return; // Para se não puder pagar
    }

    // 4. Incrementa Usos em Combate (se custo foi pago)
    bool usesChanged = false;
    if (ability.costAmount > 0) {
      // Só incrementa fadiga se a habilidade tem custo
      ability.usesInCombat++;
      usesChanged = true;
    }

    // 5. Aplica Cooldown (se custo foi pago)
    bool cooldownChanged = false;
    if (ability.cooldown > 0) {
      ability.currentCooldown =
          ability.cooldown + 1; // +1 porque o round atual conta
      cooldownChanged = true;
    }

    // 6. Executa o Efeito da Habilidade
    // ATUALIZADO: Checa localization keys para tipos de habilidade
    if (ability.abilityType == localization.damage ||
        ability.abilityType == localization.restoreHealth ||
        ability.abilityType == localization.restoreEffort || // "Restaurar Esforço" (agora Mana)
        ability.abilityType == localization.defense) {
      final List<DieSpecification> dice = [];
      int modifier = ability.bonusModifier; // Modificador base da habilidade
      int bonusPoints = 0; // Pontos de bônus de passivas/itens
      List<BonusSource> bonusSources = []; // Detalhamento dos bônus

      // Adiciona dados fixos da habilidade
      dice.addAll(ability.bonusDice);

      String baseMaestria =
          'Novato'; // Assume Novato como padrão para cálculo de bônus
      int baseProficiencia = 0;

      // Calcula pontos baseados nos Atributos/Perícias e seus bônus
      for (var base in ability.baseComponents) {
        int points = 0;
        String sourceName = base.value; // Nome do atributo/perícia
        String currentMaestria = 'Novato';
        int currentProficiencia = 0;

        // Obtém pontos do atributo/perícia
        if (base.type == 'Atributo' &&
            _attributesControllers.containsKey(base.value)) {
          points = int.tryParse(_attributesControllers[base.value]!.text) ?? 0;
          // TODO: Obter Maestria/Proficiência do Atributo (se implementado)
          // currentMaestria = _atributoMaestria[base.value] ?? 'Novato';
          // currentProficiencia = _atributoProficiencia[base.value] ?? 0;
        } else if (base.type == 'Perícia' &&
            _periciasControllers.containsKey(base.value)) {
          points = int.tryParse(_periciasControllers[base.value]!.text) ?? 0;
          currentMaestria = _periciaMaestria[base.value] ?? 'Novato';
          currentProficiencia = _periciaProficiencia[base.value] ?? 0;
        }

        // Usa a maior maestria/proficiência encontrada como base para converter Pontos de Bônus
        // (Pode ajustar essa lógica se preferir)
        if (MaestriaLevel.fromString(currentMaestria).index >
                MaestriaLevel.fromString(baseMaestria).index ||
            currentProficiencia > baseProficiencia) {
          baseMaestria = currentMaestria;
          baseProficiencia = currentProficiencia;
        }

        // Obtém bônus passivos para esse atributo/perícia
        final bonuses = _getBonusesFor(sourceName);
        bonusPoints +=
            points + bonuses.bonusPoints; // Soma pontos base + pontos de bônus
        modifier += bonuses.modifier; // Soma modificadores
        bonusSources.addAll(bonuses.sources); // Adiciona fontes
      }

      // Converte os pontos totais (base + bônus) em dados Dark Age
      final rollData =
          DarkAgeLogic.getRollData(bonusPoints, baseMaestria, baseProficiencia);
      dice.addAll(rollData.dice);
      int fixedBonus =
          rollData.fixedBonus; // Bônus fixo de Mestre/Proficiência

      // Executa a rolagem (se for Defesa, pede o dano recebido)
      if (ability.abilityType == localization.defense) {
        // Mostra diálogo para inserir o dano recebido
        final damageController = TextEditingController();
        String damageType = _damageTypes.first;
        showDialog(
            context: context,
            builder: (context) => AlertDialog(
                  // backgroundColor: Colors.grey[850], // Usa tema
                  title: Text(
                      '${localization.use} ${ability.name}'), // Usa localização
                  content: StatefulBuilder(builder: (context, setDialogState) {
                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextField(
                            controller: damageController,
                            decoration: InputDecoration(
                                labelText: localization.damageTaken),
                            keyboardType: TextInputType.number), // Usa localização
                        const SizedBox(height: 16),
                        DropdownButtonFormField<String>(
                          value: damageType,
                          items: _damageTypes
                              .map((String value) => DropdownMenuItem<String>(
                                  value: value, child: Text(value)))
                              .toList(), // Usa tema
                          onChanged: (newValue) {
                            if (newValue != null) {
                              setDialogState(() => damageType = newValue);
                            }
                          },
                          // dropdownColor: Colors.grey[850], // Usa tema
                          decoration: InputDecoration(
                              labelText: localization.damageType), // Usa localização
                        ),
                      ],
                    );
                  }),
                  actions: [
                    TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: Text(localization.cancel)),
                    TextButton(
                        onPressed: () {
                          final incomingDamage =
                              int.tryParse(damageController.text) ?? 0;
                          Navigator.of(context).pop();

                          if (incomingDamage > 0) {
                            // Realiza a rolagem de defesa contra o dano
                            final rollResult = _performRoll(
                              name: ability.name,
                              dice: dice,
                              modifier: modifier,
                              multiplier: ability.multiplier,
                              triggers: ability.conditionalEffects,
                              bonusSources: bonusSources,
                              defenseTarget: incomingDamage,
                              fixedBonus: fixedBonus,
                            );

                            int finalDamage =
                                rollResult.total < 0 ? rollResult.total.abs() : 0;

                            // Aplica resistências da armadura ao dano que passou
                            if (finalDamage > 0) {
                              // Considera apenas a armadura equipada principal para resistência de habilidades de defesa?
                              final equippedArmor =
                                  this.equippedArmor; // Usando o getter
                              if (equippedArmor != null) {
                                // Calcula o multiplicador de resistência
                                // Valor no mapa: 0.5 = 50% res (multiplica por 0.5)
                                // Valor no mapa: 1.5 = 50% vul (multiplica por 1.5)
                                double armorResistance =
                                    equippedArmor.resistances[damageType] ??
                                        1.0;
                                finalDamage =
                                    (finalDamage * armorResistance).round();
                              }
                              // TODO: Considerar outras fontes de resistência?
                            }

                            // Aplica dano à vida
                            if (finalDamage > 0) {
                              _unaccountedDamageTaken +=
                                  finalDamage; // Para gatilhos
                              final hpController =
                                  _statusControllers['Vida']?['atual'];
                              if (hpController != null) {
                                final currentHp =
                                    int.tryParse(hpController.text) ?? 0;
                                final newHp = currentHp - finalDamage;
                                hpController.text = newHp
                                    .toString(); // Chama _onStatusChange
                              }
                            } else {
                              _checkAllStatusPassives(); // Checa passivas mesmo se dano for 0
                            }
                          } else {
                            // Se dano recebido é 0, apenas rola a defesa (sem alvo) para histórico?
                            _performRoll(
                                name:
                                    '${ability.name} (Defesa sem Dano)', // TODO: Localize
                                dice: dice,
                                modifier: modifier,
                                multiplier: ability.multiplier,
                                triggers: ability.conditionalEffects,
                                bonusSources: bonusSources,
                                fixedBonus: fixedBonus);
                          }
                        },
                        child: Text(localization.apply)), // Usa localização
                  ],
                ));
      } else {
        // Dano, Restaurar Vida, Restaurar Mana
        // Realiza a rolagem normal
        final result = _performRoll(
          name: ability.name,
          dice: dice,
          modifier: modifier,
          multiplier: ability.multiplier,
          triggers: ability.conditionalEffects,
          bonusSources: bonusSources,
          fixedBonus: fixedBonus,
        );

        // Aplica cura ou adiciona Mana Temporária
        if (ability.abilityType == localization.restoreHealth) { // "Restaurar Vida"
          final hpController = _statusControllers['Vida']?['atual'];
          final hpTotal =
              _getTotalStatWithBonuses('Vida'); // Considera bônus no total
          if (hpController != null) {
            final vidaAtual = int.tryParse(hpController.text) ?? 0;
            final novaVida =
                min(vidaAtual + result.total, hpTotal); // Limita ao total
            if (novaVida != vidaAtual) {
              hpController.text = novaVida.toString(); // Só atualiza se mudar
            }
          }
        } else if (ability.abilityType == localization.restoreEffort) { // "Restaurar Esforço" (agora Mana)
          final manaController = _statusControllers['Mana']?['atual'];
          final manaTotal = _getTotalStatWithBonuses('Mana');
          final tempManaCurrentController =
              _statusControllers['Mana Temporária']?['atual'];
          final tempManaTotalController =
              _statusControllers['Mana Temporária']?['total'];

          if (manaController != null &&
              tempManaCurrentController != null &&
              tempManaTotalController != null) {
            final manaAtual = int.tryParse(manaController.text) ?? 0;
            final tempManaAtual =
                int.tryParse(tempManaCurrentController.text) ?? 0;
            final tempManaTotal =
                int.tryParse(tempManaTotalController.text) ?? 0;

            int amountToHeal = result.total;
            bool effortChanged = false;

            // Cura Mana Padrão até o limite
            int healedMana = min(amountToHeal, manaTotal - manaAtual);
            if (healedMana > 0) {
              manaController.text = (manaAtual + healedMana).toString();
              amountToHeal -= healedMana;
              effortChanged = true;
            }

            // Adiciona o restante como Mana Temporária (aumenta atual e total)
            if (amountToHeal > 0) {
              tempManaTotalController.text =
                  (tempManaTotal + amountToHeal).toString();
              tempManaCurrentController.text =
                  (tempManaAtual + amountToHeal).toString();
              widget.showToast(localization.translate('effortTempAddedToast',
                  args: {
                    'amount': amountToHeal
                  })); // TODO: Renomear chave para manaTempAddedToast
              effortChanged = true;
            }
            // Se nada mudou, não precisa chamar _onFieldChanged
            // if (effortChanged) _onFieldChanged(); // Atualiza listeners se esforço mudou
          }
        }
        // Se for 'Dano', a rolagem já foi exibida, o mestre aplica o dano ao alvo.
      }
    }
    // Lógica para outros tipos de habilidade
    else if (ability.abilityType == localization.buffTransform) { // "Buff/Transformação"
      // Alterna o estado ativo do buff
      ability.isActive = !ability.isActive;
      widget.showToast(ability.isActive
          ? localization.abilityActiveToast(ability.name)
          : localization.abilityDeactiveToast(ability.name));
      // Trigger save
      usesChanged = true; // Marca como alterado para salvar
    } else if (ability.abilityType == localization.createArmor) { // "Criar Armadura"
      if (ability.armorToCreate != null) {
        // Cria uma *cópia* da armadura definida e a adiciona como temporária
        final newArmor =
            Armor.fromJson(ability.armorToCreate!.toJson()); // Cria cópia
        newArmor.isEquipped = false; // Armadura temporária não é "equipada" no inventário
        _temporaryArmors.add(newArmor);
        widget.showToast(localization.armorCreatedToast(newArmor.name));
        usesChanged = true; // Marca como alterado
      }
    } else {
      // Habilidade sem efeito implementado
      widget.showToast(
          localization.abilityNotImplementedToast(ability.abilityType));
    }

    // Chama setState uma única vez no final se houve mudanças
    if ((usesChanged || cooldownChanged) && mounted) {
      setState(() {});
      _onFieldChanged(); // Salva as mudanças de usesInCombat e currentCooldown
    } else if (mounted) {
      // Se pagou custo, mas não houve outra mudança, salva mesmo assim
      if (paid && fatigueCost > 0) _onFieldChanged();
    }
  }

  // Exclui uma passiva
  void _deletePassive(Passive passive) {
    if (!mounted) return;
    setState(() => _passives.remove(passive));
    _onFieldChanged(); // Trigger save
  }

  // Sobe de nível
  void _levelUp() {
    if (!mounted) return;
    setState(() {
      final currentLevel = int.tryParse(_levelController.text) ?? 0;
      _levelController.text = (currentLevel + 1).toString();
      _applyLevelGains(1); // Aplica ganhos de 1 nível
    });
    _onFieldChanged(); // Trigger save
  }

  // Desce de nível
  void _levelDown() {
    if (!mounted) return;
    final currentLevel = int.tryParse(_levelController.text) ?? 1;
    if (currentLevel > 1) {
      setState(() {
        _levelController.text = (currentLevel - 1).toString();
        _applyLevelGains(-1); // Aplica "perdas" de 1 nível
      });
      _onFieldChanged(); // Trigger save
    }
  }

  // Aplica/remove ganhos de status por nível
  void _applyLevelGains(int levelChange) {
    // Garante que os controllers existem
    final hpTotalController = _statusControllers['Vida']?['total'];
    final manaTotalController = _statusControllers['Mana']?['total'];
    final staminaTotalController = _statusControllers['Estamina']?['total'];

    if (hpTotalController != null) {
      final currentHp = int.tryParse(hpTotalController.text) ?? 0;
      hpTotalController.text =
          max(1, currentHp + (_hpPerLevel * levelChange)).toString(); // Mínimo 1
    }
    if (manaTotalController != null) {
      final currentMana = int.tryParse(manaTotalController.text) ?? 0;
      manaTotalController.text = max(1, currentMana + (_manaPerLevel * levelChange))
          .toString(); // Mínimo 1
    }
    if (staminaTotalController != null) {
      final currentStamina = int.tryParse(staminaTotalController.text) ?? 0;
      staminaTotalController.text =
          max(1, currentStamina + (_staminaPerLevel * levelChange))
              .toString(); // Mínimo 1
    }
    // Opcional: Ajustar status atuais também? (Curar ao subir, manter ao descer?)
    // Ex: _statusControllers['Vida']?['atual']?.text = _statusControllers['Vida']!['total']!.text;
  }

  // Mostra diálogo para configurar ganhos por nível e calcular totais
  void _showGainsPerLevelDialog() {
    final localization = AppLocalizations.of(context);
    // Carrega valores atuais nos controllers do diálogo
    final hpController = TextEditingController(text: _hpPerLevel.toString());
    final manaController =
        TextEditingController(text: _manaPerLevel.toString()); // ATUALIZADO
    final staminaController =
        TextEditingController(text: _staminaPerLevel.toString()); // ATUALIZADO
    final atributoController =
        TextEditingController(text: _pontosAtributoPorNivel.toString());
    final periciaController =
        TextEditingController(text: _pontosPericiaPorNivel.toString());
    final vidaConController = TextEditingController(text: _vidaPorCon.toString());
    final manaSabController =
        TextEditingController(text: _manaPerSab.toString()); // ATUALIZADO
    final manaDesController =
        TextEditingController(text: _manaPerDes.toString()); // ATUALIZADO

    showDialog(
        context: context,
        builder: (context) {
          // Usa StatefulBuilder para atualizar totais de pontos no diálogo
          return StatefulBuilder(builder: (context, setDialogState) {
            final level = int.tryParse(_levelController.text) ?? 1;
            final pontosAtributo =
                int.tryParse(atributoController.text) ?? 0;
            final pontosPericia =
                int.tryParse(periciaController.text) ?? 0;
            final totalAtributo = level * pontosAtributo;
            final totalPericia = level * pontosPericia;

            // Adiciona listeners para atualizar os totais dinamicamente
            void updateTotals() => setDialogState(() {});
            atributoController.addListener(updateTotals);
            periciaController.addListener(updateTotals);

            return AlertDialog(
              backgroundColor: Theme.of(context).cardColor, // Usa tema
              title: Text(localization.levelGainsTitle),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildDialogTextField(hpController, localization.hpPerLevel),
                    _buildDialogTextField(
                        manaController, localization.effortPerLevel), // Chave ARB (effortPerLevel)
                    _buildDialogTextField(
                        staminaController, localization.sanityPerLevel), // Chave ARB (sanityPerLevel)
                    const Divider(height: 20),
                    _buildDialogTextField(
                        atributoController, localization.attributePointsPerLevel),
                    _buildDialogTextField(
                        periciaController, localization.skillPointsPerLevel),
                    const Divider(height: 20),
                    _buildDialogTextField(
                        vidaConController, localization.hpPerCon),
                    _buildDialogTextField(
                        manaSabController, localization.effortPerWis), // Chave ARB (effortPerWis)
                    _buildDialogTextField(
                        manaDesController, localization.effortPerDex), // Chave ARB (effortPerDex)
                    const Divider(height: 20),
                    Text(localization.totalAttributePoints(totalAtributo)),
                    Text(localization.totalSkillPoints(totalPericia)),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  // Botão Aplicar
                  onPressed: () {
                    if (!mounted) return;
                    // Recalcula totais de Vida e Mana com base nos valores do diálogo
                    final con =
                        int.tryParse(_attributesControllers['CON']!.text) ?? 0;
                    final sab =
                        int.tryParse(_attributesControllers['SAB']!.text) ?? 0;
                    final des =
                        int.tryParse(_attributesControllers['DES']!.text) ?? 0;
                    final currentLevel =
                        int.tryParse(_levelController.text) ?? 1;
                    // Usa os valores dos controllers DO DIÁLOGO para calcular
                    final vidaPorConCalc =
                        int.tryParse(vidaConController.text) ?? _vidaPorCon;
                    final hpPerLevelCalc =
                        int.tryParse(hpController.text) ?? _hpPerLevel;
                    final manaPorSabCalc =
                        int.tryParse(manaSabController.text) ?? _manaPerSab;
                    final manaPorDesCalc =
                        int.tryParse(manaDesController.text) ?? _manaPerDes;
                    final manaPerLevelCalc =
                        int.tryParse(manaController.text) ?? _manaPerLevel;
                    final staminaPerLevelCalc = 
                        int.tryParse(staminaController.text) ?? _staminaPerLevel;


                    final totalVida =
                        (con * vidaPorConCalc) + (currentLevel * hpPerLevelCalc);
                    final totalMana = (sab * manaPorSabCalc) +
                        (des * manaPorDesCalc) +
                        (currentLevel * manaPerLevelCalc);
                    final totalStamina = (currentLevel * staminaPerLevelCalc); // Assumindo que Estamina só escala com nível por enquanto


                    setState(() {
                      // Atualiza os status totais E atuais na ficha
                      _statusControllers['Vida']!['total']!.text =
                          max(1, totalVida).toString();
                      _statusControllers['Vida']!['atual']!.text =
                          max(1, totalVida).toString(); // Recupera ao aplicar
                      _statusControllers['Mana']!['total']!.text =
                          max(1, totalMana).toString();
                      _statusControllers['Mana']!['atual']!.text =
                          max(1, totalMana).toString(); // Recupera ao aplicar
                      _statusControllers['Estamina']!['total']!.text =
                          max(1, totalStamina).toString();
                      _statusControllers['Estamina']!['atual']!.text =
                          max(1, totalStamina).toString(); // Recupera ao aplicar

                      // Salva as configurações de ganho usadas no cálculo
                      _hpPerLevel = hpPerLevelCalc;
                      _manaPerLevel = manaPerLevelCalc;
                      _staminaPerLevel = staminaPerLevelCalc;
                      _pontosAtributoPorNivel = pontosAtributo;
                      _pontosPericiaPorNivel = pontosPericia;
                      _vidaPorCon = vidaPorConCalc;
                      _manaPerSab = manaPorSabCalc;
      ... 9651 lines left ...
