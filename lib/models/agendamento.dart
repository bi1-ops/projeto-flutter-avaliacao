class Agendamento {
  final String? id;
  final String usuarioId;
  final String? servicoId;
  final String nomeCliente;
  final DateTime data;
  final String hora;
  final String status;

  Agendamento({
    this.id,
    required this.usuarioId,
    this.servicoId,
    required this.nomeCliente,
    required this.data,
    required this.hora,
    this.status = 'pendente',
  });

  factory Agendamento.fromMap(Map<String, dynamic> map) {
    return Agendamento(
      id: map['id']?.toString(),
      usuarioId: (map['usuario_id'] ?? '').toString(),
      servicoId: map['servico_id']?.toString(),
      nomeCliente: (map['nome_cliente'] ?? '').toString(),
      data: _parseDate(map['data']),
      hora: (map['hora'] ?? '').toString(),
      status: (map['status'] ?? 'pendente').toString(),
    );
  }

  static DateTime _parseDate(dynamic value) {
    if (value == null) return DateTime.now();
    if (value is DateTime) return value;
    return DateTime.tryParse(value.toString()) ?? DateTime.now();
  }
}
