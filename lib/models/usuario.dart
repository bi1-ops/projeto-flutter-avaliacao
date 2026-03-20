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
}
