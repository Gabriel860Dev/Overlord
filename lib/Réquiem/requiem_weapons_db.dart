// lib/Réquiem/requiem_weapons_db.dart

import 'package:overlord/Réquiem/requiem_weapon.dart';

class RequiemWeaponsDB {
  // Lista predefinida com as armas base do sistema Réquiem das Almas
  static final List<RequiemWeapon> baseWeapons = [
    RequiemWeapon(
      name: 'Punho',
      baseDiceCount: 1, 
      diceSides: 4,     // Base 1d4
      bonusPerDie: 1,   // +1 por cada dado
      scalingAttribute: 'Punho', // Usa a regra especial (Força + Constituição)
      masteryPercentage: 5,      // 5% de dano extra por maestria
    ),
    RequiemWeapon(
      name: 'Espada',
      baseDiceCount: 2, // Assumindo que a base é 2 dados (para que 10 de Força = +2 dados = 4d10)
      diceSides: 10,
      bonusPerDie: 2,   // Como referiu: cada dado vem com um bónus de 2
      scalingAttribute: 'Força',
    ),
    RequiemWeapon(
      name: 'Chicote',
      baseDiceCount: 2,
      diceSides: 8,
      bonusPerDie: 1, 
      scalingAttribute: 'Destreza',
      masteryPercentage: 15,
    ),
    RequiemWeapon(
      name: 'Cano Curto',
      baseDiceCount: 2,
      diceSides: 8,
      bonusPerDie: 3, 
      scalingAttribute: 'Destreza',
      elementName: 'Morte',
      elementPercentage: 20,
    ),
    RequiemWeapon(
      name: 'Lâmina Oculta',
      baseDiceCount: 1,
      diceSides: 6,
      bonusPerDie: 0,
      scalingAttribute: 'Destreza',
    ),
    // --- Algumas armas clássicas adicionais para complementar a lista ---
    RequiemWeapon(
      name: 'Machado de Batalha',
      baseDiceCount: 2,
      diceSides: 12,
      bonusPerDie: 2,
      scalingAttribute: 'Força',
    ),
    RequiemWeapon(
      name: 'Adaga Rápida',
      baseDiceCount: 1,
      diceSides: 4,
      bonusPerDie: 1,
      scalingAttribute: 'Destreza',
      criticalMargin: 19, // Adagas costumam ter maior probabilidade de crítico (19-20)
    ),
    RequiemWeapon(
      name: 'Arco Longo',
      baseDiceCount: 2,
      diceSides: 8,
      bonusPerDie: 2,
      scalingAttribute: 'Destreza',
    ),
    RequiemWeapon(
      name: 'Cajado Arcano',
      baseDiceCount: 1,
      diceSides: 6,
      bonusPerDie: 1,
      scalingAttribute: 'Arcanismo', 
    ),
  ];

  // ==========================================
  // FUNÇÕES DE UTILIDADE
  // ==========================================

  /// Retorna apenas a lista de nomes para os Dropdowns da interface
  static List<String> get weaponNames => baseWeapons.map((w) => w.name).toList();

  /// Cria um clone exato da arma base.
  /// Isto é OBRIGATÓRIO porque, na ficha, o jogador vai poder alterar o dano,
  /// o bónus flat, e os elementos da arma sem afetar o "molde original".
  static RequiemWeapon getWeaponClone(String name) {
    final weaponTemplate = baseWeapons.firstWhere(
      (w) => w.name == name, 
      orElse: () => baseWeapons.first // Fallback de segurança para o Punho
    );
    
    return RequiemWeapon(
      name: weaponTemplate.name,
      baseDiceCount: weaponTemplate.baseDiceCount,
      diceSides: weaponTemplate.diceSides,
      bonusPerDie: weaponTemplate.bonusPerDie,
      extraFlatBonus: weaponTemplate.extraFlatBonus,
      scalingAttribute: weaponTemplate.scalingAttribute,
      masteryPercentage: weaponTemplate.masteryPercentage,
      criticalMargin: weaponTemplate.criticalMargin,
      elementName: weaponTemplate.elementName,
      elementPercentage: weaponTemplate.elementPercentage,
    );
  }
}