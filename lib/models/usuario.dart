class Usuario {
  final String? id;
  final String nomeDeUsuario;
  final String email;
  final String? telefone;
  final DateTime? createdAt;

  Usuario({
    this.id,
    required this.nomeDeUsuario,
    required this.email,
    this.telefone,
    this.createdAt,
  });

  factory Usuario.fromMap(Map<String, dynamic> map) {
    return Usuario(
      id: map['id']?.toString(),
      nomeDeUsuario: (map['nome_de_usuario'] ?? '').toString(),
      email: (map['email'] ?? '').toString(),
      telefone: map['telefone']?.toString(),
      createdAt: _parseDateTime(map['created_at']),
    );
  }

  static DateTime? _parseDateTime(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    return DateTime.tryParse(value.toString());
  }
}
