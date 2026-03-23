import 'package:supabase_flutter/supabase_flutter.dart';

class ServicoService {
  final SupabaseClient _client = Supabase.instance.client;

  Future<List<Map<String, dynamic>>> listarServicos(String usuarioId) async {
    final response = await _client
        .from('servicos')
        .select()
        .eq('usuario_id', usuarioId)
        .order('nome');

    return List<Map<String, dynamic>>.from(response);
  }

  Future<Map<String, dynamic>> criarServico({
    required String usuarioId,
    required String nome,
    required double preco,
  }) async {
    final response = await _client
        .from('servicos')
        .insert({'usuario_id': usuarioId, 'nome': nome, 'preco': preco})
        .select()
        .single();

    return Map<String, dynamic>.from(response);
  }

  Future<Map<String, dynamic>> atualizarServico({
    required String id,
    required String nome,
    required double preco,
  }) async {
    final response = await _client
        .from('servicos')
        .update({'nome': nome, 'preco': preco})
        .eq('id', id)
        .select()
        .single();

    return Map<String, dynamic>.from(response);
  }

  Future<void> deletarServico(String id) async {
    await _client.from('servicos').delete().eq('id', id);
  }
}
