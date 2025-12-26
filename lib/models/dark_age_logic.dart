// lib/models/dark_age_logic.dart

import 'package:dark_age/models/die_specification.dart';
import 'package:dark_age/models/character_sheet.dart'; // Importa o enum MaestriaLevel

class DarkAgeLogic {
  /// Calcula os dados e o bônus fixo para uma rolagem de atributo/perícia
  /// com base nos pontos, nível de maestria e nível de proficiência.
  static RollData getRollData(int points, String maestriaStr, int proficiencia) {

    MaestriaLevel level = MaestriaLevel.fromString(maestriaStr);
    bool isProficiente = level == MaestriaLevel.Proficiencia && proficiencia > 0;

    // 1. Obter o Bônus Fixo (só se aplica a Mestre ou Proficiente)
    int fixedBonus = (level == MaestriaLevel.Mestre || isProficiente) ? points : 0;

    // 2. Definir a escala de dados com base no NÍVEL de maestria/proficiência
    // (1p, 2p, 3p, 4p, 5p-Fechado)
    List<int> diceScale = [];

    if (isProficiente) {
      // Usa a escala da Proficiência
      switch (proficiencia) {
        case 1: // P I
          diceScale = [8, 10, 12, 20, 30];
          break;
        case 2: // P II
          diceScale = [10, 12, 20, 30, 40];
          break;
        case 3: // P III
          diceScale = [12, 20, 30, 40, 50];
          break;
        case 4: // P IV (Exemplo, ajuste conforme sua tabela)
          diceScale = [20, 30, 40, 50, 60];
          break;
        case 5: // P V (Exemplo)
          diceScale = [30, 40, 50, 60, 70];
           break;
        case 7: // P VII (Exemplo)
            diceScale = [40, 50, 60, 70, 80];
           break;
        case 10: // P X (Exemplo)
            diceScale = [50, 60, 70, 80, 90];
           break;
        case 15: // P XV (Exemplo)
            diceScale = [60, 70, 80, 90, 95]; // Ajuste perto do D100
           break;
        case 20: // P XX (Exemplo D100)
          diceScale = [80, 90, 95, 98, 100]; // Ajuste final para D100
          break;
        default:
          // Fallback para Treinado se a proficiência for inválida (embora não deva acontecer)
          diceScale = [6, 8, 10, 12, 20];
      }
    } else if (level == MaestriaLevel.Mestre || level == MaestriaLevel.Treinado) {
      // Mestre usa a mesma escala do Treinado
      diceScale = [6, 8, 10, 12, 20];
    } else { // Novato
      diceScale = [4, 6, 8, 10, 12];
    }

    // 3. Calcular a quantidade de dados
    List<DieSpecification> dice = [];
    if (points <= 0) {
      // Regra para 0 pontos: rola 1d4 (ou como definido nas regras)
      dice.add(DieSpecification(quantity: 1, sides: 4, damageType: 'Base'));
      // Bônus fixo não se aplica se não houver pontos investidos
      return RollData(dice: dice, fixedBonus: 0);
    }

    int dFechadoCount = points ~/ 5; // Quantos dados "fechados" (o 5º)
    int dRestoPoints = points % 5; // Quantos pontos sobrando (1-4)

    if (dFechadoCount > 0) {
      // Adiciona os dados fechados
      dice.add(DieSpecification(quantity: dFechadoCount, sides: diceScale[4], damageType: 'Base'));
    }
    if (dRestoPoints > 0) {
      // Adiciona o dado correspondente aos pontos restantes
      dice.add(DieSpecification(quantity: 1, sides: diceScale[dRestoPoints - 1], damageType: 'Base'));
    }

    // Retorna os dados calculados e o bônus fixo (se aplicável)
    return RollData(dice: dice, fixedBonus: fixedBonus);
  }

  /// Calcula o modificador de bônus percentual da proficiência.
  static double getProficiencyMultiplier(int proficienciaLevel) {
    if (proficienciaLevel <= 0) return 1.0;
    // +10% por nível de proficiência
    return 1.0 + (proficienciaLevel * 0.10);
  }
}

/// Classe auxiliar para retornar os dados e o bônus fixo calculados.
class RollData {
  final List<DieSpecification> dice;
  final int fixedBonus;
  RollData({required this.dice, this.fixedBonus = 0});
}
