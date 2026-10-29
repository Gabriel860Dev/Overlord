class DieSpecification {
  final int quantity;
  final int sides;
  final String damageType;
  final int? rollResult; // Adicionado para guardar o resultado de um grupo de dados
  final List<int>? individualResults; // NOVO CAMPO para guardar os resultados individuais

  DieSpecification({
    required this.quantity,
    required this.sides,
    this.damageType = 'Físico',
    this.rollResult, // Adicionado ao construtor
    this.individualResults, // Adicionado ao construtor
  });

  Map<String, dynamic> toJson() {
    return {
      'quantity': quantity,
      'sides': sides,
      'damageType': damageType,
      // rollResult e individualResults não precisam de ser guardados no JSON.
    };
  }

  factory DieSpecification.fromJson(Map<String, dynamic> json) {
    return DieSpecification(
      quantity: json['quantity'],
      sides: json['sides'],
      damageType: json['damageType'] ?? 'Físico',
    );
  }
}