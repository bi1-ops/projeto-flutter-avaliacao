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
}
