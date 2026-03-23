class Servico {
  final String? id;
  final String usuarioId;
  final String nome;
  final double preco;

  Servico({
    this.id,
    required this.usuarioId,
    required this.nome,
    required this.preco,
  });

  factory Servico.fromMap(Map<String, dynamic> map) {
    return Servico(
      id: map['id']?.toString(),
      usuarioId: (map['usuario_id'] ?? '').toString(),
      nome: (map['nome'] ?? '').toString(),
      preco: _parseDouble(map['preco']),
    );
  }

  static double _parseDouble(dynamic value) {
    if (value == null) return 0;
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString()) ?? 0;
  }
}
