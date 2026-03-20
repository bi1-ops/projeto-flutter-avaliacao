import 'package:supabase_flutter/supabase_flutter.dart';

class AgendamentoService {
  final SupabaseClient _client = Supabase.instance.client;

  Future<List<Map<String, dynamic>>> listarAgendamentos(String usuarioId) async {
    final response = await _client
        .from('agendamentos')
        .select()
        .eq('usuario_id', usuarioId)
        .order('data')
        .order('hora');

    return List<Map<String, dynamic>>.from(response);
  }

  Future<Map<String, dynamic>> criarAgendamento({
    required String usuarioId,
    String? servicoId,
    required String nomeCliente,
    required DateTime data,
    required String hora,
    String status = 'pendente',
  }) async {
    final response = await _client
        .from('agendamentos')
        .insert({
          'usuario_id': usuarioId,
          'servico_id': servicoId,
          'nome_cliente': nomeCliente,
          'data': data.toIso8601String().split('T').first,
          'hora': hora,
          'status': status,
        })
        .select()
        .single();

    return Map<String, dynamic>.from(response);
  }

  Future<Map<String, dynamic>> atualizarAgendamento({
    required String id,
    String? servicoId,
    required String nomeCliente,
    required DateTime data,
    required String hora,
    required String status,
  }) async {
    final response = await _client
        .from('agendamentos')
        .update({
          'servico_id': servicoId,
          'nome_cliente': nomeCliente,
          'data': data.toIso8601String().split('T').first,
          'hora': hora,
          'status': status,
        })
        .eq('id', id)
        .select()
        .single();

    return Map<String, dynamic>.from(response);
  }

  Future<void> deletarAgendamento(String id) async {
    await _client.from('agendamentos').delete().eq('id', id);
  }
}
